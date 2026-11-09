# WARNINGS-DISCARDED-MUTATION-MILESTONE-1

`DISCARDED-MUTATION`: one compiler warning for a mutation whose modified
state no later computation can see, and for a fold exit that deliberately
carries the iteration's starting intermediate after the iteration mutated it.
The recommendation of CONSTRUCT-BINDING-MUTATION-CENSUS-1.md (sections 16
and 17), implemented. No language rule, runtime behavior, HIR node, backend or
existing diagnostic changed.

Throughout, *implementation fact* means something read from the compiler's
code, *observation* something a run or an emitted diagnostic showed, and
*judgment* a design decision or tradeoff this report argues for.

The material: hir/discarded.tcl (the two facts), hir/warnings.tcl (the pass
and its messages), hir/hir.tcl (the checked source it reads),
tests/discarded-mutation.test, `../audit/discarded-mutation/` (the
repository census, the test-file census, the fuzzer, the mutation catalog),
bench/discarded-mutation.tcl, and Compilerpedia's
`warning.discarded-mutation` with the construct-binding documentation the
census asked for.

@@RESULT@@
