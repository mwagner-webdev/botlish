# The corpus at the warning-driven refactor's kickoff

These files are byte-identical copies, at commit 6e3f9f7 (the pinned
post-affine kickoff tree of REFACTOR-WARNINGS-CLEAN.md), of

* `examples/stdlib/*.bot` (the nine algorithm-corpus programs),
* `examples/refinement/refined-strings.bot`,
* `bench/lex-strategy.bot`,

as they were before the refactor cleaned them under the compiler's own
warnings. They are a **frozen, warning-bearing fixture**, not corpus
programs: the warning gate (`audit/refactor/tools/gate.tcl`) does not compile
them, nothing edits them, and nothing may "clean" them.

They exist for the tests whose subject is that real programs carrying real
warnings of every code print identical warning text on every backend
(`me-cli-backend-independent-stdlib`, `fa-cli-backend-independent-stdlib`,
`oc-cli-backend-independent-corpus` and their siblings in
`tests/*.test`). Those tests were written over the live stdlib corpus while
it was frozen with its findings; once the corpus is clean, the live corpus
would make them vacuous (no `METHOD-ELIGIBLE` or `FIXED-ARITY-LIST-RETURN`
line left to compare), so they read these copies instead. The live corpus's
own warnings are the gate's job.

They import the live `lib/` modules, so a library's findings print here
exactly as the manifest (`audit/refactor/manifest.txt`) says they print
everywhere else.
