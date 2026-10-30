# audit/equality-semantics

Material of [EQUALITY-SEMANTICS.md](../../docs/EQUALITY-SEMANTICS.md) (how
`==` treats operands of unrelated static types, against integer-domain
admission) and of its follow-up,
[EQUALITY-SEMANTIC-CENSUS.md](EQUALITY-SEMANTIC-CENSUS.md) (what makes two
types suitable for equality, partial equality, `any`, inferred obligations,
callable values, semantic-instance independence, collections). Audit only:
nothing here is loaded by the compiler, the tests or CI.

## The first report's material

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

## The semantic census's material

* `census/` holds the census's probe programs, one question each, named by
  the investigation they serve (`i1-` compatibility and value overlap, `i2-`
  partial and undefined equality, `i3-` `any` and untyped parameters, `i4-`
  inferred obligations, `i5-` callable values, `i6-` semantic-instance
  budgets, `i7-` collections and hashing, `i8-` the one-character-literal
  hazard). Each file's first line says what it probes. `census/methods/` is
  an application with two modules for the method-applicability probes (run
  `ambiguous.bot`, `decided.bot`, `only-m1.bot`).
* `tools/run.tcl ?-backends B,...? ?-out FILE? ?PROBE.bot ...?` runs each
  probe through `main.tcl -check` and then on each backend (default interp,
  compile, cranelift, cranelift-generic), and tells the outcomes apart:
  `ok` (the check found nothing), `static KIND: LINE:COL: TEXT` (a
  diagnostic of the compilation), `value V`, `runtime EQUALITY: TEXT`,
  `runtime KIND: TEXT`. `census-probes.txt` is its output for every probe on
  the report's tree.
* `tools/inspect.tcl ?-semantic 0|1? ?-max-per-block N? ?-max-instances N?
  PROGRAM.bot` prints what the compiler knows about one program: each
  function's declared, trusted and checked parameter contracts with their
  provenance, each `==` with its operands' static types, their equality
  totality, the native operation lowering would choose and the candidate
  relations, each call's target and semantic instance (or why it was
  declined), and each instance's status and the operand types it gives each
  `==`. A rejected program is inspected through its lenient (`-strict 0`)
  build.
  `census-inspect.txt` is its output for the probes the report leans on.
* `tools/results.tcl` runs `==` of Result values, which no source program
  can build (`ok(v)`/`error(v)` are core IR forms), as core IR programs on
  the interpreter, the Tcl compiler and the native backend.
  `census-results.txt` is its output.
* `tools/lib.tcl` defines the candidate relations (`eqcensus::Head`,
  `Overlap`, `Kinded`, `Related`, `Defined`); inspect.tcl and
  reclassify.tcl source it.
* `tools/reclassify.tcl ?-out DIR? ?-cache DIR?` compiles the first census's
  corpus (a program that imports a platform's namespaces for that
  platform's target) and writes, into DIR, `sites.tsv` (every `==` site
  under every relation, in the generic HIR and in the worst semantic
  instance, with where an unknown operand comes from), `params.tsv` (every
  untyped parameter compared with an operand of fixed kind: the concrete
  contract a concrete-inference policy would give it) and `failed.txt`.
  `reclassify/` holds its output on the report's tree, and
  `tools/policies.tcl reclassify/` turns it into the report's tables
  (`reclassify/policies.txt`).

Run everything from the repository root with `tclsh9.0` under `LANG=C.utf8
LC_ALL=C.utf8`; the native runs need a built native backend (`cargo build
--release --manifest-path native/Cargo.toml`).
