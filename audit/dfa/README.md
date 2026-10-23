# audit/dfa

Declared finite-state recognizers: the evidence of two milestones.

* `results/`, `evidence/` -- the exploration's (DFA-COROUTINE-EXPLORATION.md),
  kept as history: its prototype preprocessor and generated modules are
  retired (commit e5286ad5 holds them).
* `milestone-2/` -- DFA-COROUTINE-MILESTONE-2.md's: the differential run
  (`differential.md`), the mistake census (`mistakes.md`), the native
  evidence (`evidence/`) and the performance report (`bench.md`, from
  `bench/dfa.tcl`; `bench-exploration.md` is the exploration's benchmark
  re-run on the same machine).
* `tools/` -- the live tools, over the integrated workloads in
  `examples/dfa/`:
  - `differential.tcl` -- the JSON workload against JSONTestSuite and
    generated cases, CPython's strict json (`oracle.py`) the oracle;
  - `mistakes.tcl` (`mistakes.txt`) -- realistic mistakes in
    `examples/dfa/json/json_lex.bot`, each applied alone: caught by the
    compiler, by the differential tests, or surviving;
  - `evidence.tcl` -- NIR, fusion reports and machine code of fused and
    unfused recognizer programs.
