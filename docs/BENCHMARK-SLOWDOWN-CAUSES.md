# BENCHMARK-SLOWDOWN-CAUSES.md

Why the `bench/bench.tcl` programs that are still well behind Go are slow,
cause by cause, measured on main after UNICODECHAR-CLASSIFIERS.md.
BENCHMARK-BIMODALITY.md explained why the native column splits into a Go
cluster and a Python cluster. This report takes the programs still in the
slow one and puts a measured cost on every cause. Each cost comes from a
variant of the program that removes just that cause, and the variants are
applied one after another, so each step's saving is measured on top of the
previous one. The report changes no compiler code. Its material is in
`audit/bench-bimodality/`: the variants, `tools/measure.tcl`,
`tools/profile.sh` and the new `tools/instructions.sh`.

## Outcome

| program | native | Go | ratio | variant chain (one change at a time) | the last variant |
|---|---:|---:|---:|---|---:|
| lex-strategy | 28.8 us | 1.45 us | 19.9x | characters, index walk, count, direct call | 1.03 us (0.7x Go) |
| source-checks | 8.54 us | 0.68 us | 12.6x | characters, a List literal of direct calls | 1.58 us (2.3x Go) |
| json-parse | 361 us | 30.9 us | 11.7x | an ASCII document | 90 us (2.9x Go) |
| uri-steady | 2,130 us | 192 us | 11.1x | no String built (lengths only) | 269 us (1.4x Go, which builds) |
| game-server | 2,355 us | 348 us | 6.8x | one `continue` | 1,470 us (4.2x Go) |
| test-selection | 3.41 us | 1.17 us | 2.9x | String comparison for set membership | 2.98 us (2.5x Go) |
| fib | 117.9 us | 94.6 us | 1.25x | none (calling convention) | |

Two programs from the earlier slow group are no longer in it:
refined-checks runs at 167 us against Go's 162 (UNICODECHAR-CLASSIFIERS.md),
and loop-count and sum-refined stay ahead of Go.

The causes, ranked by what they cost across these programs:

1. **Building a List or String one piece at a time.**
   - Each piece is a construction-plan step: an `rt_construct` call of
     about 490-650 instructions, plus its allocation.
   - This is most of uri-steady (87%), of lex-strategy once characters are
     characters (7.2 of 9.1 us), of source-checks (5.2 of 6.8 us) and 38% of
     game-server.
   - It takes three forms. A loop in result position collects a List nobody
     reads (game-server). A program collects a List only to count or scan
     it (lex-strategy, source-checks). And Strings are concatenated piece by
     piece because there is no builder (uri-steady).
2. **Generated code that keeps mutable state in memory and Ints tagged.**
   This is what json-parse and game-server spend once their first cause is
   gone (85% and 55% generated code).
   - Mutable variables are one-slot MutableArrays, so each access reloads a
     header and checks writability.
   - Loop bounds read from them leave the index tagged, with overflow checks.
   - A comparison is built as a Boolean word, then compared with `true`.
   - 29% of json-parse's fused loop is stack loads and stores.
3. **`std::str::char_at` in non-ASCII text seeks from byte 0.** That is 79%
   of json-parse (an ASCII document makes it 4.0x faster), 26% of
   refined-checks and 13% of uri-steady's scan.
4. **Set membership through type-blind equality.** `ImmutableSet.contains`
   scans calling `equal`, which calls `kind_of` on both operands. That is
   28% of uri-steady's scan and 23% of refined-checks; replacing it with a
   String comparison saves 12% of test-selection.
5. **Calls through callable values** (`rt_call_value` and
   `invoke_native`). Once nothing else is left, this halves lex-strategy:
   1.93 to 1.03 us.
6. **One `malloc` per object.**
   - test-selection rebuilds 42 objects per run at about 170 instructions of
     `malloc` each.
   - Their frees are paid when the heap is released. That happens between
     runs here, untimed; a long-running program pays it at collection.
   - There is no bump allocator or nursery.
7. **One-character Strings** where a canonical benchmark's API takes `str`.
   Removing them saves 8.2 us of lex-strategy's 28.8 and 1.7 of
   source-checks' 8.5.
8. **The calling convention.** fib's whole gap: the Vm pointer in every
   call, callee-saved registers spilled unconditionally
   (BENCHMARK-BIMODALITY.md, "fib").

