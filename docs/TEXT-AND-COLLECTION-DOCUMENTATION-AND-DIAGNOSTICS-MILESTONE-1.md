# Text and collection documentation and diagnostics (milestone 1)

M2 of [TEXT-AND-COLLECTION-PRECISION-CENSUS.md](TEXT-AND-COLLECTION-PRECISION-CENSUS.md):
the compiler's own documentation now says what the language and standard
library do about UTF-8, text construction, literal escapes and List typing,
and a declared function result that is not proven is reported with the
result type the compiler inferred beside the declared one. No language,
type-system, standard-library or backend semantics changed: the one
production code change is the text of one diagnostic.

Measured on the branch from `main` at `cbaa0402` (the census was taken at
`f2787af0`; every finding this milestone acts on was reproduced at
`cbaa0402` first, section B), Linux x86-64, Tcl 9.0.1, the native backend
built in release mode, a 4-core container.

**Executed evidence and inspection.** Every before/after diagnostic, help
query, measurement, test count and mutation outcome below was produced by a
command run for this report (named in section J). Three statements rest on
code inspection and are marked so where they occur: that semantic-instance
walks never write the program's own `inferredResultType` (section G), that
the new formatting runs only on a mismatch (section K), and why the
`std::test::joined` helper is quadratic (section D).

## A. Result

| what | before | after |
|---|---|---|
| `encode_utf8`'s help | "There is no decoding operation back from bytes to a String"; its type `List[std::byte::Byte]` stated unconditionally | names `std::abi::bytes::from_list` and `decode_utf8` (strict, `InvalidUtf8`), the two contracts, and the `std::byte` condition of its static type, each with an executable example |
| `-help "decode utf8"` | the internal substrate `std::byte_store::decode_utf8` | `std::abi::bytes::decode_utf8`, with a note and an example |
| `task.string-concatenation` | "For many parts, chain concat calls or use stdlib/test.bot's std::test::joined" (both quadratic natively) | the five distinct needs, the linear idiom that exists today with its measured cost, what stays quadratic (`append_char` carried along, `std::test::joined`), and that this is an optimization, not a guarantee |
| `capability.string-formatting` | recommends `std::test::joined` | points at `task.string-concatenation` |
| `std::test::joined`'s page | "PARTS joined by SEPARATOR." | a test helper, quadratic, not for building long text |
| `concept.strings` | escapes `'\n'`, `'\''`, `'\\'` | the complete vocabulary of both literals (`\\ \" \n \r \t`; `\\ \' \n \r \t`), no numeric escape, raw control characters, the one-character-String warning; an invalid escape's help line leads here |
| `-help "control character"`, `"invalid escape"` | nothing | `concept.strings` |
| `-help "char from int"` | `std::char::scalar_value` (the reverse operation) | `std::char`'s page, which says no conversion exists and what does |
| `-help "list element type"` | a list of 21 topics, `concept.lists` second | `concept.lists`, which now states that element types are kept and held exactly at a declared List type |
| README §19 | "Lists carry no element type. `std::list::at` returns `any`." (present tense) | marked as the state of that milestone, with what is true since; §21's "semantic HIR types are unchanged" and two §8 rows likewise |
| declared-result TYPE diagnostic | `function result does not prove declared type List[int]` | `function result does not prove declared type List[int] (result type: List[int[std::byte::Byte]])` |

## B. Starting state

Reproduced at `cbaa0402` before any change: the census's eighteen probes
pass (`audit/text-collection-precision/tools/probes.tcl`: `18 probes, 0
failed`), the type matrix is the census's, and each finding acted on here
holds:

* `compilerpedia/notes/stdlib.notes`, `stdlib.std::str::encode_utf8`:

      The general byte-level view of a String: one Int per byte, in order. Its
      static type is List[std::byte::Byte], so it feeds std::abi::bytes::from_list
      (the bytes a write(2) or a C call takes) and ascii:: classification
      directly. Its length is the String's size in bytes, not its character count.
      There is no decoding operation back from bytes to a String. To classify
      characters, prefer std::str::char_at, which reads a character without
      building a List.

  Probe c3 (no `std::byte` loaded) reports `argument type: any` for an
  element of `encode_utf8()`; c4/c5 differ only by an unused `import
  std::byte` and differ in acceptance.
