# ShortString1: a one-i64 physical representation of Strings of at most one character

## Outcome

A Botlish `String` value whose existing frontend facts prove a semantic
character length `<= 1` may be represented physically as **`ShortString1`**:

```
Empty
or
one Unicode scalar value
```

rather than as a materialized, tagged String object. Concretely it is **one
signed `i64`**: `-1` is Empty, `0 .. 0x10FFFF` is the one scalar value of a
one-character String. U+0000 is `0`, a one-character String, never Empty.

The semantic type remains `String`. `ShortString1` is not a source type and is
not visible to user code. NIR records the physical representation explicitly
(`shortregs=`, `shortparams=`, `shortresult=1`, `shortlit`, `strtoshort`,
`shorttostr`, `shortlen`, `shorteq`, `strsliceshort`) as a kind distinct from a
tagged String and from a `RawInt`. Exact, closed parameter and result positions
transport it directly, and a local binding, alias or branch join keeps it in
one register; open/dynamic boundaries, storage and the general String
operations retain the canonical String representation. **A real String is
materialized only where an operation actually requires one**, once per value
and region (the conversion is cached in the same cache the RawInt conversions
use).

The selection is **categorical**: *proven length <= 1 => ShortString1.* There
is no profitability score, no use count, no demand suppression and no backend
cost; mixed scalar/tagged uses materialize at the tagged use and are measured,
not suppressed. The resulting frontiers are the evidence for the later
struct-style heuristic (see *Future frontier heuristic*).

What was measured over the canonical corpus (17 programs, 233 functions):

* **Correctness.** Optimization on and off agree on every corpus value, in
  differential parity (every backend, leaf inlining on/off, ShortString1
  on/off), in 2,253 randomly generated programs (1,471 + 491 under GC stress +
  291 with specialization off; **0 disagreements**), in the 59 tests of
  `tests/short-string.test`, and in the full existing regression
  (interp 3,789/3,789, compile 3,785 + 4 skipped, native coverage, Rust 90 + 26, whole suite under GC stress 3,792/3,792 and 3,788 + 4 skipped, bench and corpus parity).
* **Whole-corpus machine code: 101,879 -> 102,423 bytes (+544, +0.53 %).**
  Only programs that use the representation change; `ai_text_clean` shrinks by
  608 bytes (-19.7 %), the CSV family and `string_replace` grow by 137-158
  bytes (the inline frontier conversions, below), nothing else changes.
* **Dynamic instructions (callgrind Ir per steady-state run), optimization on
  versus the parent commit:** `uri-steady` **-16.56 %** (-7,076,968),
  `ai_text_clean` **-64.50 %** (-120,865), `source-checks` **-10.27 %**
  (-7,546); `refined-checks` **+1.70 %** (+115,377), of which +66,228 is the
  mixed-use frontier this milestone exists to expose (a one-character
  parameter consumed only by tagged operations) and +49,149 is a runtime cost
  paid with the optimization off (see *Dynamic instruction results*); every
  other program within +/-0.8 % and the five programs without Strings exactly unchanged.
* **GC.** A ShortString1 is a non-root scalar (`shortregs`, excluded from the
  root analysis exactly like `rawregs`); corpus root candidates 1,276 -> 1,257,
  root slots 807 -> 799, safepoints 595 -> 600. Pinned under GC stress in the
  tests, a 491-program fuzz run and the full suite.

Files: `native/shortstring.tcl` (the proof query, planner, audit),
`native/lower.tcl` (plan storage, physical signature, short wants, local /
alias / join / ABI lowering, conversions, scalar consumers),
`native/src/nir.rs` (`RegKind`, header attributes, ops, kind validation,
19 unit tests), `native/src/codegen/clif.rs` (physical signature, prologue,
generic-entry wrapper, inline conversions), `native/src/codegen/roots.rs`
(scalar registers, 2 unit tests), `native/src/runtime/{ops,vm,value,heap}.rs`
(three helpers, interned Latin-1 materialization, first-scalar field, 4 unit
tests), `native/explain-native.tcl` (`short-string.txt`),
`tests/short-string.test` (59 tests), `audit/short-string/` (tools and
measured output).

## Motivation

