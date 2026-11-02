# Compilerpedia: the compiler's built-in reference

Compilerpedia is the Botlish compiler's offline documentation and help
system: `botlish -help` (in a checkout, `tclsh9.0 main.tcl -help`). It
explains what Botlish means, what it guarantees, what this compiler can
prove, why its rules and warnings exist, and which practices it recommends,
from the compiler itself, without a repository checkout, a network or a
search service. The milestone that built it is reported in
COMPILERPEDIA-REPORT.md; this document is the architecture and the
maintenance guide.

## 1. Principles

* **The unit is a topic, not a diagnostic.** A topic is one documented
  language rule, compiler capability, diagnostic code, warning, programming
  principle, standard-library entry or backend fact, with a stable ID.
* **Indices are views.** A topic names the indices it belongs to (`index:
  concepts rules`); nothing is written twice under errors, warnings and
  concepts. The indices are `concepts`, `rules`, `proofs`, `errors`,
  `warnings`, `lint`, `principles`, `stdlib` and `backends`.
* **Data, not code.** Topics are plain-text files. The engine
  (`compilerpedia/compilerpedia.tcl`) parses, indexes, searches and renders
  them; no CLI branch holds documentation.
* **Derived where the compiler knows.** Standard-library signatures, errors,
  method eligibility and backend availability are generated from the native
  registry and the library sources; the diagnostic inventory that coverage is
  checked against is scanned from the compiler's source; the warning list is
  the warning pass registry. Hand-written text explains; it never restates a
  list the compiler owns.
* **Separate from compilation.** Help reads only its own files: it never
  compiles, imports or loads a module, starts a backend or reads the
  compiler's state. Diagnostic help lines are presentation: they are looked
  up from the printed code and message, after the compiler has reported.
* **Tested.** Every example compiles, runs or is rejected as its page says;
  every reference resolves; every diagnostic code the source can report and
  every warning has a topic (`tools/compilerpedia.tcl check`,
  `tests/compilerpedia.test`).

## 2. Layout

```
compilerpedia/compilerpedia.tcl   the engine: parse, index, search, render, validate
compilerpedia/topics/*.topic      hand-written topics
compilerpedia/generated/*.topic   generated topics (stdlib.topic): never edit
compilerpedia/notes/stdlib.notes  prose merged into the generated stdlib topics
tools/compilerpedia.tcl           generate, check, examples, inventory
tests/compilerpedia.test          the catalogue, search, rendering and coverage
tests/main-cli.test               the command line: usage, -help, -version, errors
```

The single executable packs `compilerpedia/compilerpedia.tcl`, `topics/`
and `generated/` (single/package.tcl); the notes and the tool are
development files.

## 3. Topic files

A `.topic` file holds any number of topics. Lines before the first `@topic`
are the file's header comment; after it, a line with `#` in column 0 is a
comment, except inside an example (whose lines are Botlish, comments
included). Body text is therefore indented or starts with another character.

```
@topic proof.list-bounds
title: Indexed access: when std::list::at cannot fail
summary: One sentence (at most 200 characters): what the topic says.
index: proofs stdlib
alias: bounds proof; index proof; IndexNotFound
keywords: std::list::at, guard, descending
related: proof.slices rule.unhandled-errors stdlib.std::list::at
docs: STDLIB-NAMESPACES.md STATIC-COMPLETION-PROOFS.md
code: CORE SEMANTIC UNHANDLED-ERROR
match: CORE SEMANTIC UNHANDLED-ERROR | *"std::list::at" may produce*

== LANGUAGE GUARANTEE
Text, verbatim: wrap at about 76 columns; indent code by 4 spaces.

@example accept
import std::list
[1, 2, 3].at(0)
@value 1
@caption One-line description shown above the code
@end
```

### Header keys

The header runs from `@topic ID` to the first blank line.

