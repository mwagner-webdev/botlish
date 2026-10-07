# Compiler warnings: `ONE-CHAR-STRING-LITERAL`

## Outcome

Botlish's sixth compiler warning, **`ONE-CHAR-STRING-LITERAL`**, is one pass
plus one registry line on the warning framework of milestones 1-5
(`hir/warnings.tcl`; WARNINGS-SAME-RETURN.md, WARNINGS-METHOD-ELIGIBLE.md,
WARNINGS-FIXED-ARITY-LIST-RETURN.md, WARNINGS-SAME-FAILURE.md,
WARNINGS-PROVES-NAMING.md): a written String literal whose exact value is one
character.

```botlish
fn peek(text, index):
    text
fn scan_quoted(text, index, field):
    character = peek(text, index)
    if character == "\"":
        return field
    scan_quoted(text, index + 1, field)
```
```
f.bot:5:21: warning: the String literal `"\""` is one character long; a single character is written as a character literal (ONE-CHAR-STRING-LITERAL)
```

(`tests/one-char-string-literal.test`, `oc-motivating-rendered`. The brief's
three-line excerpt calls a `peek` it does not define; a binding must be
defined before it is read, so the pinned program defines it first and the
literal is on line 5, column 21 -- its opening quote.)

The warning states the fact and names the form. It does not print the
character spelling, does not rewrite, does not say the String is wrong, and
never looks at what consumes the literal. It is **deliberately not
autofixable**, and this milestone's verification shows why more sharply than
the brief anticipated: the rewrite does not merely fail to type-check where an
API takes a String -- in two of the three String-taking context kinds it
*does* type-check, and then fails at run time (a native's `str` parameter) or
silently changes the program (`==` of a String and a character is `false`; in
the corpus, a scanner whose loop exits on such a comparison runs forever after
the rewrite). 81 of the 92 corpus findings form the catalog of those APIs;
the other 11 are deliberate Strings, and none can be converted today (see
"Corpus findings").

The three goals:

1. **One pass plus one registry line**, framework untouched: `git diff
   e7f715c -- hir/warnings.tcl` is the inserted registry line and the appended
   section (a header comment and two procedures). No frontend, analysis,
   lowering or native file changed.
2. **The idiom is declared**: README.md §1, "Strings and characters" (new; the
   encode-utf8 work had stated the char/String distinction as a performance
   finding, not as the idiom, so a statement was written rather than cited).
3. **The item-2 inventory was run and its adaptations made here**: 5
   code-enumerating pins, 12 complete-set assertions over programs whose
   one-character literals are incidental test data, 1 error-mode acceptance
   test, and 4 of the 5 warning fuzzers' oracles (see "Kickoff").

**A representation finding (item 4).** The brief expected the node kind to be
the provenance. It nearly is: every written `"..."` lowers to a `const` node,
and HIR text spells one as `const str ...`. But the frontend synthesizes
exactly one String const of its own: a context parameter is bound to
`context#load("ID")` (`hir/contexts.tcl`, `DeclareParams`), whose key is the
context struct's identity -- **one character for a context struct named `C`**.
A pass reading only the node kind would report `fn f(context c: C)` at the
parameter. The pass recognizes that one construct by the compiler's own
predicate for it (`hir::contexts::isLoad`) and never reports its key; no
source can spell `context#load`, so no written literal is affected. This is the
one place the pass looks beyond a const node, and it is a decision the user
may want to revisit (see "Deviations"); a source audit pins every place the
frontend builds a String const, so a second synthesized one fails a test
(`oc-synthesized-string-consts-enumerated`).

## The four calls made before writing, checked

The brief opened with four calls to flag if wrong.

1. **Context-blind by design** -- right, and implemented exactly; but its
   premise is *incomplete*. The call says the warning fires "exactly where Char
   would not type-check today (a `str` parameter)". A declared `str` parameter
   does reject the character spelling statically (`TYPE`). The two other
   String-taking context kinds accept it: a native's `str` parameter is
   checked only at run time (`str::length('a')` compiles and fails with
   `TYPE`), and `==` of a String and a UnicodeChar type-checks and is `false`
   (README §1: values of different kinds are never equal). In the corpus, 55
   of the 92 findings are such comparisons. So the deficiency surface is wider
   than "where it would not type-check", and the strongest reason the warning
   must not be autofixable is the silent case, not the rejected one. The
   decision stands; its documentation says this.
2. **The law weakens to a spelling law** -- right, and implemented. One
   refinement: no *typed* context accepts both spellings in a valid program (a
   `UnicodeChar` parameter rejects the original String statically, a `str`
   parameter rejects the rewrite), so the "Char-accepting contexts" the law
   verifies value preservation in are untyped (or `any`-typed) consumers that
   treat both kinds alike -- the fuzzer generates kind-tolerant matchers
   (`fn is_K(c): c == 'X' or c == sxK`) -- plus a typed probe that a
   `UnicodeChar` parameter takes the character spelling (see "Fuzzing").
3. **No reachability** -- right, implemented and pinned with the milestone-2
   contrast (`oc-dead-branch-literal-warns`).
4. **One code; the message may render the written literal, never the Char
   spelling; no fixit** -- right, implemented. Two details: the form is named
   as the repository names it, "character literal" (the lexer's own
   diagnostics: "empty character literal", "unterminated character literal";
   the type is `UnicodeChar`), not "Char literal"; and the rendering of the
   literal follows the exact-value convention (`core::value::show`), which
   escapes a carriage return as `\r`, as a character literal does (see
   "Record, message, ordering").

## The theorem

> A literal site is reported exactly when it is a **written String literal**
> whose **exact value is a String of character length 1**.

One diagnostic per site. Everything else is silent. Each clause is pinned
(all in `tests/one-char-string-literal.test`):

| clause | pinned by |
|---|---|
| a written String literal: a `const` node whose exact value is a String | `oc-motivating-rendered`, `oc-hir-text-input-warns`, `oc-const-nodes-unchanged` |
| ... and not the synthesized context-load key | `oc-context-load-key-is-not-a-literal`, `oc-synthesized-string-consts-enumerated`, `oc-desugarings-build-no-string-const` |
| ... and not a character literal | `oc-character-literals-never-warn`, `oc-string-beside-character-of-the-same-character` |
| ... and not anything computed or read | `oc-initializer-is-the-site`, `oc-alias-silent`, `oc-parameters-silent`, `oc-call-results-silent`, `oc-computed-strings-silent` |
| exact value, not spelling | `oc-escaped-one-character`, `oc-escapes-are-resolved-by-the-exact-value`, `oc-apostrophe-in-a-string` |
| length exactly 1 (0 and 2 silent) | `oc-length-boundary`, `oc-empty-string-silent`, `oc-two-or-more-characters-silent` |
| length in characters (code points) | `oc-non-bmp-single-code-point`, `oc-grapheme-of-two-code-points-silent`, `oc-length-is-str-length` |
| every written site, wherever it is | `oc-list-and-struct-elements-are-sites`, `oc-nested-positions`, `oc-dead-branch-literal-warns`, `oc-uncalled-and-unreachable-functions-warn`, `oc-module-literal-located-in-the-module` |
| context-blind | `oc-str-parameter-is-the-api-deficiency-shape`, `oc-str-native-argument-warns`, `oc-comparison-with-a-string-warns`, `oc-character-accepting-context-warns`, `oc-the-message-names-no-context` |
| one diagnostic per site | `oc-one-diagnostic-per-site`, `oc-instances-never-walked`, `oc-trait-program-warned-as-written` |

The pass is `hir::warnings::OneCharStringLiteral` with the helper
`ContextLoadKeys`, appended to `hir/warnings.tcl`.

## "Written String literal": the representation and its robustness

**The representation.** String literals are leaf `const` nodes, not calls: the
frontend's rule is `"text"` -> `const str text` (`surface/lower.tcl`, `Node`,
the `string` case), and a character literal is `const UnicodeChar N` (the `char`
case). So no `written` marker is needed or added (milestone 2's marker is a
call-level fact, and no String literal is a call); the node kind, together with
the exact value's kind, is what the pass reads.

**The robustness argument, the milestone-2 way: what can build a `const`
node.** Every `const` node in the HIR the pass reads comes from one of two
constructors (the source audit `oc-synthesized-string-consts-enumerated` lists
every occurrence in `hir/` and `surface/`):

* `hir::syntax::constNode`, called from exactly six places: the frontend's
  integer, String and character literal rules (written literals), the unary
  minus rule (`-a` -> `call ^- (const 0) a`: an Int, never a String), and
  **`hir/contexts.tcl`'s `DeclareParams`, which builds `const str ID` twice**
  -- the context-load key of a context-struct parameter and, since context
  traits (CONTEXT-TRAITS.md, merged from `main` during this milestone), of a
  context-trait parameter in the checked source build;
