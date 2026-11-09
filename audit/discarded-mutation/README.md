# DISCARDED-MUTATION

The material of
[WARNINGS-DISCARDED-MUTATION-MILESTONE-1.md](../../docs/WARNINGS-DISCARDED-MUTATION-MILESTONE-1.md):
the evidence for the `DISCARDED-MUTATION` warning (hir/discarded.tcl,
hir/warnings.tcl).

* `tools/census.tcl` -- every `DISCARDED-MUTATION` warning in the
  repository's programs (every tracked `.bot` file but the generated
  bindings, and a loader per standard-library module), compiled with
  warnings on; `-shard I/N` splits the work, `-out FILE` writes the rows.
  `census.tsv` is its committed result, each row classified in the report
  (section 12).
* `tools/test-census.tcl`, `tools/test-census.sh` -- the same facts inside
  every program the Tcl test files compile (most with warnings off), by a
  hook around `hir::BuildFull`; `test-census.tsv` is the committed result.
* `tools/fuzz.tcl` -- generated programs against an independent model of
  the two rules (a liveness and a must-walk over the generator's own
  statement tree), the warning policies and every backend's behavior.
* `tools/mutate.tcl`, `tools/mutants.txt` -- the mutation catalog: every
  mutant must apply and be killed by a test of
  `tests/discarded-mutation.test` its `!!` line names.

The reproducers the warning was designed against are the construct-binding
census's (`../construct-binding-mutation/corpus/`); `tests/discarded-mutation.test`
reads them. `bench/discarded-mutation.tcl` measures the compile-time cost.
Nothing here is loaded by the compiler.
