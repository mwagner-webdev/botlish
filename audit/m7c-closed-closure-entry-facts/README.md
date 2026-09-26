# M7.c closed-closure entry-facts audit artifacts

Frozen-corpus census output for
[M7C-CLOSED-CLOSURE-ENTRY-FACTS.md](../../M7C-CLOSED-CLOSURE-ENTRY-FACTS.md),
generated with M7.a's own unmodified tool
(`audit/m7a-instance-selection/tools/corpus.tcl`) against the frozen
`bench/uri-steady.bot`/`bench/refined-checks.ir` workloads, kept in this
adjacent directory rather than mixed into `audit/m7a-instance-selection/`
so before/after provenance for the two milestones stays clearly separate
(spec item 87).

`before/` was generated against the tree exactly as M7.b left it (before
any M7.c production change); `after/` was regenerated against the tree
with this milestone's own `hir/specialize.tcl` change in place (the
default: `hir::specialize::analyze`'s own `-closed-caller-facts-opt 1`).
Both runs invoke M7.a's own tool identically:

```sh
export LANG=C.utf8 LC_ALL=C.utf8
tclsh9.0 audit/m7a-instance-selection/tools/corpus.tcl bench/uri-steady.bot OUTDIR
tclsh9.0 audit/m7a-instance-selection/tools/corpus.tcl bench/refined-checks.ir OUTDIR
```

To reproduce `before/` directly against the current (post-M7.c) tree
without reverting the production change, pass
`-closed-caller-facts-opt 0` where `corpus.tcl`'s own helper library
(`audit/m7a-instance-selection/tools/lib.tcl`'s `m7a::analyze`) calls
`hir::specialize::analyze` -- the option this milestone added specifically
so its own before/after comparison never depends on stashing a diff. See
M7C-CLOSED-CLOSURE-ENTRY-FACTS.md's own "Outcome" and "Frozen corpus
census" sections for the summarized before/after numbers.

| directory | contents |
|---|---|
| `before/uri-steady/`, `before/refined-checks/` | pre-M7.c: `instances.txt`, `conditions.txt`, `guards.txt`, `functions.txt`, `summary.txt` |
| `after/uri-steady/`, `after/refined-checks/` | post-M7.c: the same five files |