* `hir::syntax::fromIR`, which reads core IR text (`hir::build`): core IR
  programs are hand-written IR, and no source compilation calls it (warnings
  run only in `surface::lower::Finish`).

Every other desugaring builds no constant: `!=`, `not`, `and`, `or` build `if`
nodes over root references (`true`, `false`); `elif` is a nested `if`; struct
destructuring builds a hygienic binding and projections; flags are names; `with
context` builds a binding and an installation call; collecting and lockstep
loops are loop nodes; method sugar is a call. `oc-desugarings-build-no-string-
const` compiles a program using every one of them with no written String
literal and finds no String const but the context-load key. Trait
monomorphization clones a function per witness, but the framework warns about
the checked source build (`traitSource`), where each function exists once
(`oc-trait-program-warned-as-written`: two clones of one literal, one warning).
Semantic instances live in the `semantic` side table and are never visited
(`oc-instances-never-walked`: three instances, one warning; collecting over
HIR stripped of the table gives the identical result).

**The synthesized-literal finding.** `fn f(context c: C)` gives

```
e3 bind b3 c : C
    e4 call native(context#load) : C
        e5 ref b2 context#load : native context#load
        e6 const str C : str
```

and `e6` is a one-character String const that nobody wrote. It survives HIR
text (`hir::parse` reads the explicit load back). The pass excludes it by
recognizing the construct, with the compiler's own query for it
(`hir::contexts::isLoad`, which every context analysis uses): a context load's
argument is a context identity, not a String literal. Three properties make
this sound and narrow: (1) `context#load` cannot be spelled in source (`#` is
not an identifier character), so no written literal is ever such an argument
and the exclusion silences nothing a programmer wrote; (2) the same predicate
recognizes the load in HIR read back from text, so source and HIR text agree
(`oc-context-load-key-is-not-a-literal`: a written `"C"` in the same program
warns, from source and from HIR text, and the key does not); (3) the fuzzer
declares `context struct C` with a context parameter in 30% of its programs
(602 of 2000), and the `context-key-reported` mutant (the exclusion dropped) is
killed by it. Context traits, merged from `main` while this milestone ran,
added the second construction (`fn f(n: int, context t: T)` binds `t` to
`context#load("T")` in the checked source build); the source audit failed on it
as designed, the same predicate recognizes it, and
`oc-context-trait-key-is-not-a-literal` pins a trait named `T` silent beside a
written `"T"` that warns, from source and from HIR text. The alternatives were
weighed and rejected for now: a `written`
marker on source-built const nodes is new HIR state (the brief requires none)
and would make HIR text silent unless `hir::read` set it too (the brief
requires HIR text to warn); deriving literal-ness from the origin's node role
(`f()/context(c)`) is the origin-shape sniffing the brief forbids.

**Consequences, pinned.** A computed String, a parameter, a call result and a
binding read at a use site are never findings, whatever their value; a
binding's written initializer is a site (`sep = ","` warns once, at the `","`).
An alias is silent at the alias. HIR read back from text warns
(`oc-hir-text-input-warns`: the same three values, located `{ir PATH}`), the
milestone-4 precedent. `""` is length 0, `"ab"` length 2: silent
(`oc-length-boundary`).

## Length is in characters, not bytes

The pass reads the literal's exact value with `hir::exact::Of` -- the fact
milestone 1's grouping uses (`{val {str TEXT}}` for a String const) -- and
measures it with `core::strings::length`, **the reference implementation of
`str::length` itself**. No helper was added: the language's own length is a
function of a value already, and calling it is the strongest form of
"consistently with the language's own notion". So:

* escapes are resolved by the exact value: `"\n"`, `"\t"`, `"\r"`, `"\""`,
  `"\\"` are one character each and warn; `"\\n"` (a backslash and an `n`) is
  two (`oc-escaped-one-character`, `oc-escapes-are-resolved-by-the-exact-
  value`). Botlish has no `\u{...}` escape (the String and character escape sets
  are `\\ \" \n \r \t` and `\\ \' \n \r \t`); other characters are written raw;
* a supplementary-plane character (`"😀"`, `"𝄞"`) is one character and warns
  (`oc-non-bmp-single-code-point`);
* `e` + U+0301 (a grapheme cluster of two code points) is two and is silent;
  the precomposed `é` (U+00E9) warns (`oc-grapheme-of-two-code-points-silent`);
* `oc-length-is-str-length`: over nine literals, the ones that warn are exactly
  those whose `str::length` is 1, on all four backends.

**No spelling gap.** For every Unicode scalar (U+0000..U+10FFFF without the
surrogates: 1,112,064), the one-character String spelling and the character
spelling both lex -- through the lexer's own `String` and `Char` procedures --
to that scalar with no diagnostic (`fuzz.tcl -spelling-exhaustive`, 14.7 s;
`oc-spelling-law-no-gap-sampled` checks 293 of them in the suite). So there is
no language finding of the milestone-5 `unit` kind: every one-character String
has a character spelling (the mechanical rewrite escapes `\ ' \n \t \r` and
writes everything else raw).

## Literals only: no heroic proving

No value identity beyond the literal's own exact value. The pass never follows
a binding (`oc-initializer-is-the-site`: `sep` read four times, one warning),
never evaluates a call (`oc-computed-strings-silent`: `str::concat("ab", "")`
and `"AB".lowercase().substring(0, 1)` are silent, the `"x"` inside
`str::concat("x", "")` warns as the literal it is), and never looks at what a
function returns (`oc-call-results-silent`: functions whose every result is a
one-character String are silent). The `computed-string-warned` mutant -- which
evaluates a native call whose arguments are exactly known -- is killed (see
"Mutation testing"), and so is `use-site-read-warned`.

## Context-blind by design

The pass inspects nothing but the literal (and, for the one synthesized
construct, whether it is that construct). It never looks at the enclosing
call, the callee's parameter types, the other side of a comparison or any
container. The consequence chain, owned:

* **The fact-to-advice gap is the widest of the six, chosen deliberately.**
  `METHOD-ELIGIBLE` gated on a proof that the sugared form resolves to the
  identical callee and compiles to the identical program; `FIXED-ARITY-LIST-
  RETURN`'s conversion law holds for every finding; `PROVES-NAMING`'s rename
  law holds for every finding. This warning's advice ("a single character is
  written as a character literal") is sound at the value level always -- the
  character spelling denotes the same character, which the spelling law
  verifies -- and sound at the program level exactly where the consumer accepts
  the character type. The warning's job is to make the second count visible.
  What the brief called "where Char would not type-check" is, measured, three
  different outcomes (`oc-str-parameter-is-the-api-deficiency-shape`,
  `oc-str-native-argument-warns`, `oc-comparison-with-a-string-warns`, and the
  fuzzer's catalog below): a declared `str` parameter rejects the rewrite
  statically; a native's `str` parameter accepts it and fails at run time; a
  comparison with a String accepts it and is silently `false`.
* **There is no author opt-out.** The declaration whose shape would be
  controlled is the *API's* (a `str` parameter, a String-returning helper, a
  set of Strings), and changing it is the response, not a suppression. There is
  no annotation, no `nomethod` analogue, and the language still has no
  call-site suppression of any kind.
* **No reachability notion.** Milestone 2 skipped structurally unreachable
  calls because its fact was about a call the program makes: a call that cannot
  execute makes no call. This warning's fact is about the written source -- a
  literal spelled as a String -- and its response is a static spelling change;
  a literal in a dead branch is spelled the same way and would be respelled the
  same way, and the API-catalog purpose counts every written literal. This is
  milestone 5's declaration reasoning, not milestone 2's call reasoning:
  `oc-dead-branch-literal-warns` puts a `METHOD-ELIGIBLE`-shaped call and a
  literal in the same dead branch -- the call is silent, the literal warns --
  and pins literals after a `return` and under a range-infeasible branch;
  `oc-uncalled-and-unreachable-functions-warn` pins an uncalled function and one
  declared in a dead branch; `oc-no-completion-walk` traces 0 calls of
  `hir::completions::reachedExprs`. The `reachability-added` mutant is killed.
* **Per-site granularity**, as in milestone 2: one diagnostic per written
  literal, no grouping; two identical literals are two warnings
  (`oc-one-diagnostic-per-site`; the `first-site-per-value` mutant is killed).

## Record, message, ordering

**Record.** The framework's `{code message primary secondary data}`:

* `primary`: the literal's own origin, the span of the written token, quotes
  included (`oc-primary-is-the-literal`); a module's literal is located in the
  module file (`oc-module-literal-located-in-the-module`);