| key | value | |
|---|---|---|
| `title` | one line | required |
| `summary` | one sentence, at most 200 characters | required |
| `index` | index names, space-separated | required; at least one |
| `related` | topic IDs, space-separated | each must exist |
| `docs` | design documents (bare names in docs/) | shown as optional repository links |
| `alias` | phrases separated by `;`, repeatable | exact-match lookup keys; unique across the catalogue |
| `keywords` | phrases separated by `;` or `,` | weighted search words |
| `code` | one diagnostic or warning code per line, as printed: `CORE SEMANTIC TYPE`, `SURFACE MODULE CYCLE`, `NATIVE NOT-BUILT`, a parser code such as `LIST-DESTRUCTURING`, a warning code | the topic *documents* the code; each code is documented by one topic |
| `symbol` | standard-library symbols | generated topics only, in practice |
| `match` | `CODE \| GLOB`, repeatable | a printed diagnostic of CODE whose message (without its location) matches GLOB points at this topic |

### IDs

An ID is a lowercase category, a dot and a name: `concept.method-sugar`,
`rule.if-placement`, `proof.list-bounds`, `error.unhandled-error`,
`warning.method-eligible`, `principle.name-the-parts`, `backend.interp`,
`cli.options`, `capability.integer-division`, `task.print-output`,
`lint.policy`, `index.errors` (an index's introduction), and the generated
`stdlib.std::list::at`, `stdlib.module.std::list`. The category is a reading aid; the
`index:` key decides where a topic is listed. IDs are stable: other topics,
the help lines the compiler prints and users' notes refer to them. Rename one
only with every reference.

### Sections

`== HEADING` starts a section (shown upper-cased); its lines follow
verbatim, indented four columns when shown. Use the headings the reader
expects for the kind of topic:

* a concept: WHAT IT IS, RULES, WHY, EXAMPLES, MORE;
* a rule: THE RULE, WHY, WHAT IS REPORTED, WHAT TO DO;
* a proof: LANGUAGE GUARANTEE, RECOGNIZED PATTERNS (PROVEN TODAY),
  LIMITATIONS (NOT PROVEN TODAY), WHAT TO DO WHEN THE PROOF FAILS;
* an error: MEANING, LIKELY CAUSES, HOW TO INVESTIGATE (and WHAT TO DO);
* a warning: WHAT IT DETECTS, WHY IT MATTERS, RECOMMENDED PRACTICE,
  EVIDENCE, LEGITIMATE EXCEPTIONS -- required, the check fails without
  them -- then EXAMPLES and, where relevant, RESPONSES;
* a principle: THE PRINCIPLE, WHY, IN PRACTICE, WHEN IT DOES NOT APPLY;
* an absent facility (`capability.*`): STATUS, NEAREST ALTERNATIVE.

A topic says what is true of this compiler, and keeps three things apart
where they could be confused: what the language guarantees, what the
compiler proves today, and what it does not prove (yet). An absent facility
is documented as absent, with the nearest supported alternative: never
describe something Botlish does not have as if it existed.

### Examples

```
@example accept           (or reject)
...source lines of a complete program...
@DIRECTIVE ...
@end
```

An example is a whole program, compiled on its own through the public front
end (strict, warnings default) with nothing imported but what it imports.
One that imports a Linux namespace documents Linux: on a host of another
operating system the check compiles it for that host architecture's Linux
target (`surface::modules::PlatformTarget`, as the golden runner does) and
runs it on the Tcl backends. One whose outcome is a fact of one target (a C
scalar's width, say) names it with `@target`, and is compiled for it the
same way on every host.
Directives:

| directive | for | meaning |
|---|---|---|
| `@value TEXT` | accept | the program's value, as `main.tcl` prints it after `value:` |
| `@warn CODE` | accept | the compilation warns CODE (repeatable) |
| `@nowarn CODE` | accept | the compilation does not warn CODE (repeatable): the negative case of a lint rule |
| `@quiet` | accept | no warning at all |
| `@backends LIST` | accept | where it runs: `interp compile` (the default), any of `cranelift-generic cranelift`, or `all` |
| `@output LINE` | accept | a line the program prints (repeatable), checked through `main.tcl` on each backend listed (use with a native backend) |
| `@error CODE` | reject | the first diagnostic's code, as printed: `CORE SEMANTIC KNOWN-ERROR`, `SURFACE SYNTAX`, `SURFACE MODULE CYCLE` |
| `@at LINE:COL` | reject | the first diagnostic's location |
| `@message GLOB` | reject | the first diagnostic's message, without its location |
| `@caption TEXT` | both | the line shown above the code |
| `@target TARGET` | both | compile for TARGET (a `core::cabi` target name), on the Tcl backends when it is not the host's |
| `@module NAME` | both | the lines up to the next directive are the text of `NAME.bot`, an application module beside the program (repeatable), for an example about modules (`private`, opaque structs, airlocks: MODULE-PRIVACY-AND-CONTEXT-ESCAPE-MILESTONE-1.md); the page shows it under `-- NAME.bot`, and an `@at` in it is written `NAME.bot:LINE:COL` |

A rejected example is checked against the compiler's structured diagnostics
(the error code and the first entry of `-diagnostics`), never against
printed text: an expected message cannot pass by appearing somewhere else in
the output. When the example's topic documents the code (`code:`) or matches
it (`match:`), the check also requires that the help line printed for that
diagnostic names this topic. Keep examples small and independently
intelligible; prefer one rejected example per rule to several. A rejected
example whose function is also called at top level may report the call
first: end such a program with a plain `0`.

## 4. Indices, search and pages

`-help` with no query prints the overview: first the primer's table
(BEFORE YOU WRITE A PROGRAM: the AT A GLANCE section of
`task.first-program`, rendered as that page renders it -- a view of the
topic, never a copy -- and the query that shows the page, `-help primer`;
AGENT-PRIMER.md), one line for a newcomer
(`New to Botlish?  botlish -help "best practices"`, the topic
`principle.idiomatic-botlish`), the indices with their sizes and example
queries. The usage summary (no arguments) names `-help primer` before the
options. `-help NAME` with an index name (or its singular) prints
the index: its introduction (the topic `index.NAME`) and one line per topic
(the standard-library index lists the modules and the hand-written topics;
each module's page lists its symbols). An index's size counts its topics,
not its introduction. `-help all` lists every topic ID by index.

Any other query is looked up in this order: the keys as written, then
case-insensitively, then loosely (`-`, `_`, `.` and spaces alike:
`method eligible`); within each, by rank:

1. an exact topic ID;
2. an exact code (the whole code, or its last word: `KNOWN-ERROR`) or
   standard-library symbol (`std::list::at`);
3. an exact alias;
4. a word search: the query's words, minus stop words, each folded to its
   singular, must *all* occur in a topic, and at least half of them in its
   ID, title, aliases, keywords or summary (a page whose text merely
   mentions the words is a near match, not an answer); a word scores by the
   best field it occurs in (ID, codes, symbols and title 30; aliases 25;
   keywords 20; summary 10; body 2), a topic by the sum.

A code's last word that is a plain word (`TYPE`, `STRUCT`, `RANGE`) is a
key only as written, in capitals: `-help STRUCT` is the run-time error,
`-help struct` the concept (its alias), `-help range` a word search. Case
matters in one more place: `std::abi::I8` (the type) and `std::abi::i8` (the
function) are both symbols, and the spelling as written decides.

A single result is shown as its page (an index's introduction,
`index.NAME`, as the whole index: `-help "style guide"` is the
principles index); several are listed best first (ties by ID), with their
summaries; nothing found prints the near matches (edit distance on IDs,
codes, symbols and aliases; pages whose text holds every word; topics
holding most of the words) on stderr and exits 1. `-help` never fails
silently, and a reader that stops early (`| head`) ends it quietly.

A page is plain text: the ID and title, the indices, SUMMARY, CODE or
SYMBOL, the topic's sections and examples, SPECIFIC RULES (for a code: the
topics whose matchers point at it), RELATED (the topic's own, then the
topics that name it as related) and DESIGN DOCUMENTS (repository paths,
marked optional: every page is complete without them). No ANSI, no paging,
no terminal width: a page fits 80 columns. The engine wraps what it
composes (summaries, lists, example headings) at 78; a section's text is
shown as written, four columns in, so the check holds hand-written prose to
76 columns and titles to 78 (code lines, indented four or more, may be
longer), and the generator refills library comments' prose to 76.

## 5. Diagnostics and help lines

`main.tcl` prints, after each diagnostic it prints, a line

```
   help: botlish -help rule.if-placement
```

naming the topic `compilerpedia::topicForDiagnostic CODE MESSAGE` finds:
the first topic (catalogue order) with a matcher `CODE | GLOB` whose glob
matches the message, else the topic that documents CODE, else the one that
documents its longest prefix of two or more words (a code whose last words
vary: `NATIVE UNSUPPORTED value`, `CORE DECLARED-ERROR NAME`). Each topic is named
once per input file. A program that warns gets one line per distinct warning
code, on stderr after the warnings. The diagnostic itself -- its code, its
message, its order, the recovery state, `CompilerError`'s text, the
static-decision scheduler's inputs -- is unchanged: the lookup reads the
catalogue only, and only `main.tcl` prints the line. It reads only the
topics' header lines (`compilerpedia::DiagnosticTables`, a scan of the
files for their `code:` and `match:` keys, held equal to the full load by
`cp-diagnostic-tables-equal-load`), so a rejected compilation pays about
30 ms for its help lines, and a clean one never loads Compilerpedia.

A broad code (`SURFACE SYNTAX`, `CORE SEMANTIC TYPE`,
`CORE SEMANTIC UNHANDLED-ERROR`) is documented once, and each specific rule
behind it is a topic of its own with a matcher. The code's page lists those
rules (SPECIFIC RULES). A matcher must be exercised: its topic carries a
rejected example of that code, and the check verifies that the example's
help line names the topic.

## 6. The standard library

`tools/compilerpedia.tcl generate` writes `compilerpedia/generated/stdlib.topic`:

* one topic per namespace (`stdlib.module.NS`; `stdlib.module.root` for the
  language primitives): the module's header comment, its source file and
  directness, and its members, each with its kind and first comment sentence;
* one topic per public native (`stdlib.std::list::at`, `stdlib.mod`): its
  signature, declared errors and use (import, method syntax, `nomethod`)
  from `core::native`'s registry, and its backends (a native whose registered
  runtime needs a raw address or a raw system call is native-only);
