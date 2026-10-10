# Rippling the character type, and spelling a character set

Two questions asked of the warning-driven refactor (REFACTOR-WARNINGS-CLEAN.md,
section 15, findings 11 and 13; LANGUAGE-LIBRARY-DEFICIENCIES.md):

* **The ripple.** `examples/stdlib/ai_text_clean.bot` compares characters since
  P3, but it still reads each one as a one-character String (`peek`) and
  decodes it (`char_at(0)`). What does it cost to carry the character type up
  to the read itself?
* **Membership.** Its emoji set is a 12-way `or` chain of character
  comparisons. What do the List and set spellings cost?

The variants here are `ai_text_clean.bot` as merged with one change each. They
are not corpus programs: the gate does not compile them.

| file | the change |
|---|---|
| `as-merged.bot` | none (the corpus program) |
| `list-loop.bot` | `cleaner_emoji` loops over a List of the 12 characters built in the function |
| `set-per-call.bot` | `cleaner_emoji` asks an `ImmutableSet` built on every call |
| `set-program.bot` | `cleaner_emoji` asks an `ImmutableSet` bound at program level |
| `ripple.bot` | `clean_from` reads `text.char_at(index)` and `clean_char` takes the character; an unchanged character is still output as a slice (`text.peek(index)`), because a character cannot be appended to text |

`measure.tcl` runs `clean_ai_text` over `bench/ai_text_clean.tcl`'s punctuation
and emoji fixtures, 100,000 characters each, on native. Every variant returns
the same value. Re-decoded bytes and allocation counts are deterministic; the
times are best of 5, and each range spans separate runs (three for as merged,
set at program level and ripple; two for the list loop and the set per call):

| variant | punctuation | emoji | UTF-8 re-decoded (punctuation / emoji) | Strings | all objects |
|---|---:|---:|---:|---:|---:|
| as merged | 17.3-23.7 ms | 16.7-28.0 ms | 0 / 0 | 290,328 | 290,336 |
| list loop | 27.9-30.0 ms | 29.2-30.7 ms | 0 / 0 | 290,328 | 390,391 |
| set per call | 81.1-90.1 ms | 83.7-86.2 ms | 0 / 0 | 290,328 | 490,446 |
| set at program level | 3,383-3,666 ms | 3,511-3,709 ms | 5,983,665,075 / 7,118,857,948 | 100,062 | 100,072 |
| ripple | 7,197-7,463 ms | 8,191-8,395 ms | 11,378,740,608 / 13,272,530,323 | **7** | 90,222 |

(Strings and objects are the punctuation fixture's; emoji's differ only by the
input.)

What it shows:

* **The ripple is the right program and the wrong native code.** It allocates
  7 Strings where the merged program allocates 290,328 -- every character
  output unchanged is a slice of the input, never materialized. But the
  native traversal plan (`hir/traversal.tcl`) recognizes only `peek`-shaped
  width-1 slices at a zero start, so each `text.char_at(index)` decodes
  non-ASCII text from byte 0 again: 11-13 GB re-decoded, about 400 times
  slower.
* **A program-level constant costs the plan too.** `cleaner_emoji` reading a
  program-level set is a value-capturing closure with a non-Int capture,
  which `hir/specialize.tcl` keeps generic, with every caller up to
  `clean_ai_text`; a traversal plan is only ever given to a specialized
  instance. The same quadratic decode follows.
* **A List or a set built in the function is rebuilt on every call**: one
  more object per character for the List, two for the set, and the time with
  them. Today the `or` chain is the cheapest membership test.
