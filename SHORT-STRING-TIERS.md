# Tiered short-String regime: packed ASCII, ShortString1, tagged

> **Later runtime change.** The later `STRING-ALLOCATION.md` milestone replaced
> the two-allocation canonical String representation (a `StrObj` plus a
> separately allocated `Box<str>` text buffer) with one allocation holding the
> header and the UTF-8 bytes. Frontier costs in this report (the ~312 / ~862
> instruction materialization figures included) therefore describe the
> historical runtime used for this experiment, and are preserved unchanged as
> experimental history.

Second short-String milestone, on top of `SHORT-STRING.md`. It replaces the
interned materialization table with this regime, chosen per position by the
compiler's proof alone:

```
known ASCII, at most 8 characters        -> packed ASCII   (tier A, one i64)
known length <= 1, possibly non-ASCII    -> ShortString1   (tier B, one i64)
anything else                            -> the tagged String
```

A one-character ASCII String is known ASCII, so it is packed; only a String
that may be non-ASCII (a `substring` of an unknown text, a join with a
non-ASCII literal) is a scalar. The semantic type stays `String`; neither tier
is a source type. Selection stays categorical: no use count, no profitability
score, no demand suppression.

**Status.** Implemented, tested and measured on branch
`claude/cool-allen-564579`; **not merged to `main`**. Without the demand rule
(next section) it regresses several corpus programs and 9 existing
allocation/NIR-shape pins fail; with the rule (the default) four of the
regressions are gone, one program (`string_replace`) still regresses by +85 %,
and the 8 allocation pins pass again (see *The demand rule* and *Open
decision*).

## Packed ASCII layout

```
bit 63 ............................................ bit 0
 byte 7    byte 6   ...   byte 1    byte 0
 0x80|c7   0x80|c6        0x80|c1    0x80|c0      (absent bytes are 0)
```

Byte `i` is `0x80 | c` for the character `c` at index `i` and `0` past the end.
The otherwise-unused eighth bit of every ASCII byte is a **presence flag**; the
eight flags are a thermometer code for the length, so **no separate length
field exists and none is needed**:

| need | how | cost |
|---|---|---|
| length | `(71 - clz(w)) >> 3` (the highest set bit of an n-character word is bit `8n-1`; `w = 0` gives 0) | `clz`, `isub`, `ushr` |
| equality | word equality (the form is canonical: equal Strings have equal words) | one `icmp` |
| empty String | `0` | constant |
| NUL character | a *present* `0x80`, never "absent" | no special case |
| String bytes | `w & 0x7F7F7F7F7F7F7F7F`, one 8-byte store, truncated to the length | one `and` + one store |
| to ShortString1 (<= 1 char) | `w == 0 ? -1 : w & 0x7F` | `select` |
| equality with a ShortString1 `s` | pack `s` (`-1 -> 0`, ASCII `c -> 0x80|c`, else `1`, a word no canonical value equals) and compare words | a few `select`s |

Layouts considered for the spare bits:

* **Presence flag per byte (chosen).** Length costs three operations, but
  unpacking (the frontier cost) is a single `and`, equality is one compare, and
  the empty and NUL cases need no special handling. All eight characters fit.
* **7-bit packing plus a 4-bit length field** (60 bits). Length would be one
  shift, but unpacking needs a shift and mask per character (or `pdep`, which
  is not baseline x86-64) -- and unpacking is what the regime pays at every
  tagged use.
* **A length field next to 8-bit bytes.** Impossible: eight characters already
  fill 64 bits.

SIMD was not used: the unpack is already one scalar `and` and one store, so a
vector path would add a dependency without removing work.

Canonical form is enforced: the NIR validator rejects an `asciilit` whose
bytes are not "present, contiguous from byte 0, rest zero".

## ShortString1 (tier B), unchanged but for materialization

One signed i64: `-1` Empty, `0 .. 0x10FFFF` the scalar (U+0000 is `0`).
Extraction from a tagged String is still the two loads and a `select`. What
changed: **there is no interned table.** `shorttostr` allocates a fresh String
by UTF-8 encoding the scalar (`rt_short_to_str`), `asciitostr` allocates by
unpacking the word (`rt_ascii_to_str`). A value the compiler knows statically
(a literal) materializes to a `str` constant exactly as before and never reaches
the runtime. The `Vm.short_cache` field, its 257 interned objects, the inline
probe and `VM_SHORT_CACHE_OFFSET` are gone.

## The proof

The fact lattice is a product of a character-count range and an ASCII bit:

