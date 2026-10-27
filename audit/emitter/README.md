# audit/emitter

Grammar-constrained emission: the exploratory milestone
EMITTER-COROUTINE-EXPLORATION.md. An isolated prototype -- nothing in
`core/`, `hir/`, `surface/`, `compiler/` or `native/` loads it, and
`tests/local.tcl` and CI do not run it.

* `tools/emitcheck.tcl` -- the emission checker: proves an emitter's claim
  (`#: emits R` on the line before its `fn`) that every normal completion
  has yielded exactly one token of the declared recognizer R, by abstract
  interpretation of its HIR over R's effective table
  (`tclsh9.0 audit/emitter/tools/emitcheck.tcl PROGRAM.bot`).
* `json/` -- the JSON workload: `json_grammar.bot` (json_text and the guards,
  composed from examples/dfa/json/json_lex.bot), the emitters
  (`number_emit.bot`, `string_emit.bot`, `value_emit.bot`), the consumers and
  run-time validation (`sinks.bot`), the program the claims are checked in
  (`check_all.bot`), the benchmark workloads (`bench_work.bot`) and a
  streaming demonstration (`demo.bot`). They run beside json_lex.bot and
  json.bot: `tools/workspace.tcl` copies the three directories' modules into
  one application directory.
* `census/cases.txt`, `tools/census.tcl` -- the mistake census
  (`results/census.md`).
* `tools/property.tcl`, `tools/support.tcl`, `tools/oracle.py` -- property
  and differential tests against CPython's strict json and the reference
  interpreter of tests/dfa-support.tcl.
* `tools/witness.tcl` -- grammar-directed generation: coverage witnesses of
  every recognizer (`results/witnesses.md`).
* `tools/bench.tcl`, `tools/evidence.tcl` -- the performance report
  (`results/bench.md`) and the native evidence (`results/evidence/`).
* `tests/emitter.test` -- the tests (`tclsh9.0 audit/emitter/tests/emitter.test`).