* one topic per library declaration (`stdlib.std::list::get`, `stdlib.std::test::value`):
  its declaration text and the comment above it, from `stdlib/*.bot` through
  `surface::parse`. A comment block that starts on the file's first line is
  the module's header, never a declaration's; a block of several paragraphs
  whose later paragraph begins with the declaration's name is that
  declaration's from there on (`stdlib/web.bot`'s `local_extra_chars`).

Natives have no source comment, so each has a note in
`compilerpedia/notes/stdlib.notes`: a topic-format entry with the same ID
whose `summary` (and any aliases, keywords, related topics, sections and
examples) the generator merges in; a list key the generated topic already
has (`index: stdlib`) is merged without repeating a value. A library declaration may have a note
too. The check fails when a public native has no note, when a note names no
current entry, and when the generated file is not what `generate` writes, so
a new intrinsic or a changed signature cannot go undocumented: regenerate
and commit.

## 7. Validation

`tclsh9.0 tools/compilerpedia.tcl check` (and `tests/compilerpedia.test`,
which runs it) fails on:

* a structural problem (`compilerpedia::validate`): a duplicate ID; an ID
  outside the category-dot-name form; an unknown index; a related ID that
  does not exist; an alias shared by two topics or shadowed by an ID, code or
  symbol; a code or a symbol documented by two topics; an index without
  topics; a rejected example without `@error`;
