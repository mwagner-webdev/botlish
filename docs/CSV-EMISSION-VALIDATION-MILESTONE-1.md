# CSV-EMISSION-VALIDATION-MILESTONE-1.md

Production `emits` against a second, independent serialization protocol:
CSV, with quoted fields, doubled quotation marks, record delimiters and
streaming output (`examples/dfa/csv/`, `audit/csv-emission/`,
`tests/csv-emission.test`).

> A grammar can prove that emitted symbols form valid CSV. It cannot, by
> itself, prove that they represent the intended data or that a spreadsheet
> will interpret that data safely.

This follows DFA-COROUTINE-MILESTONE-2.md (declared recognizers),
EMITTER-COROUTINE-EXPLORATION.md, MODULAR-EMISSION-PROOFS-MILESTONE-1.md and
EMISSION-CLAIMS-MILESTONE-1.md (the production clause), whose semantics it
takes as given. Unlike the JSON work, nothing here is a prototype: every
grammar is an ordinary `dfa` declaration, every emitter an ordinary function
with an ordinary `emits` clause, checked by the compiler a user runs.

## Contents

1. [Result](#1-result)
2. [Profiles and normative references](#2-profiles-and-normative-references)
3. [DFA declarations and the quotation-mark ambiguity](#3-dfa-declarations-and-the-quotation-mark-ambiguity)
4. [The always-quoted field emitter](#4-the-always-quoted-field-emitter)
5. [Selective quoting, the comparison](#5-selective-quoting-the-comparison)
6. [Records and record streams](#6-records-and-record-streams)
7. [What the compiler certifies](#7-what-the-compiler-certifies)
8. [Field and record boundaries](#8-field-and-record-boundaries)
9. [Semantic round trips](#9-semantic-round-trips)
10. [CSV injection versus formula injection](#10-csv-injection-versus-formula-injection)
11. [Errors, partial output and coroutine behavior](#11-errors-partial-output-and-coroutine-behavior)
12. [Mutation census](#12-mutation-census)
13. [Differential and exhaustive tests](#13-differential-and-exhaustive-tests)
14. [Unicode and UTF-8](#14-unicode-and-utf-8)
15. [The cleanroom exporter](#15-the-cleanroom-exporter)
16. [Native code, allocation and throughput](#16-native-code-allocation-and-throughput)
17. [Diagnostics and usability](#17-diagnostics-and-usability)
18. [Compiler changes and regressions](#18-compiler-changes-and-regressions)
19. [What `emits` could not prove](#19-what-emits-could-not-prove)
20. [Recommendation and next steps](#20-recommendation-and-next-steps)
21. [The evaluation questions](#21-the-evaluation-questions)

Appendix: [A. Files](#a-files), [B. How to rerun](#b-how-to-rerun).

## 1. Result

**`emits` generalizes to CSV without any change to its declaration, its
analysis or the DFA facility.** The two profiles (section 2) are 27 ordinary
recognizers in two modules; 52 claims on 41 emitter functions and sources
-- always-quoted fields, three-column records, record lines, streams and
documents, over ASCII codes, Unicode scalar values and UTF-8 bytes, plus
selective quoting -- are all certified by the distributed compiler, from
the declarations and the code alone, in 0.6-0.8 s of checking (section 16).

Evidence, each kept apart from the others:

* **Static.** Every claim certified (`csv-claims-certified`). The malformed
  compositions the milestone lists are each rejected with the kind of their
  mistake (`csv-malformed-compositions`). The mutation census (section
  12): 25 mutations of the emitters, every one classified as stated: 18
  rejected statically (9 whose ordinary-example runs are already invalid,
  5 latent ones the ordinary examples never trigger, 4 correct but
  uncertifiable), 7 accepted (4 grammatical but semantically wrong, 2
  stopped by a run-time guard, 1 wrong outside the claim) -- and **no
  accepted mutant with an invalid trace** (34,650 runs in all).
* **Grammatical, at run time.** 25,246 generated cases on five backends
  (126,230 runs): every completed trace one token of the claimed recognizer
  and every failed one a viable prefix, judged by the reference interpreter
  over the declarations themselves; the five backends identical, symbol for
  symbol (section 13).
* **Semantic.** The same runs judged by `oracle.py`, which reads no Botlish:
  every completed output equal to the reference serialization, read back by
  an independent strict parser and by CPython's `csv` module as exactly the
  input, and byte-identical to CPython's `csv.writer(QUOTE_ALL, CRLF)`; every
  failure at the first unrepresentable character, its partial output exactly
  the serialization of what came before it and never a complete document
  (section 9).
* **Cleanroom.** An export application built by the single-file compiler, in
  an empty environment, from the example's `.bot` files alone; its file
  checked by the oracle (section 15).
* **Native.** A claim is erased: the fused NIR of a program driving a
  certified source is identical with and without every claim, allocates no
  coroutine object, and holds no recognizer work but the guards the code
  itself calls (section 16).

**One compiler correction**, narrow and independently tested (section 18):
the checker required an Int-returning claimed function to complete with -1
(EMIT-TERMINAL-VALUE). That convention belongs to the JSON sources'
protocol, not to the trace property; a CSV source that returns the number of
records it wrote was rejected. The rule and its diagnostic are withdrawn;
the JSON sources keep returning -1 in their own code.

**What `emits` cannot carry** is equally clear (section 19): the selective
emitter's natural spelling (a fact about the whole string), a counted loop's
zero-iteration exit when the count is at least one, the UTF-8 encoder's
lead/continuation relation, the identity of the values (the census's
semantic mutants all compile), and anything a spreadsheet does with a cell.

## 2. Profiles and normative references

RFC 4180 (https://www.rfc-editor.org/rfc/rfc4180), section 2, is the
starting point:

```
file        = [header CRLF] record *(CRLF record) [CRLF]
record      = field *(COMMA field)
field       = (escaped / non-escaped)
escaped     = DQUOTE *(TEXTDATA / COMMA / CR / LF / 2DQUOTE) DQUOTE
non-escaped = *TEXTDATA
TEXTDATA    = %x20-21 / %x23-2B / %x2D-7E
```

**Profile A, strict ASCII** (`csv_strict.bot`): exactly that ABNF over ASCII
codes. Nothing outside its alphabet: no TAB, NUL, other control, DEL or
non-ASCII character. A lone CR or LF outside a quoted field is no separator.

**Profile B, UTF-8** (`csv_utf8.bot`): RFC 4180's structure unchanged --
comma separators, CRLF between records, quoting with doubling -- and one
stated policy per scalar value:

| scalar values | policy |
|---|---|
| U+0020..U+0021, U+0023..U+002B, U+002D..U+007E; U+00A0..U+10FFFF except U+2028, U+2029, U+FEFF | text: written as it is, quoted or not (supplementary planes, combining marks, noncharacters included) |
| `,` CR LF TAB U+2028 U+2029 U+FEFF | data only inside a quoted field: a separator, line breaks, a tab, two characters some readers take for line breaks, and the byte-order mark a BOM-aware reader would strip at the start of a file |
| `"` | inside a quoted field only, doubled |
| NUL, U+0001..U+0008, U+000B, U+000C, U+000E..U+001F, U+007F, U+0080..U+009F | unsupported: the emitter fails `UnsupportedCSVCharacter {at, value}` |

A document never starts with a byte-order mark (U+FEFF is only ever quoted,
and nothing writes one). The encoding is strict UTF-8 (RFC 3629): no
overlong form, no surrogate, nothing past U+10FFFF. A Botlish `str` holds
scalar values, so invalid UTF-8 exists only as bytes: a field given as
`std::abi::bytes::Bytes` is decoded strictly first (`InvalidUtf8`, never a
replacement character).

**Width and emptiness.** The records are fixed-width: exactly three fields.
The empty file is zero records (RFC 4180's ABNF would read it as one record
of one empty field, which no three-column file has; CPython's `csv` module
also reads it as zero rows).

**Excluded**, as separate policies: other separators, other quote
characters, backslash escapes, locale conventions, spreadsheet dialects.

## 3. DFA declarations and the quotation-mark ambiguity

Each profile declares, from its classes and from each other:

| recognizer | language |
|---|---|
| `quoted_field` | `"` then data or `""`, then `"` -- ending *before* the `,` or CR that follows, or at the end |
| `unquoted_field` | one or more text characters, ending the same way |
| `field` | either (`call quoted_field` / `call unquoted_field`) |
| `record3` | exactly three fields, any of them empty, separated by commas; ending before CR or at the end |
| `line3` | `record3` and its CRLF |
| `stream3` | records with CRLF between them, the last CRLF optional; the empty file |
| `document3` | `line3`*: every record a whole line (the exporters' canonical form) |
| `quoted_char`, `text_char` | one symbol of the quoted or the text class: guards |

and Profile B the same over UTF-8 bytes (`*_bytes`, with `utf8_quoted` and
`utf8_text`, the non-ASCII characters a quoted and an unquoted field hold).

The ambiguity CSV adds is the closing quotation mark: inside a quoted field
`""` is one quotation mark of data, `"` followed by `,`, CR or the end closes
the field, and `"` followed by anything else is an error. The DFA facility
states it directly, with `accept before`:

```
dfa quoted_field over ascii:
    open:
        '"' -> body
    body:
        qdata -> body
        '"' -> quote
    quote:
        '"' -> body
        ',' '\r' -> accept before
        end -> accept
```

The state `quote` is "a quotation mark was seen, its meaning not yet known".
The token ends before the separator, which is the record's: a field never
manufactures its own terminator. The reference interpreter's verdicts
(`csv-quote-ambiguity`): `"hello"`, `"he said ""hi"""` and `"hello,world"`
are tokens; `"a",` ends after 3 symbols leaving the comma; `"ab"x` is
rejected at `x` in state `quote`; `"ab` at the end is UnexpectedEnd.

Composition uses the facility's existing call semantics: `record3` calls
`field`, which calls `quoted_field`; a callee that ends before a symbol
passes it back (`then STATE` reconsiders it, `then accept` passes it on), so
the record's `s1: ',' -> f2` consumes the comma the field left. Nothing new
was needed. Two facts of the facility shaped the grammars:

* **A token is empty only when nothing was supplied and the start state
  accepts the end.** An empty unquoted field is therefore no `field` token:
  the record holds it (two separators in a row). The stream and document
  accept the empty file (`end -> accept` in their start states).
* **No parameterization.** The record, line, stream and document structure
  is spelled once per alphabet (ASCII, Unicode, bytes): the same five
  recognizers three times, differing only in their classes and callees.

The checker's step against the reference interpreter on all 27 CSV
recognizers (`emit::conformance`, `dfatest::cases`' generated inputs):
9,539, 9,551 and 9,546 cases for seeds 7, 11 and 13, **0 mismatches**
(`csv-conformance` runs seed 7) -- the outcome model of
EMISSION-CLAIMS-MILESTONE-1.md, section 6, on grammars it was not written
for.

## 4. The always-quoted field emitter

```
fn quoted_field(value: str) -> unit errors csv_common::UnsupportedCSVCharacter emits csv_strict::quoted_field, csv_strict::field:
    yield 34
    loop i from 0 to value.length():
        c = value.char_at(i).scalar_value()
        if c == 34:
            yield 34
            yield 34
        else:
            csv_strict::quoted_char(c):
                on std::dfa::UnrecognizedInput:
                    fail csv_common::UnsupportedCSVCharacter {at: i, value: c}
                on std::dfa::UnexpectedEnd:
                    fail csv_common::UnsupportedCSVCharacter {at: i, value: c}
            yield c
        continue
    yield 34
    unit
```

This is what a serializer looks like anyway. The one dynamic check is the
profile's own restriction, written as a call of the grammar's guard
`quoted_char` -- a recognizer of one symbol of the quoted class -- so the
emitter holds no second, hand-written list of what is allowed; the checker
narrows `c` to that class on the guard's normal path. Certified for every
`str` from its declaration alone, against both `quoted_field` and `field`.
Profile B's emitters are the same text with `csv_utf8`'s guard; the byte
emitter adds the UTF-8 encoder (section 14).

`UnexpectedEnd` must be handled although `c` is never -1: the guard is a
function of an Int that fails `UnexpectedEnd` at the end (-1), and without
the handler the compiler reports the call's error unhandled (UNHANDLED-
ERROR) -- it does not exclude that error from `scalar_value`'s
nonnegative result. One more handler, never taken.

## 5. Selective quoting, the comparison

Policy: a field is written unquoted when the grammar's text class holds
every character and it is not empty; otherwise quoted. The decision reads
the grammar's guard (`text_char`), never a list of its own.

| spelling | verdict | why |
|---|---|---|
| *natural*: decide, then yield the characters of the unquoted branch as they are | rejected (EMIT-REJECTED, -BEYOND-TOKEN, -INCOMPLETE) -- correct, not certifiable | "needs_quotes returned false" is a fact about the whole string; each character the branch yields is, to the checker, any scalar value |
| guarded: each character of the unquoted branch passed through `text_char` again | rejected (EMIT-INCOMPLETE) -- correct, not certifiable | the checker keeps a counted loop's zero-iteration exit even when the count is at least one (`n == 0` was excluded), so the branch "may" emit nothing |
| guarded, first character peeled before the loop | **certified** | (shipped: `selective_emit::field`, `field_strict`) |

The obstacle is the milestone's first kind -- a missing *value fact* that
relates program state to grammar state -- twice: a relation between a
loop's result and later values (relational, deliberately out of scope), and
the iteration count (not relational: a single-value fact about `n` the loop
transfer drops). Neither needs the emitter to encode DFA states; both need
it to restate a fact the compiler cannot carry. The certified spelling pays
for it with a second guard per character, which can never fail
(`QuotingDecision`, a declared error that is never raised), and an unrolled
first iteration. Records and documents composed from the *uncertified*
selective field are still certified: the record grammar holds the empty
field, so the record-level claim needs neither fact
(`selective_emit::record3_strict` was certified even while the field's own
claim was rejected).

Cost of the comparison: the always-quoted field is 17 lines and one guard
per character; the certified selective field 22 lines plus a 12-line
decision, two guards per character of an unquoted field and one per
character of a quoted one. Throughput in section 16; mutation coverage in
section 12 (its `selective-*` mutants).

## 6. Records and record streams

```
nomethod fn record3(a: str, b: str, c: str) -> unit errors csv_common::UnsupportedCSVCharacter emits csv_strict::record3:
    quoted_field(a)
    yield 44
    quoted_field(b)
    yield 44
    quoted_field(c)
    unit

fn stream(rows: List[csv_common::Row]) -> unit errors csv_common::UnsupportedCSVCharacter emits csv_strict::stream3, csv_strict::document3:
    loop r in rows:
        row_line(r)
        continue
    unit
```

Each level is certified on its own and composed through the lower level's
**certificate**, never its body: `record3` composes with `quoted_field`'s
statement (its exit states and its open boundary obligation: the token
ends before `,` or CR), and the comma it yields discharges that obligation.
`line3`, `row_line`, `stream`, `stream_unterminated` (CRLF between records,
none after the last: `stream3` only) and `document` (a header, then the
records) compose the same way, for every number of records including zero.

The malformed compositions the milestone lists, each a claimed function
(`csv-malformed-compositions`):

| mistake | verdict |
|---|---|
| a separator omitted: `"a","b""c"` -- two fields merge into one holding a quotation mark | EMIT-BOUNDARY |
| two separators: an empty fourth column | EMIT-REJECTED |
| a trailing separator | EMIT-REJECTED |
| a quote closed early: `"a"b"` | EMIT-REJECTED |
| a quotation mark not doubled: `""a"` | EMIT-REJECTED |
| text after a completed field | EMIT-REJECTED |
| text after a completed line | EMIT-AFTER-TOKEN |
| an unquoted CRLF inside a value: `"a"\r\n"b"` | EMIT-BEYOND-TOKEN |
| two fields glued without a boundary | EMIT-BOUNDARY |
| the unterminated stream claimed as a document | EMIT-INCOMPLETE (`csv-unterminated-not-document`) |
| an emitter that may write nothing claiming a field | EMIT-INCOMPLETE (`csv-empty-not-field`) |

All rejected statically; which of them a run would also catch, and on which
input, is the census's business (section 12).

## 7. What the compiler certifies

For every argument tuple the declaration permits (every `str`, every
`List[Row]`):

1. every completion has yielded exactly one token of the claimed recognizer,
   nothing unread; and
2. every finite prefix -- before completion, at a failure, when the consumer
   stops -- is a viable prefix.

Proved statically, for the CSV claims:

* a quoted field is opened, its every quotation mark doubled, closed, and
  followed by nothing but a separator, a CR or the end;
* every character written raw is in the profile's class for its position
  (quoted or not) -- NUL, controls, C1, DEL, or (Profile A) non-ASCII never
  reach the output;
* a record has exactly three fields with separators in their places; a
  stream's records are separated (or terminated) by CRLF exactly;
* every byte sequence is strict UTF-8 of an admissible scalar;
* across helpers, the boundary obligations: nothing a caller writes after a
  field can continue it.

Not by `emits`, and kept apart: that the decoded fields equal the input
(section 9: runtime tests), how a spreadsheet interprets a cell (section 10:
outside the grammar), and what a source's final value means (section 18).

## 8. Field and record boundaries

The security motivation: a value such as `hello","admin` must stay one
field. Three properties, tested separately:

**A. Syntactic.** Certified (section 7) for every input.

**B. Structural.** For the fixed-width grammars this is *also* certified:
`record3` is exactly three fields, so a certified record emitter cannot
produce a fourth column or a second record, whatever its input -- the
regular-language constraint is the field count itself. Concretely, the
census's `comma-outside` mutant (writing a value's comma outside the
quotes, the injection bug) and `crlf-outside` (a value's line break as a
record separator) are rejected at compile time (EMIT-BEYOND-TOKEN), the
latter although the ordinary examples have no line break at all.

**C. Semantic.** *Not* certified: a certified emitter could write three
valid fields of the wrong values. Section 9 tests it; the census's semantic
mutants (section 12) show the gap is real -- each compiles.

On the injection value itself (`csv-injection-boundaries`): `hello","admin`
in all three columns is written `"hello"",""admin"` three times, and CPython
reads one record of three fields, each `hello","admin`. The exporter's table
carries the value in a record and a value that tries to end the record and
open a new one (`x"\r\n"evil","=1+2","z`): one field each.

## 9. Semantic round trips

`audit/csv-emission/tools/oracle.py` restates the profiles from RFC 4180 and
section 2, parses with its own strict parser, and uses CPython's `csv`
module (`delimiter=','`, `quotechar='"'`, `doublequote=True`,
`strict=True`, text read with `newline=''` so embedded line breaks reach the
parser unchanged). It never reads a Botlish file. For each completed run:

| check | statement |
|---|---|
| expected | the input is representable, and the source's final value is the number of records (or characters) |
| reference | the output equals the reference serialization written in the oracle from the policy, symbol for symbol |
| strict | the oracle's strict parser reads back exactly the input's records and fields |
| csvmodule | `csv.reader` reads back exactly the input |
| csvwriter | for the always-quoted documents, `csv.writer(QUOTE_ALL, lineterminator='\r\n')` writes exactly the same text |
| utf8 | bytes decode as strict UTF-8 (CPython's codec: no overlong form, no surrogate) and do not start with a BOM |

and for each failed run: `expected` (the first unrepresentable character,
its index in its field and its value), `prefix` (the partial output is the
reference serialization of everything before it) and `incomplete` (the
strict parser refuses the partial output as a document).

All 25,246 cases pass every check that applies (section 13). The
established parser is more permissive than the profile, as expected; the
oracle's self-test records where (`python3 -I oracle.py selftest`): of 25
hand-written documents, `csv.reader` accepts 12 that the strict profile
rejects -- a quotation mark inside an unquoted field (`a"b`), two and four
fields, bare LF and bare CR line ends, an empty line, a non-ASCII field in
Profile A, an unquoted TAB or U+2028, a leading BOM (kept as data), NUL, a
C1 control. Validity is the profile's; `csv.reader` decides only the
semantic round trip of documents the profile accepts.

## 10. CSV injection versus formula injection

CSV quoting does not prevent spreadsheet formula interpretation
(https://owasp.org/www-community/attacks/CSV_Injection). The probes and the
exporter write `=1+2`, `+1+2`, `@SUM(1,2)`, `-2+3` and a boundary-escape
attempt followed by `=1+2`:

```
"=1+2","+1+2","@SUM(1,2)"
"103","hello"",""admin","a value that tries to open a column"
"104","x""
""evil"",""=1+2"",""z","a value that tries to end the record"
```

Every field is valid CSV, quoted, and decodes to exactly its input
(`csv-formula-unchanged`, the exporter's oracle check). The boundary attempt
stays inside its field: no new cell begins with `=`. But a spreadsheet that
opens the file may still evaluate the cell `=1+2` -- its decoded value is
`=1+2`, which is what the input asked for. **Nothing here claims protection
against formula interpretation.** No sanitization is implemented: prefixing
a quote or apostrophe changes the value, how it round-trips depends on the
target application (import, export, save and reopen), and that is a policy
for a spreadsheet-specific exporter, outside the grammar and outside this
milestone.

## 11. Errors, partial output and coroutine behavior

The emitters are ordinary functions; `sources.bot` runs each inside a
coroutine root, and `sinks.bot` consumes them. Tested on every backend --
the reference interpreter, the Tcl compiler, the generic and the fused
native backends and the general coroutine runtime -- with identical results
(`csv-backends-agree`, `probes.bot`):

| behavior | observed |
|---|---|
| eager construction | the first symbol is the construction's value (`"`) |
| deep yields | the bytes come from `quoted_field_bytes` and `utf8` inside `record3_bytes` inside `document_bytes` inside the root |
| completion, stable terminal | the final value (records written, header included) read after `done?`; resumed three more times it answers the same and stays done |
| failure before the first symbol | invalid UTF-8 bytes fail `InvalidUtf8` at construction, nothing written |
| failure mid-field | NUL in a later record: the sink holds the header and the first record whole, then `"102","still","x` -- the failing field opened, never closed; `UnsupportedCSVCharacter {at: 1, value: 0}` |
| failure after a completed field | the same: the record's earlier fields and their separators are written, the record is not complete |
| a Profile A field with a non-ASCII character | fails after the opening quotation mark only (`{at: 0, value: 233}`) |
| consumer abandonment | the first 7 bytes, then the emitter's handle released, never resumed |
| sink failure mid-field | a sink full after 30 bytes fails `SinkFull` inside a quoted field |
| chunk boundaries | chunks of 3 end inside a doubled quotation mark and inside the final CRLF; chunks of 2 split UTF-8 sequences (six chunks begin with a continuation byte); the concatenation is always the document |
| zero records | the empty stream |
| both CRLF forms | `stream` and `stream_unterminated` |

The viable-prefix guarantee is not atomicity: after a failure the sink holds
an unfinished quoted field, a viable prefix and never a complete document
(the oracle's `incomplete` check on every failed case). A consumer that
needs all or nothing buffers (`sinks::validated_bytes` beside the
streaming sinks) or writes to a temporary file it renames.

**Terminal values.** A claim is about yields, not results (section 18):
the CSV sources return the number of records they wrote, and the consumers
read it after `done?`; the JSON sources still return -1, the end their
own consumers' protocol uses.

## 12. Mutation census

`audit/csv-emission/tools/census.tcl` applies each of
`audit/csv-emission/census/mutants.txt`'s mutations alone to a private copy
of the example (a mutation changes an emitter, never a declared
recognizer), compiles every emitter module, then runs the mutated emitters
(claims removed: a claim is erased) on the **ordinary examples** -- a small
realistic table: names, a comma, a quoted nickname, ASCII, no control, no
line break -- and on the **adversarial inputs** (every corpus value of
section 13 in every source kind, every string of length 0..3 over
`{a , " CR LF}` in six contexts), judging traces by the declared recognizer
and outputs by `oracle.py`. Its class is computed from those facts:

| class | meaning |
|---|---|
| static | rejected, and the ordinary examples' runs already show an invalid trace |
| static-latent | rejected; the ordinary runs are valid; an adversarial run shows an invalid trace |
| unprovable | rejected; no run finds an invalid or wrong output: correct code the checker cannot certify (a precision limit, never reported as a bug) |
| guard / guard-latent | accepted; a run fails with a declared error where the reference completes: a run-time guard stops the mistake before anything wrong is written |
| semantic | accepted; every trace grammatical, outputs wrong |
| outside | accepted; every trace grammatical and every value right, something outside the claim wrong |

`results/census.md` has each mutant's rejected claims and run counts. In
the table, as ordinary / adversarial (the ordinary set is 54 runs, the
adversarial set 1,332: 396 corpus cases and 936 exhaustive ones),
*invalid* counts runs whose trace the declared recognizer rejects, *wrong*
the oracle's failed checks (a run may fail several: reference, strict,
csvmodule, ...), and *stopped* runs a guard failed where the reference
completes.

| mutant | the mistake | compiler | invalid | wrong | stopped | class |
|---|---|---|---:|---:|---:|---|
| `no-doubling` | an embedded quotation mark written once | rejected: EMIT-REJECTED, -INCOMPLETE, -BEYOND-TOKEN, -AFTER-TOKEN, -BOUNDARY | 3 / 335 | 9 / 1137 | 0 / 0 | static |
| `tripled-quote` | written three times | rejected: the same five | 3 / 335 | 9 / 1137 | 0 / 0 | static |
| `no-closing-quote` | the closing quotation mark omitted | rejected: EMIT-INCOMPLETE, -BOUNDARY | 14 / 552 | 42 / 1632 | 0 / 0 | static |
| `no-opening-quote` | the opening one omitted | rejected: all five | 14 / 560 | 43 / 1666 | 0 / 0 | static |
| `quote-after-close` | a quotation mark after the closing one | rejected: EMIT-INCOMPLETE, -BOUNDARY | 14 / 552 | 42 / 1632 | 0 / 0 | static |
| `comma-outside` | a value's comma written outside the quotes (close, comma, reopen) | rejected: EMIT-BEYOND-TOKEN, -REJECTED | 3 / 240 | 10 / 800 | 0 / 0 | static |
| `crlf-outside` | a value's LF written as an unquoted CRLF | rejected: EMIT-BEYOND-TOKEN, -INCOMPLETE, -AFTER-TOKEN, -REJECTED | 0 / 234 | 0 / 780 | 0 / 0 | static-latent |
| `missing-separator` | the second separator omitted | rejected: EMIT-BOUNDARY | 1 / 192 | 4 / 732 | 0 / 0 | static |
| `extra-separator` | a separator written twice | rejected: EMIT-REJECTED | 1 / 192 | 4 / 732 | 0 / 0 | static |
| `trailing-separator` | a separator after the last field | rejected: EMIT-REJECTED | 1 / 192 | 4 / 732 | 0 / 0 | static |
| `handwritten-ascii` | the guard replaced by `c >= 32 or c == 10 or c == 13` (no upper bound) | rejected: EMIT-REJECTED | 0 / 27 | 0 / 27 | 0 / 0 | static-latent |
| `guard-caught-continues` | the guard's failure caught and the character written anyway | rejected: EMIT-REJECTED | 0 / 36 | 0 / 36 | 0 / 0 | static-latent |
| `guard-strips` | the guard's failure caught and the character skipped | accepted | 0 / 0 | 0 / 36 | 0 / 0 | semantic |
| `drop-first-char` | every field's first character dropped | accepted | 0 / 0 | 40 / 1818 | 0 / 0 | semantic |
| `field-order` | a record's second and third fields swapped | accepted | 0 / 0 | 4 / 728 | 0 / 0 | semantic |
| `header-twice` | the header written twice | accepted | 0 / 0 | 4 / 732 | 0 / 0 | semantic |
| `bytes-unguarded` | the byte emitter's guard removed | rejected: EMIT-REJECTED | 0 / 16 | 0 / 16 | 0 / 0 | static-latent |
| `utf8-bad-lead` | a two-byte lead from `v >> 7` | rejected: EMIT-REJECTED | 0 / 4 | 0 / 22 | 0 / 0 | static-latent |
| `utf8-no-e0-split` | E0 merged into E1..EC (the same bytes) | rejected: EMIT-REJECTED | 0 / 0 | 0 / 0 | 0 / 0 | unprovable |
| `selective-natural-claimed` | the natural selective field, claimed | rejected: EMIT-REJECTED, -BEYOND-TOKEN, -INCOMPLETE | 0 / 0 | 0 / 0 | 0 / 0 | unprovable |
| `selective-unpeeled` | the guarded loop without its peeled first character | rejected: EMIT-INCOMPLETE | 0 / 0 | 0 / 0 | 0 / 0 | unprovable |
| `selective-guard-weakened` | the unquoted branch guarded by the quoted class | rejected: EMIT-BEYOND-TOKEN, -AFTER-TOKEN, -REJECTED | 0 / 0 | 0 / 0 | 0 / 0 | unprovable |
| `selective-wrong-decision` | the decision reads the quoted class | accepted | 0 / 0 | 0 / 0 | 1 / 87 | guard |
| `selective-classic-rule` | the decision as "a comma, a quotation mark, CR or LF" | accepted | 0 / 0 | 0 / 0 | 0 / 14 | guard-latent |
| `final-value` | a source's record count off by one | accepted | 0 / 0 | 0 / 0 (33 wrong final values) | 0 / 0 | outside |

What the census shows:

* **No false proof.** Every accepted mutant's every trace is grammatical;
  every invalid trace any run produced belongs to a mutant the compiler
  rejected.
* **Latent mistakes are caught before any input shows them.** Five
  rejected mutants produce no invalid output on the ordinary table -- a
  value's line break turned into a record separator, a handwritten ASCII
  check without its upper bound, a guard's failure caught and execution
  continued, the byte emitter's guard removed, a wrong UTF-8 lead shift --
  and the compiler rejects each from the code alone; the adversarial runs
  then confirm each with invalid traces (as few as 4 of 1,332 for
  `utf8-bad-lead`, which only characters U+00C0..U+00FF reach).
* **Precision limits are reported as such.** Four rejected mutants have no
  invalid and no wrong run: correct code the checker cannot certify --
  two relations (a whole-string decision, a lead byte constraining the
  next), the zero-iteration exit, and a weakened guard whose safety rests
  on the decision before it. The message says "may" for each; none is
  counted as a bug.
* **Semantic corruption compiles.** Four mutants write valid CSV of the
  wrong values -- including `guard-strips`, which silently drops what the
  profile cannot hold, the exact behavior the milestone forbids -- and only
  the round trips catch them. `header-twice` changes the number of records
  and stays valid: the record *count* of a stream is outside its grammar.
* **Guards turn mistakes into failures.** The selective emitter's
  re-guarding (section 5) is what makes its claim certifiable; the census
  shows its other value: a wrong quoting decision (`selective-wrong-
  decision`, `selective-classic-rule`, the latter the common real-world
  rule that forgets TAB, U+2028, U+2029 and U+FEFF) fails `QuotingDecision`
  instead of writing an unquoted field the profile forbids. The classic
  rule also changes which error an unsupported character raises
  (`QuotingDecision`, not `UnsupportedCSVCharacter`) -- nothing wrong is
  written, but the error is not the profile's. (The census's first run
  counted those 8 runs as wrong outputs; oracle.py now tells a run stopped
  by another guard from a wrong output, and the mutant was rerun alone.)
* **Outside the claim.** A source's final value is no symbol; only its
  consumer's check sees it off by one.

## 13. Differential and exhaustive tests

`audit/csv-emission/tools/differential.tcl` (`results/differential.md`),
every case on the reference interpreter, the Tcl compiler,
`cranelift-generic`, `cranelift` (fused) and `cranelift-unfused` (the
general coroutine runtime):

| part | cases | outcomes | backends disagree | recognizer rejects | oracle failures |
|---|---:|---|---:|---:|---:|
| corpus: the milestone's 36 input classes, each as a field of every kind, as each column of a record of every document kind, in an unterminated stream, and all together as documents; zero, one and several records; six invalid UTF-8 byte strings | 850 | 696 completed, 148 unsupported, 6 invalid UTF-8 | 0 | 0 | 0 |
| exhaustive: every string of length 0..5 over `{a , " CR LF}` (3,906 strings) in six contexts -- each field kind, between fields beginning and ending with quotation marks, as every field of two records, in an unterminated stream | 23,436 | all completed | 0 | 0 | 0 |
| fuzz: 8 seeds x 120 random documents (0-5 rows; fields from weighted pools: ASCII, separators, quotation marks, CR/LF/CRLF, TAB, Latin-1, combining marks, CJK, supplementary, U+2028/9, U+FEFF, noncharacters; one field in fifty with a character its profile cannot hold) | 960 | 813 completed, 147 unsupported | 0 | 0 | 0 |
| **total** | **25,246 (126,230 runs)** | | **0** | **0** | **0** |

The input classes: empty; ASCII; commas; one, two, three, four and 41
quotation marks; a quotation mark before a comma and before CRLF; CR, LF and
CRLF; fields beginning and ending with quotation marks; 2,100 characters of
`abc,"\r\n`; supplementary characters; combining marks; U+2028/U+2029;
U+FEFF; TAB; NUL; BEL; DEL; NEL; the formula prefixes; the injection values;
a field holding a complete record and one holding separators; Latin-1; CJK;
noncharacters.

The exhaustive bound is exactly length <= 5 over five symbols; no claim of
exhaustive Unicode coverage is made. The fuzzer's inputs are drawn from
character pools, never from the grammar's own generator, so they test the
value-to-output transformation, not the grammar against itself.

## 14. Unicode and UTF-8

* **Scalar values.** Profile B's emitters over scalar values pass the
  supplementary planes, combining marks, CJK and noncharacters through as
  they are, quote TAB, U+2028, U+2029 and U+FEFF, and refuse NUL, the other
  controls, DEL and the C1 controls -- in every input class and the fuzzer's
  pools, on every backend.
* **Bytes.** `utf8_emit::utf8` encodes in the byte grammar's case structure
  (C2, C3..DF, E0, E1..EC, ED, EE..EF, F0, F1..F3, F4): `utf8_quoted`'s lead
  classes constrain the next byte, and the checker's facts are single-value
  sets, so each lead class is a branch (EMISSION-CLAIMS-MILESTONE-1.md,
  section 19). Merging E0 into E1..EC writes the same bytes and is no longer
  certifiable (census `utf8-no-e0-split`); computing a lead from the wrong
  shift is rejected statically although ordinary ASCII data never reaches it
  (census `utf8-bad-lead`).
* **The byte grammar is checked twice**: against strict decoding by CPython
  (every byte output of section 13) and on hand-written sequences
  (`csv-byte-profile`: C2 85, C0 80, E0 80 80, ED A0 80 and F4 90 80 80
  rejected; C2 A0 and F0 9F 98 80 accepted; U+2028 and U+FEFF only quoted).
* **Invalid UTF-8 input** exists only as bytes:
  `quoted_field_from_bytes(data: Bytes)` decodes strictly before yielding
  (overlong, encoded surrogate, past U+10FFFF, truncated, stray
  continuation, 0xFF: all `InvalidUtf8`, nothing written).
* **The BOM** is never written; a value starting with U+FEFF is quoted, so
  the output starts with `"` (`csv-no-leading-bom`).
* **Both paths, scalar and byte, are implemented.** The byte path is the
  one a file or socket takes; the scalar path is what text-level consumers
  (and the selective comparison) use.

## 15. The cleanroom exporter

`examples/dfa/csv/export.bot` is an ordinary program over the example's
modules: a table of ten records (the header; names; a quoted nickname; the
injection value; a value that tries to end the record; formula prefixes; a
multiline value with a bare LF; a TAB; Latin-1, euro sign, emoji and CJK;
an empty field and four quotation marks), streamed into the file named by
its argument through `sources::bytes_document_source`, 4,096 bytes at a
time: the file is truncated, then each chunk appended as it fills
(`std::linux::fs`), so only the current chunk is ever held. On success it
reports the source's final value ("wrote 10 records to ..."); a value the
profile cannot hold stops it with a message naming the character.

Built three ways, each output byte-identical and accepted by `oracle.py
export` (403 bytes, 10 records: strict UTF-8, no BOM, the strict parser and
`csv.reader` reading exactly the table, `csv.writer(QUOTE_ALL)` writing
exactly the file):

* `main.tcl -backend cranelift -argv export -argv out.csv export.bot`;
* `main.tcl -emit-native-executable export.bot`, the executable run with
  nothing on PATH (`csv-exporter`);
* **the single-file compiler** (`single/build.sh`'s `single/out/botlish`,
  this branch's), run by `audit/csv-emission/tools/cleanroom.sh` with an
  empty environment (`env -i`, a fresh HOME) from a directory holding only
  the example's `.bot` files -- no checkout, no tclsh, no Rust toolchain on
  the compiler's side, no emission tool -- linking with the stub linker;
  the executable then runs with `PATH=/nonexistent`.

Nothing in the build is CSV- or emission-specific: the claims are checked by
the compiler's ordinary path, and nobody inspects HIR or runs a Tcl script.
No CSV library is packaged or published.

Two frictions of the environment, not of `emits`: a native executable
prints its program's final value on standard output (here `unit`, after the
exporter's own work), which is why the exporter writes a file rather than
standard output; and a consumer receives the source's symbols as `int`
(a resume's value has its type, not the source's certificate), so the
exporter narrows each one to a `Byte` before buffering it -- one comparison
per byte that the certificate makes redundant but cannot remove.

## 16. Native code, allocation and throughput

`audit/csv-emission/tools/bench.tcl` (`results/bench.md`), the native
backend (cranelift, fused unless stated), the in-process certificate memo
off:

ns per output symbol (best of 5 in-process runs, median of 3 interleaved
rounds; `results/bench.md`). `short`: a header and 20,000 records of short
fields (quotation marks, commas, a CRLF; 842,261 bytes). `large-ascii`: 6
records whose two large fields are 70,000 ASCII characters each. `large`:
the same with a non-ASCII chunk (euro sign, emoji, accented letters) and
5,600-character fields.

| variant | short | large-ascii | large (non-ASCII) |
|---|---:|---:|---:|
| certified: always-quoted UTF-8 bytes, fused | 38.84 | 37.81 | 1,718 |
| unclaimed: the same, every claim removed | 38.32 | 38.41 | 1,747 |
| validated: certified + document3_bytes fed every byte at run time | 45.84 | 44.78 | 1,675 |
| general: certified, fusion off (general coroutine runtime) | 92.76 | 96.24 | 1,763 |
| scalar: always-quoted, scalar values (no UTF-8 encoding) | 19.06 | 17.83 | 2,051 |
| selective: scalar values | 28.98 | 19.96 | 2,135 |
| buffered: conventional, no coroutine, MutableVector of bytes | 29.39 | 26.53 | 1,707 |

Resources, short shape:

| variant | allocations | coroutine objects | code bytes | NIR table loads / switches / `dfa#transition` | NIR branches | front end | of it, emission check |
|---|---:|---:|---:|---|---:|---:|---:|
| certified | 40,006 | 0 | 30,191 | 0 / 1 / 1 | 383 | 4,097 ms | 821 ms |
| unclaimed | 40,006 | 0 | 30,191 | 0 / 1 / 1 | 383 | 3,100 ms | 0 |
| validated | 40,006 | 0 | 70,512 | 108 / 1 / 55 | 767 | 5,036 ms | 676 ms |
| general | 40,008 | 1 | 7,042 | 0 / 1 / 1 | 32 | 4,665 ms | 734 ms |
| scalar | 40,006 | 0 | 10,830 | 0 / 1 / 1 | 107 | 3,789 ms | 614 ms |
| selective | 73,343 | 0 | 27,743 | 0 / 2 / 2 | 212 | 3,537 ms | 650 ms |
| buffered | 40,009 | 0 | 4,917 | 0 / 1 / 1 | 17 | 3,655 ms | 668 ms |

* **A claim costs nothing at run time.** The certified and unclaimed
  programs' fused NIR is identical (the tool compares them, and
  `csv-native-erasure` pins it); their times differ by run-to-run noise
  (38.84 against 38.32, 37.81 against 38.41 ns/byte). The one recognizer
  dispatch in both is the guard's: `csv_utf8::quoted_char#run`'s one NIR
  `switch` over the quoted class's ranges (the column's `dfa#transition`
  is the text of its internal-error branch), the profile's own run-time
  check, which the unclaimed code has as well; the claim adds no table, no
  transition and no branch.
* **What the proof saves** is the validated variant's work: feeding every
  byte to `document3_bytes` as it is emitted costs 7 ns per byte (+18%),
  2.3 times the code, 108 table loads and 55 transition sites -- the
  run-time alternative a certificate makes unnecessary.
* **Fusion matters more than anything else.** The fused emitter runs at
  2.4 times the speed of the same code on the general coroutine runtime
  (one coroutine object, a stack switch per byte). Every sink here
  constructs and resumes its source in one function, so fusion applies;
  a handle passed to another function (as `examples/dfa/json/sinks.bot`'s
  `drain` takes one) keeps the general runtime.
* **Escaping work, not proof work, is the cost.** Over scalar values
  (no UTF-8 encoding) the same policy runs at 19 ns per symbol; the byte
  path's encoder and the larger fused code double it. The selective
  emitter's decision scan and second guard cost 50% over always-quoting on
  short ASCII fields (29 against 19 ns), and almost nothing on long ones
  (20 against 18), where each field's decision is made once. Its extra
  33,000 allocations are one empty List per unquoted field: the guarded
  loop is the value of an `if` branch, so it collects (nothing) -- a `unit`
  after it would remove them; code shape, not claims.
* **Streaming costs little against buffering.** The conventional
  serializer, pushing the same bytes into a MutableVector and then
  checksumming it, runs at 29 ns per byte against the stream's 39 -- and
  holds the whole output (842 KB of Ints) where the stream holds one byte.
* **Short and large ASCII records cost the same per byte** (38.8 and 37.8
  ns): the emitters are linear. **Large non-ASCII fields are quadratic in
  every variant, claimed or not, buffered or streamed**: `std::str::char_at`
  locates character *i* of a non-ASCII String by decoding from its start
  (native `runtime/ops.rs`'s `char_at_index`), so a loop over a 5,600-
  character field costs ~1,700 ns per symbol (at 56,000 characters, the
  benchmark's first run, ~17,000). A linear way to walk a String's
  characters is the fix (section 20); it is no property of `emits`.

**Compilation.** Checking the 52 claims of the CSV modules takes 0.59-0.76 s
(three compilations; 207 summaries computed, 121 reused, 104 fixpoint
rounds; composition with certificates 0.44-0.54 s of it, certificates
0.04-0.05 s), within whole compilations of 3.6-4.8 s that vary as much
between runs (the same modules with every claim removed: 3.7-4.8 s). The
in-process memo makes a later compilation of the same modules reuse every
certificate (the benchmark's first runs showed 648 ms for the first variant
and 40-60 ms for the others until it was turned off).

## 17. Diagnostics and usability

The diagnostics needed no change; the existing EMIT-* kinds describe CSV
mistakes precisely. Writing one undoubled quotation mark into
`strict_emit::quoted_field` gives, among others:

```
strict_emit.bot:40:13: strict_emit::quoted_field's claim to emit csv_strict::quoted_field: this yield may
  send a symbol the token ends before ("accept before"), which would begin the next token: '\r' ','
  in state quote of csv_strict::quoted_field (CORE SEMANTIC EMIT-BEYOND-TOKEN)
note: csv_strict.bot:54:5: state quote of csv_strict::quoted_field is declared here
help: tclsh9.0 main.tcl -help error.emit-beyond-token
```

-- the yield of the value's character, the state (`quote`: a quotation mark
was just seen), the symbols (a comma or CR there ends the field), the state's
declaration. That is the injection bug, explained in the grammar's terms.
Each diagnostic is primary-located at the yield or call, relates the claim,
and notes the state's declaration (`csv-diagnostic-located`); the strict
compilation raises the first.

* **Real, abstract, unsupported.** A rejection's message says "may": the
  facts over-approximate. The census tells the cases apart by running them:
  `static` mutants have invalid runs, `unprovable` ones none. The checker
  never claimed a precision limit to be a bug (its wording), and the census
  never counted one as a soundness failure.
* **`static compile`** pins an intentional rejection by its
  `DiagnosticCode` (`csv-static-compile`: the undoubled emitter's block is
  rejected with EmitIncomplete -- the first diagnostic: an undoubled
  quotation mark may leave the field open), and shows a subtle point: the
  same emitter *without* the doubling branch at all is accepted -- the guard
  admits no quotation mark, so such a value fails `UnsupportedCSVCharacter`
  rather than corrupting the field.
* **The compiler service** hovers a CSV emitter with its guarantee, one line
  per claim, including its boundary ("its token ends at the end of the input
  or before '\r' ','"; `csv-service-hover`), and navigates from a claim's
  recognizer name to the `dfa` declaration in csv_strict.bot, listing the
  claims among its references (`csv-service-navigation`). The language
  server consumes the same facts.
* **Friction.** `UnexpectedEnd` must be handled at every guard (section 4).
  The warning gate asked for `nomethod` on the record functions (their
  arguments are a record's fields) and on multi-argument sinks; one-character
  String literals in the probes became longer values. Selective quoting
  needs two restatements the compiler cannot infer (section 5).

## 18. Compiler changes and regressions

**One change: a claim's result is no symbol.** The checker required a
claimed function whose declared result is an Int to complete with -1
(EMIT-TERMINAL-VALUE, on the ground that a consumer reading values after
the end would take any other Int for a symbol). A coroutine root's outward type *is* its
declared result (COROUTINES.md, section 19), so every CSV source returns an
Int, and returning the number of records written was rejected. The
convention is the JSON sources' protocol -- their consumers resume past the
end and read -1 -- not a property of the yield trace: a consumer tells the
end by `std::coroutine::done?`, as every sink here and in
`examples/dfa/json` does.

The correction is narrow:

* `hir/emission.tcl`: the -1 check removed; the result stays in the
  certificate (composition reads it), and a comment says why.
* EMIT-TERMINAL-VALUE no longer exists: its `std::compiler::DiagnosticCode`
  case (`EmitTerminalValue`, `stdlib/compiler.bot`; `hir/static.tcl`'s
  table; `std::test`'s lists), its Compilerpedia topic, and the concept
  page's sentence (now: a source may complete with any value). A case no
  diagnostic can produce would fail `sc-census-exhaustive`.
* **Regressions:** `ec-result-not-symbol` (a source returning its argument,
  0 and -1 are all certified) and `ec-result-not-symbol-runs` (its consumer
  reads the symbol, then the unrelated result after `done?`, stable when
  resumed again, on every backend) replace `ec-terminal-value`.
* **The JSON protocol is preserved**: `examples/dfa/json`'s sources still
  return -1 in their code, `sinks::after_end` still reads it, and its tests
  pass unchanged. The emission census's `terminal-value` mistake (a JSON
  root completing with 0) is now `accepted`, recorded as a change from the
  exploratory checker's verdict.
* Counts and generated files that follow: the code tables' 140 cases ->
  139 (`sc-codes-one-to-one`, `gf-code-name-complete`); the golden manifest,
  its census and names; `audit/stdlib-census/after.tsv` regenerated;
  EMISSION-CLAIMS-MILESTONE-1.md annotated where it states the rule.

Not changed: the DFA facility, the emission analysis's rules, coroutine
completion, return types, fusion.

**Regression runs** (private temporary directories): each file run directly -- interval-sets
(35), dfa (85), dfa-workloads (21), static-compile (83), golden-framework
(42), compilerpedia (42), emission-claims (84), csv-emission (34) -- all
passed; `tests/local.tcl` narrowed to emission-claims, static-compile,
golden-framework, csv-emission, dfa and dfa-workloads (313 Tcl tests on
interp and on compile, golden duplicates skipped; the golden suites
holding their ports -- errors.bot, framework-semantics.bot,
diagnostics.bot, static-compile.bot -- 161 tests on all four backends):
all passed. `tools/compilerpedia.tcl check`: 0 problems.
`audit/emission-claims/tools/mutate.tcl`: 57 of 57 mutants killed (none
had relied on the removed test). The emission census's `terminal-value`
mistake: accepted, as now expected. Not run locally: the whole
`tests/local.tcl` (90 minutes on this container), GC stress, and the
static-decisions comparison (CI only, by the repository's rules).

**CI on the branch** (d2889cd, before merging main):

| workflow | result |
|---|---|
| static-decisions (dispatched) | passed: batched and sequential agree on every suite |
| tests (macos arm64) | passed |
| icy-tower (macos arm64, windows x86-64) | passed |
| tests (linux arm64, dispatched) | every job passed but GC stress, cancelled at GitHub's 6-hour job limit (below) |
| tests (dispatched) | the failures main's latest run (bdd5e3d) has, test for test: package-authoring.test's `pa-add-refusals` (the runner's linker cannot link the AArch64 library the test builds) in interp, compile and the system-linked executables, and with `pa-pack-refuses-incomplete` in both native coverage runs; nothing else |
| tests (windows x86-64) | one failure, package-authoring.test's `pa-compare-git-tree-matches-git`, which main fixed (a9b29ba) after this branch left it; the merge brings the fix |

The arm64 GC-stress job ran the suite's two passes (interp, compile) in one
job: 5 h 40 min on main's latest run, 6 h on this branch's, cancelled in the
second pass's last files. csv-emission.test costs it about 3 minutes a pass
(2 min 39 s and 3 min 3 s), and the runner was slower throughout (the first
pass 7 min 49 s longer than main's, of which csv-emission.test is 2 min 39
s). Rather than shave this file, `tests-arm64.yml` now runs the two passes as
two jobs (`CORE_BACKEND` interp and compile), each about 3 hours, as
`tests.yml`'s own suite jobs already are.

## 19. What `emits` could not prove

Correct programs, or properties, the checker does not certify:

* **A decision about the whole string** (selective quoting's natural
  spelling): rejected; certifiable only by re-guarding each character.
* **A counted loop that runs at least once.** The loop transfer keeps the
  zero-iteration exit even when the bound excludes it (`n >= 1` known):
  `selective-unpeeled` is EMIT-INCOMPLETE until the first iteration is
  written out. This is a single-value fact, not a relation; a narrow
  improvement of `hir::emission::EvalLoop` would recover it (section 20).
* **The UTF-8 lead/continuation relation** (`utf8-no-e0-split`): the encoder
  must branch where the grammar's lead classes do.
* **Values received from a certified source** are values of their type: a
  byte consumer narrows each symbol before making it a `Byte`.
* **The values themselves**: the census's semantic mutants (a dropped first
  character, swapped fields, the header twice, unsupported characters
  silently stripped) all compile; only round trips catch them.
* **Empty forms**: an empty unquoted field is no token, so no emitter that
  may write nothing can claim a field; the record grammar holds it.
* **Anything about a spreadsheet** (section 10), and a source's final value
  (section 18; the census's `final-value`).
* **Variable width.** Fixed-width records are regular; "every record has as
  many fields as the header" for an unbounded width is not, and no
  recognizer states it.

## 20. Recommendation and next steps

**Keep `emits` as it is and use it for serializers.** CSV needed no new
syntax, analysis, diagnostic or DFA construct, and the one correction it
found was a convention mistaken for a property. The always-quoted exporter
is ordinary code, its grammar declared once per alphabet, its claims
certified in well under a second, and the compiled code is the code without
the claims.

Next steps, in order of value:

1. **The zero-iteration exit.** Drop a counted loop's empty exit in
   `EvalLoop` when its start and end facts prove at least one iteration
   (start a point, end above it). It is a non-relational precision gain that
   would certify selective quoting's guarded loop without peeling; it needs
   the soundness audit every value rule gets (EMISSION-CLAIMS-MILESTONE-1.md,
   section 4).
2. **Typed sources.** A consumer of a certified byte source still checks
   every symbol to make it a `Byte`. A coroutine whose outward type is a
   domain (`std::byte::Byte`) with an Int result is the natural shape, but a
   root's result and yields share one outward type; separating them is a
   coroutine-typing question, not an `emits` one.
3. **Parameterized recognizers** (one record grammar over several field
   recognizers and alphabets) would remove the three copies of the
   record/stream structure. Only if a third serializer needs it.
4. **Relational facts** remain out of scope; selective quoting shows the
   price of their absence is a redundant guard, not an unsafe program.

Outside `emits`, two findings for the language and its runtime:

* **A linear walk of a String's characters.** Every emitter here (and
  every JSON emitter) loops `char_at(i)`; natively that is O(i) for a
  non-ASCII String, so one large non-ASCII field is quadratic (section 16).
  A character iteration (`loop c in text`, or a cursor) would make the
  serializers linear without changing what the checker sees (a
  `scalar_value` of a character).
* **A native executable prints its program's final value** on standard
  output, even `unit`; a program whose standard output is its product
  (a CSV exporter writing to a pipe) cannot avoid the trailing line.

## 21. The evaluation questions

**1. Does `emits` generalize beyond JSON?** Yes. CSV's different ambiguity
(a quotation mark whose meaning depends on the next symbol) is `accept
before` on a state of "quote seen", and its field/record/stream layering is
the facility's existing calls and the checker's existing boundary
obligations. Nothing was added; one JSON-specific convention was removed.

**2. What does the compiler actually prevent?** Every syntactic mistake the
census plants and the milestone lists: undoubled, tripled, missing and extra
quotation marks; a value's comma or line break outside the quotes (the
injection bugs); missing, doubled and trailing separators; fields glued
together; characters outside the profile (non-ASCII in Profile A, controls
and C1 in Profile B); invalid UTF-8 from a wrong lead byte or a missing
guard. Five of these are **latent**: the ordinary table never triggers them,
yet the compiler rejects each from the code alone (`crlf-outside`,
`handwritten-ascii`, `guard-caught-continues`, `bytes-unguarded`,
`utf8-bad-lead`); adversarial runs confirm every one, `utf8-bad-lead` in
only 4 of 1,332 runs. No accepted mutant ever produced an invalid trace.

**3. How much semantic correctness remains outside the guarantee?** All of
it. A certified emitter can drop characters, swap columns, repeat the
header or strip what it should refuse, and still satisfy its grammar; the
census's semantic mutants compile. Independent round trips -- the oracle's
reference serialization, its strict parser, CPython's `csv.reader` and
`csv.writer` -- detect each one. The fixed-width record count is the one
structural fact the grammar does pin.

**4. Does the grammar encourage natural serializer code?** For
always-quoted output, yes: the certified emitter is the loop anyone would
write, with the profile's check as a call of the grammar's own guard. For
selective quoting, partly: the decision is natural, but certification
needs a per-character re-check and a peeled first iteration -- the code
restates for the checker what it already knew. Neither variant is
structured around the DFA's states. The UTF-8 encoder is the one place where
the code must follow the grammar's case structure.

**5. Does certification survive ordinary composition?** Yes. Field, record,
line, stream and document emitters are certified separately and composed
through certificates: the record checks the field's statement and boundary
obligation, never its body, and the source roots compose with the
documents the same way. A field whose own claim is uncertified (selective,
before peeling) still composes into certified records, because the record
grammar does not need the field to be a token.

**6. Is the feature worthwhile in production?** For a serializer whose
grammar matters -- one whose output another system parses -- yes. It costs
a declared grammar (written once, checked by the compiler), a claim per
function, under a second of compilation for the whole workload, and nothing
at run time: the certified and unclaimed programs compile to the same NIR.
It prevents the class of bugs that turn data into structure (CSV injection,
merged fields, broken records), including latent ones the ordinary examples
never trigger. It does not replace round-trip tests, and it says nothing
about formula interpretation. CSV revealed one compiler defect, the
terminal-value convention, and no other.

## A. Files

* `examples/dfa/csv/`: `csv_strict.bot` and `csv_utf8.bot` (the profiles),
  `csv_common.bot` (Row, UnsupportedCSVCharacter), `strict_emit.bot` and
  `utf8_emit.bot` (always-quoted emitters), `selective_emit.bot`,
  `sources.bot` (coroutine roots), `sinks.bot` (consumers), `probes.bot`,
  `export.bot` (the cleanroom exporter).
* `audit/csv-emission/tools/`: `run.tcl` (generated batch programs on every
  backend, the reference interpreter's verdicts), `oracle.py` (no Botlish),
  `differential.tcl`, `census.tcl` with `census/mutants.txt`, `bench.tcl`,
  `claims.tcl`, `cleanroom.sh`; `results/`: `differential.md`,
  `census.md`, `bench.md`.
* `tests/csv-emission.test` (34 tests); `tests/emission-claims.test`'s
  `ec-result-not-symbol`, `ec-result-not-symbol-runs`.
* The correction: `hir/emission.tcl`, `hir/static.tcl`,
  `stdlib/compiler.bot`, `stdlib/test.bot`,
  `compilerpedia/topics/emission.topic`.

## B. How to rerun

```
tclsh9.0 tests/csv-emission.test
tclsh9.0 audit/csv-emission/tools/differential.tcl -part all -length 5 -out audit/csv-emission/results/differential.md
tclsh9.0 audit/csv-emission/tools/census.tcl -out audit/csv-emission/results/census.md
tclsh9.0 audit/csv-emission/tools/bench.tcl -out audit/csv-emission/results/bench.md
python3 -I audit/csv-emission/tools/oracle.py selftest
single/build.sh && audit/csv-emission/tools/cleanroom.sh
tclsh9.0 audit/csv-emission/tools/claims.tcl PROGRAM.bot
```
