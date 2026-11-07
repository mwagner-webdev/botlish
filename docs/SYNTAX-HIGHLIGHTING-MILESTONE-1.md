# Syntax highlighting, milestone 1: the token IR, excerpts and color, semantic tokens, editor grammars

Status: complete. The compiler says, in one specified form, what every token
of a text is -- the token IR -- and everything that highlights Botlish reads
it or is checked against it: the command line's diagnostics (source
excerpts, underlined and highlighted, colored on a terminal), the compiler
service's highlight tokens, the language server's semantic tokens, and the
TextMate (VS Code) and Vim/Neovim grammars, which are generated from the
compiler's own word lists. Why the lexer is not written in Botlish for this
is BOTLISH-LEXER-RATIONALE.md.

## 1. What was there

No grammar (editors/vscode/README.md said so), no semantic tokens
(LSP-MILESTONE-1.md, "Not implemented"), and diagnostics printed as one line,
`FILE:LINE:COLUMN: MESSAGE (CODE)`, with a help line. The lexer knew 21
keywords; the parser recognized about sixty more words by comparing an
identifier's text where a construct starts, recording nowhere which
identifiers it had read so. A highlighter had no way to know them, and a
hand-written grammar would have copied the lists and drifted.

## 2. The token IR (`surface/tokens.tcl`)

Version 1 is a dict (the file's header is the specification):

- `version 1`, `length` (the text's length in Unicode scalar values; every
  offset counts them, END exclusive);
- `tokens`: `{KIND START END VALUE}` each, in order, ending in EOF. KIND is
  one of `surface::tokens::kinds`: IDENT, INT, HEX, DECIMAL, STRING, CHAR, a
  keyword or an operator as its own text, NEWLINE, INDENT, DEDENT, EOF. The
  token's text is the source's [START, END); its VALUE the lexer's (an
  identifier's name, a literal's canonical or decoded value, a keyword's own
  text, "" otherwise);
- `comments`: `{START END}` each, a `#` to its line's end;
- `diagnostics`: `{START END MESSAGE ROLES}` each, ROLES how the parser's
  recovery weighs it (`structural`, `skipped`, `indentation`, `unclosed`);
- `synthetic`: the offsets of the closers the lexer inserted;
- `words`: the indices of the identifiers a parse read as contextual words.

Lines and columns are not in it: they follow from the offsets and the text.
`surface::syntaxTokens SOURCE FILE` makes the IR of a text's recovering
parse; `surface::tokens::fromLexed` the IR of a lexer result; `toLexed` the
lexer result an IR stands for; `validate` checks an IR against its text
(kinds, order, bounds, each token's text against its kind, comments, roles,
words) and raises `{SURFACE TOKEN-IR}` at the first problem;
`classes` gives the highlight classes every highlighter reads: `keyword`,
`word` (a contextual word), `constant` (true, false, unit), `number`,
`string`, `char`, `comment`, `operator`, `identifier`.

The IR is the seam a later lexer in another language would produce:
`toLexed (fromLexed L) = L` exactly, so the parser reads nothing the IR does
not hold. Checked over **every one of the repository's 1,504 Botlish files**
(the round trip, the validator and the words: 0 problems) and, in
tests/syntax-highlighting.test, over the standard library, the grammars'
fixture and texts with lexical errors. The level is tokens only: no syntax
tree (BOTLISH-LEXER-RATIONALE.md, section 2).

The lexer now also reports its comments (`comments`, the one thing it reads
that no token stands for). The AST is unchanged: surface::parse drops the
words, and over all 1,504 files the recovering parse's AST with the final
parser and lexer was compared with `main`'s (identical: no file of the
repository meets the defect of section 4).

## 3. Contextual words (`surface/parser.tcl`)