* `secondary`: empty -- a single-location fact, as in milestones 2 and 5; no
  `note:` lines (`oc-render-has-no-notes`);
* `data`: `site` (the literal's ExprId) and `value` (the exact String value,
  `{str TEXT}`, the repository's representation -- it is the proof: `{val
  VALUE}` is `hir::exact::Of` of the site), nothing else; the character count is
  implied (`oc-record-data-fields`).

**Message.** One template (`oc-message-template`):

```
the String literal `VALUE` is one character long; a single character is written as a character literal
```

VALUE is the literal's exact value as the repository displays values
(`core::value::show`, milestone 1's rendering convention:
`oc-message-renders-the-value-convention`). The form is named as the
repository names it: "character literal" is the lexer's own name for `'x'`
(its diagnostics), the type is `UnicodeChar`, and "String" is the prose name of
`str`; the brief's "Char literal" is not the repository's spelling (the
milestone-5 `bool` lesson). **The character spelling is never printed**: not in
the message, not in `data`, not in the rendered text (`oc-no-character-spelling-
anywhere` scans for the rewrites `'a'`, `','`, `'"'`, `'\\'`, `'\''`, `'\n'`,
`'\t'`, `'%'`, `'😀'`, and for `should`, `consider`, `use`, `instead`, `prefer`,
`replace`, `rewrite`, `did you mean`, `suggest`, `fix`, `->`, `callee`,
`parameter`, `API`, `stdlib`, `str::`, `UnicodeChar` and ` Char `). No API
advice anywhere: the deficiency catalog lives in the audit.

A String's display escapes what a character literal's does (`\\ \n \r \t` and
its own quote; `tests/value-display.test`), so the warning for `"\r"` shows
`"\r"` and no message carries a raw carriage return
(`oc-message-escapes-a-carriage-return`). This milestone first recorded the
opposite as a known limitation: a String's display left `\r` raw, and on a
terminal the warning's line was overwritten from its start. `core::value::show`
and the native runtime's renderer now escape it for every String value.

**Ordering.** The inherited `Sort`. All six codes interleave by location in
both orders (`oc-interleaving-six-codes`, `-other-order`, `-deterministic`),
and literals inside constructs that trip other codes are independent
diagnostics: `["-", "-"]` returned from two exits gives `SAME-RETURN-VALUE`,
`FIXED-ARITY-LIST-RETURN` and four `ONE-CHAR-STRING-LITERAL`s, and `two("+",
1)` gives `METHOD-ELIGIBLE` and one (`oc-independent-of-other-codes`).

## Architecture

**One pass, one registry line.**

```tcl
variable passes {
    SAME-RETURN-VALUE hir::warnings::SameReturnValue
    METHOD-ELIGIBLE   hir::warnings::MethodEligible
    FIXED-ARITY-LIST-RETURN hir::warnings::FixedArityListReturn
    SAME-FAILURE      hir::warnings::SameFailure
    PROVES-NAMING     hir::warnings::ProvesNaming
    ONE-CHAR-STRING-LITERAL hir::warnings::OneCharStringLiteral
}
```

`git diff e7f715c -- hir/warnings.tcl` is two hunks: the registry line and the
appended section (a header comment and two procedures, about 80 lines).
**Framework untouched**: policy modes, `run`/`collect`/`of`, the record shape,
`Sort`, `render`, `Raise`, the stats counter, `BOTLISH_WARNINGS` and the CLI
option are byte-for-byte milestones 1-5.

**Timing and scope.** `surface::lower::Finish`, unchanged: after
`hir::buildSyntax`/`hir::check` and strict diagnostics, before any backend. A
program with error diagnostics is never warned about (`oc-compilation-with-
errors-has-no-warnings`).

**What supplied the proof.** The `const` node kind and each const's exact value
(`hir::exact::Of`, which predates the milestone), measured by
`core::strings::length` (the reference `str::length`); and, to recognize the
one synthesized const, `hir::contexts::isLoad`. **Not needed**: a provenance
marker, annotations, identity (`hir::exact::Identity`/`AliasRoot`), exits, any
walk (structural reachability or the completion walk), the resolver, types, a
call graph, and any new helper on `core::value` (the brief's contingency was not
exercised).

## No new HIR state, no semantics change

Nothing is recorded on HIR for this warning (`oc-no-new-hir-state`: under
`default` the top-level keys are `off`'s plus `warnings`, every expression node
has exactly its `off` fields, and the expression, binding and scope tables are
identical; `oc-const-nodes-unchanged`: a String literal's const node has the
fields every const node has had). `dict remove $hir warnings`, `hir::format`,
`hir::lower` and `native::nir` (specialized and generic) are identical under
`off` and `default` (`oc-hir-identical-across-modes`, `oc-nir-identical-across-
modes`), and `native::report`, NIR and CLIF are identical with and without the
side table and contain no warning text (`oc-machine-readable-outputs-clean`,
`oc-no-warning-text-in-machine-readable-outputs`). The exact values this pass
reads predate the milestone; nothing under `native/` changed.

## Policy, inherited and re-pinned

`default` warns; `off` runs no pass (no stats entry; a trace sees 0 calls under
`off` and 1 under `default`: `oc-off-runs-no-warning-pass`, `-via-trace`);
`error` raises the sort-first warning across all six codes, as `{CORE SEMANTIC
ONE-CHAR-STRING-LITERAL}` when it is this warning's (`oc-mode-error-only-this-
code` with the exact message, `oc-mode-error-first-in-sort-order` in both
directions, `oc-error-promotion-identity`), before `hir::lower`,
`native::prepareHir`, `native::evalHir` or `core::compiler::evalHir` run (0
traced calls, `oc-error-stops-before-backend`), and `main.tcl -backend cranelift
-warnings error` prints no value (`oc-error-cli-stops-before-backend`). A
program whose Strings are all empty or longer and whose characters are
character literals compiles under `error` (`oc-mode-error-clean-program`). No
new CLI surface: `-Wno-one-char-string-literal` is an unknown option in process
and through `main.tcl` (`oc-no-fine-grained-options`, `oc-cli-no-wno-option`);
unknown modes are rejected (`oc-unknown-mode`, `oc-cli-unknown-mode`); the
registry is six static lines and there is no enable/disable (`oc-no-new-modes-
or-options`); `BOTLISH_WARNINGS` is unchanged and read fresh per compilation
(`oc-environment-default`, `oc-mode-default-is-the-default`); interleaved
compilations do not interact (`oc-policy-is-per-compilation`); `of` equals
`collect` (`oc-warnings-attached-structurally`).

## Backend independence and clean outputs

The warnings are computed from generic HIR before any backend, so the set is the
same on `interp`, `compile`, `cranelift` and `cranelift-generic`
(`oc-backend-independent`, `-off`: the same value and six warnings
everywhere). Through `main.tcl`, the warning text is identical on all four
backends for a six-code program (`oc-cli-backend-independent`: 8 lines, one
of them this warning's) and over `examples/stdlib`, the refinement example and
the string-heavy `examples/surface/06-csv-records.bot` and
`bench/lex-strategy.bot` (`oc-cli-backend-independent-corpus`). Warnings go to
stderr only (`oc-cli-stdout-clean`).

**CI's plain corpus steps, reproduced, with the count reported honestly.**
The native job's example step (`main.tcl -backend cranelift` over
`examples/stdlib`, `examples/surface/0[1-8]`, `1[1-3]` and
`examples/hir/0[1-3]`) **exits 0 with 376 stderr lines**, up from milestones
3-5's 314: **62 new `ONE-CHAR-STRING-LITERAL` lines**, beside the unchanged
301 `METHOD-ELIGIBLE`, 8 `FIXED-ARITY-LIST-RETURN`, 2 `SAME-RETURN-VALUE` and 3
notes. The 62 are the stdlib corpus's findings (`ai_text_clean` 22, the four
csv programs 8 each, `string_replace` 7, `string_reverse` 1); the surface
samples and the HIR fixtures have none. The Tcl jobs' `main.tcl -backend
interp` and `-backend compile` (their built-in `.ir` examples) exit 0 with an
empty stderr. Unlike milestones 4 and 5, this warning is loud on the corpus by
design; that volume is the API catalog.

## Kickoff: ownership and the item-2 inventory

**Ownership.** As in milestones 4 and 5, this milestone owned and made the
minimal adaptations itself.

**Baseline at kickoff (before the pass)**, at `e7f715c` (`main`), `interp` and
`compile`: the five warning test files, `tests/flags.test`, the refinement trio
and `tests/str-char-at.test` -- **883 tests, 883 passed on each** (warnings 81,
method-eligible 145, fixed-arity-list-return 149, same-failure 99,
proves-naming 84, flags 155, refinement-values 88, refinement-validators 48,
emailish-predicate 20, str-char-at 14). The fuzzers' 60-seed smoke runs:
`same-return-value` 42/18 with/without warnings, 0 failures, 0 extra groups;
`method-eligible` 43/17, 0 failures, 280/280 round trips;
`fixed-arity-list-return` 42/18, 0 failures, 42/42 conversions;
`same-failure` 36/24, 0 failures, 70 groups; `proves-naming` 33/27, 0
failures, 76/76 renames; the refinement fuzzer (`-seed 1 -count 60`) 38
accepted, 22 rejected, 0 failures. (A first baseline attempt ran beside the
native build and showed 88 `NATIVE NOT-BUILT` failures; it was discarded and
rerun once the backend was built.)

**With the pass, before adaptation** (`interp`): **22 failures**, in four
groups.

*The code-enumerating pins (5), as expected.*

| file | test | adaptation |
|---|---|---|
| `tests/warnings.test` | `warn-off-runs-no-warning-pass` | `ONE-CHAR-STRING-LITERAL 1` / `2` added to the expected stats |
| `tests/method-eligible.test` | `me-off-runs-no-warning-pass` | the sixth code added |
| `tests/fixed-arity-list-return.test` | `fa-no-new-modes-or-options` | the sixth code added to the registry pin |
| `tests/same-failure.test` | `sf-no-new-modes-or-options` | the same |
| `tests/proves-naming.test` | `pn-no-new-modes-or-options` | the same |

*Complete-set assertions over programs whose one-character literals are
incidental test data (12), not in the brief's list.* Every finding is true
(each is a written one-character String literal); none of the tests is about
it. The adaptation is each file's existing filter mechanism, extended by
exactly this code, so every other code each test pins is pinned as before:

| file | test | the literal | adaptation |
|---|---|---|---|
| `tests/warnings.test` | `warn-different-kinds-not-same` | `return "1"` (the String among different kinds) | `codes` -> `sameReturnCodes`, the file's existing SAME-RETURN-VALUE filter (milestone 4's precedent exactly); its comment names this warning too |
| `tests/method-eligible.test` | `me-form-string-literal`, `me-form-receiver-forms-recorded`, `me-intrinsic-callee` | the receiver `"s"`, the argument `"x"`, `t("a")` | `ownWarnings` -- the file's existing filter of "what these tests are not about" (library findings) -- also drops `ONE-CHAR-STRING-LITERAL`: a fact about a literal that the functional and the sugared spelling carry alike |
| `tests/proves-naming.test` | `pn-interleaving-five-codes`, `-other-order`, `pn-independent-of-other-codes` | `v == "a"`, `v == "x"` | `allWarnings` drops `ONE-CHAR-STRING-LITERAL` through a new `exceptLiterals` helper; the five-code pins stay five-code pins (the six-code ones are in the new file) |
| `tests/proves-naming.test` | `pn-mode-default-is-the-default`, `pn-one-diagnostic-per-function`, `pn-warnings-attached-structurally` | `use("x")`, `v == "a"` | `exceptLiterals` at the assertion |
| `tests/proves-naming.test` | `pn-rename-is-semantics-preserving` | `use("x")` | the rename law's "no warning after the rename" is over `exceptLiterals` (the literals are not renamed) |
| `tests/proves-naming.test` | `pn-cli-backend-independent` | `emailish("a")` | the line count excludes this code's lines; the four backends' texts are still compared whole |

*An error-mode acceptance test (1).* `pn-mode-error-clean-program` pins that
`error` accepts a program whose proves functions conform; its `v == "a"` and
`is_empty("b")` now reject it. A filter cannot keep "accepts", so the two
literals became `"a@b"` and `"bc"` (the test's subject, conforming names, is
untouched). This is the only test whose program changed.

*The fuzz smokes (4)*: `me-`, `fa-`, `sf-`, `pn-fuzz-smoke` -- see the
fuzzers below.

**The milestone-5 sweep, applied here.** The files that compile under `off`
(`tests/str-char-at.test`, `tests/flags.test`, the refinement trio) were re-run
in a scratch copy with every compile site switched to `-warnings default
-warning-channel stderr` (4, 0, 28, 9 and 6 sites in the five files, 2 in
`tests/helpers.tcl`: `sourceAgree`, `refinedChecksSourceHir`) under
`BOTLISH_WARNINGS=default`:

| file | result | `ONE-CHAR-STRING-LITERAL` lines | adaptation |
|---|---|---|---|
| `tests/str-char-at.test` | 14/14 | 2 (`at("é", -1)`, `at("é", 1)`: one-character test inputs) | none: nothing breaks; the subject is `str::char_at` |
| `tests/flags.test` | 154/155 | 5 (a scratch module's `"a"`, `"b"`, `"c"`) | none; the one failure, `flags-standalone-executable`, **fails identically without the pass** (its program prints a `FIXED-ARITY-LIST-RETURN` line on `main.tcl`'s stderr, which makes `exec` raise; checked on the same scratch tree with the registry line removed) and is not this milestone's |
| `tests/refinement-values.test` | 88/88 | 154 | none |
| `tests/refinement-validators.test` | 48/48 | 15 | none |
| `tests/emailish-predicate.test` | 20/20 | 547 (`lib/web.bot`'s 26 findings, printed by every compile that loads `web`) | none |

**The fuzzers.** Checked, not assumed:

| fuzzer | with the pass | the literals | adaptation |
|---|---|---|---|
| `same-return-value` (milestone 1) | unaffected: identical summary | none: its returns are Ints; `mutable_array` has no finding | none |
| `method-eligible` (2) | 60 of 60 seeds failed | `s = "s"` in every function, the receiver `"t"`, `str::concat(s, "x")` | the oracle predicts `ONE-CHAR-STRING-LITERAL` at every occurrence of `"s"`, `"t"`, `"x"` (the generator's only one-character literals; nothing else it writes contains them), exactly (missed = failure, unpredicted = EXTRA); `error` mode expects the code of the sort-first *predicted* warning |
| `fixed-arity-list-return` (3) | 32 failed | the element pool's `"s"` (dead and range-unreachable branches included: this warning has no reachability notion) | the same, for `"s"` |
| `same-failure` (4) | 60 failed | the drivers' `u$f("s", [3])` | the same, the sites recorded at generation |
| `proves-naming` (5) | 60 failed, 33 rename-law failures | the drivers' `"x"`, `"z"`, the wrong-shape arguments `"x"`, `"y"`, the hygiene twin's `"t"` | the same, over the entry file and the module; the rename law's "no warning of any code" now means no warning but the renamed program's own literal findings, exactly |
| refinement (`-seed 1 -count 60`) | unaffected | compiles with `-warnings off` | none |

The third milestone-4 option -- teach the oracle -- was taken everywhere over
filtering, because the literals are construction-known and filtering would
leave the new code unverified in four more harnesses. The generators are
unchanged, so every seed produces the same program as before: **after
adaptation each summary line is identical to its baseline**.

**After adaptation**: the 10 files, 883/883 on `interp` and on `compile`; on all
four backends in "Full regression".

## Tests

`tests/one-char-string-literal.test`, **84 tests**, every compile passing its
policy explicitly (84/84 on `interp`, `compile`, `cranelift-generic` and
`cranelift`):

* **Shape and boundary**: the motivating quote literal rendered exactly; 0, 1
  and 2 characters in one program; the empty String; two or more characters;
  escapes denoting one character (`\n`, `\t`, `\r`, a quote, a backslash) with
  their code points; the exact value deciding (`"\n"` vs `"\\n"`); an
  apostrophe; two supplementary-plane characters; the two-code-point grapheme
  silent beside the precomposed character; agreement with `str::length` on four
  backends.
* **Literals only**: the initializer is the site; aliases; parameters; call
  results (every result one character); computed Strings (concatenation,
  lowercase, substring); list and nested list elements and struct fields;
  every position (nested function, closure, loop body, handler body,
  condition, method receiver and argument, return).
* **Context-blindness**: a `str` parameter (the rewrite rejected: `TYPE`), a
  native's `str` argument (the rewrite compiles and fails at run time), a
  comparison with a String (the rewrite compiles and is `false`), a
  kind-tolerant consumer (the rewrite keeps the value), a `UnicodeChar`
  parameter (the String spelling is a `TYPE` error, so never warned), five
  consumers with one message; dead branches (the milestone-2 contrast), code
  after a return, a range-infeasible branch, uncalled and dead-declared
  functions, no completion walk (trace).
* **Kind**: character literals never warn; a String beside the character
  literal of the same character.
* **Representation**: HIR text input warns; the context-load key of a context
  struct and of a context trait is silent and a written `"C"` / `"T"` warns
  (source and HIR text); the source audit of String consts; every desugaring
  builds none.
* **Structure**: record shape, data fields (the value is the exact value),
  primary is the literal, no notes, the template, the value convention, no
  character spelling or advice anywhere, one diagnostic per site, source order
  and determinism, a module's literal in the module file, instances never
  walked, a trait program warned as written.
* **Policy matrix**: six-code interleaving (both orders, determinism),
  independence from other codes, default/off/error, the clean program,
  default-is-default, `BOTLISH_WARNINGS`, unknown mode, no
  `-Wno-one-char-string-literal`, the six-line registry, promoted identity,
  stats and trace off-pins, error diagnostics never warned, per-compilation
  interleaving, `of` equals `collect`, `error` before all four entry points.
* **No semantics change**: HIR/format/lower, no new HIR state, const nodes
  unchanged, NIR (specialized and generic), report/NIR/CLIF with and without
  the side table, no warning text in machine-readable output.
* **Backends and CLI**: four backends in process (on and off); CLI modes,
  `-Wno-one-char-string-literal`, unknown mode, stdout/stderr separation,
  `-backend cranelift -warnings error` prints no value, identical text on all
  four backends (a six-code program, and the stdlib corpus with the refinement
  example and two string-heavy programs).
* **The spelling law at unit level**: for eleven characters (a letter, a comma,
  both quotes, a backslash, newline, tab, carriage return, a two-byte, a
  three-byte and a supplementary-plane character), the warned literal's
  character spelling compiles, its exact value is the UnicodeChar of the same
  code point, and a `UnicodeChar` parameter takes it; a 293-scalar sample
  across all planes has no spelling gap.
* **Fuzz smoke**: 60 seeds.

## Fuzzing and the spelling law

`audit/one-char-string-literal/tools/fuzz.tcl SEEDS FIRST`
(`audit/one-char-string-literal/fuzz-result.txt`; `-show SEED` prints a program
and its prediction; `-spelling-exhaustive` runs the lexer clause over every
scalar). Each seed builds a program from construction-known pieces:

* **literals** of 0, 1 or 2 characters from a pool of 17 -- `a`, `Z`, `7`,
  space, `%`, `-`, `,`, both quotes, the backslash, newline, tab, carriage
  return (escapes), `é`, `世` (raw), `😀`, `𝄞` (supplementary plane, raw) -- or
  the grapheme `e` + U+0301 (two code points);
* **contexts**: `str-param` (a declared `fn take_s(text: str) -> int`),
  `str-length` (`str::length(LIT)`), `str-concat` (`LIT.concat("ab")`, method
  syntax: the functional form would be `METHOD-ELIGIBLE`), `str-compare`
  (`sxK == LIT`, `sxK` a computed one-character String), `char-accepting`
  (`is_K(LIT)`, `fn is_K(c): c == 'X' or c == sxK` -- a kind-tolerant matcher:
  no typed parameter accepts both kinds), `element` and `field` (in the
  program's result, where the kind is visible), and `binding` (the initializer
  `bI = LIT`, read by one of the others);
* **placements**: top level, nested function, closure, dead branch, range-
  infeasible branch, after an if/else that returns from both branches,
  uncalled function;
* **silent pieces**: character literals of the same characters (only where the
  original program accepts them), 0- and 2-character literals, the grapheme,
  computed one-character Strings (`"aX".substring(1, 2)`), binding reads,
  parameters; and in 30% of the programs a `context struct C` with a context
  parameter (the synthesized one-character key);
* names collision-free by construction; every call written so that no other
  code can fire (one-parameter functions, method syntax for two, no function
  returning a list, single exits, distinct returns); a third of the programs
  silent by construction.

**The oracle** is the construction: a literal of exactly one pool character is
predicted as {LINE COL VALUE} (the anchor its opening quote; columns counted
in characters, as the lexer counts them). Modes: **default** -- exactly the
prediction, values included (missed or mislocated fails; unpredicted is EXTRA,
counted, pinned 0; a site twice fails; any other code fails); **off** --
compiles silently, no pass ran (stats and an execution trace), identical HIR;
**error** -- rejected with `{CORE SEMANTIC ONE-CHAR-STRING-LITERAL}` iff a
warning is predicted (no other code can fire, so the sort-first rule needs no
generalization here).

**The spelling law**, per predicted finding, exactly as checked:

1. **lexes and parses**: a probe `x = SPELLING` compiles with no diagnostic (a
   failure would be a spelling gap, a language finding: none was found, and the
   exhaustive check over all 1,112,064 scalars agrees);
2. **the same code point**: the probe's const has the exact value (`hir::exact::
   Of`) `{val {UnicodeChar CP}}`, CP the code point of the String's one
   character; and a typed character context takes it -- `code(SPELLING)` with
   `fn code(c: UnicodeChar) -> int: char::scalar_value(c)` evaluates to CP;
3. **in a character-accepting context**, the program with that one literal
   rewritten compiles, has exactly the original's warnings minus that site (the
   columns after it on its line shifted by the spelling's change of length),
   and evaluates to the identical value on the reference interpreter. In every
   other context the outcome is **catalogued, never a failure** (the rewritten
   program's warnings are still checked whenever it compiles).

**2000 seeds** (one run, at `dac80d3`): **1375 programs with warnings, 625
without; 0 failures, 0 extra warnings; the spelling law held for 5118 of 5118
findings**, every one of the 1199 character-accepting rewrites keeping its
program's value; 17 distinct characters probed. The rewrite catalog (context,
placement, outcome):

| context | live placements | dead placements (dead, range, after, uncalled) |
|---|---|---|
| `str-param` | rejected `TYPE` 348 | rejected `TYPE` 310 |
| `str-length` | runtime `TYPE` 350 | same 312 |
| `str-concat` | runtime `TYPE` 369 | same 302 |
| `str-compare` | changed 150, same 149 | same 225 |
| `element` | changed 283 | same 224 |
| `field` | changed 280 | same 221 |
| `char-accepting` | same 572 | same 455 |
| `binding` -> `str-param` | rejected `TYPE` 45 | rejected `TYPE` 50 |
| `binding` -> `str-length` | runtime `TYPE` 45 | same 39 |
| `binding` -> `str-compare` | changed 25, same 15 | same 28 |
| `binding` -> `element` | changed 37 | same 36 |
| `binding` -> `field` | changed 47 | same 29 |
| `binding` -> `char-accepting` | same 94 | same 78 |

Read it as the warning's own case for not being autofixable: only the
character-accepting rows are "same" everywhere; a declared `str` parameter
rejects the rewrite even in dead code (static typing does not care about
reachability), a native's `str` parameter rejects it only when it executes, a
live comparison with a String changes its value whenever the characters were
equal and **keeps it silently when they were not** (`str-compare` live:
"same" 149 -- a rewrite that changed the program's meaning without changing
this run's value), and a kind-visible result changes. The generated corpus:
contexts str-param 1476, str-length 1469, str-concat 1441, str-compare 1446,
char-accepting 2841, element 1446, field 1431, bindings 1483; placements top
4290, nested 1451, closure 1468, dead 1445, range 1446, after 1469, uncalled
1464; 1690 character literals, 602 context keys, 660 quiet programs, 625
only-silent programs. The suite runs 60 (`oc-fuzz-smoke`).

## Mutation testing

`audit/one-char-string-literal/tools/mutate.tcl ?SEEDS? ?PATTERN?`
(`audit/one-char-string-literal/mutation-result.txt`), milestone-3/4/5 style:
each mutant is a small, local break of the pass (or its registry line), applied
to a scratch copy of the tree; the fuzzer runs first (40 seeds), and
`tests/one-char-string-literal.test` runs for any mutant the fuzzer does not
kill.

| mutant | required | killed by |
|---|---|---|
| empty String warned (`empty-string-warned`: length <= 1) | yes | fuzz: 60 extra warnings, 12 failures |
| two characters warned (`two-characters-warned`: length 1 or 2) | yes | fuzz: 165 extras, 14 failures |
| length counted as >= 1 (`at-least-one-character`) | yes | fuzz: 165 extras, 14 failures |
| a character literal warned (`character-literal-warned`: the kind check dropped, a character measured as the one-character String of its scalar) | yes | fuzz: 91 extras, 37 failures; the spelling law fails for 84 of 96 findings (the rewritten literal still warns) |
| a use-site binding read or alias warned (`use-site-read-warned`: `ref` nodes read through `hir::exact::Of` too) | yes | fuzz: 11 extras, 8 failures, 10 law failures |
| a computed / call-result String warned (`computed-string-warned`: a native call whose arguments are exactly known is evaluated) | yes | fuzz: 60 extras, 14 failures (every `sxK = "aX".substring(1, 2)`) |
| the exact-value check bypassed for the raw spelling (`raw-spelling-counted`: the token's width between the quotes) | yes | fuzz: 12 failures (escaped one-character literals missed) |
| instances visited (`instances-visited`: each warning once more per semantic instance whose snapshot covers the site) | yes | fuzz: 20 failures (sites reported more than once) |
| registry line removed (`registry-line-removed`) | yes | fuzz: 26 failures (every prediction missed; the smoke pin fails the same way) |
| a reachability notion added (`reachability-added`: structurally unreachable consts skipped) | yes (as extra) | fuzz: 17 failures (dead and after-return placements) |
| the context-load key reported (`context-key-reported`: the exclusion dropped) | extra | fuzz: 12 extras, 5 failures |
| bytes counted (`bytes-counted`: UTF-8 length) | extra | fuzz: 18 failures (`é`, `世`, `😀`, `𝄞` missed) |
| UTF-16 code units counted (`code-units-counted`) | extra | fuzz: 10 failures (`😀`, `𝄞` missed) |
| one warning per value (`first-site-per-value`: grouping) | extra | fuzz: 10 failures, 10 law failures |
| the character spelling printed (`character-spelling-printed`: the message appends it) | extra | unit tests: 6 failing, `oc-no-character-spelling-anywhere`, `oc-message-template`, `oc-motivating-rendered`, `oc-mode-error-only-this-code`, `oc-the-message-names-no-context`, `oc-cli-modes` |

**15 of 15 mutants killed: the 10 the brief lists (its required nine and the
reachability mutant), 14 of all 15 by the fuzzer and 1 by the unit tests.**
The one the fuzzer cannot see is message wording, which its oracle does not
read; the unit tests own it. The fuzzer's polymorphic-call coverage was enough
for `instances-visited` with no generator change (milestone 5 needed one): its
placement functions have semantic instances whose snapshots cover their
literals.

**The first mutation run surfaced two tool defects, both fixed before the run
recorded here, and one tool guard.** `character-literal-warned` and
`computed-string-warned` were "killed" by crashes, not by warnings: the first
fed a UnicodeChar to `str::length` (a `TYPE` error that aborted every
compile), the second wrapped the native's `{value V}` completion as a value.
Each now does what its name says -- the kind check dropped, a call evaluated --
and is killed by the warnings it invents. And a mutated tree whose fuzzer prints
no summary (a syntax error in a mutant, say) is now reported as `BROKEN
MUTANT` and fails the tool, never counted as a kill. Mutation texts that open a
brace they do not close are double-quoted, milestone 5's note.

## Corpus findings and the API-deficiency catalog

`audit/one-char-string-literal/tools/corpus.tcl`, output
`audit/one-char-string-literal/corpus-audit.txt`, at the **pinned commit
`61f1864`** recorded in its header (corpus paths clean: `examples`, `bench` and
`lib` are byte-identical to the kickoff base `e7f715c`; the corpus is not
edited). It compiles `examples/stdlib` (9), `examples/surface` (14),
`examples/refinement` (1), `bench/*.bot` (8) and `lib/*.bot` (8) with warnings
on. 36 of 40 compile standalone: the two deliberate rejections (`09`, `10`),
and `lib/list.bot` and `lib/mutable_array.bot` (which use their own namespace
without importing it, as milestones 2-5 recorded).

**92 distinct findings** (a module's finding once: `lib/web.bot`'s 26 are
reported by every program that loads `web`). Volume is information (milestone
2): they sit in 10 files, and three shapes repeat --

| file | findings |
|---|---|
| `lib/web.bot` | 26 |
| `examples/stdlib/ai_text_clean.bot` | 22 |
| `examples/stdlib/csv.bot`, `csv_chunked.bot`, `csv_geometric.bot`, `csv_records.bot` | 8 each (one scanner, four copies) |
| `examples/stdlib/string_replace.bot` | 7 |
| `bench/lex-strategy.bot`, `bench/source-checks.bot` | 2 each |
| `examples/stdlib/string_reverse.bot` | 1 |

**False positives: 0.** The tool re-lexes the source token at every finding's
anchor with the lexer's own `String` procedure, independently of the pass: all
92 are String literals whose decoded value is the warning's and is one
character long. (The only way this warning can be wrong is a value that is not
one character, and the exact value makes that impossible; the check confirms
it on the corpus.)

**The spelling law at corpus level, per finding.** Clauses 1 and 2 hold for all
92 (50 distinct characters: the character spelling lexes, its exact value is
the UnicodeChar of the same code point, and a `UnicodeChar` parameter takes
it). Then each literal alone is rewritten to its character spelling in a
scratch copy, and the rewritten program -- for a `lib/web.bot` finding, each of
the three corpus programs that load `web` (`examples/refinement/refined-
strings.bot`, `bench/refined-checks.bot`, `bench/uri-steady.bot`) -- is
compiled and evaluated against the original in a child process under a 60 s
limit:

| class | rewrite outcomes (over every probe) |
|---|---|
| API-deficiency (81 findings) | same 80, changed 22, runtime `TYPE` 23, **diverges 8** |
| deliberate (11) | rejected `TYPE` 8, runtime `TYPE` 3 |

**8 rewrites diverge**: the four CSV scanners' `delimiter == ","` and
`delimiter == "\n"` (`scan_record` / `scan_record_rest`) end the record loop;
rewritten, the comparison can never be true, and the scan does not terminate.
This is the sharpest form of the "silently changes" outcome, and it was found
the hard way: the audit's first run hung on it, which is why every evaluation
now runs in a time-limited child. "Same" is common because a program's own run
need not reach the literal with the matching character (the emoji filter is
exercised with a few emoji; a probe may not escape every hex digit) -- which is
why "the rewrite compiles and keeps this run's value" is not the convert-now
criterion.

**Classification** (the tool's rules, with a hand table for "deliberate"; a
finding no rule classifies would fail the tool -- none does):

* **convert-now: 0.** Convert-now requires the rewrite to keep every probe's
  value *and* the consumer to accept the character type statically (the other
  side of `==` is a UnicodeChar, a parameter declares `UnicodeChar`). No
  corpus consumer of a one-character String literal does: every one of them
  meets a String. The corpus's character code already uses character literals
  -- `uri_query_value?` in the same `lib/web.bot` reads `str::char_at` and
  compares with `'%'`, and has no finding -- and everything that warns predates
  that style. A rewrite that merely compiles is never counted: 55 of the 92 are
  `==` comparisons, where it always compiles.
* **API-deficiency: 81**, in six rows -- the deliverable to the future API and
  autofix work:

| catalog row | findings | consumers (the tool's keys) | where | rewrite | what the API lacks |
|---|---|---|---|---|---|
| `==` against a one-character String sliced by a `peek`/`char_at` helper (`str::substring`) | 31 | `== str-substring:peek()`, `:character`, `:delimiter`, `:char_at()` | the four CSV scanners; `lib/web.bot`'s `emailish?` (`domain?`) | changed 12, same 17, **diverges 8** | the helper returns a one-character String, or `""` past the end; `str::char_at` returns a UnicodeChar but fails (`IndexNotFound`) outside the String, so a scanner needs an end-of-input form that is not `""` |
| `==` against an untyped parameter that receives one-character Strings | 21 | `== any-param:param:character`, `:c` | `ai_text_clean`'s `cleaner_emoji` and `clean_char`; `bench/source-checks.bot`'s `is_underscore?`, `is_hyphen?` | same 13, changed 8 | the callers pass `str::substring` slices (`peek`, a first-character slice inside a list of `str` predicates with `str::is_tcl_alpha`/`alnum`); the comparison would hold for a UnicodeChar only if every caller changed too |
| element of a `List[str]` table indexed (`list::at`) and concatenated (`str::concat`) | 16 | `list-element bind:web::hex_digits` | `lib/web.bot`'s `uri_escape_text` | same 28, runtime `TYPE` 20 | the digits are appended to output text with `str::concat`: there is no append of a UnicodeChar to a String |
| element of a `List[str]` made an `ImmutableSet[str]`, queried with one-character Strings | 5 | `list-element immutable_set::from_list:arg0` | `lib/web.bot`'s `local_extra_chars` (`emailish?`) | same 15 | `immutable_set::contains` is queried with `char_at` slices; a set of UnicodeChars needs the scanner to read characters (`str::char_at`) |
| `str::concat` argument | 5 | `call str::concat:arg0`, `:arg1` | the four CSV scanners (`"\""` appended to a field), `lib/web.bot`'s `pct` (`"%"`) | same 4, runtime `TYPE` 3 | `str::concat` takes two Strings |
| `==` against a `str` parameter | 3 | `== str-param:param:c` | `bench/lex-strategy.bot`'s `lenient_ident_char?`; `lib/web.bot`'s `label_char?` | same 3, changed 2 | the parameter is declared or inferred `str`: its callers pass one-character Strings sliced from text |

  Reading the table as an API work list: almost everything reduces to two
  missing pieces -- **reading characters** (a scanner over `str::char_at` with
  a total end-of-input form, replacing every `peek`/`char_at`/first-character
  slice; that unlocks the 31 + 21 + 3 + 5 comparison and set findings) and
  **appending a character to text** (a String builder or `str::concat` taking a
  UnicodeChar; that unlocks the 16 + 5 table and concatenation findings).
* **deliberate String usage: 11**, by hand, with reasons
  (`corpus-audit.txt`, "Deliberate String usage"):
  * `examples/stdlib/string_replace.bot`, `sample` (7): test data of a substring
    replacement whose needles and replacements are 0, 1, 2 and 3 characters long
    in one call list -- a one-character needle is the length-1 case of a String
    argument (the rewrite is rejected statically: `TYPE`);
  * `examples/stdlib/string_reverse.bot`, `sample` (1): the length-1 boundary
    input of a String reversal (rejected: `TYPE`);
  * `examples/stdlib/ai_text_clean.bot`, `clean_char`'s three returned
    replacements (`"-"`, `"'"`, `"\""`): `clean_char` maps a character to `""`,
    `"..."` or a one-character normalization, so its result is a String of
    variable length (the rewrite fails at run time: `TYPE`). The comparisons in
    the same function are API-deficiency, catalogued above.

  This is the brief's "code whose subject is String syntax itself" category in
  the corpus's own form: Strings that are one character long by value, not by
  kind.

**False positives: 0. Corpus edited: no.**

## The idiom, the non-autofixable rationale and the graduation criteria

**The idiom, declared** (README.md §1, "Strings and characters", new): a String
is a sequence of characters; a character is a UnicodeChar; **a single character
is written as a character literal**; `""` and every String of two or more
characters are Strings; characters are counted as `str::length` counts them;
the kinds never convert implicitly. The warning points at that statement (the
milestone-3 lesson: a warning must not precede its declared idiom). The
encode-utf8 work (ENCODE-UTF8-ALLOCATION-RESEARCH.md) had made the distinction
live -- `str::char_at` reads a String's character as a UnicodeChar -- but stated
it as an allocation finding, so it is cited, not quoted.

**Why the warning is not autofixable today.** Conversion may require API
changes, and the warning is the instrument that surfaces them. Measured
(fuzzer catalog, corpus audit): the rewrite is rejected statically by a
declared `str` parameter, fails at run time in a native's `str` parameter, and
silently changes a comparison with a String -- in the corpus, 55 of 92 findings
are such comparisons, and rewriting one in a scanner can remove its loop's
only exit (`diverges` in the audit). A fixit would therefore be wrong in most
of the corpus and dangerous where it compiles.

**Graduation criteria (future work, not implemented).** The warning may become
autofixable when the rewrite is total, i.e. when either holds:

1. **the API surface is soundly character-typed**: every catalog row below is
   emptied by an API that takes or yields characters -- a scanner reading
   `str::char_at` (with an end-of-input form that is not `""`), an append of a
   UnicodeChar to a String (or a String builder taking characters), character
   sets and character tables, and comparisons whose other side is a
   UnicodeChar -- so that a re-run of `audit/one-char-string-literal/tools/
   corpus.tcl` classifies every finding convert-now or deliberate; or
2. **the language gains the conversions that make the rewrite total** in the
   remaining String contexts (an explicit, checked character-to-String
   conversion the rewrite can insert, and a static rejection of `==` between a
   String and a UnicodeChar, so a comparison rewrite can never be silently
   wrong).

Until then the warning names the form, and the audit's catalog is the work
list.

## Full regression

All runs are on this milestone's code as committed at `6d9f8a8` (the pass,
its tests, fuzzer and mutants; every later commit changes documentation, the
corpus tool and audit outputs only, none of which a test runs). The native
backend is built from that tree (nothing under `native/` changed).
`tests/all.tcl` ran on both Tcl backends with the harness's default policy
(`BOTLISH_WARNINGS=off`), each with a private `-tmpdir` (AGENTS.md, "Running
tests concurrently"), in parallel. This milestone adds 83 tests
(`tests/one-char-string-literal.test`) and adapts 18 existing tests in place,
some through their file's helper; no `test` line is added or removed outside
the new file (`git diff e7f715c -- tests/`), so the kickoff base `e7f715c` had
6409 - 83 = 6326 (derived, not a separate run).

* **`interp`: 6409 tests, 6409 passed, 0 failed. `compile`: 6409 tests, 6405
  passed, 4 skipped (the existing `coreScoping` constraint), 0 failed.**
* **`tests/native-coverage.tcl`** (the suite on `cranelift`, as CI's native
  job): 6409 tests: 2516 native, 3766 independent of the backend, 67
  passed-partial, 60 unsupported (the constructs it already classifies, the
  same 60 as milestones 2-5), **0 failed**.
* **`cranelift-generic`**, file by file: `tests/one-char-string-literal.test`
  83, the five adapted warning files (`warnings` 81, `method-eligible` 145,
  `fixed-arity-list-return` 149, `same-failure` 99, `proves-naming` 84),
  `tests/flags.test` 155, the refinement trio (88, 48, 20) and
  `tests/str-char-at.test` 14: **966 tests, 966 passed**.
* **`tests/one-char-string-literal.test`: 83/83 on each of `interp`, `compile`,
  `cranelift-generic` and `cranelift`.** The item-2 files after adaptation pass
  on all four backends (`interp` and `compile` in the full runs, `cranelift` in
  native coverage, `cranelift-generic` file by file), and their fuzz smoke tests
  (`warn-`, `me-`, `fa-`, `sf-`, `pn-`, `oc-fuzz-smoke`) pass.
* CI's plain example steps, reproduced: the native job's `main.tcl -backend
  cranelift` corpus step exits 0 with 376 stderr lines (62 of them this
  warning's); the Tcl jobs' `main.tcl -backend interp` and `-backend compile`
  exit 0 with an empty stderr (see "Backend independence and clean outputs").
* The fuzzer passes 2000 seeds with the spelling law and the exhaustive lexer
  check finds no gap (`fuzz-result.txt`, at `dac80d3`); the mutation tool kills
  15/15 (`mutation-result.txt`, at `6d9f8a8`); the corpus audit is
  `corpus-audit.txt`, at `61f1864`.
* The GC-stress job (`BOTLISH_NATIVE_GC_STRESS=1`, CI on push to `main`) was not
  run locally: nothing under `native/` changed, and the pass runs before any
  backend and changes no HIR (pinned).

## Known limitations

* **The context-load exclusion is structural.** The one synthesized String
  const is recognized by its construct (`hir::contexts::isLoad`), and a new
  synthesized String const would be a false positive until it is recognized
  too; the source audit `oc-synthesized-string-consts-enumerated` fails the day
  one is added, which forces that decision.
* **Library findings print for every program that loads the module**, as
  milestones 2-5 recorded for theirs: `lib/web.bot`'s 26 findings appear in
  every compile of a program importing `web`.
* **The value the corpus audit compares is the program's own run.** A rewrite
  that keeps a program's value may still change its meaning on other inputs
  (the fuzzer's `str-compare` "same" rows); the audit's convert-now rule
  therefore also requires the consumer to take a UnicodeChar statically.
* Only the first warning is raised under `error`, as in milestones 1-5.

## Future warning candidates

`ONE-CHAR-STRING-LITERAL` moves from proposal to implemented. New: its
**autofix graduation** (the criteria above), recorded as future work, not
built. Still future, unchanged from milestone 5: a condition that repeats an
already established proof; manual iteration whose cardinality duplicates
another domain; milestone 3's possible helper-chain extension; and, evidence-
gated, multi-parameter predicates. Nothing else is new. (The audit's
observation that `==` of a String and a UnicodeChar type-checks and is always
`false` is a language-design question about kind-mismatched equality, not a
warning candidate this milestone proposes.)

Not planned: per-warning flags, `-Wall`/`-Wextra` or levels, call-site
suppression, pragmas or lint-ignore comments, any author opt-out, a printed
character spelling or any fixit, automatic rewriting, context or consumer
gating, value proving beyond a literal's own exact value, byte-based lengths,
checks on character literals or a reverse rule, and any new CLI option or
`BOTLISH_WARNINGS` value.

## Deviations from the brief

* **A synthesized String const exists** (item 4 expected none): the
  context-load key, of a context struct's parameter and -- since context traits
  were merged from `main` -- of a context trait's. It is excluded by recognizing the construct with
  `hir::contexts::isLoad`, which is the one place the pass looks beyond a
  `const` node -- a reading of "callee sniffing" the brief forbade *for
  deriving literal-ness*; here it derives non-literal-ness of a construct no
  source can write, and changes nothing about any written literal. The
  alternatives (a `written` marker: new HIR state, and HIR text silent unless
  `hir::read` sets it; the origin's node role: origin-shape sniffing) were
  rejected. **This is the decision most worth the user's review.**
* **The form is named "character literal"**, the repository's own name (the
  lexer's diagnostics), not "Char literal"; the type is `UnicodeChar` in the
  documentation.
* **The motivating example's location is `5:21`**, not `3:20`: the excerpt's
  `peek` must be defined before it is read, and column 21 is the opening quote.
* **The brief's `"\u{...}"` escape does not exist**; characters outside the
  escape set are written raw. Nothing depends on it.
* **"Char-accepting contexts" are untyped kind-tolerant consumers**, because no
  valid program passes a one-character String to a `UnicodeChar` parameter; the
  typed character context is a probe (clause 2). See "Fuzzing".
* **The premise of call 1 is incomplete** (see "The four calls"): two of the
  three String-taking context kinds accept the character spelling and fail at
  run time or change silently.
* **The inventory found 13 adaptations beyond the brief's list** (12
  complete-set assertions and one error-mode acceptance test), all over
  incidental one-character test data, each listed with its reason.
* **Branch.** `AGENTS.md` says to push finished work to `main`. This session was
  assigned a development branch and told not to push elsewhere without
  permission, so the work is pushed to that branch.

## Required questions

**Warning framework**

1. *Enabled by default?* Yes.
2. *All warnings disableable globally?* Yes: `-warnings off`.
3. *All warnings promotable globally?* Yes: `-warnings error`.
4. *Per-warning `-Wfoo`?* No (`-Wno-one-char-string-literal` is an unknown
   option, in process and through `main.tcl`).
5. *Warning groups?* No.
6. *Codes stable?* Yes: `ONE-CHAR-STRING-LITERAL`.
7. *Policy per compilation?* Yes (interleaved compilations pinned).
8. *Does `off` skip the pass?* Yes: no stats entry; a trace shows 0 calls under
   `off` and 1 under `default`.
9. *Does `error` preserve the code?* Yes: `{CORE SEMANTIC
   ONE-CHAR-STRING-LITERAL}`.
10. *Backend-independent?* Yes: all four backends, in process and through the
    CLI (identical warning text).

**`ONE-CHAR-STRING-LITERAL`**

11. *Meaning?* A written String literal whose exact value is one character.
12. *Applies to computed, bound or call-result values?* Never: literals only; a
    binding's written initializer is the site, its reads are not.
13. *Empty and 2+-character literals?* Silent.
14. *Length semantics?* Characters (Unicode scalar values), by the reference
    `str::length` on the exact value: escapes resolved, a supplementary-plane
    character is one, a two-code-point grapheme is two (silent).
15. *Context gating?* None: context-blind by design; the String-taking APIs it
    exposes are its purpose.
16. *Author opt-out?* None.
17. *Does the message print the rewritten spelling?* Never (pinned over the
    message, the data and the rendered text).
18. *Is it autofixable?* No; the graduation criteria are recorded as future
    work.
19. *Unreachable literals?* They warn: the fact is about written source and the
    response is a static spelling change (milestone 5's declaration reasoning),
    in contrast to milestone 2, whose fact was a call the program makes.
20. *HIR text input?* Warns (`oc-hir-text-input-warns`).
21. *Character literals of the same character?* Silent.

**Architecture**

22. *Stage?* `surface::lower::Finish`, unchanged.
23. *Which facts supply the proof?* The `const` node kind, each const's exact
    value (`hir::exact::Of`) measured by the reference `str::length`
    (`core::strings::length`), and `hir::contexts::isLoad` to recognize the one
    synthesized const. Not needed: a provenance marker, annotations, identity,
    exits, walks, reachability, the resolver, types, a call graph, any new
    helper.
24. *New HIR state?* None (`oc-no-new-hir-state`, `oc-const-nodes-unchanged`).
25. *Walks/reachability?* None (`oc-no-completion-walk`,
    `oc-dead-branch-literal-warns`).
26. *Record shape and secondary?* `{code message primary secondary data}`;
    `secondary` empty; `data` is `site` and `value`.
27. *Deterministic ordering, six codes?* The inherited `Sort`, pinned in both
    orders.
28. *Instances?* Generic HIR once, never walked (three instances, one warning;
    a trait program's two clones, one warning; the mutant is killed).
29. *Framework changes beyond the registry line?* None.
30. *Does `error` reject before backend lowering?* Yes (traces on all four
    entry points; a cranelift CLI run prints no value).
31. *Structurally collectable?* Yes: `hir::warnings::of` / `collect`.

**Verification**

32. *Corpus findings and the API-deficiency catalog?* 92 distinct findings
    (`lib/web.bot` 26, `ai_text_clean` 22, the four CSV programs 8 each,
    `string_replace` 7, `lex-strategy` and `source-checks` 2 each,
    `string_reverse` 1): 0 convert-now, 81 API-deficiency, 11 deliberate. The
    catalog has six rows -- `==` against a one-character String sliced by a
    `peek`/`char_at` helper (31), `==` against an untyped parameter fed such
    slices (21), a `List[str]` hex-digit table concatenated into output (16), a
    `List[str]` made an `ImmutableSet[str]` of characters (5), `str::concat`
    arguments (5), `==` against a `str` parameter (3) -- and reduces to two
    missing API pieces: reading characters (a `str::char_at` scanner with a
    total end-of-input form) and appending a character to text. The 11
    deliberate are one-character test data of String functions (8) and
    variable-length replacement texts (3).
33. *False positives?* Zero (each finding's token re-lexed independently).
34. *Spelling law at which levels?* Unit (`oc-spelling-law-unit`,
    `oc-spelling-law-no-gap-sampled`, and the context tests that rewrite a
    literal), the fuzzer (2000 seeds, 5118 of 5118 findings, plus all 1,112,064
    scalars for the lexer clause), and per corpus finding (clauses 1-2 for 92 of
    92; the scratch rewrite of every finding, classified; no finding is
    convert-now, so no corpus rewrite was required to keep its value). No
    spelling gap: no language finding.
35. *Warning-mode tests pass?* Yes. `tests/one-char-string-literal.test` 84/84
    on `interp`, `compile`, `cranelift-generic` and `cranelift`; after their
    adaptation `tests/warnings.test` 81, `tests/method-eligible.test` 145,
    `tests/fixed-arity-list-return.test` 149, `tests/same-failure.test` 99 and
    `tests/proves-naming.test` 84 on the same four backends, and
    `tests/flags.test` 155, the refinement files (88, 48, 20) and
    `tests/str-char-at.test` 14 too.
36. *Fuzzer and mutation results?* Fuzzer: 2000 seeds, 1375 with warnings and
    625 without, 0 failures, 0 extras; the spelling law held for 5118 of 5118
    findings (1199 character-accepting rewrites, all keeping their value); no
    spelling gap over all 1,112,064 scalars. Mutation: 15 of 15 killed (the 10
    the brief lists among them): 14 by the fuzzer, 1 by the unit tests
    (`character-spelling-printed`).
37. *Backend parity?* Identical warning sets on all four backends, in process
    and through the CLI (a six-code program, the stdlib corpus, the refinement
    example and two string-heavy programs).
38. *Full regression?* 6409 tests on `interp` (6409 passed) and `compile`
    (6405 passed, 4 skipped by the existing constraint), 0 failures each; native
    coverage 6409 tests, 0 failed (2516 native, 3766 independent, 67
    passed-partial, 60 unsupported); CI's plain example steps exit 0, the native
    one with 376 stderr lines (62 `ONE-CHAR-STRING-LITERAL`, 301
    `METHOD-ELIGIBLE`, 8 `FIXED-ARITY-LIST-RETURN`, 2 `SAME-RETURN-VALUE`, 3
    notes), the Tcl ones with none. The adaptations changed 18 existing tests'
    assertions or data (5 pins, 12 complete-set assertions, 1 program) and four
    fuzzers' oracles; everything the pass broke is listed in "Kickoff".