```
never | over:WHY | {lo hi asc known}     lo..hi <= 8 characters, asc 1 when all
                                         ASCII, known = the scalar of a
                                         one-character value
```

Join is the least upper bound (min lo, max hi, asc and, `known` kept when
equal). A join no tier can represent is `over` (more than 8 characters, or more
than one character not proven ASCII). Tier of a fact: `ascii` when `asc` and
`hi <= 8`; else `short` when `hi <= 1`; else none. ASCII-ness has **one source:
a literal's text** (and its transport through aliases, joins and exact closed
calls); a `substring` of a text says nothing about the text's alphabet, so a
slice is a ShortString1. The existing composition (aliases, dead branches via
`hir::range`, the induction width of `substring(t, i, i + K)`, closed-instance
parameter/result fixpoints, `hir::construction` exclusion) is unchanged; no new
String-length inference was added, and `concat` is not a producer.

`-ascii-pack-opt 0` (`BOTLISH_NATIVE_ASCII_PACK_OPT=0`) turns tier A off: one
character is then a ShortString1 and nothing longer is virtual (the first
milestone's regime, minus the table). `-short-string-opt 0` turns everything
off and reproduces the tagged Strings.

## NIR, ABI, backend

* A third physical kind: `asciiregs=`, `asciiparams=`, `asciiresult=1`,
  `asciilit W`, and ops `strtoascii`, `asciitostr`, `asciilen` (a raw Int),
  `asciieq`, `asciitoshort`, `asciishorteq`. The validator keeps the kinds
  distinct from tagged, RawInt and ShortString1 (a register is in at most one
  scalar kind, a result is of one scalar kind, a call's arguments and result
  must match the callee's physical signature, `asciishorteq` takes
  `(ascii, short)` in that order).
* Closed instances only; the generic-entry wrapper converts with
  `rt_str_to_ascii` / `rt_ascii_to_str` and is exercised by Rust tests.
  Error-capable packed results return `(value, status)`; the empty word `0` is a
  successful value, never a failure.
* Packed registers are non-root scalars (`scalar_regs`).
* Conversions are cached per region in the existing `rawCache` (so branch
  scoping is inherited); the one cross-tier conversion is ascii -> short
  (`asciitoshort`, or a `shortlit` for a literal), valid because the plan only
  puts a value in a ShortString1 position when its join has at most one
  character.
* `length` and `==` on proven-small operands are scalar ops for any tier
  combination; every other consumer (storage, general String operations,
  hashing, FFI, a dynamic call, a capture) materializes once per region.
  `strtoascii` is a non-allocating helper call (an inline load of eight bytes
  could overrun the allocation).

## Tests and verification

| check | result |
|---|---|
| `tests/packed-ascii.test` (new) | 47 tests, all pass: plan/proof, 8/9-character boundary, NUL/DEL/U+0080, tier joins and widening, mixed equality, errors, GC stress, standalone executables, differential parity across every backend and every switch combination (4 backends x short-opt x pack-opt x inlining) |
| `tests/short-string.test` | 59 tests, all pass, now with the ASCII tier off (they pin the ShortString1 tier) |
| Rust unit tests | 104 + 28 pass (new: packed layout/length/canonical form, round trips, NIR kind validation, generic-entry wrappers) |
| differential fuzz with the demand rule (same seeds; the outcome set now also varies the rule) | see `out/fuzz-demand*.txt`: 1,471 + 491 under GC stress + 291 with specialization off, **0 disagreements** |
| differential fuzz (generator extended with ASCII 2..8, NUL/DEL, the 9-character and non-ASCII multi-character controls) | 1,471 programs + 491 under GC stress + 291 with specialization off: **0 disagreements** |
| full `tests/all.tcl`, two passes, before the demand rule | 3,830 / 3,839 and 3,826 + 4 skipped / 3,839; the same 9 tests fail in both |
| full `tests/all.tcl`, two passes, with the demand rule | 3,855 / 3,856 and 3,851 + 4 skipped / 3,856: only `native-validator-predicate-known-result-nir-shape` failed, because the length it counts is now `asciilen`; its pin now runs with the switch off and passes |
| first-milestone counterfactual (`short-first-recovered`) full suite, clean worktree | 3,792 / 3,792 and 3,788 + 4 skipped, 0 failed |

The 9 failing tests are real consequences of the regime, not miscompiles: six
`ht-alloc-*` and two `csv-records-alloc-readback-*` allocation counts (literal
keys of at most 8 characters are now packed and every runtime materialization
allocates) and `native-validator-predicate-known-result-nir-shape`. They have
been left failing deliberately rather than adapted with `-ascii-pack-opt 0`,
because adapting them would hide the regression below.

## The demand rule

The struct scalar-replacement precedent -- a value all of whose uses
materialize it is not virtualized -- applied to String positions
(`-short-demand-opt`, default on; `BOTLISH_NATIVE_SHORT_DEMAND_OPT=0` or
`-short-demand-opt 0` restores the categorical behavior).

A candidate position -- a closed instance's String parameter or result that
has a tier, or a local `bind` that has a tier and that lowering would keep in a
register -- stays virtual only if it has at least one **free use**:

* a scalar consumer: `length(x)` or `x == y` whose operands could both be
  scalars (a literal, a reference, a call with a candidate result, or a
  one-character `substring`), and which is not taken by the String-region forms
  of `length`/`==` first;
* a flow into another position that is itself virtual and useful: an argument
  of a virtual parameter, the value of a virtual result (a `return` or the
  function's trailing value), the value of a virtual local, directly or through
  a branch join.

A position with no free use keeps the tagged String (reason `no-scalar-use`).
Usefulness is the **least fixpoint** of "has a free use", so a cycle of pure
forwarding (a function that only passes its String to itself, a forwarding
chain ending in a `list_append`) never justifies itself. Uses the walk does not
understand are not free, so the rule can only turn a position tagged, never
invent a scalar. Two lowering facts are folded in so the rule matches what the
code generator will actually do: a call that lowering turns into a String-region
companion (tagged arguments, no scalar result) is not a flow, and a local the
String-region analysis keeps as a region is never a candidate. (The first
version missed the companion case and still packed a literal-fed `text`
parameter that a region-producing helper then re-materialized every loop
iteration.)

Implementation: `native::shortstr::ApplyDemand`, `DemandWalk`, `PotNatural`
(`native/shortstring.tcl`), with lowering supplying one callback
(`native::lower::DemandCallTagged`) and consulting `localVirtual` in `Bind`.
`tests/short-demand.test` (17 tests) pins parameters, equality, forwarding
chains and cycles, results, locals, ShortString1, the region-companion case and
the switches; the representation pins in the other two files run with the rule
off, and every parity test covers both settings.

Instruction counts, all configurations (`out/ir-demand.txt`; `nd` = tiers
without the rule, `new` = with it; percentages against the pre-milestone
commit):

| program | m1 (table) | nd | **new** |
|---|---:|---:|---:|
| refined-checks | +1.7 % | +42.8 % | **+0.7 %** |
| source-checks | -10.0 % | +37.0 % | **+0.5 %** |
| hashtable | +0.1 % | +71.6 % | **+0.1 %** |
| csv_records | +0.1 % | +6.1 % | **-0.1 %** |
| ai_text_clean | -64.5 % | -54.0 % | **-54.0 %** |
| uri-steady | -16.6 % | -2.6 % | **+0.3 %** |
| string_replace | +0.4 % | +99.4 % | **+84.6 %** |
| lex-strategy, test-selection | | -0.6 %, -0.3 % | same |
| csv, csv_chunked, csv_geometric, string_reverse | | | within +0.7 % |
| fib, loop-count, sum-refined, matmul | | | unchanged |

What the rule does and does not do:

* It recovers `refined-checks`, `source-checks`, `hashtable` and `csv_records`
  to baseline: in each, the virtualized positions had no scalar consumer, so
  every use materialized them (round trips and literal-fed parameters).
* It keeps `ai_text_clean` (-54 %): the scalar equalities are free uses.
* It gives back `uri-steady`'s small gain (-2.6 % -> +0.3 %): that gain was an
  avoided producer allocation (the slice), which a use count cannot see.
* **It does not fix `string_replace` (+84.6 %).** Its packed parameters each
  have at least one scalar use (`length`, seven of them) and so stay virtual,
  but they are also materialized 35 times at about 290 instructions each while
  a scalar `length` saves a few. "At least one free use" is the wrong threshold
  there; the fix is an allocation-weighted model (benefit = avoided producer
  allocation + scalar-consumer savings, cost = runtime materializations, static
  literals free), not implemented.

## Results (corpus: 17 programs, 233 functions)

Callgrind instructions per steady-state run, `audit/short-string/out/ir-tiered.txt`
(`base` = parent of the first milestone, `m1` = first milestone as shipped with
its table, `b` = this tree with the ASCII tier off, `new` = defaults):

| program | base | m1 | b (no table) | new (tiers, no table) | new vs base |
|---|---:|---:|---:|---:|---:|
| refined-checks | 6,778,650 | 6,891,968 (+1.7 %) | 9,678,378 (+42.8 %) | 9,679,122 | **+42.8 %** |
| source-checks | 73,598 | 65,982 (-10.4 %) | 100,307 (+36.3 %) | 100,307 | **+36.3 %** |
| uri-steady | 42,726,040 | 35,661,990 (-16.5 %) | 41,651,531 (-2.5 %) | 41,651,531 | -2.5 % |
| ai_text_clean | 187,330 | 66,521 (-64.5 %) | 86,180 (-54.0 %) | 86,180 | -54.0 % |
| csv_records | 99,551 | 99,557 | 99,270 | 105,876 | **+6.4 %** |
| hashtable | 11,727 | 11,741 | 11,741 | 20,116 | **+71.5 %** |
| string_replace | 12,039 | 12,072 | 13,442 | 23,959 | **+99.0 %** |
| fib, loop-count, sum-refined, matmul | | | | | unchanged |
| other (lex-strategy, test-selection, csv, csv_chunked, csv_geometric, string_reverse) | | | | | within +/- 0.9 % |

Two separable causes:

1. **Removing the table** (`m1` -> `b`). A runtime materialization is now two
   allocations, about **315 instructions** (`short_to_string` + `new_str_known`
   + `Vm::alloc` + two `malloc`s; measured on `refined-checks`: +2.9 M for 9,070
   round trips). `uri-steady` goes from -16.5 % to -2.5 %, `ai_text_clean` from
   -64.5 % to -54 %, `refined-checks` from +1.7 % to +42.8 %, `source-checks`
   from -10.4 % to +36.3 %.
2. **The ASCII tier** (`b` -> `new`). Literal-fed parameters of 8 characters or
   fewer are packed, and a callee that uses them as a String materializes
   them at every call -- and, in a self-tail loop, every iteration (the NIR of
   a `count_a(text, ...)` over literal text has `asciitostr` inside the loop
   body). The value was a free `str` constant before; there is no producer
   saving to offset the allocation. `hashtable` +71 %, `string_replace` +78 %
   over `b`, `csv_records` +6.6 %.

What materializes at run time (single run per program; one scratch build with
counters, not committed). Tier A is statically proven ASCII; tier B is
"at most one character, not proven ASCII" and splits by what the scalar turned
out to be:

| program | tier A (packed, by length) | tier B total | B: ASCII | B: Latin-1 non-ASCII | B: BMP | B: astral |
|---|---|---:|---:|---:|---:|---:|
| uri-steady | - | 14,000 | 12,500 | 500 | 1,000 | 0 |
| refined-checks | 3 (len 3) | 6,803 | 6,403 | 400 | 0 | 0 |
| source-checks | - | 84 | 72 | 12 | 0 | 0 |
| ai_text_clean | - | 48 | 48 | 0 | 0 | 0 |
| string_replace | 35 (len 0:3 1:9 2:2 3:11 4:5 6:5) | - | | | | |
| hashtable | 22 (len 2:1 3:12 4:6 5:1 7:2) | - | | | | |
| csv_records | 15 (len 3:3 4:12) | - | | | | |

Of 20,935 tier-B materializations, **19,023 (91 %) are in fact ASCII** but
cannot be proven so (they come from `substring` of an unknown text), and
1,912 (9 %) are non-ASCII (Latin-1 and BMP; none astral). 75 are proven ASCII
(tier A). No materialization is of a value *statically* known to be non-ASCII
(known literals are constants).

Other measurements (`out/*-tiered.txt`): corpus machine code 101,879 ->
102,950 bytes (+1,071, +1.05 %; first milestone +544); safepoints 595 -> 619,
root candidates 1,276 -> 1,223, root slots 807 -> 788; census (`census-tiered.txt`):
154 positions examined, 50 given a tier (22 ASCII, 28 ShortString1), 28 of 107
parameter positions and 6 of 26 result positions selected, **22 packed
parameters against 8 scalar `length` uses and 15 `asciitostr`**.

**Wall-clock** (`nativebench`, one quiet run, off versus on; tiny kernels are
noisy, but the directions match the instruction counts): `refined-checks`
+69 %, `source-checks` +42 %, `uri-steady` -3.3 %, `ai_text_clean` -35 %,
`csv_records` +8 %, `hashtable` +79 %, `string_replace` +159 %, the other CSV
programs within +/-3 %.

**Compile time** (`compiletime-tiered.txt`, corpus total, median of 5): planner
140 ms (7 fixpoint rounds at most), NIR 2,317 -> 2,406 ms (+3.8 %), whole
compile including Cranelift 2,499 -> 2,633 ms (+5.3 %); the first milestone
measured +1.7 % to +8.8 % on different runs, so this is within the spread.

## Cost of a materialization

Where the "about 315 instructions" goes, measured two ways
(`audit/short-string/tools/materialize-cost/`).

**In the corpus, allocation side** (`refined-checks`, 9,067 runtime
`shorttostr` per run; the program with the materializations minus the same
program without them, function by function, callgrind exclusive Ir):
**311.6 Ir each**.

| part | Ir | share |
|---|---:|---:|
| glibc `malloc` (two per String: the `StrObj` and the text `Box<str>`; `_int_malloc` 70 + `malloc` 68) | 140.2 | 45 % |
| runtime code | 126.7 | 41 % |
| of which `Vm::alloc::<StrObj>` (register, account, `Box::new`) | 40.5 | |
| `short_to_string` (char -> `String`, encode) | 32.7 | |
| `new_str_known` (length check, `StrObj` construction) | 32.2 | |
| `rt_short_to_str` (metrics, call) | 11.3 | |
| other inlined glue | 10.0 | |
| Rust allocator shims (`__rdl_alloc`, `__rust_alloc`, no-alloc shim) | 25.5 | 8 % |
| `memcpy` (text copy into the new `Box<str>`) | 12.1 | 4 % |
| GC registration/sweep bookkeeping inside the window | 4.5 | 1 % |
| everything else (slice work the materialization replaced, net) | 2.6 | 1 % |

No GC collection runs inside these short measured windows, so the **free side
is not in 311.6**.

**Whole life cycle in a churn heap** (a loop that materializes U+0061 and drops
it, 20,000 -> 40,000 iterations, control loop subtracted): **862 Ir** per
materialization: about 500 on the allocation side (glibc `malloc` ~250, runtime
code ~190, Rust shims ~44, `memcpy` ~16) and about 360 on the free side
(`_int_free` 168, `free` 56 + 22, `malloc_consolidate` 50, `unlink_chunk` 32,
`free_object` 22, collect ~8). The free-side figures depend on glibc's
allocator state (tcache/fastbin/consolidation), so 862 is a pure-churn
worst case and a long-running program with a similar churn rate pays between
the two figures; the demand rule's cost model should use the larger.

What is removable without a storage redesign: the intermediate `String`
(`c.to_string()` then `into_boxed_str`, about 12 + 17 Ir) and the metrics call
(about 8); what is not: the two allocations (`malloc` ~140 plus shims ~25 on the
way in, most of the free side on the way out). A single-allocation small String
(text inline in `StrObj` for up to 8 bytes) would remove one `malloc`, its
shim, its free and the `memcpy`: roughly 40 % of the allocation side and
about half of the free side.

## Open decision

The regime as specified is net-negative on this corpus without a rule that
keeps a position tagged when virtualizing it costs more than it saves. The
losses are all "materialization-dominated positions": a literal-fed packed
parameter with only String uses, or a one-character parameter that goes in as a
scalar and comes straight back out. A use-based rule like the struct
scalar-replacement one (do not virtualize a value all of whose uses
materialize it) would remove most of them; an allocation-weighted opportunity
cost model (benefit = avoided producer allocation + scalar-consumer savings,
cost = runtime materializations, with static literals free) would keep the
positions that still pay (`uri-steady`, `ai_text_clean`). Neither is
implemented. Separately, a larger lever is static ASCII proof for
`substring` results of known-ASCII text (91 % of tier-B materializations are
ASCII) -- not attempted, per the "no new String-length inference" scope.

## Reproducing

```
cargo build --release --manifest-path native/Cargo.toml
LANG=C.utf8 LC_ALL=C.utf8 tclsh9.0 tests/packed-ascii.test
LANG=C.utf8 LC_ALL=C.utf8 tclsh9.0 tests/short-string.test
tclsh9.0 audit/short-string/tools/ir2.tcl BIN BASE-BIN BASE-NIR-DIR M1-BIN M1-NIR-DIR OUTDIR
tclsh9.0 audit/short-string/tools/{corpus,census,codesize,roots,compiletime,nativebench}.tcl
tclsh9.0 audit/short-string/tools/fuzz.tcl -n 1500 -seed 1
```

Audit builds must be made from inside the repository checkout so the root
`.cargo/config.toml` (frame pointers, needed by the native stack-map GC walker)
applies; a copy of the crate built elsewhere panics in `rt_construct` on
allocation-heavy programs.
