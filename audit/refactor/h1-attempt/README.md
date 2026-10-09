# H1 attempt: `clean_char`'s three one-character return values

Hypothesis H1 of the warning-driven refactor (REFACTOR-WARNINGS-CLEAN.md):
the three `ONE-CHAR-STRING-LITERAL` findings of
`examples/stdlib/ai_text_clean.bot`'s `clean_char` -- its one-character
*return values* `"-"`, `"'"`, `"\""` -- can reach warning-clean by program
restructure alone, on today's language and stdlib, without weakening the
function's contract and without new API.

`ai_text_clean.bot` in this directory is the attempt: the corpus program
after P3 (its comparisons read characters) with `clean_char`'s three
replacement returns rewritten as a translation table -- the punctuation marks
and, at the same positions, their ASCII normalizations, the one
literal-free spelling of a single character as text that today's surface
has (`tr(1)`'s two sets):

```botlish
marks = "–—‘’“”"
normalized = "--''\"\""
...
        loop i from 0 to str::length(marks):
            if marks.char_at(i) == c:
                return normalized.substring(i, i + 1)
```

It is not a corpus program: the gate does not compile it and nothing loads
it. It is kept as the evidence for the verdict.

## What holds

* **Warning-clean.** The file has no `ONE-CHAR-STRING-LITERAL` finding (and,
  with P4's `-> list` on its sample, no finding at all).
* **The contract is unchanged.** `clean_char` keeps its one parameter, its
  String result and its empty error set: the compiler proves
  `normalized.substring(i, i + 1)` in range from the two constants' lengths
  and the loop bound, so no `LowerUnderrun`/`UpperOverrun` joins it.
* **Behavior is identical**: the sample's value and the behavior probes of
  `audit/refactor/tools/probes/ai_text_clean.tcl` (clean_char over its whole
  documented domain, clean_ai_text over texts mixing every class) agree with
  the tree before P3 on every backend: 42 of 42 identical (`probes.txt`).
* **No new API.**

So a sound restructure **exists** -- the M6 audit's argument for "deliberate"
(the result type is a variable-length String) is not by itself an
obstruction.

## Why it is not a closing (the verdict: H1 falsified)

The milestone's verdict rule asks for a restructure that is not a
contortion. This one is, for four reasons, the first decisive:

1. **It keeps the one-character String; it only hides it.** At run time
   `normalized.substring(i, i + 1)` *is* `"-"`, `"'"` or `"\""`: the function
   still produces a single character as text, because its consumer
   (`str::concat` in `clean_from`) appends text. The warning is literals-only
   by design (a computed String is never reported), so slicing the character
   out of a longer literal removes the finding without removing what it
   reports -- the absence of a character-to-text construction. A finding
   closed this way would erase the API-deficiency datum the warning exists to
   produce.
2. **It introduces an invariant nothing states.** `marks` and `normalized`
   must have equal lengths and aligned positions; inserting a mark without
   its replacement silently re-maps every later mark, and an unequal length
   adds `LowerUnderrun`/`UpperOverrun` to `clean_char` -- a contract change
   caused by a data edit.
3. **As written, it costs the traversal.** Measured on the 10,000-character
   punctuation fixture of `bench/ai_text_clean.tcl` (native,
   `native::allocationReport`): the P3 program seeks 0 UTF-8 bytes
   (`clean_from` keeps its traversal plan); the table form seeks 60,276,313
   bytes -- `clean_from` gets no plan, and its scan is quadratic again. That
   is the table's placement, not its form (next section): reasons 1, 2 and 4
   hold wherever the table lives, and 1 is decisive.
4. **It reads worse.** Each normalization is no longer next to its
   condition; the reader counts positions in two strings, one of them full of
   escaped quotes.

## Where the cost comes from

`variants/` holds the attempt with its `marks` table spelled two ways (a
String, a List of characters) and placed two ways (program level, inside
`clean_char`); `variants/measure.tcl` measures all of them and the corpus
program at 2,000, 4,000 and 8,000 characters:

| `marks` | where | UTF-8 seek bytes | List element copies |
|---|---|---:|---:|
| String | program level (`ai_text_clean.bot`) | 2,483,588 / 9,751,421 / 38,647,782 | 6 / 6 / 6 |
| List of characters | program level (`variants/list-program.bot`) | 2,394,941 / 9,576,437 / 38,300,055 | 12 / 12 / 12 |
| String | in `clean_char` (`variants/string-local.bot`) | 88,647 / 174,984 / 347,727 | 6 / 6 / 6 |
| List of characters | in `clean_char` (`variants/list-local.bot`) | 0 / 0 / 0 | 12,336 / 24,336 / 48,336 |

The quadratic seek follows the placement: a function that reads a
program-level String or List binding is a value-capturing closure with a
non-Int capture, which `hir/specialize.tcl` keeps generic ("Which instance a
call uses"), with `clean_ai_text` and the `clean_from` instance it calls; a
traversal plan is given only to a specialized instance. Inside `clean_char`
the String table costs its own decoding (each `marks.char_at(i)` of the
non-ASCII constant decodes from byte 0: about 44 bytes a call, linear), and
the List of characters costs a rebuilt literal (six element copies a call).
REFACTOR-WARNINGS-CLEAN.md, section 15, finding 11 turns this into a
recommendation about a candidate warning.

The obstruction is therefore **character-to-text construction**: with a way
to append a character to text (`str::of_char`, or a `str::concat` that takes
a UnicodeChar, or a builder), `clean_char` could map a character to a
character and its caller append it. The three findings stay in the manifest,
tagged `H1`.
