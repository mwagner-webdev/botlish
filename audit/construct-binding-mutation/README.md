# Construct-binding mutation census

The material of [CONSTRUCT-BINDING-MUTATION-CENSUS-1.md](../../docs/CONSTRUCT-BINDING-MUTATION-CENSUS-1.md):
mutation of loop variables, fold intermediates, handler payloads and other
construct-local bindings.

* `corpus/` -- the reproducers, each a standalone program whose leading
  comments state its category, its class (A productive, B temporary, C
  silently discarded, rejected, proof interaction), what was intended and
  what happens, and the checked outcome (`# expect:`,
  `# expect-diagnostics:`, `# alloc:`). `cNN` are the discarded writes
  (`-fixed` their corrections), `aNN` the legitimate idioms, `rNN` the
  programs existing rules reject, `pNN` the proof interactions.
* `tools/run.tcl` -- runs the corpus on interp, compile, cranelift-generic
  and cranelift, and checks every stated outcome.
* `tools/census.tcl` -- every mutation site of the repository's programs,
  classified by the root binding's construct (report, section 11).
* `tools/test-census.tcl`, `tools/test-census.sh` -- the same analysis
  inside every Tcl test file's programs.
* `tools/textscan.py` -- an independent, textual cross-check that needs no
  compiler.
* `tools/fold-cost.tcl` -- the cost of pushes into a fold intermediate, an
  outer local and a threaded working copy (report, section 15).

Nothing here is loaded by the compiler, the tests or CI.
