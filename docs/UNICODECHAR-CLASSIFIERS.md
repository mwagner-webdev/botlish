# UNICODECHAR-CLASSIFIERS.md

`std::char::is_tcl_alpha(c: UnicodeChar) -> bool` and
`std::char::is_tcl_alnum(c: UnicodeChar) -> bool`: the character classes of a
`UnicodeChar`, on every backend, and `std::web::emailish?` ported to them.

## Why

The `ONE-CHAR-STRING-LITERAL` warning (WARNINGS-ONE-CHAR-STRING-LITERAL.md)
steers new code toward `UnicodeChar`: write `'-'`, not `"-"`. A
`UnicodeChar` is an immediate word (`(scalar << 3) | tag`), and
`std::str::char_at` returns one, its ASCII path inline in generated code.
The library stopped there. The only Unicode classifiers,
`std::str::is_tcl_alpha` and `std::str::is_tcl_alnum` (NATIVE-TCL-UNICODE.md),
take a one-scalar `str`. Code that classifies characters therefore held them
as one-character Strings: one heap object per character read, 318-357
instructions each (BENCHMARK-BIMODALITY.md, "What one operation costs").
`stdlib/web.bot`'s `emailish?` was that code. It allocated 6,815 Strings per
run of bench/refined-checks.bot. Its six `ONE-CHAR-STRING-LITERAL` findings
were in the warning gate's manifest with the obstruction `classifier`: no
classifier took a character.

## What they are

* **The classes are the String forms' classes.** `is_tcl_alpha` is true
  exactly for a letter (General_Category Lu, Ll, Lt, Lm, Lo). `is_tcl_alnum`
  is true for a letter or a decimal digit (Nd). These are Tcl 9's `[:alpha:]`
  and `[:alnum:]`. The Unicode-version and Tcl-compatibility notes of
  NATIVE-TCL-UNICODE.md apply unchanged. So does its open question of what
  Botlish's eventual public classes should be. "tcl" stays in the names for
  that reason.
* **Total.** Every `UnicodeChar` is one Unicode scalar, so there is no RANGE
  case. The String forms fail with RANGE on a String that is not one scalar.
