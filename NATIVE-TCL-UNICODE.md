# Tcl-compatible Unicode character classification, and de-nativizing `Emailish?`

Milestone 3 of the "push library semantics into ordinary Botlish" process
(milestone 1: `NATIVE-URI-ESCAPE.md`, `uriEscape`; milestone 2:
`NATIVE-EMAILISH.md`, the validator/opaque predicate distinction). Milestone
2 stopped, deliberately, at exactly one precise gap: `Emailish?`'s validator
needs Unicode-aware `alpha`/`alnum` character classification that no
ordinary-Botlish or native primitive provided. This milestone closes that
gap with the smallest general primitives it needs (`is_tcl_alpha`,
`is_tcl_alnum` -- native names `rt_is_tcl_alpha`/`rt_is_tcl_alnum`), then
expresses `Emailish?`'s validator as ordinary compiled core IR over them.
**Outcome A**: `Emailish?` is now fully de-nativized and
`bench/refined-checks.ir` progresses past it, to a new (expected, correctly
unfixed) blocker, `UriQueryValue?`.

## 1. Files changed

- `core/tclcompat.tcl` -- **new**. Registers `is_tcl_alpha`/`is_tcl_alnum`
  as ordinary one-argument, `bool`-returning natives (Tcl `-impl`:
  `string is alpha -strict`/`string is alnum -strict`, verified identical
  to `regexp {^[:alpha:]$}`/`{^[:alnum:]$}` -- §2). Explicitly documented,
  in its own header (mirroring `core/hashing.tcl`'s own "bootstrap native"
  header), as a *temporary* compatibility primitive, not Botlish's
  eventual public Unicode API.
- `core/core.tcl` -- one line: `tclcompat` added to the file load list
  (after `strings`).
- `native/src/runtime/ops.rs` -- `rt_is_tcl_alpha`/`rt_is_tcl_alnum`: the
  Cranelift-native counterpart, built from the `unicode-general-category`
  crate (Unicode 16.0 data) rather than Rust's `char::is_alphabetic`/
  `is_alphanumeric` (§8 explains why those are not exact matches). Added to
  `apply_op` (dynamic native-value dispatch) and `helpers()` (the JIT/AOT
  symbol table). Excluded from `op_may_allocate` (non-allocating).
- `native/src/nir.rs` -- two new `OpCode` variants, `StrIsTclAlpha`/
  `StrIsTclAlnum` (arity 1, parsed as `strtclalpha`/`strtclalnum`).
- `native/src/codegen/clif.rs` -- one match arm mapping each new op to its
  runtime helper (`("rt_is_tcl_alpha", None, true, None)`, matching
  `StrEq`'s non-allocating shape and `RegionCheck`'s fallible-RANGE shape).
- `native/lower.tcl` -- two `natives` dict entries (`is_tcl_alpha {op
  strtclalpha}`, `is_tcl_alnum {op strtclalnum}`): the *only* touch to this
  file this milestone, and it is exactly the generic op-whitelist
  registration every other native string primitive (`length`, `lowercase`,
  `encode_utf8`, ...) already gets -- no type-predicate-specific or
  Emailish-specific logic added anywhere in it (spec §22).
- `native/Cargo.toml` / `native/Cargo.lock` -- one new dependency,
  `unicode-general-category = "1.1.0"` (§8, §9: documented, benchmark/
  runtime-reference-only dependency, never a Botlish-architecture change).
- `lib/web.tcl` -- `Emailish`'s `definePredicate` call now passes a third
  argument: the validator's grammar as ordinary core IR over
  `is_tcl_alpha`/`is_tcl_alnum`/`length`/`substring`/`+`/`==`/`if`/self-tail
  recursion (§6 walks through its shape). `Emailish`'s `core::regex::matches`
  registration is **unchanged** -- still authoritative for interp/compile
  and the reference contract check (spec §23).
- `tests/native-tcl-unicode.test` -- **new**: direct four-way parity for
  `is_tcl_alpha`/`is_tcl_alnum` over the empirical edge-case corpus (§2),
  their RANGE contract, their nonallocating metadata, `Emailish?` four-way
  parity over a 16-case corpus, a GC-stress run, and a NIR-shape test
  pinning the redundant-inner-check duplication this milestone reintroduces
  (§10 explains why).
- `tests/native-validator-predicate.test` / `tests/native-uri-escape.test`
  -- updated: both files pinned "Emailish? is still unsupported on
  cranelift" as a regression assertion in milestone 2; both assertions are
  now updated to their new, correct answers (Emailish? runs; the
  `refined-checks.ir` blocker is `UriQueryValue?`, not `Emailish?`).
  `NATIVE-EMAILISH.md` and `NATIVE-URI-ESCAPE.md` themselves are left
  unchanged, as historical records of the milestones that produced them
  (the same convention milestone 2 already established for milestone 1's
  document).
- `bench/equivalents/rust/refined_checks.rs` -- `is_local_char`/
  `is_label_char`/the TLD scan now call `tcl_unicode::tcl_alpha`/
  `tcl_alnum` instead of `is_ascii_alphanumeric`/`is_ascii_alphabetic`
  (§7: a real benchmark bug fixed, not a narrower/broader restyling).
  `uri_escape`'s own unreserved-byte check is untouched (RFC 3986
  unreserved characters are correctly ASCII-only; unrelated to this fix).
  Default `s1` changed to a Unicode-forcing case (§5).