A Botlish String object carries a header, a character count, an ASCII flag and
a boxed text. A String the compiler can already prove has at most one
character is "a real String object carrying a lot more representation than the
value semantically requires": `peek(text, i)` (`""` past the end, otherwise
`substring(text, i, i + 1)`) is the corpus idiom, and the equality tests
against single-character literals that follow it (`ai_text_clean`'s 19
emoji/punctuation comparison sites, `csv`'s `"\""` and `","`) were each a
`regioneq`/`streq` helper call, with a one-character String allocated by the
`peek` that produced the character wherever it was not consumed as a
StringRegion.

The starting point is exactly the RawInt lesson applied to a second
representation: keep a value in the cheapest physical form its proof allows,
across aliases, joins and exact calls, and convert only at the frontiers.
Unlike RawInt this milestone deliberately **does not** begin with a demand or
profitability model.

## What one Botlish "character" is (settled, not assumed)

A String character is a **Unicode scalar value**: the native runtime's String
is a Rust `str` (`StrObj::chars` counts scalars; `length` and `substring`
index by it), and the reference interpreter's is a Tcl 9 string (`string
length` counts code points, astral ones included). It is not a UTF-8 byte, not a
UTF-16 unit and not a grapheme cluster (`string_reverse.bot` documents that a
base letter plus a combining mark is two characters).

* **Highest legal value: U+10FFFF** (`MAX_SCALAR`, `0x10FFFF`).
* **Surrogates (U+D800..U+DFFF) are not representable in a Botlish String.**
  Rust `str` cannot hold one, a surrogate in UTF-8 source is rejected when the
  file is read (`error reading ...: invalid or incomplete multibyte or wide
  character`), and `UnicodeChar` excludes them by definition. The planner
  additionally refuses (`over:unknown`) a one-character literal whose scalar
  is a surrogate or above U+10FFFF, so it could never encode one.
* **Multi-byte UTF-8 characters are one character.** "ä", "€", "λ", "猫" and
  "😀" are one semantic character and one scalar each: eligibility is decided
  on character count, never on encoded length (`short-unicode-model-*`,
  `short-plan-non-ascii-branch-join`, `short-slice-non-ascii`).
* **NUL (U+0000) is a legal one-character String.** The surface language has
  no `\0` escape; a raw NUL in a source literal is read and kept
  (`short-nul-is-not-empty`).

## Semantic proof inputs

**No existing analysis states a String length bound as a fact**, and this
milestone adds none (hard stop of the brief). What exists, and is composed by
`native::shortstr::Fact` (a pure query, `native/shortstring.tcl`):

| input | read as |
|---|---|
| a String literal (`const`) | its text: length 0 -> Empty, 1 -> `one:N`, more -> `over:long` |
| an immutable local alias chain (`bind`/`ref` of a single-assignment binding of the instance's own region) | the bound value's fact (aliases need no flow analysis) |
| `hir::range::ConditionOutcome` and the instance view's `reachable` flags | a branch the existing analyses prove dead contributes `never` (no new reachability analysis; a dead long-String branch never forces a conversion: `short-plan-dead-long-branch-does-not-poison`) |
| `hir::induction::ClassifyArg` (the existing `index + K` step classifier `hir/traversal.tcl` uses to recognize `peek`'s `substring(text, index, index + 1)`) and `hir::exact::IntOf` | `substring(t, s, e)` succeeds with exactly `e - s` characters: `{step 0}`/`identity` -> Empty, `{step 1}` -> one character (scalar unknown); both operands exact -> their difference |
| `hir::specialize` closedness and the call-target map | a closed instance's parameter is bounded by the join of its reachable callers' arguments; a call's value by the callee's result fact |
| `hir::escape::Exits` | the exits of an instance (every reachable `return` and its trailing value, self-tail back edges excluded), joined into its result fact |
| `hir::construction` | a position already carried as a virtual-construction plan keeps that representation (`construction-plan`): two virtualizations never claim one position |

The fact lattice is five points plus the unproven top (height 5, so the
call-graph fixpoint is finite):

```
never                 no value (dead code / cannot complete)
empty                 exactly 0 characters
one:N                 exactly 1 character, scalar N known
one                   exactly 1 character, scalar unknown
maybe                 0 or 1 character          (the case the Empty encoding is for)
over:WHY              more than one character, or unknown
```

Join is the least upper bound; `over` absorbs and keeps its first reason
(`long`, `unknown`, `open-instance`, `not-string`, `disabled`). Parameters and
results are least fixpoints from `never` (monotone chaotic iteration, no
special case for recursion).

**Missed opportunities, recorded and not pursued** (proof improvements are a
separate milestone): a branch-derived fact from `if length(s) <= 1`;
`lowercase(s)` and `concat("", x)` (length-preserving) as producers; a
`list_get` of a `List[str]` of one-character literals; per-position facts
through a struct field; `csv`'s `delimiter`-style locals whose *every* use is
an equality are already allocation-free as StringRegions, so ShortString1
correctly does not compete with them; `lex-strategy`'s token Strings (callers
pass literals of several lengths, so the join is `over:long`).

## Physical representation

```
ShortString1 = i64
   -1                 Empty
   0 .. 0x10FFFF      the one character's Unicode scalar value (never a surrogate)
```

Admissible domain: `{-1} union ([0, 0x10FFFF] minus [0xD800, 0xDFFF])`.
`nir.rs` rejects a `shortlit` outside it at parse time.

### Why one i64 is sufficient

The logical state space is `Empty | One(scalar)`, a sum of a unit and a
21-bit-wide value. The scalar domain needs 21 bits, so one machine word holds
the discriminant and the payload with room to spare; **no second word and no
presence bit are needed**. Scalar/Empty equality is word equality because both
encodings are canonical, and `length` is `(w != -1)`.

### The Empty encoding

`-1` is Empty. It can never collide with a valid one-character String because
every valid scalar value is non-negative, so `-1` lies outside the scalar
domain. **U+0000 is `0`** and pinned as a one-character String by
`short-nul-is-not-empty` (length 1/0, `== ""` false/true, equality with the
NUL literal) and the runtime tests (`short_encoding_is_the_scalar_value_and_
empty_is_minus_one`).

**Empty is a value, never an error sentinel.** An error-capable function with a
ShortString1 result uses the repository's existing completion convention for
scalar results (`(value, status)`, status `0` = an error is pending, `1` =
success; a function that cannot fail returns the bare scalar). `-1` is never
overloaded for failure: `short-error-capable-result`,
`short-error-in-the-caller-handler`, `short-slice-empty-index-error-is-
unchanged`.

## Eligibility

A local value is eligible iff its fact is not `over`/`never`. A parameter
position (resp. the successful result) of instance `I` is a ShortString1
position iff

1. its semantic type is String (key type `str` / result kind `str`),
2. `I` is **closed** (`InstanceClosed`, the same closedness `RawInt` reads: so
   no unknown caller can hand the entry a tagged String it does not expect),
3. its fact (join of every reachable caller's argument; join of every
   reachable exit) is not `over`, and
4. the position is not a virtual-construction plan position.

A result fact is valid for an open instance too (it describes the instance's
own exits): callers use it to keep a *local* value short, converting at the
call (`strtoshort` of a tagged result, a non-allocating load), while the ABI
stays tagged.

## Local virtualization

* **Bindings.** `x = <proven short>` in statement position is one short
  register for its scope (`locals x {shortreg r}`); every read is a short
  consumer's register or the one cached materialization.
* **Aliases.** `y = x`, `z = y` read `x`'s register: `Expr` of a `ref` asked
  `short` returns the same register (`short-nir-alias-stays-virtual`; the
  audit lists `alias y` / `alias z`).
* **Branch joins.** `if c: "" else: "x"` joins in one short register: each
  branch's last value is itself proven (it is below the join in the lattice),
  `MarkShort` declares the join register, no branch is materialized
  (`short-nir-result-is-a-short-register-join`; two one-character branches
  `"x"`/`"λ"` join too: `short-plan-two-one-character-branches`).
* **Constants.** A proven literal is a `shortlit` directly (`""` -> `-1`,
  `"A"` -> `65`, NUL -> `0`, `"λ"` -> `955`, `"猫"` -> `29483`, `"😀"` ->
  `128512`, U+10FFFF -> `1114111`): never `str` followed by a decode
  (`short-constants-are-generated-directly`). A literal whose short form is
  asked for the reverse direction materializes to a **String constant**, not an
  allocation.
* **Producers.** `substring(t, s, e)` whose width the planner proves `<= 1`
  lowers to the ordinary `regioncheck` (so the RANGE error and its message
  are byte-identical) followed by an infallible `strsliceshort` (no String
  allocated, the Empty encoding never a failure value:
  `short-slice-is-an-infallible-extract-after-the-ordinary-check`,
  `short-slice-bounds-error-message`).
* **Existing virtualizations win.** A binding the String-region analysis
  already keeps allocation-free (every use `==`/`length`) stays a StringRegion,
  and `ShortNatural` declines a *call* that is itself region-eligible
  (a direct `substring`, a region-producing instance) so the existing region
  NIR (`callmulti`, `regioneq`) is unchanged; ShortString1 applies where the
  region machinery does not. This is why only five existing test files needed
  `-short-string-opt 0` (below).

## Authoritative ABI planning

`native::shortstr::plan` returns one plan, `InstanceId -> {params {value|short...}
result value|short paramReasons resultReason closed paramFacts resultFact}`,
computed **once** in `native::lower::program`, after the closedness, Range and
virtual-construction analyses and before any lowering, and stored in
`native::lower::shortPlan`. The callee's lowering (`Function`) and every exact
caller (`Call`, through `ShortAbiParams`/`ShortAbiResult` merged into the same
slot list `RawInt` uses: `0` tagged, `1` raw Int, `short` ShortString1) read it;
**nothing decides shortness at an individual call instruction**. Planning:

```
specialize (closedness) -> range -> RawInt plan -> escape/stringregion/
blockescape/traversal/construction -> ShortString1 plan -> lowering -> Cranelift
```

It is downstream of the proof: selection removes materialization, never a check
the proof relied on, and nothing feeds back into any analysis. Only the
**canonical** function of an instance has a physical short signature;
companion, region, internal and fields variants keep the tagged ABI (they are
separate NIR functions with their own conventions), and the generic Block-value
entry always does. A variant that reads a parameter whose fact is `<= 1`
converts it at the use (`strtoshort`, cached).

### Closed instances, open/dynamic callers, the generic entry

A parameter can be short only for a closed instance; an open instance's
parameter is `open-instance` (`short-plan-open-instance-stays-tagged`). A Block
value / dynamic (`callvalue`) call always enters the tagged generic entry
(`short-dynamic-callable-stays-tagged`). `nir.rs` rejects `fnvalue`/`closure`
of a function with any scalar ABI, and `GenericRef` throws a compiler bug if
lowering would materialize a Block value of one. The generic
`botlish_entry_N` wrapper of such a function nevertheless converts defensively
(tagged String -> `rt_str_to_short`, the short result -> `rt_short_to_str`, the
status word for an error-capable result) even though it can never run.

## NIR representation

The smallest coherent extension of the existing raw-value discipline: a second
register class, declared once per function rather than inferred.

```
func 3 "pick" params=1 ... shortregs="1 2 3" shortresult=1        ; a ShortString1 result
func 4 "h"    params=1 ... rawregs="1" shortregs="0 3" shortparams="0"
    %1 = op shortlen %0           ; raw Int result (rawregs)
    %3 = shortlit 955             ; constant
    %4 = op shorteq %0 %3         ; tagged Bool
    %2 = op shorttostr %0         ; the frontier
    %5 = op strtoshort %6         ; the other frontier
    %7 = op strsliceshort %b %s %e ; after `op regioncheck`
```

`RegKind { Tagged, Raw, Short }` is derived from `rawregs=` and `shortregs=`
(`Function::kind_of`); `scalar_regs` (their union) is what codegen and the root
analysis read. `OpCode::operand_kind`/`result_kind` give each op's kinds.

**Distinct from RawInt.** Both lower to an `i64`, but they are different kinds
in NIR: no register is in both (`a register is declared both raw and short`),
a `riadd` of a short register, a `shorteq` of a raw one and a raw/short `move`
are validator errors (Rust tests `short_is_not_raw_int`,
`a_raw_argument_cannot_feed_a_short_parameter`). The common machine type is an
implementation detail.

### Validation (all treated as compiler bugs, never repaired)

* call/callenv argument `i` has exactly the callee's parameter-`i` kind, and
  the destination the callee's result kind (`tagged_argument_to_short_
  parameter_is_a_bug`, `short_argument_to_a_tagged_parameter_is_a_bug`,
  `short_destination_for_a_tagged_result_is_a_bug`,
  `tagged_destination_for_a_short_result_is_a_bug`);
* `ret` has the function's result kind (`ret_kind_must_match_the_function_
  result`); `tail` arguments have the parameter slots' kinds (`tail_arguments_
  follow_the_parameter_kind`);
* every `shortparams` position is a `shortregs` register and every short
  parameter register is a `shortparams` position; the program function cannot
  use the ABI;
* `fnvalue`/`closure` of a short-ABI function is rejected; a short value where
  a tagged Value is required is rejected (`a_short_value_is_not_a_tagged_
  value`); `shortlit` must be a short register in the admissible domain.

The text is `shortregs=`, `shortparams=`, `shortresult=1` in the function
header (a compact, deterministic encoding of the plan).

## Frontend / NIR / backend separation

```
semantic proof (shortstring.tcl: Fact)          hir::range / hir::induction / specialize facts
        |
physical plan (shortstring.tcl: plan)           one authoritative result per instance
        |
NIR contract (lower.tcl emission, nir.rs)       kinds, ops, signature, validation
        |
execution engines                                Cranelift JIT / object / standalone executable
```

* No String proof is in Cranelift; the backend receives "this register is a
  ShortString1" and lowers it to an `i64` that is never a GC root. A future LLVM
  AOT backend consumes the same plan and NIR contract; it would implement the
  five ops and the kind, and change neither the proof nor the plan.
* **Interpreter parity.** There is no NIR/bytecode interpreter in the
  repository: the semantic interpreter and the Tcl compile backend execute the
  reference semantics from HIR/Core IR, so they cannot consume the new kind.
  Every behavioral test and the fuzz run the interpreter beside native and
  require equal values, errors and completion behavior.
* **What Cranelift receives.** `shortlit` -> `iconst`; `shorteq` -> `icmp eq` +
  Bool select; `shortlen` -> `icmp ne -1` + `uextend`; `strtoshort` -> two loads
  and a `select` (inline); `shorttostr` -> an inline probe of the interned
  static table (a helper only on a cold slot or a scalar above U+00FF);
  `strsliceshort` -> a non-allocating helper. A short parameter/result is an
  `i64` like any other: the parameter signature is unchanged and a short-result
  function that can fail returns two words (value, status), exactly as RawInt.

## Boundary conversions

| conversion | NIR | cost |
|---|---|---|
| tagged String -> ShortString1 | `op strtoshort` (or a `shortlit` when the tagged register is a literal this lowering built) | total, non-allocating; two loads and a `select`. No "reject length > 1" check: the frontend theorem is the proof (the runtime helper `debug_assert`s it) |
| ShortString1 -> tagged String | `op shorttostr` (or a static `str` constant when the register is a known literal) | inline probe of `Vm::short_cache`; Empty and U+0000..U+00FF are interned static Strings built once (no allocation, never collected); any other scalar allocates one String |

Both directions are cached together with the RawInt conversions
(`fn rawCache`, a register-number-keyed dictionary scoped like `locals` by `If`
and loops): a value converts once per region, the reverse conversion of a
value just extracted is the original register again, and a materialization
repeated in one region is a cache hit. The census below finds **no short value
materialized more than once** (0 of 52 registers).

`ShortToStr` materializes **exactly** the original String, never lossy: Empty ->
`""`, `One(U+....)` -> the one-character String of that scalar, including
non-ASCII (`short_round_trips_every_character_class`: `""`, `"a"`, NUL, `"é"`,
`"λ"`, `"猫"`, `"😀"`, U+10FFFF, U+D7FF, U+E000).

## Continuous virtual regions

```
tagged / general String world
   -> extract or produce ShortString1 once (a literal, a slice, a short call result, a param)
   -> continuous scalar region (alias, join, exact call, scalar consumer)
   -> materialize once at the first consumer that needs a real String
```

* Exact chain `pick -> f -> g -> h`: every position is `short` and **no
  function** contains `strtoshort` or `shorttostr` (`short-nir-chain-is-one-
  continuous-region`).
* A short result returned through a short result ABI is not `scalar -> String
  -> return -> scalar` (`short-nir-return-stays-virtual`).
* Tagged frontier: one producer forwarded through two exact calls and stored
  in a List costs **one** `shorttostr`, in the storing function, not one per
  transport edge (`short-nir-tagged-frontier-materializes-once`).
* A short String carried around a self-tail loop is a short parameter slot:
  `tail` passes a short register, no conversion per iteration, no special loop
  logic (`short-nir-loop-state-stays-scalar`; `RawParams`' loop slot
  discipline, extended through `SlotKind`).
* The program's externally visible result is a String on the canonical
  representation, so a final ShortString1 materializes once at the program
  frontier (`short-nir-program-frontier`).

## Supported scalar consumers

| operation | lowering |
|---|---|
| `length(s)` | `shortlen` (Empty 0, One 1), a raw Int; no String traversal |
| `s == ""`, `s == "x"`, `s == t` (both proven short) | `shorteq`: scalar equality (`Empty == Empty`, `One(a) == One(a)`, nothing else); against a literal it is the same op with a `shortlit` operand |
| `substring(t, s, e)` with a proven width `<= 1` | producer: `regioncheck` + `strsliceshort` |
| exact call argument / result, `return`, `tail`, alias, join | the register itself |

**Equality against an unrestricted String** does not redesign String equality:
the short operand materializes and the existing `streq` runs
(`short-equality-with-an-unrestricted-string-materializes`). If either operand
is not short-natural (it would need a fresh String produced just to be
decoded), the ordinary paths, including the String-region forms, run
unchanged. No other operation consumes a ShortString1 directly.

## Tagged materialization frontiers

Storage stays tagged: a `List`, `MutableArray`, `Hashtable`, struct field,
module static, captured closure slot, `ImmutableSet` or `ok`/`error` payload
materializes the String at that frontier (`short-storage-list-materializes`,
`short-capture-materializes`). `concat`, `lowercase`, `hash`, `is_tcl_alpha`,
`substring` of a short operand and every other String operation consume the
real String (`short-general-string-operations-materialize`); a dynamic
call's argument is materialized; FFI/native boundaries and the runtime's
program-result ABI are unchanged. Hashing is not redesigned (the existing
`hash` runs on the materialized String).

Static materialization census over the corpus (10 `shorttostr` ops):

| frontier class | count |
|---|---:|
| program frontier | 0 |
| collection/storage frontier | 0 |
| general String operation (concat / virtual-construction piece / lowercase / hash) | 8 |
| generic/dynamic call | 1 |
| tagged result (return of a tagged-ABI function) | 1 |
| FFI/native frontier | 0 |
| mixed scalar/tagged use (equality with an unrestricted String) | 0 |
| other | 0 |

(The census classifies the *first* consumer of each materialization; a value
materialized for a concat piece that is also compared scalar is a "mixed" use
of the value, and is recorded at its tagged use.)

## GC / root semantics

A ShortString1 is a **non-root scalar**. `shortregs` registers are in
`Function::scalar_regs`; `codegen::roots` filters them out of every
safepoint's root set and `def_raw` never stores them to the shadow stack, so
**no stack-map entry is ever emitted for one**, and nothing is special-cased per
parameter (a short parameter is `def_raw` in the prologue). A ShortString1 may
therefore be live across any number of allocations as a scalar in a register or
spill slot. The String it materializes to participates in rooting normally: a
`shorttostr` is an allocating op (a safepoint, `op_may_allocate`), and the
materialized register is an ordinary root while live (`roots.rs` tests
`short_live_across_allocation_is_not_a_root` and
`materialized_short_is_an_ordinary_root`).

Interned Latin-1 Strings are static objects (`is_static`, skipped by marking,
freed with the VM): materializing U+0000..U+00FF performs **no allocation and no
GC attempt**, which is also why a GC-stress run still exercises the rooting of
the allocating (non-Latin-1) and ordinary-String paths in the tests below.

Root census (`audit/short-string/out/roots.txt`; fewer roots is a side effect,
not the goal): safepoints 595 -> 600, root candidates 1,276 -> 1,257, root slots
807 -> 799. The five extra safepoints are the `shorttostr` ops (allocating in the
general case) and the calls into functions that now contain one; the candidate drop is the String values that stayed short
(e.g. `string_replace` 41 -> 35).

## Unicode behavior

Pinned by `short-unicode-model-*`, `short-nul-is-not-empty`,
`short-highest-scalar-round-trips`, `short-slice-non-ascii` and the runtime
tests: ASCII, a 2-byte (`ä`, `é`), 3-byte (`€`, `λ`, `猫`) and 4-byte (`😀`)
character, NUL, U+10FFFF and Empty all round-trip and compare identically with
the optimization on, off, in the interpreter and in native. A one-character
non-ASCII String is eligible exactly like an ASCII one; the representation is
the scalar, not a byte and not a packed ASCII word.

## Dynamic instruction results

`audit/short-string/tools/ir.tcl` runs callgrind (the repository's
`profile-nir.sh`, audit-only builds, steady-state runs, run 0 excluded) three
ways per program: **base** = the parent commit (`d51c0d3`, before the
milestone: its NIR on its own audit build), **off** = this tree with
`-short-string-opt 0`, **on** = this tree (default). Ir per run:

| program | base | off | on | on vs base | on vs off |
|---|---:|---:|---:|---:|---:|
| fib | 1,404,178 | 1,404,178 | 1,404,178 | 0 | 0 |
| lex-strategy | 312,814 | 314,020 | 314,020 | +1,206 (+0.39 %) | 0 |
| loop-count | 12,037 | 12,037 | 12,037 | 0 | 0 |
| refined-checks | 6,777,452 | 6,826,601 | 6,892,829 | **+115,377 (+1.70 %)** | +66,228 (+0.97 %) |
| source-checks | 73,492 | 73,686 | 65,946 | **-7,546 (-10.27 %)** | -7,740 (-10.50 %) |
| sum-refined | 12,435 | 12,435 | 12,435 | 0 | 0 |
| test-selection | 33,420 | 33,297 | 33,297 | -123 (-0.37 %) | 0 |
| uri-steady | 42,730,297 | 42,855,215 | 35,653,329 | **-7,076,968 (-16.56 %)** | -7,201,886 (-16.81 %) |
| ai_text_clean | 187,382 | 187,975 | 66,517 | **-120,865 (-64.50 %)** | -121,458 (-64.61 %) |
| csv | 19,631 | 19,665 | 19,685 | +54 (+0.28 %) | +20 (+0.10 %) |
| csv_chunked | 19,516 | 19,558 | 19,558 | +42 (+0.22 %) | 0 |
| csv_geometric | 19,637 | 19,679 | 19,679 | +42 (+0.21 %) | 0 |
| csv_records | 99,074 | 99,816 | 99,629 | +555 (+0.56 %) | -187 (-0.19 %) |
| hashtable | 11,727 | 11,727 | 11,727 | 0 | 0 |
| matmul | 9,240 | 9,240 | 9,240 | 0 | 0 |
| string_replace | 12,035 | 12,130 | 12,094 | +59 (+0.49 %) | -36 (-0.30 %) |
| string_reverse | 11,382 | 11,364 | 11,364 | -18 (-0.16 %) | 0 |

**Which workloads exercise the representation:** `ai_text_clean` (19 static
scalar equalities in the `character` parameters of `cleaner_emoji`/`clean_char`),
`uri-steady` (the one-character slices of `esc_from`/`esc_char`),
`source-checks`, `refined-checks`, the CSV family (`peek` as a ShortString1
result) and `string_replace` (one-character replacement literals). `fib`,
`loop-count`, `sum-refined`, `hashtable` and `matmul` have no Strings, and
`lex-strategy`, `test-selection` and `string_reverse` no provable short
String: all eight have byte-identical NIR.

**Which direct scalar operation accounts for the benefit.** `ai_text_clean`:
the `shorteq` operations replace `regioneq` (the base profile is 31.4 %
`rt_str_region_eq` and 29.3 % its `Take<Chars>` iterator: every comparison of a
`peek`'d character against an emoji/punctuation literal walked two character
iterators; the on profile has neither) across the short parameter/result chain
`peek -> clean_char -> cleaner_emoji`; `uri-steady`: `strsliceshort` replaces
`substr` (3.2 % `rt_substr` plus the `StrObj` allocation and the `malloc`/`free`
traffic of one one-character String per scanned character: `_int_malloc`
3.88 M -> 2.73 M, `malloc` 3.18 M -> 2.00 M Ir; the new non-allocating
`rt_str_slice_short` costs 0.89 M). Exact-call ShortString1 transport removes the
materialize/extract pairs the previous representation implied at every boundary:
`pick -> f -> g -> h` has zero conversions.

**Why is `refined-checks` +1.70 %?** (spec: explain, never "noise".) The
deterministic breakdown from its profile: `local_char?(c)` and `esc_char(c)`
each receive a one-character String that is *proven short at every caller* (so
the parameter is a ShortString1) but **consume it only with tagged operations**
(`is_tcl_alnum`, `immutable_set_contains`, `encode_utf8`). Every call therefore
does `strtoshort` at the caller and `shorttostr` in the callee: a round trip
`tagged -> short -> tagged` with no scalar consumer in between. That is the
mixed/tagged-only frontier the categorical rule produces on purpose (no
suppression yet) and the cleanest input for the later heuristic. Its cost
fell from +418,692 Ir (+6.18 %, conversions as helper calls: 31.5 + 9.5 Ir per
round trip x ~9,070) to **+66,228 (+0.97 %)** by implementing the two
conversions inline (the interned-table probe and the two-load extract), which
is an implementation of the NIR contract, not a heuristic. The remaining
+49,149 (0.73 %) is the **off** configuration's own cost: the String object
gained a `first` scalar field (and `Vm` a 257-slot interned table), so
every String construction does one more load/store and libc `_int_malloc`
walks a slightly different arena (`test-selection`, whose NIR is identical,
moves by -0.37 % through `_int_malloc` alone). Both are runtime-wide costs
of the representation, paid with the optimization off.

**String-heavy programs without extra work (`csv*`, `string_replace`) move by
<= +0.56 % versus base** and by <= +/-0.3 % versus off: each has one
materialization (`concat`'s piece), cheap for Latin-1 (inline probe).

### Wall-clock

`audit/short-string/tools/nativebench.tcl` (`out/nativebench.txt`): `botlish-native
bench 200` of the emitted NIR, best of 7 invocations, ShortString1 off versus on,
programs whose NIR is identical not repeated:

| program | off (ns) | on (ns) | delta | Ir on vs off |
|---|---:|---:|---:|---:|
| refined-checks | 450,763 | 536,409 | +19.0 % | +0.97 % |
| source-checks | 5,455 | 5,525 | +1.3 % | -10.50 % |
| **uri-steady** | 3,662,175 | 2,778,927 | **-24.1 %** | -16.81 % |
| **ai_text_clean** | 11,754 | 4,637 | **-60.5 %** | -64.61 % |
| csv | 1,272 | 1,313 | +3.2 % | +0.10 % |
| csv_chunked | 1,157 | 1,379 | +19.2 % | 0 |
| csv_geometric | 1,433 | 1,383 | -3.5 % | 0 |
| csv_records | 7,596 | 7,581 | -0.2 % | -0.19 % |
| string_replace | 670 | 758 | +13.1 % | -0.30 % |

The two large improvements (`uri-steady`, `ai_text_clean`) agree in direction
and size with the deterministic Ir. **The rest of the table is not evidence.**
On this shared machine the same off/on pair of a microsecond-scale kernel
varies by +/-15-20 % between *invocations* of the tool: `refined-checks` repeated
three times gave +13.3 %, +22.4 % and **-12.6 %**; `csv_chunked` -1.1 %, -8.4 %,
+16.8 %; `string_replace` +0.4 %, -5.1 %, +0.7 %; `csv` -0.4 %, -2.5 %,
+10.8 % (200-400 runs, best of 7 each). Sign flips with identical NIR and
identical machine code are measurement spread (frequency/placement/neighbors),
not a property of the representation. `refined-checks` is the one program with
a real deterministic regression (+0.97 % Ir, branch mispredictions
37,720 -> 39,312 and D1 read misses 7,891 -> 8,090 in callgrind's simulation),
a few percent at most, far below the wall-clock swing. **Does any wall-clock
anomaly lack an instruction-count/code-shape explanation?** Single-invocation
numbers for `csv_chunked` (+19.2 % with exactly +0 Ir) and `string_replace`
(+13.1 % with -0.30 % Ir) do, but repeated runs show they are not stable (see
above), so they are recorded as tiny-kernel measurement spread, **not attributed
to the frontend optimization**. No backend alignment, placement or Cranelift
setting was touched; the existing placement-sensitivity investigation (RawInt
`loop-count`) remains the tool if a stable tiny-kernel anomaly ever appears.

## Corpus code-size result

Whole-corpus machine code, optimization off -> on (`codesize.txt`): **101,879 ->
102,423 bytes (+544, +0.53 %)**, 233 functions both. By program: `ai_text_clean`
3,081 -> 2,473 (**-608**, -19.7 %); `refined-checks` +244; `string_replace` +158;
`csv`, `csv_chunked`, `csv_geometric`, `csv_records` +137 each; `uri-steady`
+122; `source-checks` +80; the other nine programs +0. The growth is the
inline frontier sequences (each `shorttostr` expands to a probe plus a cold
helper path with its stack-map entries, ~100-140 bytes per site); a program
with many scalar equalities (`ai_text_clean`) shrinks because 19 `streq` call
sites become single compares. Relative growth: `string_replace` +6.0 % (a 2.6 KB program),
`refined-checks` +2.7 %, `csv` +2.4 %, `uri-steady` +2.2 %, `source-checks`
+1.9 %, `csv_chunked` +1.3 %, `csv_geometric` +1.8 %, `csv_records` +0.6 %;
none grows pathologically, and the total is +0.53 %. The same program compiled
twice gives byte-identical NIR and the same code size (`codesize.tcl`,
`short-deterministic-plan-and-nir`).

## Conversion census

`audit/short-string/out/census.txt`. Static NIR over the corpus, **optimization
off: 0 strtoshort / 0 shorttostr; on: 1 strtoshort / 10 shorttostr** (the
tagged->short side is nearly empty because short values are produced short:
32 `shortlit`, 23 `shorteq`, 7 `strsliceshort`, 6 short results). Frontier classes: see
*Tagged materialization frontiers*. Zero short registers are materialized more
than once: 42 virtual registers with zero materializations, 10 with exactly
one, 0 with several.

## Virtualization census

| | count |
|---|---:|
| String values/positions examined (params of String-keyed instances + String results + live String locals) | 154 |
| proven length <= 1 | 30 |
| local String bindings examined / proven | 21 / 16 |
| local values virtualized as short registers | 5 |
| parameter positions (String) / selected as ShortString1 | 107 / 8 |
| result positions (String) / selected | 26 / 6 |
| instances with any ShortString1 ABI position | 14 (of 233) |
| of the proven-short positions and locals above: known Empty | 0 |
| known One (scalar statically known) | 0 |
| known One (scalar at run time) | 7 |
| runtime Empty-or-One (`maybe`) | 23 |
| String positions kept tagged: `length-gt-1` | 66 |
| String positions kept tagged: `unknown-length` | 53 |

(5 of the 16 proven locals are short registers: `source-checks`' and one `peek`
result in each of the four CSV programs. Of the other 11, 10 are `character`/
`delimiter` locals every use of which is an equality, which the String-region
analysis already keeps allocation-free, and 1 is `string_reverse`'s
`character`, a StringRegion piece of a virtual `concat`: the existing
virtualization wins by design. The static-NIR counts include the variant
(companion) functions: the CSV short locals live in the scalar-replacement
companions of the scanners.) The corpus is dominated by tagged Strings of length > 1; the
representation applies to the `peek`/`char_at` family and to literals, which is
where it measured a benefit.

## Compile-time impact

`audit/short-string/tools/compiletime.tcl` (`out/compiletime.txt`), median of 5, ms,
whole canonical corpus (sums):

| phase | ms |
|---|---:|
| `native::prepareHir` | 192.6 |
| `hir::specialize::analyze` | 465.1 |
| `hir::range::analyze` | 557.8 |
| **`native::shortstr::plan` (facts, fixpoint, plan)** | **142.3** |
| `native::nir`, optimization off | 2,240.8 |
| `native::nir`, optimization on (plan + lowering) | 2,279.6 (+38.8, +1.7 %) |
| `native::codeSize` off / on (everything, Cranelift included) | 2,370.1 / 2,579.9 |

The standalone planner row recomputes the per-instance HIR views, which
lowering also builds, so it overstates the marginal cost: what the optimization
adds to the Tcl-side compile (`nir` on minus off, planning plus the extra
lowering) is **+38.8 ms over 17 programs (+1.7 %)**; the largest workload,
`csv_records` (the largest program, 56 functions), is 800.2 -> 827.8
ms (+3.4 %), planner alone 57.6 ms. `native::codeSize` carries a few percent of
run-to-run noise (e.g. `refined-checks` 375 -> 468 ms is the machine, its
`nir` times are 373.1 vs 366.0). The initial policy is linear in the facts
already traversed: one liveness walk per instance, a chaotic iteration over a
height-5 lattice (1-7 rounds per corpus program, median 3, each a memoized walk
of the same expressions), no path enumeration, no combinatorial search and no
per-call ABI variants.

## Differential testing

* **Behavioral tests** (`tests/short-string.test`, 59): every one runs the
  interpreter, the Tcl compile backend, `cranelift-generic` and `cranelift`
  on the four backends plus native with `-short-string-opt` 0 and 1 and leaf
  inlining 0 and 1 (eight outcomes) via `parityShort`, requiring one
  value/error. They pin
  the plan, facts, NIR shape, controls, Unicode/NUL/Empty, errors,
  producers, storage frontiers and the audit text.
* **Fuzz** (`audit/short-string/tools/fuzz.tcl`, bounded: recursion measures are
  small literals, nothing multiplies): small programs over Empty/ASCII/Latin-1/
  BMP/astral/NUL Strings, branches, aliases, exact calls with String parameters
  and results, self-tail and non-tail recursion, `substring` slices, the `peek`
  idiom, an error-capable helper with a handler, a capturing closure, tagged
  storage and general String operations; compares the interpreter, the compile
  backend and native on/off x inline 0/1 for values, errors (including the
  message) and completion behavior. **1,471 programs: 0 disagreements**
  (1,424 values, 47 errors; 1,449 use a ShortString1 ABI, 1,317 a short
  result, 1,405 a short parameter, 745 with slices, 582 with scalar equalities, 1,335
  materializing programs, 399 with an extraction); **491 programs under
  `BOTLISH_NATIVE_GC_STRESS=1`: 0**; **291 programs with specialization off
  (`-specialize 0`): 0**. 47 generated programs (29 + 9 + 9) were rejected
  statically by the strictness checks and are not counted.
* **Existing suites.** Five existing tests pinned the unoptimized String layout
  or String allocation counts and were adapted (see below); no test was
  removed or weakened.

## GC stress

`short-gc-live-across-allocation` (a short parameter live across `concat`,
`list_append` allocations with ordinary Strings, a List and a struct as live
roots), `short-gc-materialize-before-and-after-allocation` (a short value
materialized before an allocation and again after), `short-gc-recursive-exact-
call-transport` (200 allocating recursive frames with a short parameter and
result), `short-gc-stack-map-has-no-short-roots` and the executable tests run
under `BOTLISH_NATIVE_GC_STRESS=1` (every allocation site forces a collection);
the whole file also runs under the variable (59/59). The scalar never appears
in a stack map: `short_live_across_allocation_is_not_a_root`.

## Standalone parity

`short-executable-everything` builds a standalone executable of one program
containing Empty, ASCII, non-ASCII, NUL, parameter and result transport, a
tagged frontier (`list_append`), an error-capable path with a handler and a
slice, and checks the interpreter, the compile backend, both Cranelift
backends, the executable and the executable under GC stress all agree;
`short-executable-optimization-off` does the same with `-short-string-opt 0`.
JIT, object and executable share the one code path.

## Full regression

Tcl 9.0.1, Linux x86-64, release native backend, final tree. "Before" is the
parent commit `d51c0d3` (the RawInt demand branch, the numbers its report
records).

| run | before (parent) | after |
|---|---|---|
| `tests/all.tcl` interp backend | 3733 total, 3733 passed | **3789 total, 3789 passed, 0 failed** |
| `tests/all.tcl` compile backend | 3733 total, 3729 passed, 4 skipped | **3789 total, 3785 passed, 4 skipped, 0 failed** |
| `BOTLISH_NATIVE_GC_STRESS=1 tests/all.tcl` (CI's `gc-stress` job) | not run for the parent | **3792 total, 3792 passed; compile 3788 passed, 4 skipped; 0 failed** |
| `tests/native-coverage.tcl` (cranelift) | 3767: native 1474, independent 2202, passed-partial 41, unsupported 49, failed 1 | **3826: native 1504, independent 2231, passed-partial 41, unsupported 49, failed 1** |
| Rust release tests (`cargo test --release`) | 67 + 22 | **90 + 26 passed** (19 NIR kind/ABI validation tests, 4 runtime helper tests, 2 root-analysis tests, 2 generic-entry wrapper tests) |
| `bench/bench.tcl -runs 1` | all backends agree | **exit 0, all backends agree** |
| `bench/corpus.tcl -runs 1` | all backends agree | **exit 0, all backends agree** (5 m 27 s) |
| `main.tcl -backend cranelift` examples (CI's example step) | | all run |

* The full interp/compile runs were taken when `short-string.test` had 56 of its
  final 59 tests (hence 3,789); the GC-stress run had all 59 (3,792). The
  final file passes on its own, normally and under GC stress.
* **Pre-existing failure, reported separately:** the single native-coverage
  "failed" test is `refined-5` (the cranelift test backend's error message names
  `length` instead of `emailish?`). It fails identically on the parent commit
  (`d51c0d3`, checked with the parent's own build) and with
  `-short-string-opt 0`; unrelated to this milestone, as the RawInt report
  already records.
* The 24 failures a first full run found (string-region, string-view,
  block-escape, hashtable, virtual-construction, struct-scalar-replacement
  tests) were the new representation legitimately changing pinned layouts or
  allocation counts; three of those classes were fixed in the implementation
  (existing StringRegion NIR is preserved by declining region-eligible calls;
  the hashtable's repeated `"b"` keys no longer allocate because Latin-1
  materialization is interned; plan-result/plan-parameter positions keep the
  construction analysis' ABI), the rest adapted as listed below.

### Existing tests adapted (pre-existing representation pins)

These tests assert the *unoptimized* physical String layout or String
allocation counts. As with the RawInt milestone (`-raw-int-abi-opt 0`), each
now passes `-short-string-opt 0` where it measures another optimization in
isolation; the assertions themselves are unchanged:

* `tests/native-string-region.test`, `tests/native-string-view.test`: every
  `-string-region-opt` arm (the "region off" String counts are the region
  analysis's own effect; ShortString1 alone removes those allocations too:
  e.g. the astral `peek` test counts 3 Strings with regions off, 0 with
  ShortString1);
* `tests/virtual-construction.test` (`vcReport`, `nirOf`, the `uri-steady`
  identity test: the uri materialization counts 47,500 -> 16,000 are
  virtual-construction's; with ShortString1 they are 34,500 -> 3,000);
* `tests/native.test` `native-spec-2` (a `(str, str)` instance whose callers pass
  one-character literals takes ShortString1 parameters);
* `tests/native-block-escape.test` `blockescape-region-companion-refined-
  checks-1` (pins 6,804 Strings; ShortString1 removes three more).

## Counterfactual: first scalar recovered from the String instance

The shipped design caches the first scalar in `StrObj::first` (written at every
String construction, in what was padding after `ascii`). The counterfactual
removes the field and recovers the scalar at the conversion. It is the cargo
feature `short-first-recovered` (off by default; nothing in the shipped build
changes): `cargo build --release --manifest-path native/Cargo.toml --features
short-first-recovered`. The planner, lowering and NIR are untouched; only the
runtime and the inline `StrToShort` differ:

* `StrObj` has no `first`; construction does no extra work (`first_scalar` is
  not computed at the four construction sites).
* `StrToShort` (inline): `chars == 0` -> -1; else load the `ascii` flag; ASCII
  -> load the first byte through the `Box<str>` data pointer (its offset in the
  object is measured once at startup, `str_text_ptr_offset`, because Rust does
  not guarantee the fat-pointer field order); non-ASCII -> `rt_str_to_short`,
  which decodes the first `char` of the text. That is three blocks and two
  branches instead of two loads and a select.

Measured with the same tools against the same parent-commit base
(`audit/short-string/out/*-recovered*.txt`; the binary under test is selected
with `BOTLISH_NATIVE_BIN`, and the callgrind build with
`BOTLISH_AUDIT_FEATURES=short-first-recovered`).

**Census.** `out/census-recovered.txt` is byte-identical to `out/census.txt`:
the planner, the virtualized positions, the frontier counters, the static
conversion counts and the materialization classes live above the representation
of one String's first scalar, so the counterfactual cannot change them. The
only things it can change are the instruction sequence of one conversion and
the per-String construction cost, and both are measured below.

**Roots / safepoints.** Identical (595 -> 600 safepoints, 1276 -> 1257 root
candidates, 807 -> 799 slots): the wide-path helper does not allocate and is not
a safepoint.

**Machine code.** Off is unchanged (101,879 bytes). On: **102,511 bytes
(+632, +0.62 %)** against 102,423 (+544, +0.53 %) shipped, i.e. **+88 bytes**,
all in the two programs that contain a `strtoshort` (`refined-checks` +40,
`ai_text_clean` +48). Deterministic across two compiles.

**Instructions (callgrind Ir, steady state, `out/ir-recovered.txt`).**

| program | base | off shipped | off recovered | on shipped | on recovered |
|---|---:|---:|---:|---:|---:|
| `refined-checks` | 6,777,452 | 6,826,601 (+0.73 %) | 6,776,787 (+0.00 %) | 6,892,829 (+1.70 %) | 6,894,459 (**+1.74 %**) |
| `uri-steady` | 42,730,297 | 42,855,215 (+0.29 %) | 42,748,650 (+0.03 %) | 35,653,329 (-16.56 %) | 35,576,484 (**-16.75 %**) |
| `ai_text_clean` | 187,382 | 187,975 (+0.32 %) | 187,414 (+0.06 %) | 66,517 (-64.50 %) | 66,634 (-64.42 %) |
| `source-checks` | 73,492 | 73,686 (+0.26 %) | 73,533 (-0.04 %) | 65,946 (-10.27 %) | 65,989 (-10.29 %) |

(Each Ir column is a different run; a program's *base* moves between runs by
<= 0.02 % for the large programs and by up to ~0.9 % for the ~100k-Ir CSV
programs, so for those the figures are indistinguishable from each other. The
four rows above are far outside that.)

* **The off-configuration cost disappears.** With the optimization off, the
  recovered build is at base (`refined-checks` +168 Ir against shipped's
  +49,149): the +0.73 % of the shipped design was the per-String `first`
  store plus the allocator effect, not anything the planner does.
* **The conversion gets more expensive.** `refined-checks`' tagged-only
  parameter round trip (~9,070 `strtoshort -> shorttostr` pairs) costs
  +117,672 Ir over off instead of +66,228: about **+5.7 Ir per `strtoshort`**
  (the `ascii` flag load, a second branch, the text-pointer load and the byte
  load replace one load).
* **Net.** `refined-checks` ends within 0.04 % of the shipped design (+1.74 %
  versus +1.70 % against base): the saved construction cost and the dearer
  conversion cancel almost exactly *on the program that is conversion-heavy and
  construction-light*. `uri-steady`, which constructs many Strings and converts
  rarely, is 76,845 Ir (-0.22 %) better; `ai_text_clean` and `source-checks`
  are within +117 / +43 Ir.
* Programs without Strings are unchanged in both designs.

**Wall-clock** (`nativebench`, two repetitions per build; `out/nativebench-
recovered*.txt`, `nativebench-shipped-rerun.txt`): not conclusive. The same
program swings by more between invocations of the *same* build (`uri-steady`
off 3.52-3.93 ms, on 2.80-3.10 ms; `refined-checks` on/off -0.1 % to +12.1 %)
than the two builds differ from each other, so no wall-clock difference between
the designs is claimed. Instruction counts are the figure of record.

**Compile time** (`out/compiletime-recovered.txt`): total with the optimization
on 2,497 ms for the corpus against 2,580 ms (original run) and 2,642 ms (rerun)
for the shipped build: within the run-to-run spread (about +-5 %); the
Tcl-side phases are identical by construction.

**Correctness.** `tests/short-string.test` passes 59/59 against the recovered
binary, also under `BOTLISH_NATIVE_GC_STRESS=1`; the Rust suite passes 90 + 26
with the feature; differential fuzz over the same three seeds as the shipped
run (1,471 + 491 GC-stress + 291 generic programs): 0 disagreements. The full
`tests/all.tcl` result is below.

**Reading.** The cached field costs a store on every String the program ever
builds (even with the optimization off) and buys a conversion that is about
5.7 Ir cheaper per `strtoshort`. Whether that trade pays depends on the ratio of
String constructions to `strtoshort` executions in a program, and on the corpus
the two roughly cancel: one program (`refined-checks`) leans toward the field,
`uri-steady` toward recovery. The recovered design has two practical
advantages: no runtime-wide cost when the optimization is off or irrelevant,
and no 4 bytes of object state that must be kept consistent with `text`.
Its disadvantages are a 40-48 byte larger conversion at each static site, a
dependence on a measured (not declared) `Box<str>` pointer offset, and a
non-ASCII path that calls a helper. The question of which to ship is left
open. The dominant corpus cost in both designs is the tagged-only parameter
round trip; a later demand/profitability pass that keeps such parameters
tagged would remove the `strtoshort` executions there (not implemented, not
measured), and with them most of what separates the two designs on this corpus.

## Known limitations

* **No general opportunity-cost heuristic yet.** Selection is categorical;
  `refined-checks`' round trip, `string_replace`'s replacement parameter (used
  only as a `concat` piece) and similar tagged-only positions pay a conversion
  for nothing.
* **Mixed scalar/tagged uses may materialize** (`length(s)` scalar,
  `list_append(xs, s)` tagged): materialized at the tagged use, recorded.
* **General String equality against an unrestricted String materializes** the
  short operand.
* **Storage stays tagged**: no packed one-character collection storage.
* **Hashing, `concat`, `lowercase`, `is_tcl_alpha`... stay on the existing
  representation** (materialize first). `is_tcl_alpha`/`alnum` of a short
  operand is a natural scalar op and a future consumer.
* **No `Char` source type, no SIMD, no multi-character (2/4/8) or ASCII
  packing**: strictly `length <= 1`.
* **No new String-length inference.** The proof only composes existing facts;
  `lowercase`, `concat("", x)`, branch-derived `length(s) <= 1` and per-field
  facts are missed opportunities.
* **Traversal accesses.** A `peek` access inlined by the String-traversal
  analysis (`TraversalAccess`) still decodes a tagged one-character String and
  then extracts it; a short decode (`DecodeCharAt` straight to a scalar) is a
  straightforward future step.
* **The `first` scalar field and the interned table are runtime-wide costs**
  (+0.17..+0.79 % Ir on ten String-allocating programs, even with the
  optimization off; -0.37 % / -0.16 % on two others through libc `_int_malloc`
  arena effects of the larger `Vm`; exactly 0 for programs without Strings).
  A layout-dependent read of the `Box<str>` pointer would avoid the per-String
  store but relies on an unspecified fat-pointer layout; it was not taken.
* **Generic/dynamic calls remain tagged**; nothing about dynamic dispatch was
  redesigned.
* **Backend placement/alignment is untouched** and remains the backend audit's
  concern: no function/loop alignment, branch placement, register-allocator or
  Cranelift setting was changed, and tiny-kernel wall-clock anomalies are
  recorded separately from instruction counts.

## Future frontier heuristic

The architecture leaves the obvious place: replace "eligible" by "eligible +
benefit - cost" in `native::shortstr::plan` (the final `Ok $f` tests for
parameters and results) and in the `ShortOk` queries lowering makes for locals.
The recorded frontiers are the inputs: the number and kind of scalar consumers
per position (`UsesOf`, already computed for the audit), the tagged consumers
and their frontier class (`materializations`), and transport distance along
exact calls. The first suppression to evaluate is the one the corpus shows
directly: **a parameter with tagged-only uses** (`local_char?`, `esc_char`,
`replace_from`'s `replacement`), which should stay tagged; the second is a
**mixed** position where a single scalar `length` does not pay for several
tagged uses. Cheap materialization (the interned Latin-1 table) already lowers
the break-even point, and the same concepts (semantic value, physical
representation, transport, materialization frontier, opportunity cost) are the
ones the struct heuristic uses.

## Answers to the required architecture questions

1. **Which existing analysis proves `String length <= 1`?** None states it as
   a fact. The query composes literals, immutable aliases,
   `hir::range::ConditionOutcome`/view reachability, `hir::induction::
   ClassifyArg`/`hir::exact::IntOf` for `substring` widths, `hir::specialize`
   closedness/call targets and `hir::escape::Exits` (*Semantic proof inputs*).
2. **What is one Botlish String character?** A Unicode scalar value (not a
   byte, not a UTF-16 unit, not a grapheme cluster, not a surrogate).
3. **Physical representation:** one `i64`, logically `Empty | One(codepoint)`.
4. **Empty encoding:** `-1`.
5. **Why never a collision:** valid scalar values are `0..0x10FFFF` minus the
   surrogates, all non-negative; `-1` is outside the domain. NUL is `0`.
6. **Source type?** No. 7. **Semantic String typing changes?** No.
8. **Same NIR kind as RawInt?** No: distinct `RegKind::Short`, `shortregs=` vs
   `rawregs=`; neither can stand for the other.
9. **What makes a local eligible?** Its existing-fact length proof `<= 1`.
10. **Parameter/result eligibility:** closed instance, `str` key/result, fact
    not `over` (join of callers / exits), not a construction-plan position.
11. **Open/dynamic callers:** tagged canonical ABI; the position is
    `open-instance`; Block values/`callvalue` enter the tagged generic entry.
12. **Profitability score?** No. 13. **Mixed uses suppress it?** No: materialize
    at the tagged use and measure.
14. **Exact empty Strings virtualized?** Yes (`shortlit -1`). 15. **Non-ASCII
    one-character Strings?** Yes.
16. **Aliases?** Yes. 17. **Branch joins?** Yes (including `""|"x"` and
    `"x"|"λ"`). 18. **Exact calls transport directly?** Yes. 19. **Several exact
    calls?** Yes (`pick -> f -> g -> h`, zero conversions).
20. **Where must it materialize?** Storage (List/MutableArray/struct/capture),
    general String operations (`concat`, `lowercase`, `hash`,
    `is_tcl_alpha`), equality with an unrestricted String, a tagged-ABI call
    argument/return, the program result; census classes in *Tagged
    materialization frontiers*. 21. **Storage tagged?** Yes.
22. **`length`:** `shortlen`. 23. **Emptiness:** `shorteq` with `shortlit -1`.
24. **Two ShortString1 values:** word equality. 25. **ShortString1 vs
    unrestricted String:** materialize the short operand, existing `streq`.
26. **Direct consumers:** `length`, `==` between short operands (and a short
    operand with a literal), exact call arguments/returns/tail/alias/join.
27. **Force materialization:** `list_append`/`list`, `mutable_array_*`, struct
    fields, `concat`, `lowercase`, `hash`, `is_tcl_alpha/alnum`, `immutable_
    set_*`, `encode_utf8`, `substring` of a short operand, a dynamic call, a
    captured slot, `ok`/`error` payload, the program result.
28. **U+0000:** `0`, a one-character String. 29. **Highest legal scalar:**
    U+10FFFF (1114111). 30. **Multi-byte UTF-8:** one character -> one scalar.
31. **Surrogates representable?** No (Rust `str`, strict UTF-8 reading, planner
    refusal).
32. **NIR distinction:** `shortregs=` vs `rawregs=`, `RegKind`, distinct ops.
33. **Parameter/result kinds in NIR:** `shortparams="i j"`, `shortresult=1`.
34. **Caller/callee agreement:** one plan read by both; `nir.rs` revalidates
    every call/callenv/ret/tail against the callee's header.
35. **What Cranelift receives:** an `i64` register kind with five ops and a
    two-word status return when error-capable. 36. **Future LLVM?** Yes, the
    plan and NIR contract are backend-independent.
37. **GC root?** No. 38. **Live across a safepoint?** Yes, as a scalar.
39. **Materialized before a safepoint:** an ordinary tagged root while live.
40. **Stack maps distinguish it:** `scalar_regs` filtered from every
    safepoint's roots; no entry is emitted.
41-50. **Censuses and census answers:** see *Virtualization census* (154
    examined, 30 proven, 1 local virtualized, 8 parameter / 6 result positions,
    14 instances, 0 known Empty / 0 known One-scalar / 7 known One / 23
    runtime Empty-or-One; 1 `strtoshort` and 10 `shorttostr` remain; classes
    8 general String operation, 1 dynamic call, 1 tagged result; **no value
    is materialized repeatedly**).
51. **Whole-corpus bytes:** 101,879 -> 102,423 (+544).
52. **Roots:** candidates 1,276 -> 1,257, slots 807 -> 799, safepoints
    595 -> 600.
53. **Most code gained:** `refined-checks` +244. 54. **Most shrunk:**
    `ai_text_clean` -608. 55. **Most ShortString1 values:** `ai_text_clean` (19
    `shortlit`, 19 `shorteq`), then `string_replace` (5 literals) and the CSV
    family. 56. **Largest reduction in materialized String work:**
    `ai_text_clean` and `uri-steady` (no one-character String allocated for the
    scanned characters).
57. **Material instruction regression?** `refined-checks` +1.70 % (+0.97 %
    attributable to the representation, +0.73 % to the runtime's per-String
    field/arena effect paid with the optimization off); all others <= +0.56 %.
58. **Where from:** the tagged-only parameter round trip `strtoshort ->
    shorttostr` in `local_char?`/`esc_char`.
59. **Largest benefit:** `ai_text_clean` -64.5 %; `uri-steady` -16.6 %.
60. **Operation responsible:** `shorteq` (replacing `streq`) and
    `strsliceshort` (replacing `substr`). 61. **Exact-call transport removes
    materialize/extract pairs?** Yes (zero conversions through
    `pick -> f -> g -> h`; `ai_text_clean`'s `peek -> clean_char ->
    cleaner_emoji`).
62. **Extra materializations on tagged-heavy workloads?** Yes: `refined-checks`
    (round trip), `string_replace` (`concat` piece), the CSV `concat` piece.
63. **Inputs to the later heuristic?** Yes (tagged-only parameters, mixed
    positions).
64. **Wall-clock anomaly lacking an instruction/code-shape explanation?**
    Single-invocation tiny-kernel numbers (`csv_chunked`, `string_replace`) only,
    and they flip sign on repetition; recorded in *Wall-clock* as spread, not
    attributed to this optimization.
65-72. **Correctness:** values, errors and completion behavior agree
    on/off/interpreter/native for every test, ASCII and non-ASCII, NUL, the
    Empty branches, GC stress, standalone executables and 2,253 fuzz
    programs; the full regression passes (interp 3,789/3,789, compile 3,785 + 4 skipped, native coverage, Rust 90 + 26, whole suite under GC stress 3,792/3,792 and 3,788 + 4 skipped, bench and corpus parity).