Causes 1, 3, 4, 5 and 6 are runtime-helper costs, so better generated code
cannot fix them. Cause 2 is the generated code's own. Each section below
says whether a cause needs a language decision or only implementation work.

## Method

* **Timings.** `bench/bench.tcl -runs 40 -budget 60 -columns "native go"`,
  run twice, for the benchmarks and Go. `tools/measure.tcl -runs 30..60`
  (the same `native::measure`, best of N, JIT compilation excluded) for
  every variant beside its benchmark, run twice. The tables give the
  better run.
* **Setup and noise.** This container: Linux x86-64, 4 cores, a Xeon at
  2.8 GHz, Go 1.24.7, on main at 6c872dab. It is a different machine from
  BENCHMARK-BIMODALITY.md's, and its absolute times differ (lex-strategy:
  28.8 here, 24.7 there). Ratios between programs measured here are
  consistent. Sub-microsecond Go times (loop-count, sum-refined) were
  unstable on this machine and are not used.
* **Profiles.** `tools/profile.sh FILE N1 N2`: callgrind's per-function
  self cost of one run, the difference of an N1- and an N2-run profile. It
  includes the untimed heap release between runs, so its allocator column
  includes frees that the timings do not.
* **Generated code.** `tools/instructions.sh FILE RUNS FUNCTIONS`:
  callgrind's per-instruction counts of the named generated functions,
  joined with `objdump`'s disassembly and grouped by instruction class.

## lex-strategy: 28.8 us, Go 1.45 us

| variant (`audit/bench-bimodality/variants/`) | the change | time |
|---|---|---:|
| bench/lex-strategy.bot | | 28.8 us |
| lex-strategy-indexed | walk each token by index: no `chars_of` List of one-character Strings | 15.4 us |
| lex-strategy-chars | characters as `UnicodeChar`s, `std::char::is_tcl_alnum` (the List stays) | 20.6 us |
| lex-strategy-chars-indexed | both | 9.1 us |
| lex-strategy-chars-counted (new) | `valid_chars` counts the true classifications itself, instead of collecting a `List[bool]` and counting it | 1.93 us |
| lex-strategy-chars-direct (new) | no callable value: an `if` per character picks the classifier and calls it directly | 1.03 us |

Building the program's two Lists costs 27 of its 28.8 us:

* **`chars_of`'s List of one-character Strings.** Removing it is the step
  from 28.8 to 9.1 us.
* **`classify`'s `List[bool]`.** A collecting loop builds it, and
  `count_true` reads it back with `std::list::at`. Removing it is the step
  from 9.1 to 1.93 us. It costs four times what the classification itself
  costs.

The profile of lex-strategy-chars-indexed (120,166 instructions per run)
agrees:

* `rt_construct` 33%;
* allocator and `memcpy` 35%;
* `rt_call_value` and `invoke_native` 7%;
* generated code 14%.

The last variant beats Go. Its profile is 18,461 instructions per run, 66%
generated, and no plan step left in the classification.

**What would close it:**

* **Construction (implementation).** A cheaper plan step or append, or no
  List at all when a collecting loop's only consumer counts or indexes it.
  A collecting loop already is the language's filter (BENCHMARK-BIMODALITY.md,
  "lex-strategy").
