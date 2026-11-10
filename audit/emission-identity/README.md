# audit/emission-identity

Evidence for EMISSION-IDENTITY-AND-FEASIBILITY-CORRECTNESS-MILESTONE-1.md:
the two accepted-program soundness failures the emission binding and
signature census found (function identity by bare name; an empty
environment read as an infeasible branch), their correction in
hir/emission.tcl, and what the correction costs. Research instruments:
nothing in compilation loads them, and neither `tests/local.tcl` nor CI
runs them. The regression tests are tests/emission-claims.test's
`ec-identity-*` and `ec-feasibility-*`; the mutants are in
audit/emission-claims/tools/mutants.txt.

* `tools/repro.tcl` -- the census's counterexamples (N1, N2, N3, N5, the
  sequence N4a then N4b; F1 to F4) and three parameterless programs of the
  milestone's own (P1 to P3), compiled with what the checker decides on the
  way: each claim's block, declaring binding, scope and lexical path, its
  bare name, `byName`, the memo and certificate-table key, whether it was
  reused, the fingerprints its certificate records and those of the blocks
  of the name; every `Facts` call (the environment's size, hir::range's
  paths with their known outcomes, what it returned) and every `if` the
  walk evaluated; the strict outcome; the run with the claims erased on
  every backend, judged by the reference interpreter.
* `tools/structure.tcl` -- the structural audit: generated programs of
  the shapes the earlier fuzzers never made (zero-parameter claims, a
  conditional before any binding, one name bound by functions in different
  lexical scopes, a nested function shadowing a top-level one, helpers
  with and without claims), each decided under four switch assignments
  with a fresh memo, with it off and after an edited version of itself
  (the memo kept, both directions), every emitter of both versions run for
  every argument tuple. `-root DIR` runs it against another checkout.
* `tools/bench.tcl` -- the checker's costs on the JSON and CSV probes
  (fresh processes), memo reuse on a second compilation, and the cost of
  the ambiguous-name fallback. `-root DIR` measures another checkout.
* `results/` -- the committed runs: `repro-before.md` and
  `repro-after.md` (the tree before the milestone, then with it),
  `structure.md` (this checkout), `structure-before.md` (the tree before
  the milestone: what the audit finds there), `structure-prototype.md`
  (the census's prototype corrections 21.1 and 21.2 alone), `bench.md`
  and `bench-before.md`.

```sh
LANG=C.utf8 LC_ALL=C.utf8 tclsh9.0 audit/emission-identity/tools/repro.tcl -out audit/emission-identity/results/repro-after.md
LANG=C.utf8 LC_ALL=C.utf8 tclsh9.0 audit/emission-identity/tools/structure.tcl -seeds 1-40 -out audit/emission-identity/results/structure.md
LANG=C.utf8 LC_ALL=C.utf8 tclsh9.0 audit/emission-identity/tools/bench.tcl -out audit/emission-identity/results/bench.md
```

The `-before` runs used a copy of this checkout whose hir/emission.tcl is
the milestone's parent's (`git show HEAD~N:hir/emission.tcl`), given as
`-root`; `structure.tcl` and `bench.tcl` load that tree's compiler, and
`repro.tcl` was run from it.
