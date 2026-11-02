# audit/emission-claims

Evidence for EMISSION-CLAIMS-MILESTONE-1.md: the `emits` clause, its
modular checker (hir/emission.tcl, hir/emitdfa.tcl) and the value facts it
rests on (hir/intset.tcl over hir::range's transfers). Every tool runs
against the integrated compiler; none of them is part of compilation.

* `tools/` -- the live tools:
  - `witness.tcl` -- concrete counterexamples: runs an emitter (every claim
    erased from a copy of its directory) and judges its traces with the
    reference interpreter. The one way a claim is called *disproven*; the
    compiler only says "may".
  - `census.tcl` -- `-part modular`: the modular prototype's census
    (`census/cases.txt`), every claim checked by the compiler and searched
    for a witness, proven ones included (a witness against a certificate is
    a false proof, and fails the run); `-part mistakes`: the exploratory
    milestone's 31 mistakes (`census/mistakes.txt`) applied alone to
    examples/dfa/json's emitters.
  - `fuzz.tcl` -- generated emitting modules (sequences, branches, counted
    loops, early returns, helpers, recursion, failures, handlers, guards)
    against exhaustive execution of a bounded input range: no false proof,
    every rejection searched for its witness.
  - `conformance.tcl` -- the checker's recognizer semantics (one symbol at
    a time, over core/dfa.tcl's outcome model and the tables the HIR
    carries) against the reference interpreter, on every case
    tests/dfa-support.tcl makes for the JSON workload's recognizers and
    three written for what JSON lacks.
  - `mutate.tcl` (`mutants.txt`) -- deliberate bugs in the checker's proof
    rules, the outcome model, the shared value transfers and the trust
    boundary, each on a private copy of the tree.
  - `bench.tcl` -- the costs against the modular prototype's workloads,
    certificate reuse and invalidation, interchange size, and the erasure
    of claims from native code.
* `callers/` -- the independent library's callers
  (examples/dfa/json/emitlib.bot): one calling its emitters only with
  values a caller-dependent checker would infer as safe, one across their
  whole domains, one passing invalid values (to the guarded emitter, which
  fails, and to the unguarded one, which is not certified), one composing
  certified emitters, one calling none. Every claim's verdict is the same in
  all five.
* `census/` -- the census and mistake inputs above.
* `results/` -- the committed runs (`census.md`, `fuzz.md`,
  `conformance.md`, `mutants.md`, `bench.md`): regenerate with the tool's
  `-out`.

The checker's tests are tests/emission-claims.test and
tests/interval-sets.test; AGENTS.md ("Emission claims") lists what to run
when changing any of this.