`surface::parser::words` lists every contextual word of the grammar (70 of
them); `refusedWords` the six the parser compares an identifier with only to
refuse a construct that does not exist (`import ... as`, `namespace`, a
loop's `by`, `where`, `requires`, `implements`, `extends`). Every place the
parser consumes an identifier as a word now consumes it with `Word` (or, for
an identifier known to be a word only after it was read -- a dfa item's
`any`, `end` -- records it with `WordAt`), which records the token's index
and refuses an unregistered word (the parser's own mistake, never a
diagnostic). A word read before a construct's syntax error is recorded: it
was read as a word. `sh-words-registered` checks that every word the parser
compares an identifier with, and every word of its modifier lists, is
registered or refused; `sh-words-recorded` that the grammars' fixture
records all 70 and none of the names of the same spelling.

## 4. A lexer defect the round trip found

In the newline branch that closes brackets before a statement-like line,
`regexp ... $source indentation` stored its match into `indentation` -- the
variable holding the indices of the layout diagnostics. After any bracket
closed that way, the list was a run of spaces: a tab or an inconsistent
dedent reported before it lost its `indentation` role, and syntax recovery
weighed it as an ordinary lexical diagnostic (surface::parser::Damage). The
match now has its own variable (`lead`); `sh-lexer-indentation-kept` pins it.
Only a file with both a layout diagnostic and such a bracket is affected.

## 5. Excerpts and color on the command line (`main.tcl`)

`-color WHEN` and `-excerpts WHEN` (auto, always, never), for every run,
`run` and `-check`:

    == broken.bot (interp)
       error: broken.bot:3:9: unbound name "bb" (CORE SEMANTIC UNBOUND)
         |
       3 |     a + bb   # oops
         |         ^^
       help: botlish -help error.unbound

- **auto is a terminal.** Tcl has no isatty; a channel Tcl opened on a
  terminal is a serial channel, the only kind with a `-mode` option, which no
  pipe or file has. Color also needs NO_COLOR unset and TERM not `dumb`.
  Windows' console is never taken for a terminal (its legacy host shows the
  escape sequences unless virtual-terminal processing is on, which Tcl
  cannot switch on): `-color always` there, in a terminal that reads them.
- **A pipe or a file gets the plain format byte for byte**, so no test,
  tool or Compilerpedia example sees a difference (`sh-cli-plain-unchanged`).
- **The excerpt** comes from the diagnostic's structured location
  (core::raiseDiagnostics' `location`; -check's service records), never
  from its text, in the text the compilation read: -check's revision text
  (`service::sourceText`), else the file through the source seam
  (`surface::source::text`, normalized). It shows up to three lines of the
  span, underlines from where it starts to where it ends on each, one `^`
  for an empty span or one at a line's end; a span that ends past its
  line's newline (a NEWLINE token's) is that line's. A tab is shown as four
  spaces and the underline counts a character's display width (2 for East
  Asian wide characters and emoji, 0 for combining marks: an approximation,
  Tcl ships no width table).
- **Color**: the label, the location and the code, the gutter and the
  underline, and the excerpt's source highlighted with the token IR's
  classes (`surface::tokens::classes`, computed only when color is on: one
  more lex and parse of that file).
- What is not changed: warnings a compilation prints itself (the front-end
  cache prints them while compiling) stay as they are; -check's warnings,
  which main.tcl prints, get colored labels and an excerpt. Notes keep their
  text and get a colored label, no excerpt. A standalone executable's
  run-time error has no location.

## 6. The compiler service's tokens (`service::tokens`)

`service::tokens REV PATH` gives `{START END TYPE MODIFIERS}` for a source a
revision read, the types and modifiers in the order of the protocol's legend
(`service::tokenTypes`: namespace type struct enum interface parameter
variable property enumMember function keyword comment string number
operator; `tokenModifiers`: declaration defaultLibrary). It adds no
semantics:

- every token's lexical class is the token IR's (a contextual word is a
  keyword, a character a string);
- the AST's facts: declared names (`struct`, `enum` and its cases, `trait`
  as interface, `type`, `error`, `layout`, fields, trait requirements), the
  spans of type annotations (an identifier in one is a type), field
  initializers and projections (properties), a method call's name, imported
  namespaces;
- the HIR's resolution: a name resolved to a binding is a function (a
  binding a `fn` declares, a native: `defaultLibrary`), a parameter of a
  function, or a variable (a local, a loop variable, a handler's payload);
  `defaultLibrary` for one of the standard library; a qualified name's
  earlier segments are namespaces, an `Enum::Case`'s enum and case; a
  binding's declaration site carries `declaration`;
- a name the analysis has no binding for -- unresolved, or inside a malformed
  statement whose meaning is unknown (SYNTAX-RECOVERY-MILESTONE-1.md) --
  keeps only what the syntax says, which for a plain name is nothing: no
  token.

The tokens are one of a revision's query indexes: `service::prepare` builds
them for the paths it is given, `service::export -derived 1` carries them,
`service::import` accepts them. Cost: the token IR is one more lex and parse
of the file -- examples/games/2048/demo.bot 5 ms, stdlib/event_loop.bot
(1,851 lines, 10,697 tokens) 1.0 s for its tokens, about 0.6 s of it the
lexer and parser; the language server's worker computes them for the open
documents only.

## 7. Semantic tokens in the language server

The server advertises `semanticTokensProvider` with the service's legend and
`full: true` (no `range`, no `delta`), and answers
`textDocument/semanticTokens/full` from the owner's revisions with the same
rule as definition and references (LSP-MILESTONE-1.md, section 4.6): a
fresh revision answers; a stale one waits while an analysis is pending, and
otherwise answers with the tokens in the text the client's document shares
with it (the unchanged prefix and suffix of one edit: `Mapping`); a
revision with or without a HIR answers (any source it read has tokens). The
encoding is the protocol's relative one in the negotiated position encoding
(UTF-16 or UTF-32). When a fresh analysis lands, a client that declared
`workspace.semanticTokens.refreshSupport` is sent
`workspace/semanticTokens/refresh` -- the server's first request to the
client; its response is dropped. A document no analyzed program reads gets
null.

Found on the way: `service::import` accepts only the derived index kinds it
knows, so the worker's revisions carrying the new `tokens` index were
refused -- every analysis in the editor would have failed. The kind is now
accepted (`sh-service-tokens-exported`).

## 8. The editor grammars (`tools/editor-grammars.tcl`)

`tclsh9.0 tools/editor-grammars.tcl generate` writes
editors/vscode/syntaxes/botlish.tmLanguage.json (registered in the
extension's package.json), editors/neovim/syntax/botlish.vim (botlish.lua
puts its directory on the runtime path) and the fixture's expected classes
(editors/vscode/test/fixtures/sample.classes.json); `check` exits 1 when a
committed file is not what generation writes.

- The lexer's keywords are placed in groups (control, declaration, word
  operators, constants); generation fails when a keyword is in none or two.