* **No allocation, context-free.** No `-runtime` tag, `-context-free 1`. A
  function that calls them can be proven repeatable (hir/repeatable.tcl).
  `emailish?`'s re-check in its own true branch is still decided by the
  first call (`native-string-view.test`'s `view-emailish-corpus-*`).
* **Parameter `UnicodeChar`.** As for every native's parameter, a direct
  call with a String is a run-time TYPE error
  (`std::char::is_tcl_alpha: expected UnicodeChar, got "a"`). A String that
  reaches them through an untyped parameter is a static TYPE error: the
  forwarding function's inferred contract
  (INTRINSIC-FUNCTION-CONTRACT-INFERENCE.md) says so.
* **Method syntax.** With `std::char` and `std::str` both imported, a typed
  receiver chooses its form: `c.is_tcl_alnum()` on a `UnicodeChar`,
  `t.is_tcl_alnum()` on a `str`. An untyped receiver admits both, so its
  method call is AMBIGUOUS-METHOD-CALL. That is the method rule
  (METHOD-SUGAR.md: no precedence), the same as `xs.length()` with
  `std::list` and `std::str`. No method-style use of the String forms exists
  in the repository, so no program changed meaning.

## How

| layer | file | what |
|---|---|---|
| registration, Tcl runtime | core/tclcompat.tcl | `charIsTclAlpha`/`charIsTclAlnum`. Both forms classify through one procedure, `Classify` (Tcl's `string is CLASS -strict`). |
| native lowering | native/lower.tcl | `std::char::is_tcl_alpha {op chartclalpha}`, `std::char::is_tcl_alnum {op chartclalnum}` |
| NIR | native/src/nir.rs | `CharIsTclAlpha`, `CharIsTclAlnum`, arity 1 |
| generated code | native/src/codegen/clif.rs | ASCII inline. The only ASCII letters are A-Z and a-z: `(cp \| 0x20) - 'a' < 26`, unsigned. The only ASCII Nd digits are 0-9: `cp - '0' < 10`. Any other scalar goes to the helper. |
| runtime helpers | native/src/runtime/ops.rs | `rt_char_is_tcl_alpha`/`rt_char_is_tcl_alnum` call `tcl_alpha_char`/`tcl_alnum_char`, the String forms' own General_Category lookup. |

Each implementation has one classification per class, so the two forms
cannot drift apart. Three tests check that they agree:

* `native-tcl-unicode-char-forms-agree-every-scalar`: the Tcl procedures, on
  all 1,112,064 scalars.
* ops.rs's `char_classifiers_agree_with_string_classifiers_on_every_scalar`:
  the Rust helpers, on all scalars.
* `native-tcl-unicode-char-every-ascii-scalar`: the inline rule on every
  backend, against Tcl's own classes. ops.rs's
  `inline_ascii_rule_is_the_general_category_rule` checks the rule's
  arithmetic against the tables.

## `std::web::emailish?`

The port changes only what a character is (stdlib/web.bot):

* `char_at(i)` returns `v.char_at(i)`, a `UnicodeChar`, or `' '` outside
  the String.
* `local_char?(c: UnicodeChar)` and `label_char?` classify with the `std::char`
  forms.
* `scan_while`'s predicate is `Fn{args: [UnicodeChar], return: bool}`.
* `tld?` passes `std::char::is_tcl_alpha`.
* `local_extra_chars` is a set of characters: `['.', '_', '%', '+', '-']`.

The grammar and every verdict are unchanged. The warning gate's behavior
probes (`audit/refactor/tools/probe.tcl -before HEAD -only stdlib/web.bot`)
give identical results before and after on all 54 probes and every backend.
Five of those probes are new (`emailish-char-classes`), chosen where the two
class families differ: non-ASCII letters, an Nd digit in a label and in the
top-level domain, a modifier letter in the local part, and letter numbers
(Nl) as the top-level domain. The six manifest entries closed, and
stdlib/web.bot carries 17 findings: the hex-digit table and `"%"`.

**A compatibility note.** `std::web::local_extra_chars` is a public module
binding, and its element type changed from `str` to `UnicodeChar`. Nothing
in the repository reads it outside stdlib/web.bot. A program that did, as
`std::web::local_extra_chars.contains("-")`, now gets `false`, with no
diagnostic: `==` between a String and a character is `false`, never an
error. This is the hazard EQUALITY-SEMANTICS.md is about.

## Performance

`bench/refined-checks.bot`, native (JIT), best of 40 runs, on the 4-core
container of BENCHMARK-BIMODALITY.md:

| `emailish?` | time | allocations per run |
|---|---:|---:|
| one-character Strings (before) | 380 us | 6,815 |
| `UnicodeChar`s, the measurement prototype (helper call for every character) | 164 us | 15 |
| `UnicodeChar`s, landed (ASCII inline) | 156 us | 15 |
| Go port | 140 us | |

refined-checks moves from between the clusters (2.65x Go) to 1.1x Go. The
benchmark ports that need the classifiers, which BENCHMARK-BIMODALITY.md
measured with the prototype, now run on this tree as written:

| program (audit/bench-bimodality/variants/) | `str` characters | `UnicodeChar`s |
|---|---:|---:|
| lex-strategy-chars | 23.1 us | 19.0 us |
| lex-strategy-chars-indexed | 12.8 us | 8.0 us |
| source-checks-chars | 7.0 us | 5.6-5.9 us |

The canonical benchmarks bench/lex-strategy.bot and bench/source-checks.bot
are unchanged. Their String classifiers are the workload the benchmark
measures, and their two `classifier` manifest entries stay open with that
reason. Most of what refined-checks spends now goes to two things
(BENCHMARK-BIMODALITY.md's profile of the prototype):

* the non-ASCII seek of `std::str::char_at`;
* `local_extra_chars.contains(c)`, a five-element ImmutableSet scanned with
  type-blind `equal`.

## Tests

* tests/native-tcl-unicode.test:
  - the classification corpus, now with three astral rows: a letter, an Nd
    digit, a symbol. Each row is checked for both forms on all four
    backends.
  - the corpus as text read with `char_at` at run time.
  - every ASCII scalar, and every scalar on the Tcl side.
  - the run-time and the static TYPE error.
  - the metadata; method syntax, typed and untyped.
  - the NIR op.
  - `emailish?` makes no String and slices nothing.
  - two `emailish?` corpus rows: a digit in the local part, a hyphen in a
    label.
* The value and diagnostic halves are ported to
  tests/golden/unicode-strings.bot. The census rows are in
  audit/golden/migration/census/native-tcl-unicode.tsv and the fragment rows
  in fragments/unicode-strings.tsv.
* Tests that pinned the String-based `emailish?` restate their reasons for
  the character-based one: closure-int-keys, dormant-instances,
  exact-value-facts, intrinsic-contracts, native-block-escape,
  native-string-view, raw-count-loops and raw-internal-abi. Two of them
  changed what they observe:
  - **raw-internal-abi.** Its region-companion theorem needs a String-valued
    `char_at`. The port has none, so the test now runs the String-reading
    copy of the algorithm inline
    (`raw-internal-abi-string-emailish-region-companion-tagged`).
  - **stdlib-namespaces.** Its `std::char` member lists, in the Tcl test and
    the golden suite, gained the two natives.
* Mutants: `audit/char-classifiers/tools/mutate.tcl`. The 26 mutants of its
  `mutants.txt` are:
  - the Tcl runtime and the registration: the classes swapped, BMP-only, the
    type check dropped, the parameter or result `any`, not context-free;
  - lowering and NIR spelling;
  - the inline rule: no case fold, a Latin-1 bound, an off-by-one letter
    range, a signed digit test, no digits, the wrong helper, the tagged word
    unshifted;
  - the helpers: Rust's `is_alphabetic`/`is_alphanumeric`, alnum as alpha,
    `apply_op`;
  - `emailish?`'s classes and its set.

  All 26 are killed: 14 by tests/native-tcl-unicode.test and the golden
  suite together, and the 12 native ones by those two and, for the helpers,
  the Rust tests.

## What to run when changing this

If you change the classifiers (core/tclcompat.tcl's char forms, their
registrations, native/lower.tcl's two entries, `CharIsTclAlpha`/
`CharIsTclAlnum` in nir.rs and codegen/clif.rs, ops.rs's
`rt_char_is_tcl_alpha`/`rt_char_is_tcl_alnum` or the classification they
share) or `std::web::emailish?`, run:

* `tests/native-tcl-unicode.test`;
* `tclsh9.0 tests/local.tcl tests/golden/unicode-strings.bot`;
* `cargo test --release --manifest-path native/Cargo.toml --lib --
  char_classifiers inline_ascii_rule`;
* `audit/char-classifiers/tools/mutate.tcl`: every mutant must still apply
  and be killed. When you change the code a mutant mutates, update its text
  and keep it a mutant of the same rule;
* for a change to stdlib/web.bot, also the warning gate
  (`audit/refactor/tools/gate.tcl`), its probes against the tree before the
  change (`audit/refactor/tools/probe.tcl -before REV -only stdlib/web.bot`)
  and `audit/refactor/tools/expect.tcl`.
