# UTF16-BYTE-STORAGE-MILESTONE-1.md

UTF-16LE conversion through the byte storage, and Windows native paths held
as UTF-16LE bytes. A performance and correctness milestone on the design
WINDOWS-X86-64-MILESTONE-7.md settled -- textual paths are refinements of
`str`, native paths keep the operating system's own representation -- which
it optimizes and does not change.

> UTF-16 encoding and decoding are operations on Unicode values and
> contiguous byte storage. A native filename remains a sequence of code
> units, a Botlish String remains Unicode text, and the conversion between
> them is explicit, strict when it is asked to be, and one runtime operation.

Evidence is marked by kind:

* **code inspection**: what the code does, read;
* **local experiment**: run on purpose in this repository's Linux x86-64
  development container (4 cores; ext4). The Windows path module's own code
  runs here natively as a *local experiment*: a program that imports
  std::windows and calls no C (its NIR holds no `foreign` declaration) is
  compiled for windows-x86_64 and its NIR run by the Linux driver with the
  host's target line -- the same Botlish code and the same Cranelift
  lowering, under the Linux calling convention (`bench/utf16-bytes.tcl`,
  `tests/filesystem.test`'s `fs-windows-native-runtime`,
  `audit/filesystem/tools/fuzz.tcl`'s windows part);
* **compile only**: compiled for a target this host cannot run;
* **real platform**: observed on a GitHub Actions runner -- `windows-2025`
  (NTFS), `macos-15` (APFS, arm64), `ubuntu-latest` (x86-64) and
  `ubuntu-24.04-arm` -- run named.

The work was developed on Linux, on the branch `ccr-3b394343-oobbuq`.

## Contents

1. Result
2. Starting implementation
3. Encoding contract
4. Decoding contract
5. Backend implementation
6. Windows path integration
7. Representation choices
8. Win32 call buffers
9. Correctness tests
10. Fuzzing and mutants
11. Performance
12. Regression coverage
13. Remaining limitations
14. Files changed and commands to rerun
15. Listing without a List (an addendum)

## 1. Result

Two platform-independent operations of `std::abi::bytes`, on every backend
(interp, compile, cranelift-generic, cranelift, and linked executables):

```botlish
std::abi::bytes::encode_utf16le(text: str) -> std::abi::bytes::Bytes
std::abi::bytes::decode_utf16le(data: std::abi::bytes::Bytes) -> str errors InvalidUtf16
```

`encode_utf16le` is total: each Unicode scalar value as its UTF-16 code
unit (or surrogate pair), each unit as two bytes, low byte first, in one
contiguous Bytes -- no byte-order mark, no terminator, no normalization.
`decode_utf16le` is its strict inverse: an odd byte count or an unpaired
surrogate is the new declared builtin error `InvalidUtf16` (builtin error
13), an ordinary handleable error. Both are the same machinery as
`decode_utf8` (WINDOWS-X86-64-MILESTONE-7.md): typed wrappers over
`std::byte_store` natives -- natively one runtime call and one allocation,
with no List of code units, scalars or bytes in between.

`std::windows::fs` now holds a NativePath as its units' UTF-16LE bytes, so
the conversions milestone 7 measured as Botlish list passes are one runtime
operation each: text to native path is `encode_utf16le`, native path to
text `decode_utf16le` (InvalidUtf16 becomes `std::io::path::NotText`), a
Win32 call's LPCWSTR is the bytes and one NUL unit joined for that call.
The path syntax (`kind`, `join`, `concat`) is unchanged and still the one
statement of Win32's syntax, reading the units through an internal bridge.
Everything milestone 7 established holds -- lossless native names (unpaired
surrogates included), NotText for a name without text, a lossy `display`
that is never a path, `C:` + `file` = `C:file` -- and is tested again.

What improved (section 11 has the tables): on the windows-2025 runner (run 41266378398,
the JIT, per operation): native path to text 2.7-6.8 us to 0.09-0.12 us for
8 to 40 ASCII characters (31 to 59 times), 780 us to 32 us at 4,096 mixed
ones; validate + native 2.8-3.5 us to 0.62-0.77 us, and 20 ms to 74 us at
4,096 mixed characters (the quadratic walks are gone); concat 12-20 us to
5.0-5.6 us; join 4.2-5.7 us to 4.1 us; a Win32 call's LPCWSTR 1.8-4.8 us
to 0.87-0.91 us (375 us to 3.2 us at 4,096 units). Through real Win32 calls
on NTFS (bench/filesystem.tcl, the same job): text 11.9 to 0.23 us,
validate + native 3.6 to 0.94 us, concat 22.1 to 6.6 us, open + close 24.5
to 16.2 us, listing and reopening each of 100 files 64 to 54 us per file.
What got slower, measured and kept (sections 7 and 13): `kind` (0.01-0.08
to 0.17-0.32 us) and `units` (a field read to a bridge) because both now
read units out of bytes, `display` of a name without text (a failed strict
decode first), and listing a directory (7 to 9% per name: each listed name
is also sliced into its bytes; repaired after the milestone, section 15).
Linux and macOS file operations are the same code as before (identical
NIR) and measured the same within runner noise.

## 2. Starting implementation

By code inspection of stdlib/windows/fs.bot and stdlib/windows/path.bot at
the commit before this milestone (`f9e0ed0`):

* a NativePath was `units: List[int]`;
* `utf16(text)` (text to units, behind `from_text`, `of_valid_text` and so
  `WindowsPath.native`) walked the String with `std::str::char_at` and
  pushed one or two Ints per scalar onto a MutableVector, then copied the
  vector into a List. `char_at` locates a non-ASCII String's character by
  decoding from its start (native/src/runtime/ops.rs's `char_at_index`), so
  for non-ASCII text the walk was quadratic;
* `text(path)` ran `scalars` (three `unit_at` calls -- a List read with a
  handler -- per unit, to pair surrogates), scanned the scalars for an
  unpaired one, then `utf8_of` pushed each scalar's UTF-8 bytes onto a
  MutableVector, copied it into a List, made a Bytes of it and decoded it
  (`decoded`): five passes and four collections per conversion; `display`
  the same without the scan;
* `wide(units)`, the LPCWSTR of every Win32 call, built a List of 2n + 2
  bytes one `unit_at` and one `mod`/`shift_right` at a time, then made a
  Bytes of it;
* `joined(a, b)` concatenated two unit Lists one `unit_at` per unit, after
  `append` copied the base for its separator;
* `WindowsPath.validate`'s `nul_free?` walked the String with `char_at` --
  quadratic for non-ASCII text, like `utf16` -- and `WindowsPath.concat`
  paid text to units twice, the join, units to text, and `nul_free?` of the
  result.

Measured (local experiment, section 11): `concat` 10.3 to 17.2 us for 8-
to 40-character paths, 17.9 ms for a 4096-character mixed one; `validate +
native` 2.8 us at 40 ASCII characters and 18.4 ms at 4096 mixed ones.
Milestone 7's real Windows figures (3.56 us for validate + native, 22.3 us
for concat, 11.7 us for text) are the same order as this container's for
the same code (2.8, 17.2 and 6.0 us): the cost was the Botlish code, not
Windows.

## 3. Encoding contract

`std::abi::bytes::encode_utf16le(text: str) -> Bytes`, total:

1. each Unicode scalar value of TEXT, in order, is one UTF-16 code unit if
   it is at most U+FFFF, else its surrogate pair -- high unit
   `D800 + ((c - 0x10000) >> 10)` first, low unit `DC00 + ((c - 0x10000) &
   0x3FF)` second;
2. each unit is stored as two bytes, the low byte first, on every host (the
   byte order is part of the value's meaning: never the runtime's
   native-endian `u16` layout);
3. the result holds exactly two bytes per code unit;
4. no NUL terminator and no byte-order mark are added; U+0000 is the bytes
   00 00 and U+FEFF the bytes FF FE, ordinary characters;
5. nothing is normalized (`e` + U+0301 stays two units).

So `decode_utf16le(encode_utf16le(s)) == s` for every String `s`
(`u16-roundtrip`, the fuzzer's strings part). A Botlish String's characters
are scalar values, never a lone surrogate, so there is nothing to refuse.

## 4. Decoding contract

`std::abi::bytes::decode_utf16le(data: Bytes) -> str errors InvalidUtf16`
accepts exactly the UTF-16LE encodings of Strings:

* the byte count must be even;
* reading each byte pair low byte first, every high surrogate (D800..DBFF)
  must be followed at once by a low surrogate (DC00..DFFF), and every low
  surrogate must be the second unit of such a pair.

Everything else -- one byte, an odd count of otherwise valid units, a lone
high surrogate at the start, the end or alone, a lone low surrogate, a
reversed pair, two highs, two lows, a high before an ordinary unit, U+FFFD
followed by a lone surrogate -- is `InvalidUtf16`, never a replacement
character, never a panic. Accepted are the empty input, ASCII, multibyte
BMP characters, surrogate pairs, U+0000, U+FFFD, U+FEFF (at the start or in
the middle: data, never a byte-order mark -- no order is detected, so the
big-endian bytes of "AB" decode as U+4100 U+4200) and noncharacters
(U+FFFE, U+FFFF, U+1FFFE).

`InvalidUtf16` is a new builtin error declared by the normal machinery
(`core::native::declareError` in core/utf16text.tcl, loaded after
core/utf8text.tcl, so every earlier id keeps its number and
`native/src/runtime/error.rs`'s `ERR_INVALID_UTF16` is `BUILTIN_ERROR_ID_BASE
+ 13`). It is not `InvalidUtf8` (a different encoding) and not
`std::io::path::NotText` (the path abstraction's): the Windows path layer
translates one into the other. A call that neither handles nor declares it
is UNHANDLED-ERROR at compile time like any declared error
(`u16-error-handleable`).

## 5. Backend implementation

Code inspection; every claim is pinned by a test of section 9.

**Registration** (core/utf16text.tcl). Three `std::byte_store` natives:

| native | params | result | errors | notes |
|---|---|---|---|---|
| `encode_utf16le` | str | byte storage | -- | context-free, `bytestore-alloc` |
| `decode_utf16le` | byte storage | str | InvalidUtf16 | context-free, `string-alloc` |
| `utf16le_units` | byte storage | `List[int]` | -- | internal to the standard library |

and their typed wrappers in stdlib/abi/bytes.bot (`encode_utf16le`,
`decode_utf16le`, and the `nomethod`, internal `utf16le_units`), which own
the Bytes representation as `decode_utf8` does.

**Tcl backends** (interp and compile share the native's implementation):
Tcl 9.0.1's own `encoding convertto/convertfrom -profile strict utf-16le`,
which is exactly the contract -- checked byte for byte by the test vectors,
including a BOM kept as data, odd lengths and every lone-surrogate shape
refused (a local probe before choosing it).

**Native backends** (native/src/runtime/ops.rs; NIR ops `strencodeutf16le`,
`bytesdecodeutf16le`, `bytesutf16leunits`; native/lower.tcl's op table;
codegen::clif calls each through `call_allocating`, so its operand is a
root across the allocation, and routes a failure through `check` like a
`fail`):

* `rt_str_encode_utf16le` counts the units from the String's metadata (its
  character count, plus one per four-byte UTF-8 sequence), computes the
  length with `utf16le_encoded_len` -- `checked_mul(2)` held to the
  collection-length ceiling, RANGE before any allocation -- allocates one
  storage and writes the units straight into it through a 128-byte stack
  buffer (`to_le_bytes`; an ASCII String's bytes widened directly);
* `rt_bytes_decode_utf16le` makes two passes over the payload and no other
  allocation: `utf16le_measure` validates and counts (the UTF-8 length and
  the character count, unit by unit: the rule of section 4), then one
  String of exactly that size is filled -- for all-ASCII units with their
  low bytes, otherwise with `char::decode_utf16`'s scalars encoded through
  a 256-byte stack buffer. Byte pairs are read with `chunks_exact(2)` and
  `u16::from_le_bytes`: the payload is never reinterpreted as a `[u16]`
  (it need not be aligned, and the host may be big-endian);
* `rt_bytes_utf16le_units` reads the pairs into one List of small Ints.

No `unsafe` was added: the storage and String writers (`BytesInit`,
`StrInit`) bounds-check every write and assert that every byte was
written. Collection-length ceilings, GC rooting (operands of the allocating
instruction stay live; the collector never moves an object) and byte
storage's value semantics (a new storage per result) are the existing
machinery's. The conversion mints no authority and needs no context: it is
not a direct module's, and it compiles for linux-x86_64, windows-x86_64 and
macos-aarch64 and runs on the Tcl backends whatever the host
(`u16-platform-free`).

## 6. Windows path integration

stdlib/windows/fs.bot (the module comment states the representation):

| operation | before | now |
|---|---|---|
| NativePath | `units: List[int]` | `data: Bytes`, the units' UTF-16LE bytes |
| `of_valid_text` (WindowsPath.native) | `utf16(text)` | `encode_utf16le(text)` |
| `from_text` | `from_units(utf16(text))` | `encode_utf16le`, its units checked non-empty and NUL-free |
| `from_units` | the List | its UTF-16LE bytes (`data_of_units`) |
| `units` | the field | `utf16le_units(data)` |
| `text` | scalars, scan, UTF-8 List, decode | `decode_utf16le(data)`, InvalidUtf16 -> NotText |
| `display` | the lossy decoding always | `text`, and the lossy decoding only for a name without text |
| `kind`, `join`, `concat` | syntax on the units; the List joined unit by unit | the same syntax on the units it reads -- every unit of a path of up to 64 units, the first four and the last of a longer one (below) -- and the bytes joined (`std::abi::bytes::join`) |
| Win32 LPCWSTR (`wide`) | 2n + 2 bytes built one by one | `join([data, NUL unit])` |
| `entries` | a listed name's units copied from the record | the record's own bytes of the name (`slice`) |

stdlib/windows/path.bot: `native`, `kind` and `concat` are unchanged (they
call std::windows::fs); `nul_free?` checks the UTF-8 bytes
(`encode_utf8`) instead of `char_at` per character, the same proposition in
one pass (U+0000 is the one character whose UTF-8 holds a 0 byte).

The public semantics are milestone 7's, exactly: every code unit is kept
(an unpaired surrogate is a valid unit), U+0000 and the empty path are
invalid, `units` reports the units a path was made of, `text` succeeds only
for well-formed UTF-16 (NotText otherwise, never U+FFFD), `display` may
replace a lone surrogate by U+FFFD without changing the path, `kind`,
`join`, path equality (now the equality of the bytes: the same units) and
every file operation use the exact units. Path syntax is untouched: the
functions `separator?`, `kind_of`, `segments`, `rewritten?`,
`holds_slash?`, `verbatim_name?`, `win32_name?`, `joinable?` and
`ends_separated?` are byte-for-byte milestone 7's, and only the bytes of a
joined path are made differently (`joined_data`: the same decision, one
`\` unit or none, then a join of storages). No second parser over Strings
exists.

What the syntax is given: `kind_of` reads a path's units 0..3 and whether
it has exactly three, `ends_separated?` its last unit, and `joinable?` the
component's units. For a path of up to 128 bytes (64 units) `head_units`
bridges every unit -- one List, read for the kind and the end alike, which
is milestone 7's own formulation -- and for a longer one it bridges the
first 8 bytes (four units, so "exactly three" is still decided) and
`end_units` the last two: what a long path costs to classify or join no
longer grows with it. The two give the syntax the same answers by
construction (the units it reads are the same units); tests/filesystem.test's
`fs-windows-long-syntax` pins kinds and joins of paths past 64 units and at
the 64/65-unit boundary with explicit values, `fs-windows-native-runtime`
runs two long bases on the native backends, the filesystem fuzzer draws
long segments, and two mutants of the long branch are killed (section 10).
The threshold is a measured crossover (section 11), not a semantic
boundary.

## 7. Representation choices

The milestone allowed an internal representation change if bridging Bytes
and `List[int]` dominated. Measured (section 11) and decided:

* **Bytes as the representation.** Every conversion milestone 7 measured --
  text to native, native to text, the LPCWSTR of each call -- needs the
  bytes and no units. Holding units would put a bridge (bytes to units, or
  units to bytes) in every one of them and in every Win32 call; holding
  bytes puts it only where the units themselves are read.
* **One internal bridge, bytes to units** (`std::byte_store::utf16le_units`,
  `std::abi::bytes::utf16le_units`; both internal members of the standard
  library, never API). The syntax reads units, and `units(path)` returns a
  List by contract. The bridge is one runtime call and one List allocation
  (about 2 ns per unit; 0.1 us at 40 units, local experiment), not a
  Botlish operation per unit. It is read where the syntax needs it: `kind`
  and `join` (a short path's units, a long path's first four and last:
  section 6), the component of `join` and `concat`, `from_text` (the NUL
  check), `entries` (the pattern's base) and `units`.
* **Remaining List[int] work**: the path syntax's own lists (`segments`
  builds a List of Lists and `rewritten?` compares segments with `[46]` and
  `[46, 46]`), `from_units` (its input is a List: its bytes are built in
  Botlish, as `wide` was; it is not on any conversion path), `entries`'s
  scan of the 260-unit name field for its terminator (as before; the name
  itself is now the record's bytes), and `display` of a name without text
  (section 13). The syntax functions were deliberately left as they are --
  the milestone keeps them the source of truth -- and are now the largest
  part of a join (section 11 times them alone).
* **No lossy primitive.** `display` decodes strictly first, which is the
  answer for every name that has text; only a name holding an unpaired
  surrogate takes milestone 7's Botlish decoding (`lossy`, private, called
  by `display` alone). A public lossy decoder would be a second, weaker
  conversion for one rare case; it was not added.

## 8. Win32 call buffers

A wide (W) function takes an LPCWSTR: UTF-16 units ending with one NUL unit.
The codec adds no terminator; the call boundary adds it, exactly once:

```botlish
private fn wide_of(data: std::abi::bytes::Bytes) -> std::abi::bytes::Bytes:
    std::abi::bytes::join([data, nul_unit()])
```

`nul_unit()` (like `backslash_unit()` and `star_unit()`) is a constant
`from_list([std::byte::from_int(0), std::byte::from_int(0)])`, which native
lowering makes a static storage. Three things stay distinct:

* the units Windows returns (FindFirstFileW's `cFileName`, counted to its
  terminator; the NativePath is the record's bytes before it);
* the logical path (a NativePath: no terminator, `units` never ends in 0);
* the temporary LPCWSTR (`wide`/`wide_of`), built for one call and exposed
  to it read-only for the call's duration (C-POINTER-BORROWING.md's
  `read noescape` exposure, kept alive to the end of the call), then
  garbage.

The terminator follows the whole last unit, so a surrogate pair stays whole
before it: `wide("a" + U+1D11E)` is `61 00 34 D8 1E DD 00 00`
(`fs-windows-call-buffer`, on every host through a probe appended to a
private copy of the standard library -- `wide` stays private -- and
`fs-windows-astral-names` on NTFS). An unpaired surrogate is passed as
itself (`75 00 00 D8 00 00` for u + D800), never as U+FFFD.

## 9. Correctness tests

**tests/utf16-bytes.test** (14 tests; every program on all four backends,
which must agree): exact vectors written in the test (never computed by the
codec: inputs are built from their UTF-8 through `decode_utf8`, outputs are
compared with literal hex through the harness's internal reveal):

| input | expected UTF-16LE |
|---|---|
| "" | (none) |
| A | 41 00 |
| U+0000 | 00 00 |
| U+00E9 | E9 00 |
| U+20AC | AC 20 |
| U+1F600 | 3D D8 00 DE |
| U+FFFD | FD FF |
| U+FEFF | FF FE |

and U+10000, U+10FFFF, U+D7FF, U+E000, U+FFFF, U+FFFE, U+1FFFE, mixed
ASCII/BMP/supplementary combinations, a combining sequence, NUL inside text
(`u16-encode-vectors`); the native ASCII path's 64-unit chunks at 63, 64,
65, 128 and 129 characters (`u16-encode-ascii-chunks`); twelve accepted
inputs with their exact scalars and re-encoded bytes, BOMs at the start and
in the middle among them (`u16-decode-accepted`); sixteen malformed inputs
(`u16-decode-rejected`); no byte-order detection (`u16-no-order-detection`);
round trips up to 2,400-character mixed Strings (`u16-roundtrip`) and a
32,768-character one (`u16-large`); the error's handling and compile-time
checking (`u16-error-handleable`); the platform independence
(`u16-platform-free`); the registry, the public declarations and the
internal bridge (`u16-natives-registered`, `u16-public-surface`,
`u16-internal-bridge`); one NIR operation per conversion and no List op
(`u16-nir-one-operation`); and both native backends under
`BOTLISH_NATIVE_GC_STRESS=1` with Strings, Bytes and decoded Strings live
across every conversion (`u16-gc-stress`). Rust unit tests in ops.rs
(`utf16le_encodes_exact_bytes`, `utf16le_decodes_strictly`,
`utf16le_units_bridge_reads_low_byte_first`,
`utf16le_length_never_overflows_or_passes_the_ceiling`) pin the runtime
directly, the last the length computation at the ceiling and at word
overflow.

**tests/filesystem.test** keeps every milestone 7 test (61 now) and adds:

* `fs-windows-call-buffer` (every host, Tcl backends): the LPCWSTR of a
  supplementary-plane name, of names holding a lone high or low surrogate
  and of a joined path, and the stored path's bytes and units (no
  terminator);
* `fs-windows-native-runtime` (Linux, both native backends, normally and
  under GC stress): the native-path and join programs of
  `fs-windows-native-paths` and `fs-windows-join-one-rule` (twelve bases,
  thirteen parts, astral ones among them) on the native runtime, equal to
  interp;
* `fs-windows-astral-names` (Windows): a file and a directory with
  supplementary-plane names made from text, listed with exactly their units
  and text, and reached again through the listed names.

The milestone 7 tests that decide the semantics run unchanged:
`fs-windows-concat` (34 joins, `C:` + `a` = `C:a` first),
`fs-windows-kinds`, `fs-windows-native-paths` (NotText and U+FFFD display
for D800 and DC00, `units` of a joined path holding D800),
`fs-windows-join-one-rule` (110 pairs, text and native joins equal), and on
NTFS `fs-windows-native-roundtrip` (the name holding D800 opens its own
file, the file named with U+FFFD its own: the critical regression),
`fs-windows-verbatim`, `-long-path`, `-modes`, `-sharing`,
`-directory-failures` (native error codes), `-entries`, `-executable`,
`-portable`.

Registry pins updated for the three natives and the error:
tests/abi-bytes.test, tests/abi-mutable-bytes.test,
tests/stdlib-namespaces.test (`ns-error-signatures`: InvalidUtf16 the
fourteenth builtin error), tests/linux-syscall.test.

## 10. Fuzzing and mutants

**The oracle** (audit/abi-bytes/tools/utf16-oracle.py) is integer
arithmetic written from sections 3 and 4 -- neither Tcl's encoder nor
Rust's -- and its `selftest` checks it against Python's own utf-16-le codec
(a third implementation) on 20,000 random scalar sequences and 20,000
random byte buffers biased toward surrogates. The production encoder is
never the decoder's oracle.

**audit/abi-bytes/tools/utf16-fuzz.tcl**, two generators, every backend:
random Strings (ASCII -- a quarter of them all ASCII --, BMP, supplementary,
combining marks, U+0000, U+FFFD, U+FEFF, noncharacters, some of 100 to 600
characters), each encoding compared byte for byte with the oracle and
decoded back; and random byte buffers (odd lengths, surrogate-heavy units,
a third the units of ASCII text with one fault or none), acceptance, every
scalar and the re-encoding compared with the oracle. Runs: locally (Linux x86-64) seeds 4 and 5, 1,600 cases each (200 per
generator and backend), and seed 9 under `-gc-stress 1` (800 cases); on
real platforms
the tier item `utf16-fuzz` -- seeds 1 and 2, and 9 under GC stress, 1,600
cases each -- on Windows x86-64 (run 41254346872) and macOS AArch64 (run
41254348599). No disagreement in any run. The oracle's selftest passes.

**The filesystem fuzzer**'s windows part (random Win32 paths and random
unit sequences with lone surrogates, against its own model of the rules)
now also checks `units` of every native path and, on Linux, runs on both
native backends as well as the Tcl ones. Long segments (60 to 79 characters) put some paths past the 64 units of
section 6, so both branches of `head_units` are drawn. Runs: locally seeds
1, 2 and 3 on the final code (2,800 cases each: the windows, linux and files
parts, the windows part on interp, compile and both native backends), and
on `43c0795` the files part under GC stress (seed 9); on Windows the tier item `filesystem-fuzz`
(seeds 1 and 2, 1,600 cases each; run 41254346872, and run 41266378398 on
the final code: 1,600 cases each, no disagreement). No disagreement in any completed run.

**Mutants.** audit/abi-bytes/tools/utf16-mutate.tcl applies each of the 21
mutants of utf16-mutants.txt to a private tree (the native ones rebuild a
private copy of the runtime) and requires it killed by the detector its
`!!` line names -- the test of the contract it breaks -- not merely by
something. audit/filesystem/tools/mutants.txt gains seven mutants -- the
five of the milestone's list below, and two of the long-path branch of
section 6 (`win-long-end-from-head`: a long path's end read from its first
units; `win-long-head-truncated`: its kind from three units) -- and keeps
milestone 7's 26, six of them rewritten for the new code (the same rules:
`win-drive-relative-as-absolute`, `win-always-separator`,
`win-lossy-surrogate-text`, `win-enumeration-loses-native-name`,
`win-last-error-read-late`, `bytes-lossy-text`).

One finding about the harness itself: audit/filesystem/tools/mutate.tcl
counted a mutant whose mutated library did not compile as killed (the
fuzzer's first program failed, which it read as a disagreement). It now
reports DOES NOT COMPILE, a failure, and that exposed milestone 7's
`bytes-lossy-text`, which had never compiled -- its replacement called
`display`, which std::io::bytepath defines after `text`, the function it
mutates, so method syntax cannot reach it there -- and so had never tested
its rule. Rewritten to mutate
what it describes (a strict decoding replaced by a lossy one), it is killed
by the fuzzer.

Runs: the codec's 21 mutants, each killed by its named detector, locally
(Linux x86-64, audit/abi-bytes/utf16-mutate-result.txt) and on macOS
AArch64 (run 41254348599). The filesystem's 33 on the final code: on Linux
x86-64 every one that runs there killed and none surviving
(audit/filesystem/results/mutate-linux.txt: 30 killed, the two Windows
mutants and the macOS one skipped), and on Windows (run 41266378398) every
mutant of Windows code killed on NTFS, the two only Windows runs among them
(section 12). That Windows run also showed milestone 7's nine `linux-*`
mutants without a host line -- applied on Windows, they had nothing to kill
them -- and they now carry `%% linux-x86_64 linux-aarch64`.

The milestone's list, and the mutant that breaks each:

| # | contract broken | mutant(s) | killed by |
|---|---|---|---|
| 1 | byte order | `tcl-byte-order-swapped`, `rust-byte-order-swapped`, `rust-ascii-byte-order-swapped`, `rust-decode-byte-order-swapped`, `rust-units-bridge-byte-order-swapped` | `u16-encode-vectors`, `u16-decode-accepted`, `u16-no-order-detection`, the Rust vectors, the fuzzer; the bridge's by `utf16le_units_bridge_reads_low_byte_first` |
| 2 | the high byte of a unit | `rust-high-byte-omitted` | `u16-encode-vectors`, Rust, fuzzer |
| 3 | a supplementary scalar as two unrelated values | `rust-supplementary-as-two-values` | `u16-encode-vectors`, Rust, fuzzer |
| 4 | the surrogate pair's arithmetic | `rust-surrogate-pair-miscalculated` | `u16-encode-vectors`, Rust, fuzzer |
| 5 | an isolated high surrogate accepted | `rust-accepts-lone-high` | `u16-decode-rejected`, Rust, fuzzer |
| 6 | an isolated low surrogate accepted | `rust-accepts-lone-low` | `u16-decode-rejected`, Rust, fuzzer |
| 7 | an odd byte count accepted | `tcl-accepts-odd-count`, `rust-accepts-odd-count` | `u16-decode-rejected`, Rust, fuzzer |
| 8 | malformed input replaced, not refused | `tcl-replaces-malformed`, `rust-replaces-malformed`; a panic instead of the error: `rust-decode-error-panics` | `u16-decode-rejected`, `u16-error-handleable`, Rust, fuzzer |
| 9 | U+FEFF taken as a BOM | `tcl-bom-removed`, `rust-bom-removed` | `u16-decode-accepted`, Rust |
| 10 | a NUL appended to the encoding | `tcl-encode-appends-nul`, `rust-encode-appends-nul` | `u16-encode-vectors`, Rust, fuzzer |
| 11 | the Win32 terminator omitted | `win-call-buffer-unterminated` (filesystem) | `fs-windows-call-buffer` |
| 12 | the terminator in a native path | `win-terminator-in-native-path` (filesystem) | `fs-windows-native-paths`, the filesystem fuzzer |
| 13 | path text normalized | `win-text-normalized` (filesystem) | `fs-windows-concat`, the filesystem fuzzer |
| 14 | malformed native UTF-16 given text | `win-lossy-surrogate-text` (filesystem, rewritten), `win-units-reencoded` | `fs-windows-native-paths`, the filesystem fuzzer |
| 15 | a surrogate replaced on open | `win-open-through-lossy-text` (filesystem) | `fs-windows-call-buffer`; on NTFS `fs-windows-native-roundtrip` |
| 16 | an oversized length | `rust-oversized-length-unchecked` | `utf16le_length_never_overflows_or_passes_the_ceiling` |
| 17 | GC roots lost | `rust-gc-roots-lost` | `u16-gc-stress` |
| -- | a long path's end read from its head | `win-long-end-from-head` (filesystem) | `fs-windows-long-syntax` |
| -- | a long path's kind read from three units | `win-long-head-truncated` (filesystem) | the filesystem fuzzer's long segments; `fs-windows-long-syntax` |

## 11. Performance

### 11.1 Method

`bench/utf16-bytes.tcl` times one operation per row: a program that runs
it in a loop, best of 5 runs inside one process (no compilation, link or
process start in a row), per iteration, minus the same program -- its setup
included -- with an empty loop. Inputs are texts of 8, 40, 256 and 4096
characters, `ascii` (one unit per character) or `mixed` (a, é, 中, 😀, b,
ü, x, 𝄞 repeated: a quarter astral, so 5/4 units per character); a path is
`C:\` and 7-character components. Its groups separate the costs the
milestone asked to separate:

* **codec**: `encode_utf16le` and `decode_utf16le` alone, and `decode_utf8`
  of the same text as a reference (an existing operation this milestone
  did not change);
* **Windows path operations**, which call no Windows: `validate + native`,
  `from_text`, `text`, `display` (of a valid name, and of a name holding an
  unpaired surrogate: the lossy path), `units`, `kind`, `concat` (a path
  joined with `component.txt` as text) and `join` (the same, native);
* **syntax alone**: `kind_of` and `joinable?` -- std::windows::fs's private
  functions, copied verbatim from the measured tree into the program -- on
  units computed before the loop;
* **the Win32 call buffer**: milestone 7's formulation (a List of units,
  one byte at a time, then `from_list`) and this milestone's (`join` of the
  bytes and the NUL unit), both run in the *new* tree, so the row pair
  measures the formulation and nothing else.

What the operating system costs is `bench/filesystem.tcl`'s: the same path
operations plus real file operations (open, read, write, list) in a fresh
directory. Both scripts take `-baseline-rev REV`, which measures REV in a
temporary worktree and then the current tree on the same machine, in the
same job, and prints both and their ratio. On Windows the programs are
compiled for windows-x86_64 and run by the driver (Cranelift, the JIT); on
Linux the Windows group is the local experiment described at the top.
`-measure alloc` counts heap allocations and allocated bytes per operation
instead (the driver's `--alloc summary`; counts are the code's, not the
machine's). A difference below a few nanoseconds is the timer's
resolution: two loops subtracted (shown "~0").

Every figure below compares `f9e0ed0` (before) with `36f8dd7` (after: the
code this report describes) unless it names another revision.

### 11.2 Windows, real platform

`windows-2025` runner, run 41266378398 (job "full (Windows x86-64, shard
1/4)", tier item `utf16-bench`, the final code), per operation:

ascii:

| operation | 8 before | 8 after | 40 before | 40 after | 256 before | 256 after | 4096 before | 4096 after |
|---|---:|---:|---:|---:|---:|---:|---:|---:|
| encode_utf16le | n/a | 207 ns | n/a | 189 ns | n/a | 334 ns | n/a | 2.21 us |
| decode_utf16le | n/a | 84 ns | n/a | 122 ns | n/a | 444 ns | n/a | 5.54 us |
| decode_utf8 (reference) | 74 ns | 86 ns | 82 ns | 82 ns | 207 ns | 174 ns | 1.32 us | 1.32 us |
| validate + native | 2.84 us | 617 ns | 3.51 us | 767 ns | 14.1 us | 2.19 us | 216.6 us | 26.2 us |
| from_text | 2.20 us | 580 ns | 3.49 us | 849 ns | 14.3 us | 2.61 us | 222.7 us | 34.0 us |
| text | 2.66 us | 85 ns | 6.83 us | 116 ns | 28.2 us | 454 ns | 438.8 us | 5.64 us |
| display | 2.50 us | 86 ns | 6.57 us | 130 ns | 26.4 us | 442 ns | 425.0 us | 5.42 us |
| display (lossy: + D800) | 2.96 us | 3.41 us | 7.27 us | 7.38 us | 26.4 us | 27.4 us | 416.1 us | 455.7 us |
| units | ~0 | 142 ns | ~0 | 278 ns | ~0 | 919 ns | ~0 | 16.6 us |
| kind | 29 ns | 174 ns | 12 ns | 302 ns | 76 ns | 301 ns | ~0 | 47 ns |
| concat (text) | 12.3 us | 5.04 us | 19.6 us | 5.59 us | 59.5 us | 8.05 us | 838.5 us | 35.1 us |
| join (native) | 4.19 us | 4.06 us | 5.71 us | 4.13 us | 13.1 us | 4.67 us | 178.6 us | 6.04 us |
| syntax: kind_of (path units) | 19 ns | 19 ns | 26 ns | 18 ns | 16 ns | 16 ns | 52 ns | 57 ns |
| syntax: joinable? (component) | 2.33 us | 2.30 us | 2.36 us | 2.26 us | 1.96 us | 1.90 us | 1.64 us | 1.64 us |
| Win32 buffer from List[int] (M7) | 1.79 us | 1.81 us | 4.75 us | 4.71 us | 22.8 us | 22.5 us | 384.8 us | 375.0 us |
| Win32 buffer from Bytes (this) | n/a | 870 ns | n/a | 908 ns | n/a | 1.08 us | n/a | 3.18 us |

mixed:

| operation | 8 before | 8 after | 40 before | 40 after | 256 before | 256 after | 4096 before | 4096 after |
|---|---:|---:|---:|---:|---:|---:|---:|---:|
| encode_utf16le | n/a | 241 ns | n/a | 382 ns | n/a | 1.21 us | n/a | 16.2 us |
| decode_utf16le | n/a | 136 ns | n/a | 399 ns | n/a | 2.05 us | n/a | 32.2 us |
| decode_utf8 (reference) | 97 ns | 92 ns | 172 ns | 170 ns | 648 ns | 644 ns | 9.22 us | 9.48 us |
| validate + native | 1.84 us | 664 ns | 6.02 us | 1.29 us | 96.4 us | 4.72 us | 20.0 ms | 74.0 us |
| from_text | 1.82 us | 610 ns | 5.12 us | 1.12 us | 58.2 us | 4.05 us | 10.1 ms | 55.6 us |
| text | 3.69 us | 142 ns | 10.0 us | 411 ns | 43.6 us | 2.06 us | 779.5 us | 32.5 us |
| display | 3.59 us | 146 ns | 9.67 us | 436 ns | 42.0 us | 2.04 us | 756.7 us | 32.1 us |
| display (lossy: + D800) | 3.85 us | 4.34 us | 9.97 us | 10.6 us | 41.8 us | 49.5 us | 763.1 us | 803.8 us |
| units | ~0 | 156 ns | 5 ns | 296 ns | ~0 | 1.13 us | ~0 | 20.5 us |
| kind | 80 ns | 176 ns | 26 ns | 320 ns | 24 ns | 293 ns | ~0 | 38 ns |
| concat (text) | 13.4 us | 5.25 us | 25.0 us | 6.36 us | 144.2 us | 11.7 us | 16.5 ms | 101.9 us |
| join (native) | 4.30 us | 4.01 us | 5.90 us | 4.25 us | 15.0 us | 4.57 us | 202.5 us | 7.19 us |
| syntax: kind_of (path units) | 18 ns | 15 ns | 19 ns | 16 ns | 31 ns | 19 ns | 63 ns | 60 ns |
| syntax: joinable? (component) | 2.31 us | 2.30 us | 2.66 us | 2.43 us | 1.96 us | 1.95 us | 1.68 us | 1.64 us |
| Win32 buffer from List[int] (M7) | 1.97 us | 1.96 us | 5.67 us | 5.41 us | 27.6 us | 27.5 us | 458.6 us | 479.2 us |
| Win32 buffer from Bytes (this) | n/a | 869 ns | n/a | 888 ns | n/a | 1.12 us | n/a | 3.18 us |

Where the time goes now (the same run):

* **codec**: encoding 0.19 to 0.38 us for 8 to 40 characters, 2.2 us for
  4,096 ASCII ones and 16.2 us for 4,096 mixed ones (5,120 units);
  decoding 0.08 to 0.40 us short, 5.5 and 32.2 us at 4,096 characters.
  Mixed text decodes at about 6 ns per unit (section 13), ASCII at about
  1.4.
* **the bridge** (the `units` row: one List of the units): 0.14 us at 8
  units, 0.92 us at 256, 16.6 us at 4,096 -- about 4 ns per unit, one
  boxed Int each.
* **the syntax**: `kind_of` 0.02 to 0.06 us; `joinable?` of a 13-character
  component 1.6 to 2.4 us whatever the path's length -- about half of a
  join, and the largest single cost left in one.
* **the Win32 buffer**: 0.87 us at 8 characters to 3.2 us at 4,096, where
  milestone 7's formulation took 1.8 us to 479 us (the same tree, row for
  row).
* **the operating system**: next section.

`join` is faster than before at every length (4.19 to 4.06 us at 8 ASCII
characters, 179 us to 6.0 us at 4,096) and `concat` 2.4 to 160 times. The
slices-only version (`43c0795`, run 41254346872) had made a join of 8
characters slower, 4.96 us, and `kind` 0.3 to 0.4 us; reading a short path
whole fixed both (section 6; section 11.5 has every version locally).

What became slower, and why it was kept:

* **`kind`**, 0.01-0.08 us to 0.17-0.32 us (the 4,096-character rows,
  0.04 and 0.05 us, are within the timer's spread there, where the empty
  loop's setup is largest). A NativePath no longer holds
  its units, so `kind` bridges a short path's units (one List) or slices a
  long path's head (three small allocations) and runs `kind_of`. On this
  runner a bridge of 40 units costs about what the slice does, so the two
  sides of the threshold measure alike here.
* **`units`**, from a field read to a bridge (0.14 us at 8 units, 4 ns per
  unit). `units` returns a List by milestone 7's contract; a caller that
  wants the units pays for building them.
* **`display` of a name without text**, 1 to 18% slower: the strict decode
  fails first, then milestone 7's lossy decoding runs (section 13).
* **`entries`**, 7 to 9% per listed name (next section).

### 11.3 Through Win32, real platform

`bench/filesystem.tcl` in the same job, NTFS, the benchmark directory's
path (66 characters on the runner), per operation:

| row | before | after | after/before |
|---|---:|---:|---:|
| validate + native | 3.56 us | 0.94 us | 0.26 |
| concat (text) | 22.1 us | 6.62 us | 0.30 |
| join (native) | 6.78 us | 4.64 us | 0.68 |
| text (native) | 11.9 us | 0.23 us | 0.019 |
| display (native) | 11.1 us | 0.23 us | 0.021 |
| validate + native, 256 mixed characters | 99.7 us | 5.56 us | 0.056 |
| text, 256 mixed characters | 49.3 us | 2.57 us | 0.052 |
| concat, 256 mixed characters | 200.7 us | 14.8 us | 0.074 |
| encode_utf16le, 40 characters | -- | 0.23 us | -- |
| decode_utf16le, 40 characters | -- | 0.16 us | -- |
| open + close | 24.5 us | 16.2 us | 0.66 |
| write_file 64 B | 189.5 us | 180.6 us | 0.95 |
| read_file 64 B | 51.7 us | 44.0 us | 0.85 |
| portable write 64 B | 198.5 us | 188.9 us | 0.95 |
| write_file 1 MiB | 430 us | 432 us | 1.01 |
| read_file 1 MiB | 2.36 ms | 2.30 ms | 0.97 |
| entries (100), per entry | 7.55 us | 8.20 us | 1.09 |
| reopen (100), per file | 64.2 us | 54.1 us | 0.84 |

Every file operation builds its path's LPCWSTR, which is where the small
operations gain: at 66 characters milestone 7's buffer took about 7 us
(table above), this milestone's about 0.95 us. The large transfers are the
operating system's (0.97, 1.01). `entries` is slower in this run and in
run 41254346872 (1.07): each listed name is now also sliced out of the
find record as its bytes, on top of milestone 7's scan of the record's
260-unit name field for its terminator, which still reads the field as a
List and builds the name's units (section 13). Listing and then opening
every entry (`reopen`) is 16% faster.

### 11.4 Allocations

Counted by the driver (`bench/utf16-bytes.tcl -measure alloc`, local
experiment: the Windows module's code on the Linux driver; the counts
depend on the code, not the machine), allocations / bytes per operation:

| operation | 8 ASCII before | 8 ASCII after | 40 mixed before | 40 mixed after | 256 mixed before | 256 mixed after |
|---|---:|---:|---:|---:|---:|---:|
| encode_utf16le | -- | 2 / 72 B | -- | 2 / 156 B | -- | 2 / 696 B |
| decode_utf16le | -- | 1 / 33 B | -- | 1 / 115 B | -- | 1 / 601 B |
| validate + native | 23 / 880 B | 5 / 233 B | 7 / 1024 B | 4 / 940 B | 7 / 5344 B | 4 / 5368 B |
| from_text | 15 / 616 B | 4 / 200 B | 7 / 1024 B | 4 / 620 B | 7 / 5344 B | 4 / 3320 B |
| text | 12 / 577 B | 1 / 33 B | 12 / 2309 B | 1 / 115 B | 12 / 12785 B | 1 / 601 B |
| display | 11 / 553 B | 1 / 33 B | 11 / 2285 B | 1 / 115 B | 11 / 12761 B | 1 / 601 B |
| display (lossy: + D800) | 11 / 615 B | 12 / 711 B | 11 / 2347 B | 12 / 2779 B | 11 / 12823 B | 12 / 15415 B |
| units | 0 / 0 B | 1 / 88 B | 0 / 0 B | 1 / 424 B | 0 / 0 B | 1 / 2584 B |
| kind | 0 / 0 B | 1 / 88 B | 0 / 0 B | 1 / 384 B | 0 / 0 B | 3 / 120 B |
| concat (text) | 40 / 2610 B | 27 / 1525 B | 40 / 5241 B | 27 / 2563 B | 40 / 22035 B | 32 / 7006 B |
| join (native) | 17 / 1008 B | 22 / 1164 B | 17 / 1600 B | 22 / 1534 B | 17 / 5488 B | 27 / 1846 B |
| Win32 buffer from List[int] (M7) | 5 / 338 B | 5 / 338 B | 5 / 1094 B | 5 / 1094 B | 5 / 5954 B | 5 / 5954 B |
| Win32 buffer from Bytes (this) | -- | 7 / 290 B | -- | 7 / 374 B | -- | 7 / 914 B |

Text to native path and back are one allocation each now (the decoded
String; the encoded storage and its Bytes). The Win32 buffer is seven
small allocations whatever the length -- the NUL's Bytes wrapper (its
storage is a static constant), the two-element List, `join`'s List of
storages, the result's storage and Bytes -- against milestone 7's five
whose bytes grow with the path. `kind` is one List for a short path (its
units) and three small allocations for a long one (the head's slice and
List). `join` makes more and smaller allocations than milestone 7's (the
base's units, the component's, the joined storage), fewer bytes from 40
characters on; the slices-only version made 30 at every length, this one
22 for a short base. `concat`'s remaining 27 are mostly `joinable?`'s
segment Lists.

### 11.5 Local experiment: the versions of `kind` and `join`

The Windows module's code on this container's Linux driver (section's top:
local experiment), ASCII text, every version this branch had: before the
milestone; the first (every unit bridged for the syntax); slices only (a
path's first four units and its last read from slices); final (a path of
up to 64 units bridged whole, slices beyond). Rows of a few hundred
nanoseconds vary between runs of identical code by up to 2x here --
`display` and the Bytes buffer did not change between the last three
versions -- so read the trends, not single cells:

| operation | chars | before (`f9e0ed0`) | first (`7315303`) | slices (`43c0795`) | final (`36f8dd7`) |
|---|---:|---:|---:|---:|---:|
| validate + native | 8 | 1.97 us | 661 ns | 653 ns | 400 ns |
| validate + native | 40 | 3.00 us | 480 ns | 437 ns | 467 ns |
| validate + native | 256 | 18.4 us | 1.16 us | 2.07 us | 1.89 us |
| validate + native | 4096 | 191.6 us | 36.0 us | 36.7 us | 23.4 us |
| from_text | 8 | 1.49 us | 382 ns | 370 ns | 362 ns |
| from_text | 40 | 3.10 us | 531 ns | 523 ns | 529 ns |
| from_text | 256 | 19.6 us | 1.63 us | 1.68 us | 1.64 us |
| from_text | 4096 | 262.8 us | 21.4 us | 21.3 us | 22.9 us |
| text | 8 | 1.89 us | 54 ns | 50 ns | 52 ns |
| text | 40 | 5.94 us | 70 ns | 70 ns | 65 ns |
| text | 256 | 28.6 us | 259 ns | 256 ns | 506 ns |
| text | 4096 | 397.0 us | 4.16 us | 7.69 us | 3.91 us |
| display | 8 | 1.94 us | 52 ns | 42 ns | 119 ns |
| display | 40 | 5.71 us | 71 ns | 148 ns | 71 ns |
| display | 256 | 27.1 us | 255 ns | 507 ns | 267 ns |
| display | 4096 | 383.1 us | 3.61 us | 3.71 us | 3.69 us |
| units | 8 | ~0 | 100 ns | 148 ns | 119 ns |
| units | 40 | ~0 | 110 ns | 112 ns | 112 ns |
| units | 256 | ~0 | 374 ns | 358 ns | 354 ns |
| units | 4096 | ~0 | 4.39 us | 7.33 us | 4.54 us |
| kind | 8 | 17 ns | 107 ns | 309 ns | 146 ns |
| kind | 40 | 18 ns | 119 ns | 207 ns | 119 ns |
| kind | 256 | 21 ns | 377 ns | 219 ns | 220 ns |
| kind | 4096 | 131 ns | 4.20 us | 68 ns | 212 ns |
| concat (text) | 8 | 10.2 us | 3.60 us | 4.46 us | 3.73 us |
| concat (text) | 40 | 16.9 us | 3.63 us | 4.47 us | 3.51 us |
| concat (text) | 256 | 60.1 us | 5.27 us | 6.08 us | 5.36 us |
| concat (text) | 4096 | 733.9 us | 25.2 us | 25.5 us | 24.2 us |
| join (native) | 8 | 3.57 us | 3.02 us | 3.87 us | 3.07 us |
| join (native) | 40 | 4.85 us | 2.82 us | 3.54 us | 3.24 us |
| join (native) | 256 | 16.2 us | 3.35 us | 3.24 us | 3.07 us |
| join (native) | 4096 | 164.7 us | 5.64 us | 6.47 us | 3.37 us |
| Win32 buffer from List[int] (M7) | 8 | 1.52 us | 1.56 us | 1.56 us | 1.53 us |
| Win32 buffer from List[int] (M7) | 40 | 4.35 us | 4.30 us | 4.23 us | 4.18 us |
| Win32 buffer from List[int] (M7) | 256 | 22.3 us | 21.6 us | 21.7 us | 21.6 us |
| Win32 buffer from List[int] (M7) | 4096 | 334.8 us | 324.9 us | 330.1 us | 320.8 us |
| Win32 buffer from Bytes (this) | 8 | n/a | 644 ns | 622 ns | 1.01 us |
| Win32 buffer from Bytes (this) | 40 | n/a | 617 ns | 916 ns | 931 ns |
| Win32 buffer from Bytes (this) | 256 | n/a | 1.06 us | 678 ns | 678 ns |
| Win32 buffer from Bytes (this) | 4096 | n/a | 1.30 us | 1.24 us | 836 ns |

What the versions show: slicing every path cost short paths what it saved
long ones (`kind` 0.11 to 0.31 us and `join` 3.0 to 3.9 us at 8
characters, `kind` 4.2 us to 68 ns at 4,096); the final version takes the
first version's cost below 64 units and the slices' above (`join` 3.07,
3.24, 3.07 and 3.37 us at 8, 40, 256 and 4,096 characters). The conversions
(`validate + native`, `from_text`, `text`, `display`) are the same code in
the last three versions.

### 11.6 Linux and macOS: the same code, measured again

Nothing Linux or macOS runs changed: std::linux::*, std::darwin::* and
std::io::* have no diff on this branch, and a program that validates,
converts, joins, writes, reads and decodes paths lowers to the same NIR
before and after (section 12). Measured anyway, `bench/filesystem.tcl
-baseline-rev f9e0ed0`:

* **Linux x86-64** (local experiment): every row within 0.96 to 1.12 of
  before (path operations 0.96 to 1.07; the 64-byte and 1 MiB writes,
  which are the disk's, 1.01 to 1.12).
* **macOS AArch64** (real platform, run 41254348599 on `43c0795`, full
  shard 1; the Darwin code is the same in the final commit): path
  operations 0.92 to 1.07, except `text (native)` at 1.41 (180 to 255 ns);
  file operations 0.81 to 1.15, except `write_file 1 MiB` at 2.32 (493 to
  1,145 us). Identical code in both trees, so these are the shared runner:
  in the same job `reopen (100)` moved 0.81 the other way.

The codec on macOS AArch64 (same run): `encode_utf16le` 24 to 72 ns for 8
to 40 ASCII characters, 1.6 us at 4,096; `decode_utf16le` 36 to 69 ns,
4.7 us at 4,096; mixed text 11.1 us (encode) and 28.0 us (decode) at
4,096 characters. `decode_utf8`, the unchanged reference, measured 0.92 to
1.24 of before on Windows and within the same spread elsewhere.

## 12. Regression coverage

Everything below ran on this branch. "Final" is `36f8dd7`, the code this
report describes; `43c0795` differs from it only in std::windows::fs's
`head_units`, `end_units` and `joined_data` (section 6) and in the tests
and fuzzer that pin them.

**Local (Linux x86-64, the development container)**

* `tests/local.tcl` narrowed to the files this milestone touches
  (utf16-bytes, filesystem, abi-bytes, abi-mutable-bytes,
  stdlib-namespaces, linux-syscall, contexts, windows-io, portable-io,
  linux-path, darwin-io, context-traits) and their golden suites, on
  interp and compile, golden suites on all four backends: on the final code, every test passed -- 397 on interp and 397 on compile
(49 skipped by host constraints, 117 golden duplicates), and the 11 golden
suites (443 tests on the Tcl backends, 452 on the native ones);
* `tests/filesystem.test`'s Windows path tests on the final code,
  `fs-windows-native-runtime` included (both native backends, normally and
  under `BOTLISH_NATIVE_GC_STRESS=1`): pass;
* `cargo test --release --manifest-path native/Cargo.toml --lib utf16le`:
  pass (the whole Rust suite is CI's, below);
* `tests/utf16-bytes.test` and `tests/filesystem.test` with
  `BOTLISH_NATIVE_GC_STRESS=1` in the environment: pass (14 of 14; 42 run,
  19 skipped by host constraints, none failed);
* the warning gate (`audit/refactor/tools/gate.tcl`): passes, the observed
  warnings exactly the manifest; `tools/compilerpedia.tcl check`: 0
  problems; `tests/golden-duplicates.test`: pass;
* the fuzzers and mutants of section 10.

**Windows x86-64 (windows-2025, MSVC, NTFS)**

* run 41254346872 (`43c0795`, dispatched with `tier: full`): every job
  passed -- smoke (the Rust tests, native status, C calls, GC workloads,
  the smoke tier and the Windows-relevant test files on interp and compile,
  tests/filesystem.test and tests/utf16-bytes.test among them; "Filesystem
  under GC stress" running both files on the native backends under
  `BOTLISH_NATIVE_GC_STRESS=1`), root plans, the four full shards (shard 1:
  `utf16-bench`, `utf16-fuzz`, `filesystem-fuzz`, the benchmarks of section
  11; shards 2 to 4: the GC-stress tier), the four acceptance shards and the
  system linker;
* run 41266378398 (final, `tier: full`, items `utf16-bench filesystem-fuzz
  filesystem-mutants`): smoke (the Windows-relevant test files on interp and compile,
  filesystem.test and utf16-bytes.test among them, and "Filesystem under GC
  stress"), root plans, the four acceptance shards and the system linker
  passed; full shard 1 ran `utf16-bench` (section 11), `filesystem-fuzz`
  (no disagreement) and `filesystem-mutants`, every mutant of Windows code
  killed on NTFS -- among them the two only Windows runs,
  `win-enumeration-loses-native-name` (by `fs-windows-native-roundtrip`)
  and `win-last-error-read-late` (by `fs-windows-directory-failures`,
  `-long-path`, `-modes`, `-sharing`), and the two long-path mutants. The
  job failed on the nine `linux-*` mutants of milestone 7, which mutate
  std::linux::fs and carried no host line, so this full run applied them on
  Windows, where no detector runs that code, and reported them SURVIVED
  (milestone 7 had run its Windows mutants on Windows by name). They now
  carry `%% linux-x86_64 linux-aarch64`, the file's rule for a mutant of
  code only some hosts run, and are killed on Linux (the local record);
* Icy Tower on Windows (run 41254335025 on `43c0795`; run 41266348143 on
  the final code): both passed.

**Linux x86-64 and arm64**

* tests.yml run 41254352482 (`43c0795`): every job passed -- the Tcl suite on interp and compile, its cranelift and cranelift-generic coverage, the four golden shards beside their Tcl originals, the native Rust unit tests, the stub- and system-linked executables (the latter also under GC stress), the warning gate and the method-call decision's oracle (its GC-stress job runs on pushes to main only, and was skipped);
* tests.yml run 41266528009 (final): every job passed (its GC-stress job runs on pushes to main only);
* tests-arm64.yml run 41254354267 (`43c0795`): every job passed -- the Tcl suite on interp and compile, its
  cranelift and cranelift-generic coverage, the four golden shards, the
  native Rust unit tests (also under GC stress) and the system-linked
  executables (also under GC stress) -- but the GC-stress run of the whole
  Tcl suite, which GitHub cancelled at its six-hour limit inside
  `tests/tree-struct.test` (reached after 1 h 56 min; every file
  before it, `filesystem.test` among them, passed under the stress). That
  file's size tests build trees of up to a million nodes, quadratic under a
  collection at every allocation; main fixed it after this branch started
  (`b74c877`, "Tree structs: size tests without the suite's GC stress"),
  and main's tree-struct merge `c745ed4` was cancelled the same way (run
  41198052933). It is not this milestone's: `utf16-bytes.test` sorts after
  `tree-struct.test`, so the suite-wide stress never reached it, but its
  own `u16-gc-stress` runs both native backends under the stress in every
  run, the interp job's included;
* tests-arm64.yml run 41266529720 (final): the same: every job passed but the suite-wide GC-stress run, cancelled at six hours in `tests/tree-struct.test` (reached after 1 h 44 min) for the reason above;
* static-decisions.yml run 41247717983 (`7315303`, dispatched): success.
  The commits after it change std::windows::fs and audit and benchmark
  files only, and no golden suite imports std::windows, so no static
  decision of a golden suite can have moved.

**macOS AArch64 (macos-15)**

* run 41254348599 (`43c0795`, dispatched with `tier: full`): smoke,
  acceptance shard 1, full shard 1 (`utf16-bench`, `utf16-fuzz`,
  `utf16-mutants`: 21 of 21 killed by their named detectors), Botlish.app,
  the static SDL3 link plan and the application without developer tools
  passed. Acceptance shard 2, the system linker job and the main-thread
  startup job failed, all three on one test, `main-thread-startup.test`'s
  `mts-main-process-semantics`: it compiles
  audit/macos-graphical-main-thread/programs/errors.bot, which adds two
  Lists (`erased(true) + erased(false)`, line 40) to provoke a run-time
  type error, and the compiler now rejects that statically (native argument
  kinds, METHOD-RECEIVER-TYPE-CORRECTNESS-MILESTONE-1.md). The commit this
  branch started from rejects the program the same way (`main.tcl -check`
  on `f9e0ed0`), and main's own macOS runs fail the same jobs (runs
  41244352962 and 41198055666): it predates this milestone and is not
  touched by it;
* run 41266348148 (final, push): smoke, acceptance shard 1, Botlish.app, the static SDL3 link
  plan and the application without developer tools passed; acceptance
  shard 2 (5,252 tests, one failed), the system linker job (3,850 tests,
  one failed) and the main-thread startup job failed on the same one test,
  `mts-main-process-semantics`, as above;
* Icy Tower on macOS (run 41254335004 on `43c0795`): the graphical
  acceptance's `restart` case failed one timing check on the first attempt
  (where the new game's player stood 0.6 to 1.0 s after R) while the same
  run's SDL call traces were identical to the Linux reference under both
  drivers and the oracle agreed; the rerun passed every case. Run
  41266348174 on the final code: every case passed on the first attempt.

**Unchanged code on Linux and macOS.** std::linux::*, std::darwin::* and
std::io::* have no diff on this branch. A program using `validate`,
`native`, `join`, `write_file`, `read_file` and `text` compiles to the same
NIR on `f9e0ed0` and on this branch, expression ids aside: 47 functions for
macos-aarch64, 63 for linux-x86_64 (compared with `-emit-nir`). Their
timings (section 11.6) are therefore the same code measured twice.

## 13. Remaining limitations

Only measured or demonstrated ones:

* **The path syntax is now the largest cost of a join** (section 11: the
  syntax rows). `joinable?` builds a List of segment Lists and compares
  segments with List literals; it was left exactly as milestone 7 wrote it,
  as this milestone requires (the syntax's one statement). A cheaper
  formulation of the same rules -- one pass over the units, no segment
  Lists -- would be a change to that implementation and needs its own
  equivalence evidence (the 110-pair join test, the fuzzer's model).
* **`display` of a name without text** still decodes in Botlish
  (milestone 7's `scalars` and `utf8_of`: some 10 us at 40 characters,
  local experiment), after a strict decode that fails. Only names holding
  an unpaired surrogate take this path; a lossy primitive was not added
  (section 7).
* **Textual validation is linear, not free.** `WindowsPath.validate`'s
  `nul_free?` now reads the String's UTF-8 bytes through a List
  (`encode_utf8`); for ASCII text the old `char_at` loop was faster (about
  70 ns against 210 ns at 40 characters), for non-ASCII text quadratic
  (9.0 ms against 36 us at 4096 characters). Botlish has no operation that
  searches a String or a Bytes; the linear form was chosen for its bound.
  `WindowsPath.concat` validates its result this way, so a long path's
  concat pays one such pass.
* **`std::linux::path` and `std::darwin::path` keep the quadratic
  `nul_free?`** (the same `char_at` loop: measured above as "chars", 9.0 ms
  for 4096 mixed characters). Their paths were outside this milestone and
  are unchanged; the same one-line change would apply.
* **Mixed-script decoding** costs about 7 ns per unit natively (35 us for
  5,120 units, against `decode_utf8`'s 10.5 us for the same text): the
  measuring pass and `char::decode_utf16` with a UTF-8 encoding per scalar.
  A hand-written UTF-8 writer measured 25% faster in a standalone
  experiment; not worth a second encoder. ASCII decoding has its own path
  (about 1 ns per unit).
* **`from_units`** builds its bytes in Botlish (its input is a List); it is
  on no conversion path the milestone measured.
* **`kind` and `units` are no longer field reads.** A NativePath holds
  bytes, so `units` builds its List at every call (about 4 ns per unit) and
  `kind` bridges a short path's units or slices a long path's head (0.1 to
  0.3 us, against 0.01 to 0.08 us when the units were stored). A caller that asks
  for both, or asks again, pays again; nothing in the standard library
  does. Holding both representations would double every path's memory and
  make every constructor build a List again, which is what the milestone
  removed.
* **Listing a directory was 7 to 9% slower per name on Windows** (two
  runs, section 11.3: 7.55 to 8.20 us): a listed name was sliced out of the
  find record as its bytes on top of milestone 7's scan, which read the
  260-unit name field as a List and built the name's units. Repaired after
  the milestone (section 15): one internal primitive measures the name in
  the record and the name is sliced once, with no List built. On the
  windows-2025 runner (run 41310552501) a listed entry costs 2.17 us
  against 5.85 us for milestone 7 on the same runner (0.37), and listing
  and then opening every entry 36.8 against 44.2 us (0.83).
* **The 64-unit threshold** of section 6 is the crossover measured on this
  container's x86-64 CPU (bridging 64 units costs about what slicing four
  and one does); it was not tuned per platform. Either side gives the same
  answers; only the cost moves.

## 14. Files changed and commands to rerun

**New**

| file | what |
|---|---|
| core/utf16text.tcl | `InvalidUtf16` (builtin error 13); `std::byte_store::encode_utf16le`, `decode_utf16le`, the internal `utf16le_units` (the Tcl backends' implementation) |
| tests/utf16-bytes.test | the codec's tests (section 9) |
| audit/abi-bytes/tools/utf16-oracle.py | the independent oracle and its selftest |
| audit/abi-bytes/tools/utf16-fuzz.tcl | the codec fuzzer |
| audit/abi-bytes/tools/utf16-mutate.tcl, utf16-mutants.txt | the codec's mutation harness and its 21 mutants with named detectors |
| audit/abi-bytes/utf16-mutate-result.txt | the recorded local mutation run of the codec's mutants |
| audit/filesystem/results/mutate-linux.txt | the recorded local run of the filesystem mutants (Linux x86-64) |
| bench/utf16-bytes.tcl | the per-operation benchmark (codec, Windows path operations, syntax alone, Win32 buffers; `-measure alloc` for allocations) |
| bench/baseline-tree.tcl | `-baseline-rev`: a benchmark's "before" in a temporary worktree |
| audit/golden/migration/census/utf16-bytes.tsv | census rows of the new Tcl tests |
| docs/UTF16-BYTE-STORAGE-MILESTONE-1.md | this report |

**Changed**

| file | what |
|---|---|
| core/core.tcl | loads core/utf16text.tcl after core/utf8text.tcl |
| stdlib/abi/bytes.bot | `encode_utf16le`, `decode_utf16le`, the internal `utf16le_units` |
| native/src/runtime/ops.rs | `rt_str_encode_utf16le`, `rt_bytes_decode_utf16le`, `rt_bytes_utf16le_units`, `utf16le_encoded_len`, `utf16le_measure`, their classification and dispatch, Rust tests |
| native/src/runtime/error.rs | `ERR_INVALID_UTF16` |
| native/src/nir.rs, native/src/codegen/clif.rs, native/lower.tcl | the three NIR operations |
| stdlib/windows/fs.bot | NativePath as UTF-16LE bytes (section 6) |
| stdlib/windows/path.bot | `nul_free?` in one pass |
| tests/filesystem.test | `fs-windows-call-buffer`, `fs-windows-native-runtime`, `fs-windows-astral-names`, `fs-windows-long-syntax` |
| tests/abi-bytes.test, tests/abi-mutable-bytes.test, tests/stdlib-namespaces.test, tests/linux-syscall.test, tests/contexts.test | inventories (the natives, the module surface, the builtin errors) and one HIR expression id the new functions shift |
| audit/filesystem/tools/fuzz.tcl | the windows part checks `units`, draws long segments and runs on the native backends on Linux |
| audit/filesystem/tools/mutate.tcl | a mutant whose library does not compile is DOES NOT COMPILE, never killed |
| audit/filesystem/tools/mutants.txt | seven new mutants, six rewritten for the new code; milestone 7's nine `linux-*` mutants given their hosts (`%% linux-x86_64 linux-aarch64`) |
| bench/filesystem.tcl | `-root`, `-baseline-rev`, rows for display, 256-character mixed text and the codec |
| tests/platform/tier.tcl | tier items `utf16-fuzz`, `utf16-mutants`, `utf16-bench` |
| .github/workflows/windows-x86_64.yml | utf16-bytes.test in the smoke step and under GC stress |
| compilerpedia/notes/stdlib.notes, compilerpedia/generated/stdlib.topic | the new intrinsics (and the byte-store module note) |
| audit/stdlib-census/after.tsv | regenerated |
| tests/golden/manifest.tsv, audit/golden/migration/census/filesystem.tsv, audit/golden/migration/tcl-names.txt | the new tests' rows |
| AGENTS.md | the section "UTF-16LE on byte storage" |
| docs/INDEX.md, docs/WINDOWS-X86-64-MILESTONE-7.md | the index line; forward pointers (milestone 7's findings unchanged) |

**What to run when changing this**

```sh
export LANG=C.utf8 LC_ALL=C.utf8
tclsh9.0 tests/utf16-bytes.test
tclsh9.0 tests/filesystem.test            # Windows tests on Windows
tclsh9.0 tests/abi-bytes.test
cargo test --release --manifest-path native/Cargo.toml --lib utf16le
python3 -I audit/abi-bytes/tools/utf16-oracle.py selftest
tclsh9.0 audit/abi-bytes/tools/utf16-fuzz.tcl -seed S        # several seeds
tclsh9.0 audit/abi-bytes/tools/utf16-fuzz.tcl -seed 9 -gc-stress 1
tclsh9.0 audit/abi-bytes/tools/utf16-mutate.tcl              # every mutant killed by its named detector
tclsh9.0 audit/filesystem/tools/fuzz.tcl -seed S
tclsh9.0 audit/filesystem/tools/mutate.tcl
tclsh9.0 bench/utf16-bytes.tcl -baseline-rev REV
tclsh9.0 bench/filesystem.tcl -baseline-rev REV
```

and on another host the tier items (`tests/platform/tier.tcl utf16-fuzz
utf16-mutants utf16-bench filesystem-mutants`; a Windows or macOS workflow
run with `tier: full` and `tests:` those items).

## 15. Listing without a List

An addendum after the milestone, on the one regression section 11.3
measured and kept: listing a directory was 7 to 9% slower per name on
windows-2025 (`entries (100)`: 7.55 to 8.20 us per entry in run
41266378398, 1.07 times in run 41254346872). Code: `9721c9a` on this
branch, and `fef351d` (a pinned expression id in tests/contexts.test).

**Cause** (code inspection). `take`, which turns one FindFirstFileW /
FindNextFileW record into an Entry, still did milestone 7's work:
`std::binary::read(record, FindData.name)` built a List of the name field's
260 units, a loop built a second List of the name's units up to the
terminator -- read for `valid_units?`, the "." and ".." check and the
length -- and the milestone added a slice of the name's bytes after it,
since a NativePath is bytes. Measured alone (local experiment, below), that
work was almost all of a `take`.

**Change.** One internal primitive measures the name where it lies, in the
record:

```botlish
nomethod fn utf16le_units_before_nul(data: Bytes, start: int, end: int) -> int errors LowerUnderrun, UpperOverrun
```

`std::abi::bytes::utf16le_units_before_nul`, over
`std::byte_store::utf16le_units_before_nul`: both internal members of the
standard library, like `utf16le_units` (a program naming either is
INTERNAL-NAMESPACE). It is the number of whole UTF-16 units of DATA's bytes
START..END-1 -- byte pairs from START, low byte first -- before the first
unit 0, or all (END - START) / 2 of them when none is 0. A unit is 0 only
when both bytes of its own pair are: a single 00 byte (U+0100 is 00 01,
U+2E00 is 00 2E) and 00 00 across two units (U+0041 U+4100 is 41 00 00 41)
end nothing. Its bounds are the one slice rule (the declared LowerUnderrun
and UpperOverrun), an odd range is RANGE (no caller passes one), and it
reads the payload in place: no allocation, no List, no `unsafe`. The Tcl
backends' implementation is core/utf16text.tcl's (`binary scan su*` of the
range, `lsearch` for 0), the native one ops.rs's
`rt_bytes_utf16le_units_before_nul` (the codec's own pair reader
`utf16le_units_of`, then `position`), NIR `op bytesutf16lenul`, a plain
helper call that allocates nothing (codegen::clif's table, beside
`byteslen`). Swapping a pair's bytes cannot change what it finds (a pair
is 0 either way); what matters is the pairing -- whole pairs from START --
which its tests and mutants pin.

`take` now freezes the record (as before), measures the name in
FindData.name's 260 units (bytes 44..564), skips an empty one, slices its
bytes once, skips "." and ".." by comparing those bytes with the constant
Bytes 2E 00 and 2E 00 2E 00 (only a name of one or two units is compared),
and reads the attributes and the reparse tag (as before). Every unit before
the NUL is 1..65535, so `valid_units?` had nothing left to check but
emptiness. The FindData layout still describes the record; its `name`
field is no longer read as a List.

The semantics are milestone 7's, exactly: a listed name is the record's
units before the first NUL unit, all 260 when there is none (the bytes
after the field never read), an unpaired surrogate kept as itself; ".",
".." and the empty name are skipped.

**Measured, real platform.** `bench/filesystem.tcl -baseline-rev f9e0ed0`
on the windows-2025 runner, run 41310552501 (job "full (Windows x86-64,
shard 1/4)", tier item `utf16-bench`; `9721c9a`), per operation, NTFS:

| row | before (`f9e0ed0`) | after (`9721c9a`) | after/before |
|---|---:|---:|---:|
| entries (100), per entry | 5.85 us | 2.17 us | 0.37 |
| reopen (100), per file | 44.2 us | 36.8 us | 0.83 |

The same job's `filesystem-bench` (the current tree alone, run again
after) gave 2.19 us and 36.5 us. For comparison, the milestone's own code
(`36f8dd7`, merged as `effecc7`) measured 1.09 and 1.07 times its baseline
in runs 41266378398 and 41254346872 (7.55 to 8.20 us, section 11.3);
runners differ in absolute speed (this one listed milestone 7's entries in
5.85 us, that one in 7.55), which is why each figure is taken against the
baseline measured on the same runner. Every other row of the table is code
this addendum does not touch and stayed near section 11.3's ratios (here
open + close 0.68, text 0.022, concat 0.33, the 1 MiB transfers 0.97).

**Measured, local experiment** (the Windows module's code on this
container's Linux driver, as in section 11.5): `take` alone, through a
probe appended to a private copy of each tree's standard library (the probe
of `fs-windows-entry-names`, in a loop), a 592-byte record built in the
program and handed to `take` N times, minus the same loop copying the
record without `take`; best of 5 and of 7 runs, two runs per tree (the
spread below), and allocations counted by the driver (`--alloc summary`):

| name in the record | `f9e0ed0` | `effecc7` (the milestone) | `9721c9a` |
|---|---:|---:|---:|
| 8 units | 5.4-6.4 us | 6.3-7.2 us | 0.79-0.97 us |
| 20 units | 7.4-7.9 us | 7.3-7.5 us | 0.72-1.07 us |
| 64 units | 9.1-10.5 us | 9.3-9.7 us | 0.84-1.02 us |
| "." (skipped) | 3.3-3.4 us | 3.5-3.8 us | 0.24-0.34 us |
| allocations per take (8 units) | 9 | 11 | 5 |
| bytes allocated per take (8 units) | about 3,050 | about 3,120 | about 760 |

What remains in a `take` is the record's freeze (one 592-byte copy, as in
milestone 7), the name's slice and its Bytes, the Entry and the push. The
script was an ad hoc local experiment (not committed); the Windows figures
above are the report's evidence.

**Tests.**

* tests/utf16-bytes.test `u16-units-before-nul` (every backend, which must
  agree; through a probe appended to a private copy of the standard
  library, since the measure is internal): the terminator first, in the
  middle, past END (unseen), absent; a lone surrogate before it; U+0100 and
  U+2E00 (a single 00 byte) and 41 00 00 41 (00 00 at an odd distance)
  ending nothing; units counted from an odd START; the slice rule's
  LowerUnderrun and UpperOverrun; RANGE for an odd range. The registration,
  surface and internal-member tests (`u16-natives-registered`,
  `u16-public-surface`, `u16-internal-bridge`) and the native inventories
  (tests/abi-bytes.test, tests/abi-mutable-bytes.test,
  tests/stdlib-namespaces.test, tests/linux-syscall.test) include it.
* the Rust test `utf16le_units_before_nul_counts_whole_units` (ops.rs):
  the same cases on the runtime directly, the declared errors' ids, RANGE.
* tests/filesystem.test `fs-windows-entry-names` (every host): records
  built in the program and given to std::windows::fs's private `take`
  through a probe -- "a", ".", "..", the empty name, "...", ".a", a lone
  D800, a name with bytes after its NUL, "." with bytes after its NUL,
  U+2E00, U+0100 U+2E00 a, U+0041 U+4100 U+0042, a surrogate pair (a
  symbolic link by its reparse tag) and 260 units with no NUL (0xFF bytes
  after the field) -- each listed entry's bytes, units and kind, on interp
  and compile and, on Linux, both native backends, normally and under
  `BOTLISH_NATIVE_GC_STRESS=1`. It passes on milestone 7's `take` too
  (checked by running it against the old stdlib/windows/fs.bot): the
  semantics did not move. On NTFS, `fs-windows-entries`,
  `fs-windows-native-roundtrip` (a name holding D800 lists and reopens its
  own file) and `fs-windows-astral-names` run the real listing.

**Mutants.** The codec harness (audit/abi-bytes/tools/utf16-mutants.txt)
gains nine mutants of the measure, each killed by its named detectors
(`u16-units-before-nul`, and for the native ones also the Rust test):
`rust-nul-single-byte`, `tcl-nul-single-byte` (stops at a unit whose low
byte is 0), `rust-nul-high-byte-only` (reads only each unit's high byte),
`rust-nul-odd-distance`, `tcl-nul-odd-distance` (00 00 at any byte
offset), `rust-nul-absent-is-empty` (no NUL counted as none, not all),
`rust-nul-bounds-unchecked` (the slice rule dropped: an unchecked index),
`rust-nul-odd-range-accepted`, `tcl-nul-odd-range-accepted`. Swapping a
pair's bytes is no mutant of the measure (a pair is 0 either way), so the
byte-order rule it carries is the pairing, which these pin. The filesystem
harness (audit/filesystem/tools/mutants.txt) gains three mutants of `take`
-- `win-entry-name-overruns-field` (measured to the record's end, not the
name field's), `win-entry-dot-high-byte-first` ("." and ".." compared as
00 2E), `win-entry-empty-name-listed` -- and rewrites
`win-enumeration-loses-native-name` for the new code (the listed name's
units through its lossy text, the same rule); since `fs-windows-entry-names`
runs everywhere, that mutant no longer carries a Windows-only host line.

Runs: locally (Linux x86-64) the nine codec mutants, 9 of 9 killed by
their named detectors (`utf16-mutate.tcl -only ...`), and the four
filesystem mutants, 4 of 4 killed by `fs-windows-entry-names`
(`mutate.tcl -only ...`); every mutant of both files still applies exactly
once to the final code. On Windows (run 41310552501, tier item
`filesystem-mutants`, the whole file on NTFS): 26 killed, none surviving,
the ten Linux and macOS mutants skipped by their host lines -- the four
above among the killed (`win-entry-dot-high-byte-first` also by
`fs-windows-entries`, `fs-windows-astral-names` and
`fs-windows-executable`; `win-enumeration-loses-native-name` also by
`fs-windows-native-roundtrip`).

**Regression coverage.**

* Local (Linux x86-64): `tests/local.tcl` narrowed to utf16-bytes,
  filesystem, abi-bytes, abi-mutable-bytes, linux-syscall and
  stdlib-namespaces (231 tests on interp and on compile, 19 skipped by host
  constraints, 88 golden duplicates; the 9 golden suites holding their
  duplicates on all four backends): every test passed. `tests/utf16-bytes.test`
  also under `BOTLISH_NATIVE_GC_STRESS=1`; `cargo test --release --lib`
  (321 passed) and `--bin botlish-native` (117 passed); the warning gate
  (it found the wrapper's call to the native eligible for method syntax,
  answered in the code); `tools/compilerpedia.tcl check` (0 problems);
  `audit/filesystem/tools/fuzz.tcl -seed 1` (2,800 cases, no
  disagreement).
* Windows (run 41310552501, `tier: full`, items `utf16-bench
  filesystem-bench filesystem-fuzz filesystem-mutants`): smoke (the
  Windows-relevant test files on interp and compile, filesystem.test and
  utf16-bytes.test among them, and "Filesystem under GC stress": 19
  passed, 0 failed), root plans, the system linker, the full shard (the
  benchmarks, `filesystem-fuzz` seeds 1 and 2 with 1,600 cases each and no
  disagreement, the mutants) and acceptance shards 1 and 4 passed.
  Acceptance shard 3 failed one test of this change: tests/contexts.test's
  `contexts-native-nir-hello` pins the HIR expression id of
  std::linux::io::write in the Hello World's NIR (`@e801`), which the new
  wrapper in stdlib/abi/bytes.bot, loaded before it, shifts to `@e809`
  (the milestone's own new functions shifted it the same way, section 14);
  the narrowed local run had left contexts.test out. Fixed in `fef351d`.
  Acceptance shard 2 failed tests/package-manager.test's `pm-remove`,
  `pm-crash-recovery` and `pm-lock-busy`, exactly as main's own run of
  `effecc7` does (run 41307355435, the same three tests and messages):
  the package manager (PM-1) came from main in that merge and this addendum
  does not touch it. Icy Tower on Windows (run 41310489596): passed.
* macOS AArch64 (run 41310489571, the push of `9721c9a`): smoke,
  acceptance shard 2, Botlish.app, static SDL3 through it and the
  application without developer tools passed; acceptance shard 1 and the
  system linker job failed on the same `contexts-native-nir-hello`
  expression id (fixed in `fef351d`) and on `main-thread-startup.test`,
  which predates this work (section 12), as the main-thread startup job
  does.
* After the fix, locally: the whole `tests/local.tcl` (every Tcl test file
  on interp and compile, 8,017 and 8,012 passed, 0 failed, 177 and 182
  skipped by host constraints, 2,370 golden duplicates; the 114 golden
  suites on all four backends, 0 failed).

**Files.**

| file | what |
|---|---|
| core/utf16text.tcl | `std::byte_store::utf16le_units_before_nul` (the Tcl backends'), internal |
| stdlib/abi/bytes.bot | the internal wrapper `utf16le_units_before_nul` |
| native/src/runtime/ops.rs | `utf16le_units_before_nul`, `rt_bytes_utf16le_units_before_nul`, its classification, dispatch and helper entry, the Rust test |
| native/src/nir.rs, native/src/codegen/clif.rs, native/lower.tcl | NIR `op bytesutf16lenul` |
| stdlib/windows/fs.bot | `take` measures the name in place; `name_end`, `dot_unit`, `dot_dot_units` |
| tests/utf16-bytes.test, tests/filesystem.test | `u16-units-before-nul`, `fs-windows-entry-names`; the registration pins |
| tests/abi-bytes.test, tests/abi-mutable-bytes.test, tests/stdlib-namespaces.test, tests/linux-syscall.test, tests/contexts.test | inventories, and one HIR expression id the wrapper shifts |
| audit/abi-bytes/tools/utf16-mutants.txt, audit/filesystem/tools/mutants.txt | the mutants above |
| audit/golden/migration/census/utf16-bytes.tsv, filesystem.tsv, tcl-names.txt, tests/golden/manifest.tsv | the new tests' rows |
| audit/stdlib-census/after.tsv | regenerated |
| AGENTS.md | the measure in "UTF-16LE on byte storage" |

**What to run when changing this**: section 14's list, plus
`tclsh9.0 audit/abi-bytes/tools/utf16-mutate.tcl -only
rust-nul-single-byte,...` for the measure's mutants and
`tclsh9.0 audit/filesystem/tools/mutate.tcl -only
win-entry-name-overruns-field,...` for `take`'s; on Windows the tier items
`utf16-bench` (the table above) and `filesystem-mutants`.
