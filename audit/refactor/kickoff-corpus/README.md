# The corpus at the warning-driven refactor's kickoff

These files are copies, at commit 6e3f9f7 (the pinned post-affine kickoff
tree of REFACTOR-WARNINGS-CLEAN.md), of

* `examples/stdlib/*.bot` (the nine algorithm-corpus programs),
* `examples/refinement/refined-strings.bot`,
* `bench/lex-strategy.bot`,

as they were before the refactor cleaned them under the compiler's own
warnings. They were byte-identical copies; every edit since is listed under
"Migrations" below. They are a **frozen, warning-bearing fixture**, not
corpus programs: the warning gate (`audit/refactor/tools/gate.tcl`) does not
compile them, and nothing may "clean" them.

They are edited only when the language changes so that one of them no
longer compiles, and then only as far as compiling again takes. Every
warning keeps its code and its text (only its position may move), and every
program keeps its results on every backend. Check both against the tree
before the language change: run each program there and here with
`main.tcl -backend B -warnings default` on all four backends. Each such
edit is listed below.

They exist for the tests whose subject is that real programs carrying real
warnings of every code print identical warning text on every backend
(`me-cli-backend-independent-stdlib`, `fa-cli-backend-independent-stdlib`,
`oc-cli-backend-independent-corpus` and their siblings in
`tests/*.test`). Those tests were written over the live stdlib corpus while
it was frozen with its findings; once the corpus is clean, the live corpus
would make them vacuous (no `METHOD-ELIGIBLE` or `FIXED-ARITY-LIST-RETURN`
line left to compare), so they read these copies instead. The live corpus's
own warnings are the gate's job.

One other test reads them for the same reason, a subject the refactor
removed from the live program: `tests/native-string-region.test`'s
`region-csv-corpus-1` measures the String-region optimization on `csv.bot`'s
`peek()` comparisons, which the live `csv.bot` no longer makes (it reads
characters with `std::str::char_at`).

They import the live `stdlib/` modules, so a library's findings print here
exactly as the manifest (`audit/refactor/manifest.txt`) says they print
everywhere else.

## Migrations

* **NONPLACE-PARAMETER-MUTATION**
  (NONPLACE-PARAMETER-MUTATION-CORRECTNESS-MILESTONE-1.md). A parameter
  not declared `place` can no longer be mutated, and three programs
  mutated one:
  - `csv_chunked.bot`: `chunked_append` and `chunked_copy_chunks`;
  - `csv_records.bot`: `ht_rehash_insert`, `ht_place` and `ht_set`;
  - `hashtable.bot`: the same three, and `ht_delete`.

  Each function now copies its parameter into a local (`updated = table`,
  `filling = final`) right before the first mutation, and the code after it
  uses the local. That writes out the meaning the old compiler gave the
  parameter, its own copy. Nine lines were inserted and the uses after them
  renamed; nothing else changed.

  Placing the copy right before the first mutation leaves every line before
  it as written. Each parameter keeps its name. SAME-RETURN-VALUE names a
  returned value by its alias root, the parameter, so `hashtable.bot`'s
  `ht_delete` line still reads "the value of `table`". A renamed parameter
  (`table = given_table`) would have changed that text.

  Checked against 13dd290, the tree before the milestone, with these files
  unmigrated: all eleven programs, on all four backends, print the same
  results and the same warnings (357 located in these files: 285
  METHOD-ELIGIBLE, 64 ONE-CHAR-STRING-LITERAL, 5 FIXED-ARITY-LIST-RETURN, 3
  SAME-RETURN-VALUE). Only the positions moved, by the inserted lines.
