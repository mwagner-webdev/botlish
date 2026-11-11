# Text and collection precision: probes and tools

The material of `docs/TEXT-AND-COLLECTION-PRECISION-CENSUS.md`. Nothing here
is loaded by the compiler or run by CI; it records today's behavior so that a
follow-up milestone can show what it changed.

* `probes/*.bot` -- eighteen minimal programs. Each states its expected
  outcome in its leading comments (`# outcome:`, `# value:`,
  `# diagnostic: L:C TEXT`, `# error:`, `# binding: L NAME TYPE`). A
  milestone that changes a probe's outcome updates its expectation in the
  same change (M1 did for `c1` and `c6`, M2 for `j3`, whose result
  diagnostic names the inferred type since).
* `tools/probes.tcl` -- runs every probe (or the ones named): `main.tcl
  -check`, each accepted or run-time-failing probe on interp, compile,
  cranelift and cranelift-generic (`-backends` narrows), and the binding
  checks through the compiler service. Exit status 1 on any difference.

      tclsh9.0 audit/text-collection-precision/tools/probes.tcl

* `tools/matrix.py` -- the census's section H table: the checker's static
  type of twelve operations' results over six element types, read from TYPE
  diagnostics of generated programs (written to a temporary directory), and
  two more columns (a refined `List[int]{length: 2}` element, and an
  element the checker knows only as `any`). A second table, added by
  LOOP-CLAUSE-BINDING-TYPE-CORRECTNESS-MILESTONE-1.md, is the binding
  table's record of every loop clause binding of those programs, checked
  against the service's presentation, its references' types and the first
  table (exit status 1 on a disagreement).

      python3 -I audit/text-collection-precision/tools/matrix.py

* `tools/bindings.tcl` -- the binding table of one program as the compiler
  service analyzes it: each binding's recorded type, presented type and
  references' types (matrix.py reads it).

      tclsh9.0 audit/text-collection-precision/tools/bindings.tcl FILE.bot

* `tools/bench.tcl` -- section G's text-construction strategies at chosen
  sizes and backends: time and (natively) String bytes copied.
  TEXT-AND-COLLECTION-DOCUMENTATION-AND-DIAGNOSTICS-MILESTONE-1.md added the
  shapes Compilerpedia's `task.string-concatenation` documents
  (`tail-join-list`, `tail-char-concat`) and the one it warns about
  (`tail-append-char`).

      tclsh9.0 audit/text-collection-precision/tools/bench.tcl -sizes "250 1000 4000" -markdown
      tclsh9.0 audit/text-collection-precision/tools/bench.tcl -sizes "4000 16000 64000" -backends cranelift -markdown

The native backends need `cargo build --release --manifest-path
native/Cargo.toml` first.
