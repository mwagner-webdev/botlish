# Strict reference determinism -- audit data

Evidence for `STRICT-REFERENCE-DETERMINISM.md`. "before" = the parent commit
(`5e344a8`, the scalar-asm regeneration after the typed MutableArray builder
source fence); "after" = the tree containing this directory. Every tool is
observation-only and runs against the tree named on its command line (default
the tree it lives in), so one script measured both trees ("before" from a
`git worktree` of `5e344a8` with `native/target` symlinked to the built
backend). Tcl 9.0.1, `LANG=C.utf8 LC_ALL=C.utf8`.

| tool | what |
|---|---|
| `corpus-census.tcl [-root TREE]` | builds the HIR of every program under `bench/`, `examples/`, `lib/` and lists each reference that violates the strict-reference invariant (`hir/refcheck.tcl`), by source area and shape; on the strict compiler also counts `UNBOUND` diagnostics (a rejected forward reference) |
| `experiment/measure.tcl [-root TREE] FILE.bot` | one program's semantic-instance counters, codegen/AOT/guard counts and a canonical NIR digest (function ids, registers and `@e` tags erased, callees named), or `REJECTED` |
| `experiment/csv_records-{A,B,C}-*.bot` | the definition-order experiment: A the callee-first source, B the caller-before-callee draft (`scan_record` before `scan_record_rest`), C an alternative legal order of independent helpers |
| existing tools, reused | `opportunistic-semantic-instances/tools/{census,nir-all}.tcl`, `mutarray-construction/tools/aot.tcl`, `native/generate-scalar-audit.tcl`, `intrinsic-function-contracts/tools/compiletime.tcl`, `bench/bench.tcl` |

The test-suite census (`out/census-before-tests.txt`) was produced by a
temporary hook in `hir::buildSyntax` of the *pre-change* worktree (never
committed) that called `hir::refcheck::forwardRefs` on every HIR the suite
built, both backends, and logged the result per test file.

`out/`: `census-before-corpus.txt`, `census-before-tests.txt`,
`census-after-corpus.txt`, `definition-order-experiment.txt` (A/B/C on both
compilers), `semantic-census-{before,after}.txt` (counters), `aot-*.txt`,
`nir-digests-*.txt`, `compiletime-*.txt`, `bench-*.txt`, `regression-*.txt`.