* **The callable value (implementation).** A call through a value whose
  targets are a known finite set (here the two branches of
  `choose_classifier`'s `if`) could become a branch over direct calls.
* **The canonical source.** It cannot use characters while its classifier
  interface is `str`.

## source-checks: 8.54 us, Go 0.68 us

| variant | the change | time |
|---|---|---:|
| bench/source-checks.bot | | 8.54 us |
| source-checks-typed | declared parameter types | 8.20 us |
| source-checks-chars | the leading character as a `UnicodeChar`, the `std::char` classifiers | 6.82 us |
| source-checks-chars-listed (new) | `classify_leading`'s flags as a List literal of four direct calls, instead of a loop calling each element of the `checks` List | 1.58 us |

* **The callable-value loop.** `loop check in checks: check(c)` makes four
  `rt_call_value`s and a four-step plan per candidate. That is 5.2 us of
  the 6.8.
* **What remains (27,593 instructions per run).**
  - Allocation: half the instructions, with frees included. Every candidate
    still gets a four-element List.
  - `invalid_names`' collecting loop and `find`'s predicate calls.
  - It is 2.3x Go.
* **What would close it:** the same as lex-strategy. The heterogeneous List
  of callables is the benchmark's subject, so its call cost is the
  implementation's to lower.

## json-parse: 361 us, Go 30.9 us

| variant | the change | time |
|---|---|---:|
| bench/experimental/json-parse.bot | | 361 us |
| json-parse-ascii | the document's one `é` made `e` | 90 us |

**The first cause: seeking in non-ASCII text.** `scalars` reads
`chunk.char_at(i)`, and in a non-ASCII String `char_at_index` decodes from
byte 0. That is 79% of the 6.09M instructions per run.

**The second cause: the generated code.** With the seek gone, 1.23M
instructions remain, 85% of them generated code. Most of that (845,334)
is in the fused `json::validate_text`: about 212 instructions per scalar of
the 3,984. By class (`tools/instructions.sh ... botlish_fn_17`):

| class | share |
|---|---:|
| stack loads and stores | 28.8% |
| other moves | 19.8% |
| compares and tests | 18.5% |
| jumps | 17.8% |
| arithmetic and logic | 9.6% |
| cmov/setcc | 4.7% |
| calls | 0.9% |

Its hottest block (2,220 times per run, 10.5% of the function) shows the
patterns:

```
mov    rcx,QWORD PTR [rsp+0x468]          ; the chunk, from the frame
movzx  rsi,BYTE PTR [rcx+rax*1+0x19]      ; the byte: the character
shl rsi,3; or rsi,4; shr rsi,3; shl rsi,1; or rsi,1
                                          ; tag a UnicodeChar, untag it, tag an Int
mov    QWORD PTR [rsp+0x38],rsi           ; three stores of the same value
mov    QWORD PTR [rsp+0x28],rsi
mov    QWORD PTR [rsp+0x498],rsi
mov    rax,QWORD PTR [rsp+0x4d0]          ; the cursor MutableArray's header
mov    rax,QWORD PTR [rax+0x18]
test   rax,rax ; je ...                   ; may it be written in place?
mov    rax,QWORD PTR [rsp+0x4d0]          ; the header again
mov    rax,QWORD PTR [rax+0x10]
mov    QWORD PTR [rax+0x8],rsi            ; cursor slot 1 := the value
...
and    rax,rsi ; test rax,0x1 ; je ...    ; both operands small Ints?
sub    rax,rsi ; seto cl ; test cl,cl ; jne ...   ; overflow check
```

What the block shows:

* **The driver's state lives in memory.** The program keeps it in the
  MutableArray `cursor`, because Botlish has no mutable local variables.
  Each read reloads the header from the frame. Each write first checks
  whether the backing may be written in place (`[header+0x18]`).
* **Values in such slots stay tagged.** Their arithmetic checks both
  operands for small Ints and checks the result for overflow.
* **Representations change on the way.** A table byte becomes a
  UnicodeChar word and then an Int word.
* **A large frame.** The fused function has 794 NIR registers and a
  1,256-byte frame. A third of its moves are stack traffic, and some are
  repeated stores of one value. Whether those are stack-map slots or
  ordinary spills was not established.
* **Booleans materialized for branches.** Elsewhere in the function,
  comparisons materialize a Boolean and compare it with `true` (`cmovg rsi,
  [true]; cmp rsi,6; je`), as in game-server below.

The scanner and recognizer logic itself (`switch` and `rtabload8`) is a
small part of this.

**What would close it:**

* **The seek.** String iteration, a character cursor or byte offset, or an
  index for non-ASCII Strings (language or representation). A fourth
  route, validating `std::str::encode_utf8`'s bytes, needs a precise
  result type for it (BENCHMARK-BIMODALITY.md, "json-parse").
* **The generated code (implementation).** Keeping a fused function's
  one-slot MutableArrays in registers (scalar replacement: the array never
  escapes `validate_text`). Proving their contents' ranges, so values stay
  raw. Branching on a comparison directly. Mutable local variables would
  remove the need at the language level.

## uri-steady: 2,130 us, Go 192 us

| variant | the change | time |
|---|---|---:|
| bench/uri-steady.bot | | 2,130 us |
| uri-steady-append-char | `char_at`, `append_char`, character literals, the accumulator a one-slot MutableArray | 2,112 us |
| uri-steady-count-only (new) | the same scan and tests, the escaped lengths summed instead of the Strings built | 269 us |

**Building the Strings: 87%.** `uri_escape_text` builds its result with a
String plan per concatenation: `"%".concat(hex_pair(b))` per escaped byte,
`acc.concat(...)` per character. That is `rt_construct` 43%, allocator 26%
and `memcpy` 13% of the run.

**No builder to write it with.** The append-char variant is no faster: an
`append_char` to a String held in a MutableArray slot copies the text
(`alloc_str`, `new_str_pieces`). The plan machinery only helps while the
accumulator is a register. The other mutable storage is no builder either:

* `std::abi::bytes::replace` allocates and copies the whole `MutableBytes`
  on every write (`rt_mbytes_set`);
* a MutableVector can only become a List through a collecting loop, a plan
  step per element.

**The scan alone is still slower than Go's whole function** (269 us against
192, and Go builds the Strings). Of its 3.28M instructions per run:

* `std::web::is_unreserved`'s membership in `additional_unreserved_chars`
  is 28%: `equal` and `kind_of` for each element scanned.
* The non-ASCII inputs' `char_at` seeks are 13%.
* Generated code is 57%.

**What would close it:**

* **A String builder (a language or library decision).** An in-place
  builder, a String from a MutableVector of bytes or characters, or a
  `join` of a List of Strings.
* **Membership.** A membership that compares by the element type, or a
  bitset for a constant set of bytes (implementation).
* **The seek.** Cause 3, as for json-parse.

## game-server: 2,355 us, Go 348 us

| variant | the change | time |
|---|---|---:|
| bench/experimental/game-server.bot | | 2,355 us |
| game-server-continue | `continue` at the end of `simdrv::release_due`'s loop body | 1,470 us |

**The loop's unread List.** `release_due`'s last statement is a loop, so its
value is the List of its bodies' values, and its callers discard it. That
is 885 us (38%); BENCHMARK-BIMODALITY.md, "game-server", has the mechanism.

**What remains** (15.4M instructions per run, 55% generated code):

* **Out-of-line vector reads.** `rt_mv_at` is 15%: about 97,000
  `s.script.at(i * 6 + k)` calls per run, 24 instructions each.
  `mutvec::writable` is 4%: the copy-on-write check of every vector write.
* **The scans' generated code** (`release_due`, `next_due`): jumps 21%,
  moves 21%, stack traffic 19%, compares 18%, cmov/setcc 7%. The loop bound
  `s.clock.at(c_scripted)` comes from a MutableArray, so range analysis
  knows nothing of it. The index `i` stays tagged, and so does every
  `i * 6 + k` with its overflow checks. The loop test is NIR `ilt` followed
  by `br` on its Boolean, which becomes this in the hottest instructions of
  `next_due` (27,933 times per run):

  ```
  and rax,r12 ; test rax,0x1 ; jne ...             ; both small Ints?
  mov esi,0x2 ; cmp rax,r12 ; cmovl rsi,[true]     ; build the Boolean
  cmp rsi,0x6 ; je ...                             ; then test it
  ```

* **Module constants** (`c_now`, `c_scripted`) are loaded at run time
  (`staticget`, then `mutarrayget`).

**What would close it:**

* **The unread List.** A result nobody reads should not be built. That
  needs whole-program knowledge that every caller discards it
  (implementation), or a language decision about a loop in result position.
* **Vector access (implementation).** Inline MutableVector reads, a
  branch-form lowering of tagged comparisons, and constant module bindings
  folded.
* **Records instead of integer rows (language).** Vectors of records
  instead of `i * 6 + k` rows, and mutable local variables, which the
  program writes as one-slot MutableArrays.

## test-selection: 3.41 us, Go 1.17 us

| variant | the change | time |
|---|---|---:|
| bench/test-selection.bot | | 3.41 us |
| test-selection-typed-membership (new) | `changed?` compares the path with each changed String (`streq` in generated code) instead of an ImmutableSet's `contains` | 2.98 us |

**Membership: 12%.** `rt_set_contains` scans with `equal` and `kind_of`.
They are 26% of the profile, but the typed loop that replaces them is not
free.

**Allocation: most of the rest.** Each run rebuilds the 14 `Test` structs,
their 14 dependency Lists, the closures and the selections: 42 objects.

* In the typed variant `malloc` is 7,222 instructions per run, about 170
  per object.
* `free` and `_int_free` add another 9,700 when the heap is released, which
  the timings leave out.
* Go builds the same data per run, with a bump allocator and escape
  analysis.

**What else remains:** `any?` and `find` call their predicates through
callable values, and `select_affected` collects with plan steps.

**What would close it:**