* a stale generated file, or a native without a note, or a stale note;
* an undocumented diagnostic: the inventory (`tools/compilerpedia.tcl
  inventory`) is scanned from the compiler's source with the patterns each
  reporting mechanism uses -- the census token scan of
  `tests/static-compile.test` over `hir/*.tcl` and `surface/modules.tcl`
  (minus warning codes, design-document names and regular-expression
  fragments) and every `hir::static::codes` kind; the loader's `Error KIND`;
  the parser's `FailCode`; `core::semanticError KIND` and literal `throw`
  codes in `core/`, `compiler/`, `native/`, `hir/` and `surface/`; the Rust
  runtime's error-code vectors; and the warning registry -- and every entry
  needs a topic whose `code:` names it;
* a warning topic without the five required sections, without an example
  that warns and one that does not, or without its `-warnings error` code
  (`CORE SEMANTIC CODE`); so a new warning without a documented rationale
  fails the check;
* a matcher no rejected example exercises;
* an example that does not compile, run, print or fail as stated, on every
  backend it names that is available (the native ones when the native
  backend is built on Linux x86-64 or AArch64, where std::linux::io, syscalls
  and C calls run natively), or that draws a warning it does not state (`@warn`):
  pages show code a reader can copy without a surprise.

`tests/compilerpedia.test` adds the search and rendering behaviour (exact
lookups, aliases, case, multiword queries, ambiguity, unknown queries,
ordering, cross-index lookup, non-ASCII), the help lines `main.tcl` prints,
and that help never compiles, loads or runs anything. `tests/main-cli.test`
covers the command line: usage, `-help`, `-version`, malformed invocations,
exit statuses and output channels.

