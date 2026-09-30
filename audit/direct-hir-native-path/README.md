# Direct HIR -> NIR native path -- audit data

Evidence for `DIRECT-HIR-NATIVE-PATH.md`. "parent" is the commit before the
milestone (`9b2c712`, the scalar-asm regeneration after strict reference
determinism); "after" is the tree containing this directory. Tcl 9.0.1,
`LANG=C.utf8 LC_ALL=C.utf8`, Rust stable (1.9x), Cranelift 0.135.

Every tool is observation only. The parent-tree measurements were taken from a
`git worktree` of `9b2c712` with its own copy of `native/target/release`
(`-root TREE`); the after-tree measurements from this tree.

| tool | what |
|---|---|
| `tools/differential.tcl -root TREE -mode relift\|direct -out DIR FILE.bot` | one program's semantic-instance counters, codegen/AOT census, NIR (raw, canonical), scalar assembly digest and interpreter-vs-native value, through the parent's relifted route (`-mode relift`, parent tree only) or the direct HIR route |
| `tools/differential.sh TREE MODE OUTDIR FILE.bot ...` | the above, one process per program (the module-static slot table used to leak between compilations in one process) |
| `tools/tabulate.tcl LABEL-A DIR-A LABEL-B DIR-B` | totals over the 17 canonical programs and the rows that differ |
| `tools/compiletime.tcl -root TREE -mode relift\|direct` | median ms per program: front end, relift/prepare, NIR lowering, Cranelift compile |
| `tools/memory.tcl -root TREE` | string size of the core IR and reconstructed HIR the relift route holds (parent tree only) |
| `probes/*.bot` | the focused programs: shadowing, modules, container intrinsics, module native bridge, closures, self recursion, argument-passing cycle, errors, loops, semantic instances, exact callables, typed MutableArray. New audit probes; the canonical `bench/` and `examples/stdlib/` sources are untouched. |

`out/`:

* `summary-parent-relift.txt`, `summary-parent-direct.txt`: the pre-deletion
  differential (30 programs: the 17 canonical, then the 13 probes).
* `summary-after-direct.txt`: the same tool in this tree (there is no relift
  route left to run).
* `nir-ops-*.txt`: NIR opcode histograms over the 17 canonical programs.
* `canon-diff-*.txt`: the canonical-NIR differences relift vs direct.
* `tabulate-*.txt`, `compiletime-*.txt`, `memory-parent.txt`, `regression-*.txt`,
  `coverage-*.txt`, `bench-*.txt`: the rest of the report's measurements.
