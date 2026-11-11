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
  measure them: never applied to the compiler as it is. Its sections 21.1
  and 21.2 were rewritten, with their tests and mutants, by
  EMISSION-IDENTITY-AND-FEASIBILITY-CORRECTNESS-MILESTONE-1.md, and 21.3
  by EMISSION-BINDING-PROVENANCE-CORRECTNESS-MILESTONE-1.md (whose section
  2 lists the three gaps of the prototype's 21.3 it closed). It is kept as
  the census's evidence.

```sh
LANG=C.utf8 LC_ALL=C.utf8 tclsh9.0 audit/emission-dependencies/tools/census.tcl \
    -out audit/emission-dependencies/results/census.md
```

At the census's commit it found four false certificates in accepted
programs (cases N2, F1, F3 and the sequence `identity`) and 26 open cases.
A correction milestone updates the `observed` lines it changes: the report's
section 21 lists what each correction must change and what it must keep.

EMISSION-IDENTITY-AND-FEASIBILITY-CORRECTNESS-MILESTONE-1.md corrected the
two class C defects (the prototype's sections 21.1 and 21.2, with one more
rule its identity correction lacked) and updated the record: N1, N2, N3,
F1, F2, F3 and the `identity` sequence's N4b now record the corrected
verdicts, and N6a, N6b and the sequence `identity-read` are its own (the
gap: a proof that read two functions of one name, memoized). The census
now finds 0 false certificates and 20 open cases, every one a binding or
signature case of section 21.3, which that milestone defers.

EMISSION-BINDING-PROVENANCE-CORRECTNESS-MILESTONE-1.md corrected the binding
cases (section 21.3, rewritten): R1, B3c, B6, D1, D2, B8, B8f, X2, SC1, S5d
and V2 now record `dependent`, and B3, G1 and B8b, decided `dependent` by
that milestone's policy, state it as their appropriate verdict. V3 to V7
(V2's hole through a narrow result, a helper's result, a local, a captured
value, a List element), L1 and L1v (a captured loop element), Z1v and the
sequences `callable-narrow` and `trust` are its own. The census now finds 0
false certificates and 6 open cases: B2b, S1 and K1 (class A), and S4b,
S5b and S6b (undecided), which that report's section 23 explains.
