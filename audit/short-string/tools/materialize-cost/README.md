# Cost of one runtime ShortString1 materialization

`bN.nir` loops N times: `%3 = op shorttostr %1` (U+0061) then `strlen`.
`cN.nir` is the same loop with a constant `str "a"` instead (the control).
Per-iteration cost = (Ir(b40) - Ir(b20)) / 20000 - (Ir(c40) - Ir(c20)) / 20000,
function by function (`callgrind_annotate --auto=no`, exclusive Ir):

    valgrind --tool=callgrind --callgrind-out-file=b20.cg native/target/release/botlish-native run b20.nir

This measures the whole life cycle (allocation *and* the eventual GC free) in a
pure-churn heap. The corpus figure (about 312 instructions) is the program
delta of `refined-checks` with and without the materializations
(`audit/short-string/out/ir-demand.txt`, `nd` against `new`), where no
collection runs inside the measured window, so it contains the allocation side
only. Results: SHORT-STRING-TIERS.md, "Cost of a materialization".
