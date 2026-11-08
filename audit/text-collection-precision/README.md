# Text and collection precision: probes and tools

The material of `docs/TEXT-AND-COLLECTION-PRECISION-CENSUS.md`. Nothing here
is loaded by the compiler or run by CI; it records today's behavior so that a
follow-up milestone can show what it changed.

* `probes/*.bot` -- eighteen minimal programs. Each states its expected
  outcome in its leading comments (`# outcome:`, `# value:`,
  `# diagnostic: L:C TEXT`, `# error:`, `# binding: L NAME TYPE`). A
  milestone that changes a probe's outcome updates its expectation in the
  same change.
* `tools/probes.tcl` -- runs every probe (or the ones named): `main.tcl
  -check`, each accepted or run-time-failing probe on interp, compile,
  cranelift and cranelift-generic (`-backends` narrows), and the binding
  checks through the compiler service. Exit status 1 on any difference.

      tclsh9.0 audit/text-collection-precision/tools/probes.tcl

* `tools/matrix.py` -- the census's section H table: the checker's static
  type of twelve operations' results over six element types, read from TYPE
  diagnostics of generated programs (written to a temporary directory).

      python3 -I audit/text-collection-precision/tools/matrix.py

* `tools/bench.tcl` -- section G's text-construction strategies at chosen
  sizes and backends: time and (natively) String bytes copied.

      tclsh9.0 audit/text-collection-precision/tools/bench.tcl -sizes "250 1000 4000" -markdown
      tclsh9.0 audit/text-collection-precision/tools/bench.tcl -sizes "4000 16000 64000" -backends cranelift -markdown

The native backends need `cargo build --release --manifest-path
native/Cargo.toml` first.