- The contextual words are one table of patterns, each written for TextMate
  (Oniguruma) and for Vim (magic; a `{PREFIX WORDS SUFFIX}` triple turned
  into a lookbehind and a lookahead, so a prefix another item claims -- a
  keyword, an operator -- cannot hide it). Each matches a word only where
  the parser reads it, so a name of the same spelling stays a name.
  Generation fails when a registered word has no pattern or a pattern names
  a word the parser does not register (`sh-grammars-refuse-drift`).
- A declared name -- the name `fn`, `struct`, `type` or `error` introduces
  -- is marked as a function's or a type's (TextMate's `entity.name.*`,
  Vim's botlishFunction and botlishType); no other name is. What is declared
  is the syntax tree's (`grammars::Declared`: the name spans of functions,
  externs, trait requirements, structs, types and errors), so a name after
  one of those keywords that the parser reads otherwise (`std` in `import
  type std::ffi::c::Int`) is not, and a rule that hides the name (the
  domain type's `in` rule) is caught. Vim's patterns look behind the
  keyword: a `\zs` pattern would start at the keyword, which the keyword
  item claims first.
- A regular-expression grammar cannot be the parser: a word in a position no
  pattern foresees is not highlighted by the grammar, and the semantic
  tokens give it its class once the server answers.

Checked against the token IR's classes on a fixture
(editors/vscode/test/fixtures/sample.bot: every lexical class, every
contextual word where it is read, names spelled like words): with VS Code's
own engine (vscode-textmate over vscode-oniguruma, devDependencies of the
extension; `npm test` in editors/vscode, and `sh-grammar-textmate-fixture`
when they are installed), and with Vim's syntax engine (`vim` headless,
`sh-grammar-vim-fixture`; also stdlib/actor.bot and
examples/dfa/csv/csv_strict.bot, `sh-grammar-vim-corpus`), and in Neovim
through its own configuration (`lsp-neovim-highlighting`: the syntax in
force, every fixture token's group, and a semantic token received by
Neovim's client). Every check: every keyword, contextual word, constant,
number, string, character, comment and declared name has its class, and no
other name is a keyword, a constant or a declared name. Vim's also agreed
on icy-tower's sdl.bot during development.

The declared-name check was added after trying the grammar in VS Code: the
first version compared keywords and lexical classes only, and let three
mistakes through -- `std` of `import type std::...` marked as a declared
type (both grammars), Vim marking no declared name at all (its `\zs`
patterns started at the keyword), and TextMate leaving `Small` of `type
Small = int in 0..9` unmarked. All three are fixed; each has a mutant
(`declared-name-qualified`, `vim-declared-name-claimed`,
`domain-name-unmarked`), killed.

## 9. Tests and what ran

| test | result here |
|---|---|
| tests/syntax-highlighting.test (27 tests: words, lexer, IR, classes, service tokens, CLI, grammars with Vim and VS Code's engine) | 27 passed |
| tests/lsp.test's `lsp-proto-initialize` and the five `lsp-tokens-*` | passed |
| tests/main-cli.test | 68 passed, 4 skipped (native not built) |
| editors/vscode `npm test` (grammar.test.js included) | passed |
| tests/lsp-neovim.test's `lsp-neovim-highlighting` | not run here (Neovim is not installed, and downloading it was refused in this environment); CI's dispatched tests.yml installs its pinned release (section 9.2) |
| the IR round trip and validator, the words, over 1,504 files | 0 problems |
| the AST of every file, `main` against this change | identical |
| `tools/mutant-catalogs.tcl` | 0 problems after updating two compiler-service mutants of main.tcl, both killed again |

The local run of the whole Tcl layer and the golden suites, and the harnesses, are section 9.1.

### 9.1 The local run and the harnesses

The native backend is not built in the container this was done in (it needs
a newer Rust toolchain than the one installed), so the local run covered the
Tcl backends: `tests/local.tcl -golden-backends "interp compile"`.

- **Golden suites:** all 118 pass on interp and compile, through the
  front-end cache.
- **Tcl test files** (272, each on interp and compile): 198 runs pass. The
  others fail the tests that compare all four backends, `NATIVE NOT-BUILT`
  for the two native ones: 1,070 failing tests in all. The failures whose
  text does not name the native backend (69 tests, the "backend
  independent" comparisons among them) are in 21 files; each of those files
  was run on `main` and on this change, and the two fail **the same 366
  tests**. `traits.test` and `c-bindgen.test` were also compared by name:
  identical. The one failure this change did cause was an expectation of
  its own: `cs-export-import-derived` lists a revision's derived indexes,
  which now include `tokens` (updated).
- **Mutation testing:** `audit/syntax-highlighting/tools/mutate.tcl`, 17
  mutants, 17 killed, each by a test its `!!` line names. The two
  compiler-service mutants of main.tcl updated to the new code (section 9)
  are killed again. The declared-name fix (section 8) added three mutants,
  run with the two earlier grammar mutants: 5 of 5 killed (20 in the
  catalog).
- **Syntax recovery's fuzzer** (`audit/syntax-recovery/tools/fuzz.tcl`,
  seeds 1, 7 and 23; it injects tabs and line breaks, the lexer defect's
  ground): seeds 7 and 23 clean. Seed 1 reports two failures of one case,
  which **reproduce on `main`**: deleting a newline between two field
  lines of icy-tower's `struct Player` makes the declaration a hole, and
  `struct World`'s field of type `Player` then raises "unknown type" as a
  compiler failure instead of depending on the hole (outcome `failure`, the
  syntax error unreported). A defect of syntax recovery, not of this change;
  left for its own fix.
- **The recovery harnesses** (the lexer's `indentation` list feeds syntax
  recovery's damage record): `audit/syntax-recovery/tools/mutate.tcl`, 37
  mutants, 37 killed (tests/syntax-recovery.test passes 33 of 33 here, so
  each kill is the mutant's); `audit/diagnostic-recovery/tools/efficiency.tcl`,
  15 cases, every known primary in the first compilation (32 of 32), no
  cascade; `audit/diagnostic-recovery/tools/mutate.tcl`, 27 mutants, 25
  killed by tests that pass here, and two (`poison-return-check`,
  `runnable-off`, which mutate how a backend runs a lenient HIR: code this
  change does not touch) only by tests that already fail here for the
  native backend: inconclusive in this container.

### 9.2 The branch's CI

The first push's runs: the Linux and arm64 canaries, the icy-tower
workflows on Windows and macOS pass. The Windows canary failed eight tests
of tests/syntax-highlighting.test, two portability mistakes of the tests
(an expected `tclsh9.0.exe` where main.tcl names itself without `.exe`;
`/dev/null` as Vim's input), fixed in the next commit. The canaries do not
install Neovim, so `lsp-neovim-highlighting` runs only in a dispatched
tests.yml run of the branch.

## 10. Limitations

- The grammars are regular expressions: a contextual word in a position no
  pattern foresees is unhighlighted until the semantic tokens arrive.
- Semantic tokens: `full` only (no `range`, no `delta`); a type named in
  an annotation is `type` by its position, never resolved (the service has
  no resolution of type names); no token inside a malformed statement but
  its lexical classes.
- The excerpt's display width is an approximation (no Unicode width table).
- Warnings printed by the compilation itself in a run are not excerpted.
- A revision's tokens cost one more lex and parse of the file (section 6).

## 11. What to run when changing this

If you change the lexer's or the parser's recording (`comments`, `Word`,
`WordAt`, `words`, `refusedWords`), `surface/tokens.tcl`, main.tcl's
presentation, `service::tokens`/`TokenIndex`, the server's semantic tokens,
`tools/editor-grammars.tcl` or the fixture, run
tests/syntax-highlighting.test, tests/lsp.test, tests/main-cli.test,
tests/compiler-service.test, `tclsh9.0 tools/editor-grammars.tcl check` (and
`generate` after a change to the words or the patterns), `npm test` in
editors/vscode after `npm ci`, `audit/syntax-highlighting/tools/mutate.tcl`
(every mutant must still apply and be killed by a test its `!!` line
names), and on a branch the tests workflow for tests/lsp-neovim.test. A new contextual word is registered in
`surface::parser::words`, consumed with `Word`, given a pattern in
tools/editor-grammars.tcl and placed in the fixture.
