# audit/module-privacy/

The evidence of MODULE-PRIVACY-AND-CONTEXT-ESCAPE-MILESTONE-1.md (docs/):
`private` declarations and the `CONTEXT-RESOURCE-ESCAPE` warning.

| path | what |
|---|---|
| `tools/fuzz.tcl` | generated applications (an airlock, ordinary or direct module `u`, a consumer, the entry program) against an independent model of both rules, written from the specification: PRIVATE-ACCESS, PRIVATE-TYPE-ESCAPE and the set of declarations the warning reports must equal the compiler's (`-n N -seed S`) |
| `tools/mutate.tcl`, `tools/mutants.txt` | the mutants of both features, each applied to a private copy of the tree; `tests/module-privacy.test`, `tests/context-resource-escape.test` or the fuzzer must kill every one |
| `tools/warning-census.tcl` | the repository census of the warning: the corpus of ICY-TOWER-CONTEXT-REFACTOR-CENSUS.md's census (`audit/icy-tower/context-refactor/warning-census/`), built and scanned by that census's own tools, with the compiler's warning pass applied to every HIR and every crossing set beside the earlier classification |
| `census/` | its output: `warnings.tsv`, `crossings.tsv`, `sites.tsv`, `units.tsv`, `summary.txt` (the tool's header says what each holds) |

Every tool keeps its scratch files in a private temporary directory and
removes it.
