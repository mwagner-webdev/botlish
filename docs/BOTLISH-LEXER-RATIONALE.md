# A lexer written in Botlish: why not yet (design rationale)

Status: decided, nothing built. No part of the lexer or the parser is written
in Botlish. What was built instead is SYNTAX-HIGHLIGHTING-MILESTONE-1.md: the
Tcl front end's token IR (`surface/tokens.tcl`), which every highlighter
reads, and editor grammars generated from the compiler's own word lists and
checked against it. This document records the question, what the
repository's facilities answer, and what a Botlish lexer would still need,
so that the question can be picked up again without redoing the research.

## 1. The question

Could one set of ordinary Botlish definitions -- `class` and `dfa`
declarations (DFA-COROUTINE-MILESTONE-2.md) and the Botlish code around them
-- be both the compiler's lexer and the syntax highlighter's, compiled to a
native library (`exported c fn`, NATIVE-LIBRARY-MILESTONE-1.md) that the Tcl
compiler and the language server load as a Tcl extension? The aim was to
avoid drift: today's lexer (`surface/lexer.tcl`), any editor grammar and any
highlighter would otherwise each state the language's words and token shapes
for themselves.

## 2. The decision

Not now. The lexer and the parser stay in Tcl. Drift is closed at the
compiler's own seam instead:

- The token IR is one specified, validated form of everything the lexer and
  the parser say about a text's tokens (SYNTAX-HIGHLIGHTING-MILESTONE-1.md,
  section 2). The command line's excerpts, the compiler service's highlight
  tokens and the language server read only it. A lexer written in Botlish
  later has exactly one thing to produce: the IR, which
  `surface::tokens::toLexed` turns into what the parser reads (the round
  trip is checked over every Botlish file of the repository).
- The parser records the identifiers it reads as contextual words, through
  one registered helper (`surface::parser::Word`, `surface::parser::words`).
- The editor grammars are generated from the lexer's keywords and the
  parser's registry; generation refuses a word no pattern highlights.