* **Membership.** A set membership that compares by the static element
  type (a `setcontainstotal` that is `streq` for `ImmutableSet[str]`), or
  hashed membership for larger sets.
* **Allocation.** A bump allocator or nursery: runtime work, which no
  source change here can show.

## fib: 117.9 us, Go 94.6 us

All of it is generated code (99.8% of 1.41M instructions per run). The gap
is BENCHMARK-BIMODALITY.md's "fib", unchanged:

* a Vm pointer threaded through every call;
* three callee-saved registers saved and restored in every frame, the base
  cases included, because Cranelift has no shrink-wrapping;
* two redundant moves.

It is backend work, with nothing to decide in the language.

## refined-checks: at Go now

167 us against 162. What it still spends shows causes 3 and 4 at a smaller
scale (2.35M instructions per run):

* `char_at_index` 26%: the Unicode address seeks from byte 0;
* `equal` and `kind_of` 23%: `local_extra_chars`' membership, a set of
  characters scanned type-blind.

## What each cause needs

| cause | programs | language decision | implementation work |
|---|---|---|---|
| building a List or String step by step | lex-strategy, source-checks, uri-steady, game-server, test-selection | a String builder; what a loop in result position means | cheaper plan steps and appends; not building a result nobody reads; counting a collecting loop without building it |
| tagged, in-memory state in generated code | json-parse, game-server | mutable local variables; records in vectors | scalar replacement of one-slot MutableArrays; branch-form tagged comparisons; folded module constants; inline vector access |
| `char_at` seeks in non-ASCII text | json-parse, uri-steady, refined-checks | String iteration or a cursor | an index for non-ASCII Strings; a precise type for `encode_utf8` |
| type-blind set membership | test-selection, uri-steady, refined-checks | (EQUALITY-SEMANTICS.md's checked equality would make the element type the comparison's) | membership by the static element type; hashing or bitsets for constant sets |
| calls through callable values | lex-strategy, source-checks, test-selection | | a branch over direct calls when the targets are a known finite set; a cheaper `rt_call_value` |
| one `malloc` per object | test-selection, source-checks, every program that allocates | | a bump allocator or nursery |
| one-character Strings | the canonical lex-strategy and source-checks | (their `str` classifier interface is the workload) | |
| calling convention | fib | | the Vm pointer, callee-saved registers |

## Reproducing

From the repository root, with the native backend built:

```bash
export LANG=C.utf8 LC_ALL=C.utf8
tclsh9.0 bench/bench.tcl -runs 40 -budget 60 -columns "native go"
V=audit/bench-bimodality/variants
tclsh9.0 audit/bench-bimodality/tools/measure.tcl -runs 60 bench/lex-strategy.bot \
    $V/lex-strategy-indexed/lex-strategy.bot $V/lex-strategy-chars/lex-strategy.bot \
    $V/lex-strategy-chars-indexed/lex-strategy.bot $V/lex-strategy-chars-counted/lex-strategy.bot \
    $V/lex-strategy-chars-direct/lex-strategy.bot
tclsh9.0 audit/bench-bimodality/tools/measure.tcl -runs 60 bench/source-checks.bot \
    $V/source-checks-typed/source-checks.bot $V/source-checks-chars/source-checks.bot \
    $V/source-checks-chars-listed/source-checks.bot
tclsh9.0 audit/bench-bimodality/tools/measure.tcl -runs 80 bench/test-selection.bot \
    $V/test-selection-typed-membership/test-selection.bot
tclsh9.0 audit/bench-bimodality/tools/measure.tcl -runs 30 bench/uri-steady.bot \
    $V/uri-steady-append-char/uri-steady.bot $V/uri-steady-count-only/uri-steady.bot \
    bench/experimental/json-parse.bot $V/json-parse-ascii/json-parse.bot \
    bench/experimental/game-server.bot $V/game-server-continue/game-server.bot
bash audit/bench-bimodality/tools/profile.sh $V/json-parse-ascii/json-parse.bot 4 24
bash audit/bench-bimodality/tools/instructions.sh $V/json-parse-ascii/json-parse.bot 20 botlish_fn_17
bash audit/bench-bimodality/tools/instructions.sh $V/game-server-continue/game-server.bot 4 botlish_fn_70,botlish_fn_71
```

Function numbers (`botlish_fn_N`) are the program's own: `profile.sh`
lists the hot ones by number, and the NIR names them
(`audit/bench-bimodality/README.md`, "The IR dumps").
