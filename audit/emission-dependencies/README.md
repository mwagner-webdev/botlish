# audit/emission-dependencies

Evidence for EMISSION-BINDING-AND-SIGNATURE-DEPENDENCY-CENSUS-MILESTONE-1.md:
how the emission checker (hir/emission.tcl) depends on values, bindings and
callable signatures whose declarations hold unresolved names, diagnosed
expressions or syntax holes, and on the identity of the functions a
certificate depends on. A research instrument: nothing in compilation loads
it, and neither `tests/local.tcl` nor CI runs it.

* `census/cases.txt` -- the corpus: paired programs (a diagnosed
  declaration, the same program valid or repaired, an unrelated change),
  each with the verdicts the compiler gave at the census's commit
  (`observed`), the verdicts it should give (`appropriate`, or `undecided`
  where the report gives the competing readings), its consequence class
  (the report's section 19), its strict outcome, and, for the false
  certificates, a run of the program with its claims erased whose trace the
  reference interpreter judges. Sequences compile several cases in one
  process with the certificate memo kept, as the compiler service does.
* `tools/census.tcl` -- compiles every case leniently (the memo fresh, and
  off), strictly, and through HIR interchange (decoded with the memo on and
  off); runs the runnable ones on every backend; prints the tables of
  `results/census.md`. It exits 1 when an observation differs from what
  `cases.txt` records, so a change of behavior is looked at and recorded;
  a false certificate the record states is reported, prominently, and is
  no difference.

* `prototype/corrections.patch` -- the three corrections the report
  recommends (section 21), as prototyped against the census's commit to
  measure them: never applied to the compiler here, a starting point for
  the correction milestone (which owns their tests, mutants and the
  mutant text `dependent-reports` the third one duplicates).

```sh
LANG=C.utf8 LC_ALL=C.utf8 tclsh9.0 audit/emission-dependencies/tools/census.tcl \
    -out audit/emission-dependencies/results/census.md
```

At the census's commit it finds four false certificates in accepted
programs (cases N2, F1, F3 and the sequence `identity`) and 25 open cases.
A correction milestone updates the `observed` lines it changes: the report's
section 21 lists what each correction must change and what it must keep.
