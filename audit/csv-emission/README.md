# audit/csv-emission

The evidence of CSV-EMISSION-VALIDATION-MILESTONE-1.md: production `emits`
on examples/dfa/csv's CSV grammars and emitters.

* `tools/run.tcl` -- generated batch programs running the CSV sources on any
  backend; the declared recognizer (tests/dfa-support.tcl's reference
  interpreter) judging every trace.
* `tools/oracle.py` -- the independent judge: the profiles restated from RFC
  4180, a strict parser, a reference serializer, CPython's csv module
  (`check`, `export`, `selftest`). It reads no Botlish.
* `tools/differential.tcl` -- the corpus, exhaustive and fuzz runs on five
  backends (`results/differential.md`).
* `tools/census.tcl` with `census/mutants.txt` -- the mutation census
  (`results/census.md`).
* `tools/bench.tcl` -- native costs (`results/bench.md`).
* `tools/claims.tcl` -- every claim of a program and its verdict.
* `tools/cleanroom.sh` -- the export application built by the single-file
  compiler in an empty environment.

tests/csv-emission.test runs a sample of each.