* `compilerpedia/topics/tasks.topic`, `task.string-concatenation`:

      `+` adds Ints; applied to Strings it fails (a TYPE error). For many parts,
      chain concat calls or use stdlib/test.bot's std::test::joined(parts,
      separator). Numbers need std::int::to_string first (task.number-text).

  (`related:` also listed `stdlib.std::test::joined`;
  `capability.string-formatting` said "build long texts with a helper or
  stdlib/test.bot's std::test::joined(parts, separator)".)
* `compilerpedia/topics/concepts.topic`, `concept.strings`: "A character
  literal 'a' (escapes '\n', '\'', '\\') is a `UnicodeChar`". The lexer
  (`surface/lexer.tcl`'s `String` and `Char`) accepts `\\ \" \n \r \t` in a
  String and `\\ \' \n \r \t` in a character literal and rejects every
  other escape (probe f1: `\u`, `\x`, `\e`, `\0`, `\'` in a String, `\"` in
  a character literal); probe f2 runs raw control characters.
* `docs/README.md` §19: "2. **Lists carry no element type.**
  `std::list::at` returns `any`. That affects `matmul`'s entries and the
  pairs `csv` returns."
* The result diagnostic, probe j3:

      error: j3-result-diagnostic-omits-type.bot:13:8: function result does not prove declared type List[int] (CORE SEMANTIC TYPE)
      error: j3-result-diagnostic-omits-type.bot:16:6: argument for parameter "xs" cannot be proven to satisfy List[int] (argument type: List[int[std::byte::Byte]]) (CORE SEMANTIC TYPE)

  Probes d1 (invariant admission), e1/e2 (no Int-to-UnicodeChar
  conversion) reproduce as recorded.

One census measurement did not reproduce: FOLD-VIRTUAL-LIST-CONSTRUCTION-
MILESTONE-1.md reached main after the census was measured (it is not in
`f2787af0`), and a fold carrying `concat` is linear natively at `cbaa0402`
(section D). The documentation written here describes the tree it ships
in, not the census's.

## C. UTF-8 documentation

`stdlib.std::str::encode_utf8` (notes, regenerated into
`compilerpedia/generated/stdlib.topic`) now says, in order:

1. What it produces: one Int per byte of the UTF-8 encoding, each in
   0..255; total.
2. Its static type, as the compiler gives it today:

       Its static type depends, today, on what the compilation has loaded. When
       the program has loaded std::byte -- an `import std::byte` in any of its
       files, or an import of a module that loads it, such as std::abi::bytes --
       it is List[std::byte::Byte]; otherwise it is the plain `list`, whose
       elements the compiler knows nothing about. The values are the same either
       way; only what the compiler can prove about them differs. ...

   Measured: with only `import std::str` an element's argument type is
   `list` (the List) / `any` (an element); with `import std::abi::bytes`
   or `import std::byte` it is `List[int[std::byte::Byte]]`. Nothing
   presents this as desirable or as future semantics; M3 owns changing it.
3. The way back: `std::abi::bytes::from_list` (which needs a
   `List[std::byte::Byte]`, element types being held exactly -- `[104,
   105]` is rejected, `std::byte::from_int` converts each Int) and
   `std::abi::bytes::decode_utf8`, strict, whose ill-formed input is the
   declared error `InvalidUtf8` -- no replacement character, no crash.
4. The two contracts differ: encoding is total, decoding is not.

Examples (each checked by `tools/compilerpedia.tcl check`): the original
one; an encode-then-decode round trip whose invalid input `[from_int(255)]`
is handled as `InvalidUtf8` (`["héllo", "not UTF-8"]`); and a rejected
program showing `(argument type: list)` without `std::byte` loaded -- the
example that will fail the check, and so force this page to change, when
M3 lands. A note for `stdlib.std::abi::bytes::decode_utf8` (aliases
`decode utf8`, `decode utf-8`, `utf-8 decoding`, `utf8 to string`) gives the
decoding side its own page and example, and says when the bytes route is
the right operation (bytes from elsewhere) and when it is a workaround
(text built from Strings, whose `InvalidUtf8` handler is dead code).

README §8's table row for `std::str::encode_utf8` states the same
condition instead of `str → List[Byte]`.

## D. Text construction

`task.string-concatenation` distinguishes:

* a few fixed parts: `concat`, `append_char` (unchanged advice);
* many parts, a List of Strings: there is no join in `std::str`; carry one
  String and only extend it, by self-tail recursion (the documented
  `join_from`, every index proven, no handler);
* many characters: `append_char` for a few; for many, concatenate each as a
  one-character String (`acc.concat("".append_char(c))`) in the same kind
  of recursion;
* text to bytes (`encode_utf8`) and UTF-8 bytes to text
  (`decode_utf8` of `from_list`, `InvalidUtf8`), and `std::abi::bytes::join`
  for Bytes values.

Its COST section is the measured basis, and says it is the native
backends' behavior, an optimization and not a guarantee, and when the
optimization applies (the String being built used once on each path,
never read, compared, kept or captured before it is finished -- M8A's
linearity condition, `hir::construction::Linear`).

The measurements (`audit/text-collection-precision/tools/bench.tcl`, the
census's harness; this milestone added the documented shapes as
strategies `tail-join-list` and `tail-char-concat`, and `tail-append-char`;
native, best of three, JIT excluded; "copied" is
`native::allocationReport`'s String bytes copied):

| strategy | N | result bytes | us | String bytes copied |
|---|---:|---:|---:|---:|
| tail-join-list (the documented recursion, separator ", ") | 4000 | 19,998 | 419 | 70,616 |
| | 16000 | 79,998 | 1,304 | 282,762 |
| | 64000 | 319,998 | 4,686 | 1,131,388 |
| tail-char-concat (characters as one-character Strings) | 4000 | 8,000 | 323 | 38,272 |
| | 16000 | 32,000 | 1,646 | 153,272 |
| | 64000 | 128,000 | 7,002 | 613,296 |
| tail-concat (the census's constant piece) | 64000 | 192,000 | 2,266 | 629,652 |
| fold-concat | 4000 | 12,000 | 255 | 39,276 |
| | 16000 | 48,000 | 1,043 | 157,344 |
| | 64000 | 192,000 | 3,296 | 629,652 |
| tail-append-char (`acc.append_char(c)` in a recursion) | 4000 | 8,000 | 1,572 | 16,004,000 |
| | 16000 | 32,000 | 8,370 | 256,016,000 |
| | 64000 | 128,000 | 375,633 | 4,096,064,000 |
| fold-append-char | 64000 | 128,000 | 327,249 | 4,096,064,000 |
| flat-bytes | 64000 | 192,000 | 10,987 | 0 |
| bytes-join | 64000 | 192,000 | 24,535 | 0 |
| chars-via-bytes | 64000 | 128,000 | 27,587 | 128,000 |
| test-joined (`std::test::joined`) | 4000 | 12,000 | 1,139 | 24,005,997 |
| | 16000 | 48,000 | 36,151 | 384,023,997 |
| | 64000 | 192,000 | 581,031 | 6,144,095,997 |

What this establishes, and what the page says:

* The documented recursions copy in proportion to the text (4x the parts,
  4.0x the bytes). A fold carrying `concat` is linear too, on this tree:
  the census's quadratic fold-concat rows (24 MB at N = 4000) are
  `f2787af0`'s, before FOLD-VIRTUAL-LIST-CONSTRUCTION-MILESTONE-1.md.
* `append_char` is not a construction-plan piece: carried along by a fold
  or by a recursion it copies the whole String per character (4x the
  characters, 16x the bytes). The census recommended no recursion for
  characters, and this milestone's first draft of the page did; the
  measurement corrected it before it was written down. The page now says
  to concatenate one-character Strings instead.
* `std::test::joined` is quadratic: it rebuilds its text with
  `concat(sofar, separator, part)` from a one-element vector for every
  part (by inspection of `stdlib/test.bot`; the copy volume is measured).
  Its page now says so; its implementation is unchanged.
* The Tcl backends: compile at N = 4000/16000/64000 took 51/252/1,391 ms
  for tail-join-list, 23/64/359 ms for fold-concat and 76/350/1,504 ms
  for test-joined (one run each); interp at N = 1000/4000 took 634/2,289
  ms and 78/312 ms. Their cost per operation dominates at these sizes, and
  no copy count is available there, so the page states no complexity for
  them.

Nothing is advertised as a language guarantee, and neither M4 (a linear
`std::str::join`) nor M8 (fold construction fusion, which is partly on
main already) is presented as existing: the page says "std::str has no
join operation today" and describes only what this tree does. Two tests
tie the page to the compiler: `tcd-doc-construction-claims` (the
documented recursion compiles with every index proven and computes the
same value on every backend; `std::str::join` does not exist) and
`tcd-doc-construction-costs` (natively the recursions copy at most 5x the
bytes for 4x the parts and `append_char` at least 12x -- if the optimizer
changes either, the page must change with it).

## E. Literal syntax

The vocabulary, exactly as `surface/lexer.tcl` implements it:

    in a String literal "..."      \\  \"  \n  \r  \t
    in a character literal '...'   \\  \'  \n  \r  \t

`concept.strings` now prints this table in a LITERALS AND ESCAPES section,
says a String takes `\"` but not `\'` and a character literal the reverse,
that any other backslash sequence is `invalid escape "\X" in string` (or
`in character literal`, SURFACE SYNTAX), and so that there is no numeric
escape (`\u`, `\u{...}`, `\x`, `\e`, `\0`). It says every other character
-- any Unicode scalar value -- is taken from the source text as it is,
that a raw control character is accepted but invisible in most editors and
printed raw by a diagnostic, and that a one-character String literal
(`"\t"` as much as `"a"`) draws ONE-CHAR-STRING-LITERAL. It does not
mention `\u{...}` as anything but absent (M6 decides it). Its examples:
every escape's scalar value (`[17, [92, 39, 10, 13, 9]]`), and a rejected
`"\u001b[1m"` (`@error SURFACE SYNTAX`, `@at 1:8`, `@message invalid
escape "\\u" in string`).

Discoverability: aliases `string literal`, `escape sequence(s)`, `string
escapes`, `character escapes`, `control character(s)`, `invalid escape`,
and `match: SURFACE SYNTAX | invalid escape *`, so the help line printed
under an invalid escape names `concept.strings`, the page with the table,
instead of the general `error.surface-syntax`.

`tcd-doc-escapes-complete` lexes every printable ASCII character after a
backslash in both literal kinds and requires the table to list exactly the
accepted ones.

## F. Historical List documentation

README §19 (the closed-AOT readiness analysis, written before List element
types existed) keeps its account and marks it:

    **The corpus when this analysis was written.** ... None was closed:
    ...
    The blockers came from two sources, neither of them dynamic dispatch. Both
    items describe the compiler of that milestone, not today's (next
    paragraph):

    1. **Parameters had no kind.** ...
    2. **Lists carried no element type.** `std::list::at` returned `any`. ...

    **Since then.** Lists carry their element type: a List's static type is
    `List[E]` (MINIMAL-APPLIED-LIST-TYPES.md), `std::list::at`, a loop variable
    and a collecting loop's elements have type E, and a parameter, field or
    result may declare `List[T]`. A parameter may declare its type
    (STRICT-TYPED-PARAMETERS.md), and call-site specialization (§21) analyzes
    each instance under its callers' argument kinds. The corpus's functions
    still declare no parameter types, so `-aot` still reports their parameters
    without a kind, and an element read out of such a parameter as unknown:
    because the parameter's type is unknown, not because the List has no
    element type.

(Checked: `main.tcl -aot examples/stdlib/matmul.bot` at `cbaa0402` still
reports `UnknownParameterKind` and `UnknownAggregateElementType` blockers
for the untyped functions, and `matmul`'s result as `List[List[int]]`.)
Nearby statements of the same kind: §21's "Lists get element facts in
region inference only (semantic HIR types are unchanged)" is marked as the
state when written; §8's table gains a sentence saying its signatures are
the registered ones and the checker's static types are often more precise
(`std::list::at` has the element type), and its `encode_utf8` row states
the `std::byte` condition. `concept.lists` states that element types are
inferred and kept (`at`, loop variables, collecting loops) and held
exactly at a declared List type (a `List[std::byte::Byte]` is not
admissible for `List[int]`; `[27]` is a `List[int]`), and answers `-help
"list element type"`.

## G. Declared-result diagnostics

**Implementation** (`hir/range.tcl`'s `verifyDeclaredResults`, the one
production change): when `ProvesValueAcceptedBy $inferred $result
$declared` fails, the message is now

    function result does not prove declared type DECLARED (result type: R[, facts: F])[; WHY]

with R = `hir::semantic::ShowType` of `ShownArgType $inferred $declared`,
the facts clause `FactsClause` and the explanation `MismatchClause` -- the
helpers the argument diagnostic (`VerifyCall`'s `(argument type: A, facts:
F)`) already uses, so the two read alike: the same type presentation
(callables named by their function, a minted List length forgotten unless
the declaration states one), the same rule for when facts are relevant.
`$inferred` is the block's `inferredResultType`, exactly the type the
admission proof is given: the body's value and every `return`, joined. No
second diagnostic, no new formatter, no change to `MismatchClause` (a
List mismatch now carries its information in the result type; the census's
"`MismatchClause` says nothing for Lists" needs no clause of its own).

The analysis context: `verifyDeclaredResults` runs once per check
(`hir::CheckOnce`) on the program's own HIR. A semantic instance's walk
writes its `inferredResultType` into a scratch copy (`hir/semantic.tcl`'s
`Walk`: `dict set scratch exprs $block inferredResultType`), kept as the
instance's snapshot, never into the program's HIR (by inspection; tested:
`tcd-result-semantic-instances` reads both).

**Before and after** (`main.tcl -check` of `audit/text-collection-docs/
programs/`, the before tree's compiler and this one):

| case | before | after |
|---|---|---|
| applied (j3, r1) | `... declared type List[int]` | `... declared type List[int] (result type: List[int[std::byte::Byte]])` |
| nested (r2) | `... declared type List[List[int]]` | `... List[List[int]] (result type: List[List[int[std::byte::Byte]]])` |
| refinement, unconstrained Int (r3) | `... int[Digit] (facts: [-∞, +∞])` | `... int[Digit] (result type: int, facts: [-∞, +∞])` |
| refinement, a sum (r3) | `... int[Digit] (facts: [1, 10])` | `... int[Digit] (result type: int, facts: [1, 10])` |
| another domain (p1 `narrow`) | `... int[Small] (facts: [0, 9])` | `... int[Small] (result type: int[Digit], facts: [0, 9])` |
| two domains joined (p1 `joined`) | `... int[Small] (facts: [0, 9])` | `... int[Small] (result type: int, facts: [0, 9])` |
| named struct (r4) | `... Meters; Feet and Meters are distinct named struct types: ...` | `... Meters (result type: Feet); Feet and Meters are distinct ...` |
| enum (r4) | `... Color; Color is a nominal enum type: ...` | `... Color (result type: Shade); Color is a nominal enum type: ...` |
| String and Int paths (r6) | `... int (facts: [-∞, +∞])` | `... int (result type: any, facts: [-∞, +∞])` |
| String and Int branches (r6) | `... str` | `... str (result type: any)` |
| unknown element (p1 `unknown`) | `... int (facts: [-∞, +∞])` | `... int (result type: any, facts: [-∞, +∞])` |
| imprinted (r7) | `... List[int]` / `... int (facts: [-∞, +∞])` | `... List[int] (result type: List[T])` / `... int (result type: T, facts: [-∞, +∞])` |
| generic with instances (s2) | `... List[str]` | `... List[str] (result type: list)` (its instances infer `List[int]{length: 2}` and `List[str]{length: 2}`) |
| callable (r9) | `... Fn{args: [str], return: int, errors: []}; argument 1 is incompatible: ...` | `... Fn{...} (result type: inc/1 -> int); argument 1 is incompatible: ...` |
| poisoned / unbound / failed projection (p2) | only NOT-CALLABLE, UNBOUND, NOT-A-STRUCT | unchanged: no result diagnostic restates them |
| a hole past a syntax error (`-check`) | no result diagnostic for the function holding it | unchanged |

Every changed line differs from its before line by the inserted clause
alone (`diff` of the two outputs); codes, locations, order, help topics
(`rule.type-result`) and the diagnostics that are not result mismatches
are identical.

`any` is reported where the checker's join is `any` (no union type: a
String and an Int), and `list` where the result is a List of unknown
elements: both are what the proof was given, not a concrete type made up.

## H. Compilerpedia discovery

`main.tcl -help QUERY` (the first line of the answer):

| query | before | after |
|---|---|---|
| `encode utf8` | a list, `stdlib.std::str::encode_utf8` first | `stdlib.std::str::encode_utf8` |
| `decode utf8` | `stdlib.std::byte_store::decode_utf8` (the internal substrate) | `stdlib.std::abi::bytes::decode_utf8` |
| `string concatenation`, `join strings` | `task.string-concatenation` | `task.string-concatenation` (rewritten) |
| `build string` | a list | `task.string-concatenation` |
| `character escapes` | a list, `concept.strings` first | `concept.strings` |
| `control character` | nothing | `concept.strings` |
| `invalid escape` | nothing | `concept.strings` |
| `list element type` | a list of 21, `concept.lists` second | `concept.lists` |
| `list length` | `concept.list-length` | `concept.list-length` |
| `char from int`, `int to char`, `character from integer` | lists: `std::char::scalar_value` first (the reverse operation) for the first two, `error.surface-syntax` for the third | `stdlib.module.std::char`, which says there is no conversion, that no escape spells a character by number, and what exists (a literal holds any scalar; `char_at`; the UTF-8 route with its declared errors) |

No topic was added: aliases, a `match:` line, notes merged into existing
generated topics (`std::abi::bytes::decode_utf8`, `std::test::joined`) and
rewritten sections. `tools/compilerpedia.tcl generate` regenerated
`compilerpedia/generated/stdlib.topic` from the notes. The examples went
from 763 to 770 (`check`: 1294 topics, 770 examples run, 0 problems).

**The single-file compiler.** `single/build.sh` built
`single/out/botlish` (15,499,934 bytes) from this tree; a copy in an empty
directory outside the repository, run with `env -i PATH=/usr/bin:/bin
LANG=C.utf8 HOME=DIR`, answers `-help "decode utf8"` with
`stdlib.std::abi::bytes::decode_utf8`, `-help "encode utf8"` with the new
notes (decoding and the `std::byte` condition), `-help "character escapes"`
with the LITERALS AND ESCAPES table, `-help "join strings"` with the COST
section, `-help "list element type"` with `concept.lists`' rule and `-help
"char from int"` with `std::char`'s page; `-check` of a program with `"\e"`
prints `help: botlish -help concept.strings`, and of j3's `give` the new
result diagnostic. Nothing was written beside it.

## I. Semantic stability

`audit/text-collection-docs/tools/compare.tcl` compiled 183 programs with
the front end before the change (a worktree at `cbaa0402`) and after it,
each in a process of its own, `-strict 0`, no cache, both runs reading the
same program files (the before tree's, so that a suite whose expected text
this change updates is the same input to both): the 119 golden suites, the
2048 and Icy Tower suites, the census's 18 probes, `examples/surface`,
`examples/stdlib` and this audit's 20 programs
(`audit/text-collection-docs/programs/`: the representative mismatches of
section G, the documented UTF-8 and joining programs, every escape).

    programs 183; semantic differences 0
    totals: accepted 155, errors 2, reported 50, results 21, runs 68,
            messagesChanged 21

Compared field by field, every one semantic and every one equal:

* acceptance (155 accepted, 26 rejected, before and after; the 2 errors are
  probes the loader rejects before any HIR exists -- e2's unknown symbol,
  f1's invalid escapes -- with identical text);
* the reported diagnostics' kinds and locations (50), and their messages
  with the one added clause removed;
* every declared-result mismatch's declared and inferred types read from
  the HIR (21): the inferred type was already there, and is the same;
* method-call decisions and choices, static sites' outcomes and the codes
  they reify, emission verdicts;
* HIR text (`hir::format`: every expression's type, completion outcome --
  known errors, callee errors, reachability -- target and flags), with the
  clause removed from the constants a rejected static block reifies;
* the value of every accepted program outside the golden suites (68) on
  interp and compile.

What did change, as intended: the 21 result messages (every result
diagnostic of the corpus, and nothing else: p1 4, r1 1, r2 1, r3 2, r4 2,
r6 2, r7 2, r9 2, s2 1 of this audit's programs; the census's d1 1, d2 2,
j3 1), and the HIR text of 16 golden suites (abi-bytes, affinity,
callable-contracts, collections, compiled-values, layout-arrays,
layout-unions, list-flat, lists-and-sets, range-and-contract-values,
refinements, static-compile, type-predicates, types,
validators-and-proofs, warning-programs), each only in a `static compile:`
block's reified `CompilerError` message: a result diagnostic a block
rejects carries the new text into the program's value. Only types.bot,
refinements.bot and static-compile.bot compare that text exactly; they are
updated (section J), the others match on a part of it or on the code.

The comparison is not run on the native backends: their output for the
golden corpus is the golden suites' own (section J: every suite on all
four backends), and the one native-only claim of this milestone (the
copying costs) has its own test.

## J. Regression and mutation tests

Commands run on this branch (Linux x86-64, `LANG=C.utf8`), with their
results:

| command | result |
|---|---|
| `tclsh9.0 tests/text-collection-docs-diagnostics.test` (new; interp and `CORE_BACKEND=compile`) | 24 passed, 0 failed, 0 skipped on each |
| the 17 test files that pin "does not prove declared type" (c-abi-types, c-float-ffi, decimal-rounded, diagnostic-recovery, enums, exact-value-facts, list-length-refinement, raw-c-float-ffi, refinement-values, source-types, type-predicates, applied-types, empty-collection-admissibility, immutable-set, refined-signatures, refinement-validators, typed-parameters) | before updating: 17 tests failed in 11 files, each only by the added clause; after: all pass (e.g. c-abi-types 73/73, diagnostic-recovery 57/57, refinement-values 88/88) |
| `tclsh9.0 tests/local.tcl -parts golden` on types.bot, refinements.bot, static-compile.bot, validators-and-proofs.bot, range-and-contract-values.bot | 5 suites, 495/495 on each of interp, compile, cranelift-generic, cranelift |
| `tclsh9.0 tools/compilerpedia.tcl check` | 1294 topics, 770 examples run, 0 problems |
| `tclsh9.0 audit/text-collection-precision/tools/probes.tcl` | 18 probes, 0 failed (j3's expectation updated; every other probe's unchanged) |
| `python3 -I audit/text-collection-precision/tools/matrix.py` | exit 0, the tables unchanged |
| `tclsh9.0 audit/golden/migration/merge.tcl -names audit/golden/migration/tcl-names.txt -check 1` | 13580 rows, exit 0 (24 new KEEP rows for the new file) |
| `tclsh9.0 tools/mutant-catalogs.tcl` | 101 catalogs, 3413 mutants, 0 problems |
| `tclsh9.0 audit/type-predicates/tools/mutate.tcl -only converter-return-skips-proof` (its anchor moved with the code) | killed |
| `tclsh9.0 audit/text-collection-docs/tools/mutate.tcl` | 12 mutants, 12 killed, each by a test its `!!` line names |
| `audit/text-collection-docs/tools/compare.tcl` before/after | 183 programs, 0 semantic differences (section I) |
| `bash single/build.sh`, then the clean-directory help session | built; every query as in section H |
| `tclsh9.0 tests/local.tcl -jobs 3` (every Tcl test file on interp and compile, every golden suite on four backends, front-end cache) | stopped by its 7,000 s time limit after all 119 golden suites (interp 5,682/5,682, compile 5,682/5,682, cranelift-generic 5,590/5,590, cranelift 5,692/5,692) and 443 of the 568 Tcl file runs; its one failure, tests/compilerpedia.test (2 tests on each backend), is described below |
| `tclsh9.0 tests/local.tcl -jobs 4 -parts tcl` on the 122 files the first run had not reached, and compilerpedia.test again | 246 file runs, 0 failed: interp 2094 passed, 12 skipped; compile 2089 passed, 17 skipped (661 golden duplicates skipped on each) |
| both parts together | every Tcl test file on interp and compile and every golden suite on four backends: 18,517 Tcl tests passed, 0 failed, 5,517 skipped (4,986 of them golden duplicates) |

The mutants (`audit/text-collection-docs/tools/mutants.txt`), the ten the
brief asks for and two more:

| mutant | rule broken | killed by |
|---|---|---|
| result-type-omitted | the diagnostic names the inferred type | tcd-result-applied, -nested, -refinement, -unknown, -joined-paths, -semantic-instances, -type-is-the-checked-one |
| result-type-is-declared | it names the inferred type, not the declared one | tcd-result-applied, -refinement, -type-is-the-checked-one |
| result-type-carrier-only | a refinement is shown, not its carrier | tcd-result-refinement, -type-is-the-checked-one |
| result-type-from-an-instance | the generic body's type, not a semantic instance's | tcd-result-semantic-instances, -type-is-the-checked-one |
| doc-decoding-denied | encode_utf8's page names the decoding path | tcd-doc-utf8-decoding |
| doc-static-type-unconditional | encode_utf8's type is stated with its condition | tcd-doc-utf8-static-type |
| doc-test-join-recommended | the quadratic test helper is not recommended | tcd-doc-no-test-library-join |
| doc-escape-omitted | every supported escape is documented | tcd-doc-escapes-complete |
| doc-numeric-escape-valid | no unsupported escape is documented as valid | tcd-doc-escapes-complete |
| doc-readme-lists-untyped | README §19's untyped Lists are history | tcd-doc-readme-list-history |
| doc-decode-undiscoverable | `decode utf8` finds the decoding page | tcd-doc-discovery, tcd-doc-utf8-decoding |
| doc-invalid-escape-help-unrouted | an invalid escape's help line leads to the escapes | tcd-doc-no-numeric-escape |

The full run found two things this milestone broke, both in
tests/compilerpedia.test, both fixed (`637e832c`) and the file passing
since (43/43): `cp-render-fits-80-columns` -- two lines of std::char's
rewrapped note rendered at 81 columns (rewrapped to 76) -- and
`cp-string-char-search`, which pins `concept.strings`' alias list and now
pins the literal and escape aliases too (its lookups -- the warning's
code and phrase, `rune` unmatched -- were and are unchanged).

Each documentation mutant edits the notes and the generated topic alike
(what the help reads), or the topic file or README, and is detected by an
assertion about that statement, never by a test infrastructure failure.

CI: before branching, `main`'s latest runs at `0a518ba4` were green or
queued, none red; they have since all completed green (tests, tests (linux
arm64), tests (macos arm64), tests (windows x86-64), static-decisions,
single executable, icy-tower on all three hosts). The branch push of
`7ae1f014` ran each host's canary, all four green, and icy-tower on
Windows and macOS, green. The workflows dispatched on `7ae1f014` were
cancelled by the push of `637e832c` (they would have failed
compilerpedia.test); on `637e832c` icy-tower (windows x86-64) and
icy-tower (macos arm64) succeeded, and tests.yml, tests-arm64.yml,
macos-arm64.yml and windows-x86_64.yml were dispatched: queued or running
when this was written -- pending, not passed. static-decisions was not
dispatched: the change moves no static decision (the comparison's static
outcomes are equal, and both schedulers see the same message); it runs on
main's next push that changes `hir/`.

## K. Performance

**The diagnostic.** The new formatting is inside the branch that reports
the mismatch: a proven result runs exactly the statements it ran before
(`set inferred ...` and the `ProvesValueAcceptedBy` test both existed;
by inspection of the diff). Measured with an execution trace summing the
microseconds spent inside `hir::range::verifyDeclaredResults` per
compilation, each a fresh process, before and after alternately, five
runs each, the minimum (the machine was running the full local suite on
three cores meanwhile, so the spread is several percent):

| program | result mismatches | calls | before: verify us / front end ms | after |
|---|---:|---:|---:|---:|
| r8-ok.bot (three declared results, all proven) | 0 | 1 | 3,454 / 86 | 3,440 / 85 |
| examples/games/2048/demo.bot | 0 | 2 | 43,079 / 1,496 | 41,334 / 1,415 |
| examples/games/icy-tower/headless.bot | 0 | 9 | 119,818 / 3,509 | 129,796 / 3,480 |
| p1-joined-and-unknown.bot | 4 | 1 | 2,780 / 70 | 3,106 / 70 |

So no material work on success (the differences go both ways and are
within the spread), and about 80 us per reported mismatch for presenting
its type. A golden suite whose static blocks build rejected programs pays
that per rejected result in those builds: in the comparison's runs the
front end of the whole corpus took 1,274 s before and 1,228 s after, the
two runs' difference being the machine's load, not the change.

**Documentation.** `tools/compilerpedia.tcl generate` takes 4.3 s before
and after; `check` runs 770 examples instead of 763 (1 min 54 s here). The
new test file takes about a minute on one backend, most of it the native
copying measurement (four programs at two sizes). Nothing at run time
changed: no runtime, backend or standard-library code was touched.

## L. Remaining issues

Not addressed here, each the census's own milestone:

* **M3**: `encode_utf8`'s element type still depends on whether
  `std::byte` is loaded (probes c3-c5 unchanged; documented in section C).
* **M4**: no linear `std::str::join` (or `from_chars`); the page describes
  the recursion that is linear natively today.
* **M5**: no `std::char::from_scalar_value`; `std::char`'s page says so.
* **M6**: no `\u{...}` escape; `concept.strings` says there is no numeric
  escape.
* **M7**: collection admission stays invariant (probe d1 unchanged);
  `concept.lists` states the rule.
* **M8**: FOLD-VIRTUAL-LIST-CONSTRUCTION-MILESTONE-1.md made folds carrying
  `concat` linear natively before this milestone; `append_char` is still
  no construction-plan piece, so carrying it along, by a fold or by a
  recursion, copies O(n²) (section D). Untouched here.
* The census's other diagnostic finding, `.slice` on a List suggesting
  `import std::byte_store` (probes j1/j2), belongs to method resolution and
  namespace visibility: unchanged, not investigated here.
* A diagnostic quoting a literal that holds a raw control character still
  prints it raw (census J.3); the escape documentation says so.