## 8. The warning precision corpus

Each warning topic carries the rule's positive examples (`@warn`) and,
especially, its legitimate negative ones (`@nowarn`): the guard-style
predicate, the handler alternatives of one call, the Int literal receiver.
They run with the catalogue's check, so a change that restores a known
overbroad warning fails it. The warnings' own unit tests, fuzzers and
mutation harnesses (AGENTS.md, "Compiler warnings") remain the primary
evidence; the Compilerpedia examples are the user-facing statement of the
same rules, and the report's lint audit (COMPILERPEDIA-REPORT.md, "Lint
audit") records why each rule is as precise as it is.

## 9. Adding things

* **A language rule or concept**: a topic in `topics/rules.topic` or
  `topics/concepts.topic`, with examples; a matcher if a broad diagnostic
  code reports it.
* **A diagnostic kind**: the check fails until a topic documents its code
  (`code: CORE SEMANTIC KIND`): meaning, causes, how to investigate, and a
  rejected example. A new kind also needs its census entry
  (`tests/static-compile.test`, AGENTS.md).
* **A warning**: its topic in `topics/warnings.topic` with the required
  sections and examples both ways, plus the lint audit's questions answered
  in its design document.
* **A standard-library operation**: regenerate (`tools/compilerpedia.tcl
  generate`); an intrinsic also needs a note in `notes/stdlib.notes`.
* **A backend or platform fact**: `topics/backends.topic`; state only what
  the backends do today.
* **The newcomer page** (`principle.idiomatic-botlish`, IDIOMATIC-BOTLISH.md)
  is a map of defaults, each linked to the topic that holds the rule, the
  reasons and the exceptions. A new item states a Botlish-specific default
  in a sentence or two and links; it never copies a detailed page, and its
  statement of a rule changes when that rule's topic does. A test
  (`cp-idiomatic-shape`) keeps it short.
* **The primer** (`task.first-program`, AGENT-PRIMER.md) is what someone
  arriving from another language reads before writing a program: its AT A
  GLANCE table (the overview's first block) lists the habits that fail to
  compile or compile and mean something else, each with its Botlish form,
  and its examples pin them (the silent one as an accepted example with its
  surprising value). A row is a habit seen in practice, not a rule summary;
  keep the table within 76 columns and short enough to read in the
  overview. A habit whose diagnostic can be told apart by its message gets
  a matcher, so its help line names the page that explains it
  (`cp-diagnostic-habits` compiles each one).
* **An alias**: a phrase people type (`try catch`, `exit status`) maps to
  the topic that answers it; mappings from other languages must be
  semantically accurate (`throw` is `fail` of a declared error, not an
  exception).

Then run `tclsh9.0 tools/compilerpedia.tcl check` (under a minute with the
examples) and `tclsh9.0 tests/compilerpedia.test`.

## 10. Packaging

`single/package.tcl` packs `compilerpedia/compilerpedia.tcl`,
`compilerpedia/topics/` and `compilerpedia/generated/` beside main.tcl, so
`botlish -help` works from the single executable with no source tree. The
packaged `BUILD` file records the source revision `-version` prints.
`single/main.tcl` does not install the native executables for an invocation
that is only help, a version or the usage summary.