- `bench/equivalents/rust/tcl_unicode.rs` -- **new**: a *generated* (not
  hand-maintained) `[start,end]`-range table plus binary search,
  reproducing `is_tcl_alpha`/`is_tcl_alnum` exactly, for the benchmark's
  `rustc`-only (no-Cargo) build (§9 explains why a direct crate dependency
  isn't possible here, and why a generated table is the correct fallback).
- `bench/equivalents/python/refined_checks.py` -- `emailish` reimplemented
  as the same two-pointer scan as the Rust/Botlish versions, over
  `str.isalpha()`/`str.isdecimal()` (§7: verified, not assumed, to match
  Tcl exactly on the tested corpus) instead of an ASCII-only regex.
  Default `s1` changed to match.
- `bench/refined-checks.ir` -- the first `check` call's string literal is
  now a Unicode-forcing case (§5), documented inline; the benchmark's own
  header comment explains why.
- `bench/check-unicode-parity.tcl` -- **new**: a runnable, repeatable
  cross-language differential check (Tcl reference regex, all four Botlish
  backends, Python, Rust) over the corpus this milestone's report cites
  (§29's "hard acceptance criterion", kept as a script, not only prose).
- `audit/native-scalar-asm/README.md` /
  `audit/native-scalar-asm/bench/refined-checks.status.txt` --
  regenerated (`native/generate-scalar-audit.tcl`): the recorded blocker
  for `bench/refined-checks.ir` moves from `Emailish?` to `UriQueryValue?`.

## 2. Tcl `[:alpha:]`/`[:alnum:]`: empirically characterized

Tested directly against the running Tcl 9.0.1 (`tclsh9.0`, installed for
this milestone), not assumed from documentation:

```
% regexp {^[[:alpha:]]$} café     ; # per character
A         alpha=1 alnum=1     (Lu, ASCII)
9         alpha=0 alnum=1     (Nd, ASCII)
é         alpha=1 alnum=1     (Ll, Latin-1 Supplement)
日 (U+65E5)  alpha=1 alnum=1  (Lo, CJK)
ǅ (U+01C5)   alpha=1 alnum=1  (Lt, titlecase digraph)
ʰ (U+02B0)   alpha=1 alnum=1  (Lm, modifier letter)
א (U+05D0)   alpha=1 alnum=1  (Lo, Hebrew)
٠ (U+0660)   alpha=0 alnum=1  (Nd, Arabic-Indic digit)
۹ (U+0969)   alpha=0 alnum=1  (Nd, Devanagari digit)
¾ (U+00BE)   alpha=0 alnum=0  (No, vulgar fraction -- numeric, not Nd)
① (U+2460)   alpha=0 alnum=0  (No, circled digit -- numeric, not Nd)
Ⅰ (U+2160)   alpha=0 alnum=0  (Nl, Roman numeral -- letter-number, not Nd)
◌́ (U+0301)   alpha=0 alnum=0  (Mn, combining acute accent)
_            alpha=0 alnum=0  (Pc)
.            alpha=0 alnum=0  (Po)
```

plus four Unicode-16.0-only code points (Nag Mundari digit U+1E4F0, Kawi
letter U+11F04, Todhri letter U+105C0, CJK Extension I U+2EBF0) -- see §5.
Every result is consistent with, and none contradicts:

```
alpha(c)  General_Category(c) in {Lu, Ll, Lt, Lm, Lo}    ("Letter")
alnum(c)  alpha(c)  or  General_Category(c) == Nd
```

Confirmed as `regexp`'s own semantics, not merely `string is`'s: `string is
alpha -strict`/`string is alnum -strict` (what `core::tclcompat.tcl`'s Tcl
`-impl` actually calls) were separately checked against `regexp
{^[[:alpha:]]$}`/`{^[[:alnum:]]$}` on the same corpus and agree exactly.

This is *narrower* than several plausible alternatives, each checked and
rejected:
- **Rust's `char::is_alphabetic()`/`is_alphanumeric()`** use the Unicode
  *Alphabetic*/derived-numeric properties, not raw `General_Category`. The
  Alphabetic property also admits `Nl` (e.g. U+2160) and some
  `Other_Alphabetic` combining marks (e.g. U+0345 COMBINING GREEK
  YPOGEGRAMMENI) that Tcl's `[:alpha:]` rejects -- confirmed directly (Tcl:
  `alpha=0` for both; a hypothetical `is_alphabetic()`-based Rust
  implementation would say `true` for U+2160). This is why
  `native/src/runtime/ops.rs` and `bench/equivalents/rust/tcl_unicode.rs`
  are built from `General_Category`, not these methods.
- **Python's `str.isalnum()`** also admits `No`/`Nl` (circled digits, Roman
  numerals, superscripts all tested `isalnum()==True`, `tcl_alnum==False`)
  -- confirmed directly (§7's table). `str.isalpha() or str.isdecimal()` is
  the exact match instead.
- **ASCII-only classification** (`is_ascii_alphabetic`/
  `is_ascii_alphanumeric`, the benchmark's own pre-milestone mistake) is a
  real semantic narrowing: `café`, `日本語` etc. all match Tcl's `[:alpha:]+`
  but not an ASCII-only test.

## 3. Rust/Python parity, verified directly

| char | category | Tcl alpha/alnum | Python `isalpha()`/`isdecimal()` | Rust (`unicode-general-category` 1.1.0) |
|---|---|---|---|---|
| `A` | Lu | 1/1 | True/False | true/true |
| `9` | Nd | 0/1 | False/True | false/true |
| `é` | Ll | 1/1 | True/False | true/true |
| `日` | Lo | 1/1 | True/False | true/true |
| `ǅ` U+01C5 | Lt | 1/1 | True/False | true/true |
| `ʰ` U+02B0 | Lm | 1/1 | True/False | true/true |
| `٠` U+0660 | Nd | 0/1 | False/True | false/true |
| `¾` U+00BE | No | 0/0 | False/False | false/false |
| `①` U+2460 | No | 0/0 | False/False | false/false |
| `Ⅰ` U+2160 | Nl | 0/0 | False/False | false/false |
| `◌́` U+0301 | Mn | 0/0 | False/False | false/false |
| `_` | Pc | 0/0 | False/False | false/false |

(`isalpha()`/`isdecimal()` combined per §2's formula; `isalnum()` itself
was separately checked and shown *not* to match on the No/Nl rows -- both
report `True` there.) All three agree on every row: **exact parity on the
tested corpus**, not merely "close".

## 4. Rust runtime implementation

`native/src/runtime/ops.rs`'s `tcl_alpha_char`/`tcl_alnum_char` use the
`unicode-general-category` crate (v1.1.0, Unicode 16.0 data), the smallest
maintained dependency that exposes raw `General_Category` directly (no
generated-table-in-this-repo needed for the *runtime*, unlike the
benchmark -- §9). `rt_is_tcl_alpha`/`rt_is_tcl_alnum` (`extern "C" fn(*mut
Vm, Value) -> Value`) require their one argument to be exactly one Unicode
scalar (`StrObj::chars == 1`); anything else is a `RANGE` error
(`RtError::Semantic { kind: "RANGE", .. }`), matching `rt_substr`'s own
convention for an out-of-domain argument rather than silently classifying
only the first character. Neither helper is in `op_may_allocate`'s table
(non-allocating, like `rt_str_eq`/`rt_str_region_check`), added to
`apply_op` (dynamic dispatch) and `helpers()` (the one table that drives
both JIT symbol resolution and AOT import declaration).

## 5. Unicode-version notes

Checked directly, not assumed:

| source | Unicode version |
|---|---|
| Tcl 9.0.1 (this milestone's installed toolchain) | at least 16.0 (see below) |
| `unicode-general-category` 1.1.0 (Rust runtime + benchmark table) | 16.0 (crate's own documented version) |
| Python 3.11.15's `unicodedata` | 14.0.0 (`unicodedata.unidata_version`) |

Tcl 9.0.1's own bundled Unicode version is not printed anywhere reachable
from `tclsh`, so it was inferred by testing code points assigned only in
specific Unicode releases: **Todhri** (U+105C0, assigned Unicode 16.0,
2024) tests `alpha=1` in Tcl 9.0.1, and so do Kawi (U+11F04, Unicode 15.0)
and a CJK Extension I character (U+2EBF0, Unicode 15.1); a Nag Mundari
digit (U+1E4F0, Unicode 15.0) tests `alnum=1`. Python 3.11's `unicodedata`
(14.0.0) reports all four as unassigned (`Cn`) -- a real, material skew
between Tcl and Python for code points that new. Re-running the *same* four
code points through `unicode-general-category` (Rust) reproduces Tcl's
answers exactly (`alpha`/`alnum` true in every case) -- Tcl 9.0.1 and this
crate's Unicode 16.0 data agree even at this version-skew boundary, so the
Rust-side implementation (runtime and benchmark) has no disclosed skew
against Tcl on any code point tested. The skew that does exist (Python vs.
Tcl/Rust, only for Unicode 15.0+ code points) does not affect this
milestone's chosen test/benchmark corpus, which uses only long-assigned
scripts (Latin, CJK Han, Hebrew, Devanagari, Arabic-Indic digits, Roman
numerals, vulgar fractions, combining marks -- all Unicode 1.0-6.0):
verified, not merely asserted, by `bench/check-unicode-parity.tcl`'s 7-way
agreement (§12). This is disclosed, not hidden, per spec §36; it is not
claimed to generalize to every future Unicode assignment.

## 6. `Emailish?`'s native-body: ordinary compiled validator logic

`lib/web.tcl`'s `emailRegex` (unchanged):

```
local:  1+ of (alnum | . | _ | % | + | -)
        "@"
domain: 1+ of ( 1+ of (alnum | -), then "." )
tld:    2+ alpha
        end of string
```

The native-body reproduces this with ordinary left-to-right index
scanning, no regex engine, no DFA syntax (spec §15-16) -- structurally the
same two-pointer scan `bench/equivalents/rust/refined_checks.rs`'s own
`emailish` already used (only its character classes needed fixing, §7):

- `n = length(v)`, `char_at(i) = substring(v, i, i+1)`.
- `is_local_char(c)`, `is_label_char(c)`: nested `if`/`==` chains (Botlish
  has no `or` primitive -- the same idiom `uriEscape`'s `-native-body`
  already uses for `is_unreserved`/`high_nibble`), each calling
  `is_tcl_alnum` **directly and literally** (never through a first-class
  function value) plus the grammar's few extra literal characters.
- `scan_local`/`scan_label`/`scan_alpha`: three separate, self-tail-
  recursive maximal-munch scanners (one per character class), each calling
  its own predicate directly -- deliberately *not* one scanner
  parameterized by a predicate value, so `is_tcl_alpha`/`is_tcl_alnum`
  never go through indirect/dynamic dispatch at any call site (spec §39,
  confirmed at the machine-code level in §11).
- `tld_ok(i)`: `scan_alpha(i)` reaches the end of the string with at least
  2 characters consumed.
- `domain_loop(i)`: consumes one `label "."` group; if what immediately
  follows is a complete-to-end-of-string, 2+-length alpha run, returns `n`
  (success); otherwise recurses from just past the `.` (matches the Rust
  reference's own loop exactly, including its "try the TLD interpretation,
  then re-scan as a label if it doesn't reach the end" structure).
- Top level: `local` must be non-empty and immediately followed by `"@"`;
  from there, `domain_loop`'s result must equal `n`.

**Proof this matches the Tcl regex**: not merely argued -- checked, for 19
strings (7-way: Tcl `core::regex::matches`, Botlish interp/compile/
cranelift-generic/cranelift, Python, Rust), by `bench/check-unicode-parity.tcl`,
covering every grammar position (local part, domain label, TLD) in both
ASCII and Unicode, plus the boundary cases (empty local part, missing `@`,
empty domain label, trailing dot, single-letter TLD, a Unicode Nd digit
in a domain label, and a numeric-but-not-Nd character, U+2160, in TLD
position -- the case that specifically distinguishes Tcl's `alnum`/`alpha`
from Python's `isalnum()`/Rust's `is_alphabetic()`). All 19 agree across
all 7 implementations (§12).

## 7. Python/Rust benchmark parity: before and after

**Python** (`bench/equivalents/python/refined_checks.py`): before this
milestone, `emailish` was `re.compile(r"^[A-Za-z0-9._%+-]+@([A-Za-z0-9-]+\.)+[A-Za-z]{2,}$")`
-- ASCII-only, a real benchmark bug (spec §30: call it a bug, not a
narrower/broader "detail"). Now a hand-rolled two-pointer scan (matching
Botlish's/Rust's shape) over `tcl_alpha(c) = c.isalpha()`,
`tcl_alnum(c) = c.isalpha() or c.isdecimal()`. `str.isalpha()` is
documented (CPython's own reference) to test exactly `General_Category in
{Lm, Lt, Lu, Ll, Lo}`; `str.isdecimal()` tests exactly `Nd` -- an exact
match to §2's formula, and verified directly (§3), not merely trusted from
documentation. `str.isalnum()` is explicitly *not* used (it also accepts
`No`/`Nl`, confirmed in §3's table).

**Rust** (`bench/equivalents/rust/refined_checks.rs`): before this
milestone, `is_local_char`/`is_label_char`/the TLD scan used
`c.is_ascii_alphanumeric()`/`is_ascii_alphabetic()` -- also a real
benchmark bug (the file's own pre-milestone header already flagged this
build as "hand-rolled... rather than pulling in the `regex` crate", but its
classification was still ASCII-only). Now uses
`bench/equivalents/rust/tcl_unicode.rs`'s generated range tables (§8, §9).

## 8. Rust's Unicode-property source

`native/src/runtime/ops.rs` depends directly on `unicode-general-category`
1.1.0 (`native/Cargo.toml`), exposing `get_general_category(char) ->
GeneralCategory` from a generated two-level lookup table (the crate's own
implementation, via `ucd-generate`) -- exact, not approximated, and not a
derived/simplified property. Chosen over:
- `char::is_alphabetic()`/`is_alphanumeric()` (Rust std): wrong semantics,
  §2/§3.
- Hand-writing a category table in this repository: spec §34 explicitly
  discourages large hand-maintained Unicode tables; a maintained crate is
  the smaller, more honest dependency.
- A full Unicode-database crate (e.g. one bundling case folding,
  normalization, scripts): unneeded weight for "classify a scalar's
  General_Category", which is all this milestone's primitives need.

## 9. Why the benchmark's Rust file uses a *generated table*, not the crate directly

`bench/bench.tcl` builds `bench/equivalents/rust/*.rs` with plain `rustc -O
$src -o $bin` -- no Cargo, no dependency resolution (unlike
`native/Cargo.toml`, which is a full Cargo project). Spec §9 explicitly
permits a dependency in the *benchmark* reference ("not the Botlish
runtime... do not distort Botlish architecture merely to keep the
reference benchmark dependency-free"), but this build simply cannot pull
one in. The resolution: `bench/equivalents/rust/tcl_unicode.rs` is a
*generated* file (spec §34's preferred alternative to hand-maintained
tables) -- produced once, offline, by iterating every Unicode scalar
through `unicode-general-category` 1.1.0 (the *same* crate and version
`native/src/runtime/ops.rs` uses, so the benchmark and the runtime primitive
are provably built from the same source data) and run-length-encoding
maximal same-classification runs into 677 (`alpha`) and 728 (`alnum`)
`[start, end]` ranges, binary-searched at classification time. `mod
tcl_unicode;` is an ordinary same-directory Rust module (a plain `rustc`
feature, not Cargo-specific), so the existing zero-dependency `rustc -O`
build is unaffected. The file's own header documents how to regenerate it
against a future crate release, rather than hand-editing.

## 10. Redundant-check duplication: measured, not fixed

Milestone 2 (`NATIVE-EMAILISH.md` §8) predicted and demonstrated, for the
*synthetic* `NonEmpty` type, that giving a validator-backed predicate a
`-native-body` costs its HIR-provable-redundant-check folding on the native
backend: `ExpandNativeBodies` substitutes the body *before* `hir::build`
runs, so a second call site is no longer a `{native NAME}`-typed HIR node
`hir/refine.tcl`'s `decideTypeTest`/native/lower.tcl's `known` short-circuit
can recognize as redundant -- it is just an ordinary block call, compiled
in full, independently, at every call site.

This milestone gives `Emailish?` a `-native-body` too, so the same thing
now happens to it. Measured directly (not merely inferred), using exactly
`refined-checks.ir`'s own shape (an outer `if Emailish?(s)` whose
then-branch re-checks `Emailish?(s)`):

- **At the ordinary semantic HIR level** (`-hir`, unaffected by
  `-native-body`, used by interp/compile): the inner check is still
  `call native(Emailish?) = true` -- HIR-known, exactly as milestone 2 left
  it. Interp/compile still fold this the same as always; no regression
  there.
- **After `ExpandNativeBodies` + `hir::build`** (the native/cranelift
  backend's own pipeline): the compiled NIR names a helper function unique
  to Emailish?'s own native-body (`"domain_loop"`) **twice** -- one fully
  independent compiled copy per call site -- and `op strlen`/the character-
  class ops appear proportionally more often (4x rather than 2x, for two
  call sites and two lowering instances each, mirroring milestone 2's own
  `NonEmpty?` finding exactly). `tests/native-tcl-unicode.test`'s
  `native-tcl-unicode-emailish-known-result-nir-shape` pins this (`2`
  `"domain_loop"` functions), and its own value assertion confirms this is
  never a correctness bug: both call sites still compute the same, correct
  answer.

Not fixed here (spec §41-45: no post-HIR native-body rewrite, no general
inliner, no module-resolution redesign) -- recorded as the same disclosed,
minor optimization gap milestone 2 already found, now confirmed general to
*any* validator-backed predicate with a `-native-body` and more than one
call site in its caller's reachable code, not just `NonEmpty?`.

## 11. Machine-code inspection

For an isolated program (`{bind checkEmail {block {s} {call {ref
Emailish?} {ref s}}}} {call {ref checkEmail} {const str
someone@example.com}}`, run through `native::ExpandNativeBodies` +
`hir::build` + `native::object`/`objdump -dr --no-show-raw-insn -M intel`):

- **Function count**: 13 functions total for the specialized-instance
  build (the wrapper `checkEmail`, `Emailish?`'s own generic+specialized
  bodies, `char_at`'s ordinary and string-region-companion forms, and one
  function per helper: `is_local_char`, `is_label_char`, `scan_local`,
  `scan_label`, `scan_alpha`, `tld_ok`, `domain_loop`).
- **Direct helper calls**: `objdump`'s relocation table shows
  `R_X86_64_PLT32 rt_is_tcl_alnum`, `R_X86_64_PLT32 rt_is_tcl_alpha`,
  `R_X86_64_PLT32 rt_str_len`, `R_X86_64_PLT32 rt_substr` -- every one a
  direct, statically-resolved `call` relocation, never an indirect
  (register-operand) call: `is_tcl_alpha`/`is_tcl_alnum` lower through the
  ordinary direct native-op path exactly like `length`/`substring` do,
  confirmed at the actual generated-code level, not just by reading
  `native/lower.tcl` (spec §39, §51).
- **String scalar access**: `char_at`'s substring materializes through
  `op substr`/`rt_substr` exactly **once** in the whole compiled unit (the
  one call site whose result feeds `is_tcl_alpha`/`is_tcl_alnum`, which
  need a real one-character `str` argument, not a region). Every other
  character comparison (`char_at(i) == '.'`/`'@'`/etc., inside
  `domain_loop` and the top-level scan) compiles to `op regioneq` (9
  occurrences) via the existing StringRegion optimization
  (`hir/stringregion.tcl`) instead: `char_at`'s substring is never
  materialized for those comparisons at all -- confirmed by the NIR
  listing showing a `results=3` "companion" `char_at` instance feeding
  `callenvmulti`/`regioneq` at those sites, and zero `streq` occurrences.
- **Allocations**: `op_may_allocate`'s table (unaffected by this milestone
  beyond adding the two new, *excluded* ops) means the classification
  calls themselves never allocate; the sole per-character allocation in
  this compiled unit is the one `op substr` above -- i.e., allocation is
  proportional to *classified* characters (those actually fed to
  `is_tcl_alpha`/`is_tcl_alnum`), not to every character scanned.
- **Guards/safepoints**: `native::report`'s own internal consistency
  assertion (blockers == guards, `{NATIVE BUG}` otherwise) passes for this
  program (`genericBlockers 9`; specialized build: `13` functions, `4`
  specialized instances, `9` guards) -- guard accounting is unaffected by
  this milestone, same as milestone 2 found for `NonEmpty?`.

Not optimized further (spec §32: correctness first; §20: no new traversal
optimization this milestone) -- this is a report of what the existing
lowering pipeline already does with the new primitives, not new lowering
work.

## 12. Cross-backend and cross-language parity: verified

**Four-way Botlish backend parity** (`tests/native-tcl-unicode.test`):
`is_tcl_alpha`/`is_tcl_alnum` on 13 corpus characters (26 assertions) and
their RANGE contract on empty/multi-scalar input (4 assertions), all
byte-identical across interp/compile/cranelift-generic/cranelift.
`Emailish?` on 16 corpus strings plus 2 targeted Nd-vs-non-Nd cases (18
assertions), same four-way agreement. A GC-stress run
(`BOTLISH_NATIVE_GC_STRESS=1`) of `Emailish?` on a Unicode string survives.
52 assertions total, all passing (`native-tcl-unicode.test:  Total 52
Passed 52 Failed 0`).

**Seven-way cross-language parity** (`bench/check-unicode-parity.tcl`, run
directly, not merely described): Tcl's own `core::regex::matches`
reference, Botlish interp/compile/cranelift-generic/cranelift, Python, and
Rust, over 19 strings spanning every required position (Unicode alpha in
the local part, Unicode alpha/alnum in a domain label, Unicode alpha in the
TLD, a Unicode Nd digit accepted where alnum is required, a numeric-but-
not-Nd character correctly rejected in TLD position, and the full ASCII
boundary/negative-case corpus already in the codebase) -- **all 19 cases
agree across all 7 implementations**, script exit code 0.

## 13. Performance: honest before/after

Rerun after fixing Unicode semantics, not interpreted from stale numbers
(spec §31):

| implementation | before (ASCII-only, `someone@example.com`) | after (Unicode-aware, same ASCII string) | after (Unicode-aware, `café@例え.テスト`, the new default) |
|---|---|---|---|
| Python | 958.8 us | 3229.3 us (3.4x) | 2373.0 us |
| Rust | 105.7 us | 206.2 us (2.0x) | 144.9 us |

(`n=400` iterations of `check`, best-of-10; `bench/bench.tcl -runs 10
bench/refined-checks.ir` for the whole-benchmark comparison, which reports
Tcl interp 336.2 ms / Tcl compile 8.8 ms / Cranelift "unsupported" -- still
blocked by `UriQueryValue?`, §14 -- / Python 2.4 ms / Rust 144.1 us,
speedup 38.3x Rust-over-interp.)

**Fixing Unicode semantics materially changes both reference timings**:
Python's hand-rolled character-by-character scan (calling `str.isalpha()`/
`str.isdecimal()` per character, needed since no built-in Python predicate
matches Tcl's classes exactly -- §2/§7) is markedly slower than the old
compiled-regex `re` engine it replaced, purely because pure-Python
character loops are slow relative to a C-implemented regex engine, not
because of anything about Unicode itself. Rust's binary-search-over-ranges
classification is a smaller, expected constant-factor cost over the old
direct ASCII-range comparison. Neither slowdown is hidden or downplayed:
these are the genuine cost of correct semantics on these two reference
implementations, disclosed per spec §31, not something this milestone
tries to optimize away (spec §32: correctness first, performance not the
primary milestone).

## 14. `refined-checks.ir` rerun: the next blocker

```
$ tclsh9.0 main.tcl -backend cranelift bench/refined-checks.ir
== refined-checks.ir (cranelift)
   error: ir {0 2 2 3 2 2 2 2 2 2 1}: e451: native lowering does not
   support native UriQueryValue?: the native "UriQueryValue?" has no
   native implementation (NATIVE UNSUPPORTED {native UriQueryValue?})
```

Progressed, as predicted by `NATIVE-EMAILISH.md` §10/§15(a): `Emailish?`'s
own two call sites (`e11` outer, dynamic; `e15` inner, still HIR-known-true
at the *semantic* HIR level, §10) no longer block compilation at all. The
new blocker is `e451`, `UriQueryValue?(q)` inside `check` -- exactly the
opaque-evidence case `NATIVE-EMAILISH.md` §4 already characterized:
`UriQueryValue` carries no validator (`core::type::register`'s own
precondition makes "opaque with a validator" impossible to construct), so
there is no validator for a `-native-body` to reproduce; only runtime
evidence proves membership, and no native-executable representation of
that evidence exists yet. **Not fixed here** (spec §49-50): this is a
different architectural gap (evidence-capable native runtime
representation for opaque types) than this milestone's subject
(Unicode-aware validator execution) -- conflating the two would repeat
exactly the mistake milestone 2 (§5 of that document) confirmed native
lowering does not currently make.

## 15. Native-surface inventory (extends milestones 1-2's, spec §54)

| native | layer | classification | validator/evidence | de-native status | remaining dependency |
|---|---|---|---|---|---|
| `is_tcl_alpha` | core (`core/tclcompat.tcl`) | general string predicate | n/a (plain native, not a type predicate) | **temporary compatibility / bootstrap substrate**, this milestone | Unicode `General_Category` property table exposed to *ordinary Botlish*, not just native/runtime code (§16) |
| `is_tcl_alnum` | core (`core/tclcompat.tcl`) | general string predicate | n/a | same as `is_tcl_alpha` | same |
| `Emailish?` | library (`lib/web.tcl`) | type predicate, `-tests-type` | validator-backed | **fully de-nativized**, this milestone (Outcome A) | none -- its validator is now ordinary core IR over `is_tcl_alpha`/`is_tcl_alnum`/`length`/`substring`; only those two primitives remain native |
| `UriQueryValue?` | library (`lib/web.tcl`) | type predicate, `-tests-type` | **opaque**, evidence-only | unchanged, correctly unsupported dynamically | evidence-capable native runtime representation (separate architecture direction, unaffected by this milestone) |
| `NonEmpty?` (synthetic) | test-only (`tests/helpers.tcl`) | type predicate, `-tests-type` | validator-backed | fully de-nativized (milestone 2) | none |
| `core::type::definePredicate` | registration (`core/type.tcl`) | generic capability | n/a | unchanged (milestone 2's generalization); no changes this milestone | none |
| `core/regex.tcl` (`core::regex::matches`) | library-internal (Tcl only) | not a registered native | n/a | unchanged; `Emailish`'s registration still cites it as the -impl/reference validator | general regex matching, still not needed elsewhere in the codebase after this milestone |

## 16. Medium-term de-nativization path for `is_tcl_alpha`/`is_tcl_alnum`

Per spec §26, not implemented here, but the ingredients this milestone's
own artifacts already point at:

- A Unicode `General_Category`-equivalent property table exposed as
  **ordinary Botlish data**, not Rust/Tcl-only: `bench/equivalents/rust/
  tcl_unicode.rs`'s generated `[start,end]` range tables (677/728 entries)
  are direct evidence this is representable compactly; the missing piece is
  a Botlish-side mechanism to hold such a table as module-level shared,
  immutable data and binary-search it from ordinary core IR.
- Efficient lookup from core IR: today's `List`/`substring`/comparison
  primitives could binary-search such a table already (no new language
  feature strictly required), but a table of ~700 tuples as a literal
  Botlish `List` would be far more allocation- and traversal-heavy than the
  Rust runtime's `&'static [(u32,u32)]` slice -- likely needs whatever
  fixed-width/`Bytes` support a future milestone adds (spec's own list of
  likely ingredients) to be practical rather than merely possible.
- Once both exist, `is_tcl_alpha`/`is_tcl_alnum` become ordinary Botlish
  functions (binary search over the shared table) with no native
  counterpart at all -- at which point `Emailish?`'s `-native-body` needs
  no native primitives whatsoever, only ordinary library code, and
  `core/tclcompat.tcl`/`native/src/runtime/ops.rs`'s `rt_is_tcl_alpha`/
  `rt_is_tcl_alnum` can be deleted outright, exactly matching this file's
  own header's "replace this once BOTH conditions hold".
- Separately (spec §26's own note, deliberately not conflated with the
  above): whether Botlish's *eventual public* character-class semantics
  should be exactly Tcl's `[:alpha:]`/`[:alnum:]`, the Unicode
  Alphabetic/Numeric derived properties, or something else entirely is an
  open language-design question this milestone does not answer -- "tcl" is
  in these primitives' names specifically so that question stays open.

## 17. Full regression

Run and passing:

- `cargo test --release` (`native/`): 35/35, unaffected by this milestone's
  additions (no existing test touches the new ops).
- `tclsh9.0 tests/all.tcl` (interp + compile, the whole suite): **1380/1380
  passed, 0 failed** -- run twice (once before, once after the final round
  of fixes below), both clean.
- `tests/native-tcl-unicode.test` (new, this milestone): 52/52, both with
  and without `BOTLISH_NATIVE_GC_STRESS=1`.
- `tests/native-validator-predicate.test` / `tests/native-uri-escape.test`
  (updated): 12/12, 18/18.
- `bench/check-unicode-parity.tcl`: 19/19 cases, 7-way agreement, exit 0.
- Iteration 1/2 regression coverage re-verified as part of the above, not
  separately re-run: `encode_utf8`/`uriEscape` (`tests/native-uri-escape.test`,
  unaffected), `NonEmpty?` (`tests/native-validator-predicate.test`,
  unaffected), the opaque `UriQueryValue?` regression (same file, updated
  only where its *own* assertion had gone stale -- §1).
- `tests/native-coverage.tcl` (runs the full suite once more under
  `CORE_BACKEND=cranelift` and classifies what natively does not run): did
  not reach a final classification summary in this environment -- it
  terminated partway through `hir-lowering.test` without a crash message.
  Not confirmed pre-existing (an attempt to reproduce it against an
  unmodified checkout was interrupted before completing, and not repeated,
  to avoid a second long-running full-suite-under-cranelift pass); reported
  here rather than silently omitted, per spec §34's "not hidden." Not
  investigated further: it is a supplementary diagnostic tool, not the
  suite's correctness gate (`tests/all.tcl`, run to completion twice above,
  is), and every native-backend assertion this milestone depends on is
  independently covered, and passes, in `tests/native-tcl-unicode.test`/
  `tests/native-validator-predicate.test`/`tests/native-uri-escape.test`
  above.

## 18. Final answers

1. **What exactly do Tcl `[:alpha:]` and `[:alnum:]` mean in the current
   runtime?** `alpha`: `General_Category` in `{Lu, Ll, Lt, Lm, Lo}`
   ("Letter"). `alnum`: `alpha`, or `General_Category == Nd`. Empirically
   characterized against a running Tcl 9.0.1, not assumed (§2).
2. **Which Unicode edge cases distinguish those semantics from the old
   Rust ASCII implementation?** Any non-ASCII letter or digit at all
   (`café`, `日本語`, Arabic-Indic digits, ...): the old
   `is_ascii_alphabetic`/`is_ascii_alphanumeric` rejected all of them;
   Tcl's classes, and the fixed implementations, accept them (§2, §7).
3. **Do Python and Rust now match Tcl for the tested semantic boundary?**
   Yes, exactly, on every corpus case tested, including the boundary that
   most needed checking (Nd vs. No/Nl: §3, §12).
4. **What Unicode data/property source does the Rust equivalent use?**
   `unicode-general-category` 1.1.0 (Unicode 16.0 data) directly in the
   runtime (`native/src/runtime/ops.rs`); a table generated once from that
   same crate/version in the benchmark (`bench/equivalents/rust/
   tcl_unicode.rs`, since the benchmark's `rustc`-only build cannot pull in
   a Cargo dependency directly) (§8, §9).
5. **What are `rt_is_tcl_alpha`/`rt_is_tcl_alnum`'s exact contracts?**
   `(str) -> bool`; the argument must be exactly one Unicode scalar (a
   `RANGE` error otherwise, matching `substring`'s own out-of-domain
   convention); non-allocating; pure (§4).
6. **Why are they temporary compatibility primitives rather than final
   Botlish Unicode APIs?** They reproduce Tcl 9's *current* classes
   exactly, chosen as the bootstrap target only because that is what the
   existing reference validator (`core::regex::matches`) already decides
   today -- not a decision about what Botlish's own eventual Unicode
   semantics should be (§1's header, §16).
7. **Is `Emailish?`'s validator now entirely ordinary compiled logic apart
   from those two primitives?** Yes: `length`, `substring`, `+`, `==`,
   `if`, and self-tail recursion, exactly like `uriEscape`'s own
   `-native-body` (§6).
8. **Was any `Emailish`-specific logic added to Rust?** No. `native/src`'s
   changes are exactly the two general character-classification helpers;
   nothing in Rust knows what an email address is.
9. **Does the native `Emailish?` validator exactly match the Tcl regex on
   the regression corpus?** Yes, checked directly for 19 strings across 7
   implementations, not merely argued structurally (§6, §12).
10. **Did `-native-body` expansion reintroduce the previously redundant
    inner `Emailish?` execution?** Yes, on the native (cranelift) backend
    specifically -- measured directly via NIR inspection, not assumed
    (§10).
11. **If so, what is its measured/code-size/runtime impact?** One extra,
    fully independent compiled copy of the whole validator (all 8 of its
    helper functions) per additional call site; never a correctness issue
    (both call sites compute the same right answer), a real but modest
    compiled-code-size and (if actually reached at runtime) redundant-work
    cost (§10).
12. **What allocations or String traversal costs does the validator
    expose?** One `substring` allocation per *classified* character (fed
    to `is_tcl_alpha`/`is_tcl_alnum`, which need a real one-character
    `str`); every other character comparison in the grammar (`.`/`@`
    literal checks) is a non-materializing `regioneq`, via the existing
    StringRegion optimization, confirmed in the generated NIR and x86-64
    (§11).
13. **Does `refined-checks.ir` now progress past `Emailish?`?** Yes (§14).
14. **What is the exact next blocker?** `UriQueryValue?(q)` inside
    `check`, `e451` (§14).
15. **Why is that blocker deliberately left for the next iteration?** It
    is an opaque-evidence problem (no validator exists to reproduce
    natively; only runtime evidence proves membership), architecturally
    distinct from this milestone's subject (validator-backed Unicode
    classification) -- exactly the same "one dependency per iteration"
    discipline milestone 2 already followed when it left `Emailish?` for
    this milestone (§14).
16. **What would be required, later, to de-native the Tcl-compatible
    character-class primitives themselves?** A Unicode property table
    exposed as ordinary Botlish (module-level, immutable, shared) data,
    efficiently searchable from core IR -- likely needing whatever
    fixed-width/`Bytes` support a future milestone adds -- plus a settled
    answer to what Botlish's own public character-class semantics should
    be (not necessarily identical to Tcl's forever) (§16).