The user chose the token level of the IR only. A syntax-tree IR -- the AST's
fifty-odd node kinds, type expressions and recovery holes as a versioned
schema with a validating reader -- was judged substantial (on the scale of
HIR interchange's planned format 2: AGENTS.md, "HIR interchange") and is
deferred until a Botlish parser is actually planned.

## 3. What a recognizer expresses, and what the lexer does

A `dfa` declaration recognizes one token. While it runs it answers "send the
next symbol"; at the end it completes with how many symbols it left unread,
or fails with `std::dfa::UnrecognizedInput` or `std::dfa::UnexpectedEnd`. It
reports no token kind, no value and no position, and keeps no state beyond
its state number (DFA-COROUTINE-MILESTONE-2.md: "no actions, priorities,
longest match, backtracking"; DFA-COROUTINE-EXPLORATION.md: "Leave token
kinds out until a workload needs them"). A failed recognizer cannot be
resumed. Every workload (examples/dfa: JSON, YAML, CSV) is a driver of
ordinary Botlish around recognizers.

Measured against surface/lexer.tcl:

| The lexer's job | Where it would live |
|---|---|
| Token shapes: an identifier with one trailing `?`, INT, HEX, DECIMAL with an exponent, STRING and CHAR with their escapes, comments, operators (`::` before `:`, `..`, `->`) | recognizers; maximal munch written as each token's declared follow set (`accept before`) |
| Which kind a token was | the driver, from the first symbol and the length (no accept labels) |
| A keyword or an identifier | the driver: a lookup of the token's text; a keyword trie in a recognizer still completes as an identifier does |
| INDENT and DEDENT, an inconsistent dedent, a tab in indentation | the driver, with a stack (indentation is not finite-state) |
| The bracket stack, newlines ignored inside brackets, mismatched and unmatched closers | the driver, with a stack |
| Spans: offsets in Unicode scalar values, lines, columns | the driver (recognizers keep no positions) |
| Values: a string's decoded text, a character's codepoint, a HEX's decimal, an INT's canonical digits | the driver, a second pass over the token's text |
| Every lexical diagnostic, word for word (tests and Compilerpedia pin them) | the driver |
| Recovery: skipping a character, ending an unterminated string at its line's end, the index lists the parser's recovery reads (`structural`, `skipped`, `synthetic`, `indentation`, `unclosed`) | the driver; no workload restarts after a recognizer's error |
| `UnclosedBefore`: a regular expression over the next line, with its own copy of the statement keywords | the driver: beyond any fixed lookahead |

So "pure Botlish" holds, but the definitions shared with a highlighter would
be mostly a driver and a keyword list, not recognizers. The value of a
Botlish lexer is having one lexer, not that it is written as `dfa`
declarations.

## 4. The route into the Tcl process

Facts of the repository (NATIVE-LIBRARY-MILESTONE-1.md, the export probe
`audit/compiler-service/probes/export/`):

- Native libraries are made on Linux glibc only, x86-64 and AArch64
  (`native/src/codegen/library.rs`'s `SUPPORTED`). The compiler also runs on
  macOS (Botlish.app) and Windows: a native lexer would be missing there, or
  a second lexer would remain, which is the drift the plan meant to remove.
- Only `int`, `bool`, `Float64` and `str` (UTF-8 bytes) cross the boundary;
  no List, struct or byte buffer. A token sequence comes back as text
  (the probe's `token_table`: one line `KIND START END` per token), which Tcl
  must split into token dicts again (12,641 tokens for
  stdlib/event_loop.bot). The milestone lists a `bytes` result for token
  tables as future work.
- The Tcl extension exists only as a hand-run audit probe: a C shim
  (`Tcl_CreateObjCommand`, Tcl stubs) over the library. No compiler, service
  or language-server code loads a native library, and the single executable
  skips its native installation for `-lsp`.
- Botlish.app forbids extracting code to a cache (AGENTS.md, "The macOS
  application"): a library would be a signed dylib in `Contents/Frameworks`,
  which nothing can build yet.
- Bootstrapping: the library is compiled by the compiler, which needs a
  lexer -- committed binaries per host, or the Tcl lexer kept as a
  bootstrap.
- The front-end fingerprint (`hir/interchange.tcl`'s `Fingerprint`) covers
  the Tcl files of `core`, `hir`, `surface` and `stdlib`; a native lexer
  would shape the HIR without being covered, and AGENTS.md states that the
  native side never shapes a HIR. The interp and compile backends, which
  today need nothing but Tcl, would need the native build.

Two other routes were considered:

- **The Botlish lexer on the Tcl backends**: compiled by the Tcl compiler,
  the generated Tcl committed and checked for drift. It runs everywhere and
  bootstraps from the commit, but each symbol would be a table lookup and a
  coroutine resume in Tcl (no Tcl-backend benchmark of recognizers exists;
  the interpreter fails on tokens of 20,000 symbols).
- **Tables only**: the token shapes as declarations whose tables
  (`surface::dfa`, `core::dfa::Lookup`) a Tcl driver reads, the grammars
  generated from them. No drift in token shapes on every host, but the
  driver stays Tcl: not "pure Botlish".

## 5. Where the drift actually was

The lexer has 21 keywords. The parser recognizes about sixty more words by
comparing an identifier's text (`fold`, `with`, `intermediate`, `import`,
`context`, `inject`, `layout`, `union`, `dfa`, `class`, `extern`, `static`,
`proves`, `emits`, `place`, `variadic`, `satisfies`, `sendable`, `private`,
...), each only where its construct starts, so that every one of them is
still an ordinary name elsewhere. Those were the words a highlighter could
not get right, and a lexer -- in any language -- does not know them. They
are now recorded by the parser where it reads them, registered in one list,
and checked (tests/syntax-highlighting.test's `sh-words-registered`: every
word the parser compares an identifier with is registered or listed as one
it reads only to refuse a construct).

## 6. Measurements (2026-11-07, a 4-core container, Tcl 9.0.1)

- Lexing is most of parsing: stdlib/event_loop.bot (1,851 lines, 70,351
  characters, 12,641 tokens) lexes in 465 ms and parses (lexing included) in
  636 ms; stdlib/actor.bot 262 of 321 ms; examples/games/2048/game2048.bot
  68 of 75 ms.
- Of a whole cold front end it is about a tenth: examples/event-loop/
  01-run-task.bot took 6.1 s, 0.5 s of it lexing (the lexer procedure
  wrapped and timed; first run in the process).
- A fused native recognizer lexes JSON at about 14 ns per character
  (DFA-COROUTINE-MILESTONE-2.md); the export probe's library call from Tcl
  cost 37.4 microseconds for 193 bytes (NATIVE-LIBRARY-MILESTONE-1.md).

A faster lexer would help the language server's large files; it is not what
the compiler's run time is made of.

## 7. What a Botlish lexer would need

In the language and its facilities:

1. Accept labels (token kinds) for recognizers, or an agreed driver
   protocol for them: the facility's exploration deferred them until a
   workload needs them, and the lexer is that workload.
2. A recovery pattern: a driver that handles a recognizer's failure, skips
   input and starts again, reporting the lexer's diagnostics word for word.
3. A string source helper (examples write their own) and buffering for the
   lexer's one unbounded lookahead (`UnclosedBefore`), or a change of that
   recovery rule.

For running it in the Tcl process, one of:

4. Native libraries on macOS (a signed dylib in Botlish.app's Frameworks)
   and Windows (a DLL), a byte-buffer or packed-table result type, and a
   supported Tcl extension shim built per host; the fingerprint and the
   front-end cache covering the library; a bootstrap story.
5. Or the Tcl backends, with a measurement that the generated code is fast
   enough.

And in any case:

6. Parity with surface/lexer.tcl: the token IR's round trip
   (`surface::tokens::toLexed`) equal for every file of the repository and
   for the syntax-recovery fuzzer's inputs, diagnostics and recovery
   metadata included. The IR's validator (`surface::tokens::validate`) is
   the contract a Botlish lexer's output is checked against.

## 8. When it is picked up again

Start with a Linux-only experiment that answers the open questions cheaply:
`lexer.bot` (recognizers and driver) producing the token IR, a differential
test against surface/lexer.tcl over every `.bot` file and the recovery
fuzzer's inputs, and its time on the Tcl backends and as a library returning
the IR as text. That says whether route 5 is fast enough before anyone ports
native libraries to macOS and Windows.
