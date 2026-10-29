# audit/equality-semantics

Material of [EQUALITY-SEMANTICS.md](../../docs/EQUALITY-SEMANTICS.md): how
`==` treats operands of unrelated static types, against integer-domain
admission. Audit only: nothing here is loaded by the compiler, the tests or
CI.

* `tools/census.tcl ?-out FILE? ?-sites FILE?` compiles the corpus:
  - every program of examples/, bench/ and tests/golden/;
  - a loader of every standard-library module.

  It classifies every `==` and `!=` site by its operands' static types
  (refused, unknown, disjoint-kind, disjoint-nominal, disjoint-domain,
  empty-only, compatible; the script's header defines them). The output is
  the table per corpus area, and with `-sites` one line per site.
  `census.txt` and `sites.tsv` are its output on the report's tree (its
  failure lines with the checkout's path removed).
* `tools/probes.tcl ?-backends B,...? ?PROBE.bot ...?` runs the programs of
  `probes/` through main.tcl and prints each one's value or first diagnostic
  per backend (default interp and cranelift).
* `probes/` holds one small program per question the report asks. Each
  file's first line says what it probes.

Run from the repository root with `tclsh9.0` under `LANG=C.utf8
LC_ALL=C.utf8`; the probes' native runs need a built native backend.
