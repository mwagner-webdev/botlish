# Language and library deficiencies found by the warning-driven refactor

The warning-driven refactor (REFACTOR-WARNINGS-CLEAN.md) rewrote the corpus
-- `examples/`, `bench/`, `lib/` -- under the compiler's own warnings, and
measured every rewrite. Where a warning could not be answered, or its answer
cost more than the code it replaced, the cause was nearly always somewhere
other than the program: a primitive the library lacks, an analysis that
stops one step short, a native lowering that makes the natural spelling slow.
This report collects those causes in one place, with the measurements behind
each and what each one forces on code today.

It records; it changes nothing. Numbers are native (Cranelift) unless a
backend is named, measured on this repository after the refactor (991c666
and later). Allocation counts and re-decoded bytes are deterministic; times
are best-of-N and carry this machine's noise (REFACTOR-WARNINGS-CLEAN.md,
section 14). The scripts that reproduce them are named with each item.

## Summary

Ranked by what fixing it would unlock in the corpus measured here.

| # | deficiency | kind | worst effect measured | what it forces |
|---|---|---|---|---|
| 1 | A `str::char_at` scan gets no byte cursor | native | 7.2-8.4 s instead of 17-28 ms; 11-13 GB of UTF-8 re-decoded (100K characters) | reading characters through one-character String slices (`peek`) |
| 2 | Reading a program-level non-Int value makes a function, and its callers, generic | specialization | 3.4-3.7 s instead of 17-28 ms (a program-level set); 0 -> 60 MB re-decoded (a program-level table) | constants rebuilt inside the function, or written out as code |
| 3 | No way to make text from a character | library | 24 findings that cannot close; a translation table that only hides them | one-character String literals wherever a character is output |
| 4 | Strings are not iterable | language | -- (the reason for 1's index loops) | index loops with `char_at` or `substring` |
| 5 | `str::char_at` of a short String or a slice materializes it | native | +50-54% Strings and +20-54% time (`ai_text_clean`, 100K characters) | the character idiom is slower than the String idiom it replaces |
| 6 | A constant List literal is rebuilt on every call | native | one object per call; 28-31 ms instead of 17-28 ms for a 12-element membership test | `or` chains instead of tables |
| 7 | An `and`/`or` condition, and `!=` on raw Ints, become materialized bools | native | 245 instructions and 40 jumps instead of 222 and 31 (`ht_find_insert`) | nested `if`s instead of the conjunction a merge spells |
| 8 | Range narrowing does not flow through `and` | analysis | an entry range one past the small-Int bound: a parameter loses its raw ABI | nested `if`s instead of `and` |
| 9 | Classifiers exist for Strings and Bytes, not characters | library | 10 findings that cannot close | one-character Strings for every classified character |
| 10 | No List membership operation | library | -- | `or` chains, loops, or an `ImmutableSet` (with 2 and 6) |
| 11 | No Int-to-String conversion | library | -- | benchmark generators unroll String keys in Tcl |
| 12 | The index proof relates names, not linear forms; a recursive index is never proven non-negative | analysis | 1 finding that cannot close; `IndexNotFound` in four scanners' contracts | slices made only to be decoded, or wider error contracts |
| 13 | A namespace import brings every member in, and method resolution between same-named members is by receiver type only | modules | 28 calls left functional; `AMBIGUOUS-METHOD-CALL` for the method spelling | mixed spellings in one function |
| 14 | A library file cannot always compile as an entry program | modules | 5 of 14 modules | modules checked only through a loader |
| 15 | Core IR cannot carry a declared result type | representation | 1 finding that cannot close | `-> list` withheld from a fixture |
| 16 | The Tcl backends do not inline small helpers | reference backends | +13% (`csv`, compile backend) | -- (native inlines) |

Several compound. The *ripple* -- carrying the character type from the read
to the output -- needs 1 (or 4) and 3; a table of characters needs 6 and 2
(and 10 for membership); a merge's natural conjunction needs 7 and 8.

## Pathological performance (native)

### 1. A `str::char_at` scan gets no byte cursor

Botlish indexes Strings by Unicode scalar, so locating index i in non-ASCII
text decodes from byte 0. `hir/traversal.tcl` removes that cost for one
shape: a self-tail loop stepping +1 from a literal 0 whose body reads through
a `peek`-shaped helper (a width-1 slice). A loop that reads with
`str::char_at`, or starts anywhere but a literal 0, decodes from byte 0 on
every step: quadratic.

* `audit/refactor/ripple/` (`measure.tcl`): `ai_text_clean` with the
  character read by `text.char_at(index)` instead of `peek` takes
  7,197-7,463 ms (punctuation) and 8,191-8,395 ms (emoji) at 100K
  characters, against 17-28 ms, re-decoding 11,378,740,608 and
  13,272,530,323 bytes. It is otherwise the better program: 7 Strings
  allocated instead of 290,328.
* The CSV scanners start at an index that is not the literal 0, so they were
  quadratic before the refactor and after: 122,207,268 -> 132,103,099 bytes
  re-decoded at 300 non-ASCII rows (REFACTOR-WARNINGS-CLEAN.md, section 8).

**Forces**: every forward scan through a `peek` helper that returns a
one-character String, and the refactor's converted comparisons decode that
String again (5). **Direction**: a byte cursor for `char_at`-indexed +1
scans, and for starts other than 0 (seek once); or String iteration (4),
which has a cursor by construction.

### 2. Reading a program-level non-Int value makes a function generic

`hir/specialize.tcl` keeps a value-capturing closure with a non-Int capture
generic ("Which instance a call uses"), and a function that reads a
program-level binding is such a closure; its callers follow. A traversal plan
(1) is only given to a specialized instance, so the scan goes quadratic too.

* `audit/refactor/ripple/`: `cleaner_emoji` asking an `ImmutableSet` bound at
  program level: 3,383-3,666 ms and 3,511-3,709 ms at 100K characters,
  5,983,665,075 and 7,118,857,948 bytes re-decoded, against 17-28 ms for the
  same set test written as an `or` chain.
* `audit/refactor/h1-attempt/variants/` (`measure.tcl`): a translation table
  of two program-level Strings costs `clean_from` its plan -- 2,483,588 /
  9,751,421 / 38,647,782 bytes re-decoded at 2,000 / 4,000 / 8,000
  characters (x3.93, x3.96) -- and the same table inside the function costs
  only its own decoding (88,647 / 174,984 / 347,727 bytes, linear).

**Forces**: a constant table either rebuilt inside the function on every
call (6) or written out as code (`or` chains). **Direction**: specialize a
closure whose captures are program-level constants (they are one value per
program), or treat program-level constants as static values rather than
captures.

### 5. `str::char_at` of a short String or a slice materializes it

A one-character slice compared with a literal is a String region and
allocates nothing; the same slice handed to `str::char_at` becomes a
substring and then a heap String (`shorttostr`). The refactor's
consumption-side conversion reads the character of each `peek`ed slice, so
it pays this once per character.

* `bench/ai_text_clean.tcl`, kickoff against final, two same-host rounds
  (REFACTOR-WARNINGS-CLEAN.md, section 14): Strings +50-54% at every size
  (ascii 200,110 -> 300,165 at 100K), time at 100K +22% / +33% (ascii),
  +31% / +54% (punctuation), +29% / +20% (emoji). The one native regression
  of the refactor.

**Forces**: the character spelling is slower than the String spelling it
replaces. **Direction**: `char_at` on a short String or a region without
materializing it (`decodecharat` already exists for traversal plans).

### 6. A constant List literal is rebuilt on every call

A List literal of constants inside a function is built at every call.

* `audit/refactor/ripple/`: `cleaner_emoji` as a loop over a List of its 12
  characters: one more object per character (290,336 -> 390,391), 27.9-30.7
  ms against 16.7-28.0 ms; an `ImmutableSet` built per call: two more
  (490,446), 81-90 ms.
* `audit/refactor/h1-attempt/variants/`: a 6-character List inside
  `clean_char`: 12,336 / 24,336 / 48,336 List element copies at 2,000 /
  4,000 / 8,000 characters.

Hoisting the constant to program level runs into 2. **Forces**: `or` chains
are the cheapest membership test, at any length (the corpus has one of 12).
**Direction**: materialize constant aggregates once.

### 7. `and`/`or` conditions and `!=` on raw Ints become materialized bools

Native lowers `a and b` / `a or b` as a value -- each operand's outcome moved
into a register, then branched on -- even where it is only a condition, and
`x != y` on raw Ints as `rieq` followed by a materialized negation. Nested
`if`s branch directly.

* `ht_find_insert` (`examples/stdlib/hashtable.bot`, `csv_records.bot`): the
  merge spelled as conditions tested the slot's state twice and branched on
  two materialized bools: 245 machine instructions and 40 jumps, against 222
  and 31 unmerged and 213 and 32 for the `if`/`elif` chain the corpus now
  uses.
* `abi::bytes::replace`: `if index < 0 or index >= count: fail ...` needs 13
  NIR registers and two extra jumps against 10 for the nested tests.
* `emailish?`: `if local_end != 0:` lowered as `rieq` and a bool; the corpus
  uses `local_end > 0` (`rigt`, direct).

**Forces**: the warnings that merge exits (`SAME-RETURN-VALUE`,
`SAME-FAILURE`) have to be answered with nested `if`s, sometimes with an
empty (`unit`) branch, rather than the conjunction they describe
(REFACTOR-WARNINGS-CLEAN.md, finding 12). **Direction**: lower `and`/`or` in
condition position as branches; a direct `rine`.

## Analysis gaps

### 8. Range narrowing does not flow through `and`

A comparison narrows the then-branch of the `if` it is the condition of, but
not the later operands of an `and`, nor the then-branch of an `if` whose
condition is an `and`.

* `emailish?` (`lib/web.bot`): `local_end > 0 and local_end < n and ... and
  domain?(local_end + 1)` -- or the same conjunction as an `if` condition --
  leaves `local_end < n` unused: `domain?`'s entry range grows to [1, 2^62]
  from [1, 2^62 - 1], and its parameter loses its raw (untagged) ABI
  (`tests/closure-int-keys.test`'s RawInt plan: `unbounded-or-not-small`).

**Forces**: nested `if`s (with 7). **Direction**: narrow each `and` operand by
the ones before it, and an `if`'s then-branch by every conjunct.

### 12. The index proof relates names, not linear forms

`hir/completions.tcl`'s `IndexBounds` relates an index to a length only
through a guarded *name*; the slice proof uses linear forms. And a recursive
scanner's index is never proven non-negative.

* `lib/linux/path.bot`: `path.char_at(n - 1) == '/'` is not proven in range
  (n - 1 < n), while `path.substring(n - 1, n)` is; the provable character
  spelling decodes a slice made only to be decoded (two allocations a call).
  Manifested.
* The four CSV scanners: the character reads add `IndexNotFound` to their
  error contracts, where `peek` raised `LowerUnderrun`, for a negative index
  no caller passes; `ai_text_clean`'s ripple variant needs the same.

**Direction**: linear forms in the index proof; a non-negativity fact for an
index that starts at a non-negative value and only grows.

## Missing primitives (library and language)

### 3. No way to make text from a character

There is no `str::of_char`, no `str::concat` (or append, or builder) taking a
`UnicodeChar`. A character, once compared as a character, cannot become the
text a caller appends.

* 24 manifested `ONE-CHAR-STRING-LITERAL` findings (`char->text`): the hex
  digit table and `%` of `lib/web.bot`, the newline of `lib/io.bot`'s
  `print_line`/`write_error_line`, the `/` of `lib/linux/path.bot`'s
  `concat`, `ai_text_clean`'s three normalizations, the separator of
  `examples/io/child-path.bot`. 21 of them are appends.
* H1 (`audit/refactor/h1-attempt/`): the one literal-free spelling slices the
  character out of a longer literal (a translation table) -- it removes the
  findings without removing the one-character String, adds an alignment
  invariant, and reads worse.

**Forces**: one-character String literals in every output path, and the
character type stops one step short of the output. **Direction**: append a
character to text (what the corpus asks for, 21 of 24); `str::of_char` would
be a longer spelling of a literal.

### 4. Strings are not iterable

`loop c in text` is a type error (`statically incompatible with list`): only
Lists iterate. Every character scan is an index loop, which is what 1 makes
quadratic.

**Direction**: a String iteration form yielding characters in order, which
has a byte cursor by construction and makes 1 unnecessary for forward scans.

### 9. Classifiers exist for Strings and Bytes, not characters

`str::is_tcl_alnum` and `str::is_tcl_alpha` take a String; `lib/ascii.bot`'s
`is_digit`/`is_upper`/`is_lower`/`is_alphabetic`/`is_alphanumeric` take a
`Byte`. There is none for a `UnicodeChar`, whose only operation is
`char::scalar_value`.

* 10 manifested findings (`classifier`): `lib/web.bot`'s local-part and label
  classes, `bench/lex-strategy.bot` and `bench/source-checks.bot`, whose
  uniform classifier contracts (`Fn{args: [str]}`) force every classified
  character to be a one-character String.

**Direction**: the same classifiers over `UnicodeChar`.

### 10. No List membership operation

`lib/list.bot` has `get`, `any?`, `all?`, `none?`, `find`; the List natives
are `append`, `at`, `length`. Membership is a loop, `list::any?` with a
callable, or an `ImmutableSet` (`immutable_set::contains`). With 2 and 6, all
three cost more than an `or` chain today (6). A warning preferring a table
over an `or` chain would have nothing to suggest.

### 11. No Int-to-String conversion

`bench/hashtable.tcl` notes it: String-keyed benchmark programs are generated
by unrolling literal keys in Tcl, because no Botlish loop can compute
`"key" ++ str(i)`.

## Modules and representation

### 13. Whole-namespace imports and type-only method resolution

An import brings in every member of a namespace (no selective import, by
design: IMPORTS.md), and `x.f(y)` chooses between same-named members only by
the receiver's type.

* `hashtable.bot`, `csv_records.bot` and `csv_chunked.bot` import `list` for
  `list::append` and `mutable_array` for the tables, and both define `at`.
  With an untyped receiver, `controls.at(i)` is `AMBIGUOUS-METHOD-CALL
  (list::at, mutable_array::at)`; with a typed one (`a: MutableArray[int]`),
  `a.at(i)` compiles. `METHOD-ELIGIBLE` counts visible names, not admitting
  types, so it is silent in both cases, and the corpus's 28
  `mutable_array::at(...)` calls stay functional beside sugared `.set(...)`
  calls in the same functions.

**Direction**: let the warning ask the type-directed resolver when the
receiver's static type decides the call.

### 14. A library file cannot always compile as an entry program

* `lib/list.bot` and `lib/mutable_array.bot` call their own namespace's
  intrinsics (`list::at`), which a module needs no import for and may not
  import (`SELF-IMPORT`), while an entry program needs `import list`.
* `lib/io.bot`, `lib/io/path.bot`, `lib/linux/io.bot`: an entry program's
  value is its last declaration, and theirs is a context or trait function,
  which cannot be a value.

All fourteen modules load; five can only be checked through a loader (the
gate does). **Direction**: a "compile as module" mode, or a module file's
value being `unit`.

### 15. Core IR cannot carry a declared result type

`examples/surface/13-hygiene.bot`'s `pair` returns `[list, x]`; its answer is
`-> list`, but core IR re-types the call as `list` instead of `List[int]`, and
`tests/surface-samples.test` checks that this sample's HIR is what analysis
of its core IR derives. Manifested (`core-ir-roundtrip`).

## Reference backends

### 16. The Tcl backends do not inline small helpers

`csv`, 1,000 rows, compile backend: the program before P3 970 ms, after
1,098 ms; with `quote_at?` inlined 987 ms, with `scan_unquoted`'s test as
`==`/`or` instead of `!=`/`and` 1,028 ms. The character reads themselves are
not the cost (over 20,000 characters, `char_at` and a character comparison:
8.3 s interp, 413 ms compile; `peek` and a String comparison: 12.5 s, 415
ms). Across the CSV programs the Tcl backends got 10-44% slower while native
got 14-24% faster (REFACTOR-WARNINGS-CLEAN.md, section 14). The reference
backends are not the production path; recorded, not acted on.

## What would unlock the most

1. **A byte cursor for `char_at` scans, or String iteration (1, 4).** It
   turns the measured ripple from 400 times slower into the cheapest program
   (7 Strings instead of 290,328) and makes the CSV scanners linear on
   non-ASCII input.
2. **Program-level constants as static values (2), and constant aggregates
   materialized once (6).** Together they make a table of characters, a
   List or a set, no dearer than an `or` chain instead of roughly 1.6 to
   200 times dearer, and give a "prefer a table" warning something to suggest (with
   10).
3. **Appending a character to text (3).** It closes 21 of the 24
   character-to-text findings and lets the character type reach the output.
4. **Conditions lowered as branches, and narrowing through `and` (7, 8).**
   The merge warnings' natural answer becomes the cheap one.
5. **`char_at` on short Strings and regions (5)** and **character classifiers
   (9)** close the remaining measured regression and the 10 classifier
   findings.

The rest (11-16) are smaller and local.
