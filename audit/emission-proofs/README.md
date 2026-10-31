# audit/emission-proofs

Modular, caller-independent certification of emitters: the milestone
MODULAR-EMISSION-PROOFS-MILESTONE-1.md. An isolated prototype -- nothing in
`core/`, `hir/`, `surface/`, `compiler/` or `native/` loads it, and
`tests/local.tcl` and CI do not run it. The exploratory checker it is
compared with, audit/emitter (EMITTER-COROUTINE-EXPLORATION.md), is kept
unchanged as the baseline.

* `tools/modcheck.tcl` -- the checker: definition-level certification of
  `#: emits R` claims from each function's declared parameter domains
  (never its callers), invocation-level checks (`-invocation`), the
  exploratory model on the same engine for comparison (`-facts observed`),
  context-sensitive helper summaries shared across claims, certificates,
  composition by a certificate's language (`-compose certificate`, the
  default) or by bodies, a certificate store (`-store FILE`) with
  invalidation, and verdicts proven / disproven / not proved
  (`tclsh9.0 audit/emission-proofs/tools/modcheck.tcl PROGRAM.bot`).
* `tools/intset.tcl` -- the value domain: unions of intervals over
  hir::range's own transfer functions.
* `tools/dfasem.tcl` -- the recognizer semantics, read from the lowering's
  table (surface::dfa::Codes); `tools/conformance.tcl` holds it to the
  reference interpreter of tests/dfa-support.tcl.
* `tools/concrete.tcl` -- running emitters for real and judging their
  traces with the reference interpreter: the counterexample search behind
  `disproven`, and the fuzzer's oracle.
* `lib/emitlib.bot` -- the independent library (a JSON string emitter for
  every `str`, an unguarded, a guarded and a domain-typed digit emitter,
  compositions); `callers/` -- five unrelated programs that use it;
  `tools/library.tcl` -- the demonstration (`results/library.md`).
* `census/cases.txt`, `tools/census.tcl` -- the modular census and the
  exploratory census under the modular checker (`results/census.md`).
* `tools/fuzz.tcl` -- generated emitters against exhaustive execution
  (`results/fuzz.md`).
* `tools/mutants.txt`, `tools/mutate.tcl` -- the mutation audit
  (`results/mutants.md`).
* `lib/emitbench.bot`, `tools/bench.tcl` -- the costs (`results/bench.md`).
* `tests/emission-proofs.test` -- the tests
  (`tclsh9.0 audit/emission-proofs/tests/emission-proofs.test`).
