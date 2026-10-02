# ShortString1 audit (SHORT-STRING.md)

Observation-only tools and their measured output. Nothing here changes a plan
or a lowering. Run everything with `LANG=C.utf8 LC_ALL=C.utf8 tclsh9.0`.

| tool | what it measures | output |
|---|---|---|
| `tools/corpus.tcl` | corpus values off/on (native), static short-op counts, machine-code bytes | `out/corpus.txt` |
| `tools/census.tcl ?-detail?` | virtualization census (positions, proven, selected, Empty/One/maybe), lowering frontier counters, static conversion counts, materialization classes, zero/one/many materializations, fixpoint rounds | `out/census.txt` |
| `tools/explain.tcl OUTDIR` | the audit text (`native::shortstr::explainAll`) per corpus program: proven length, eligibility, representation, production, uses, rejection reasons | `out/explain/*.txt` |
| `tools/codesize.tcl` | whole-program machine code off/on, determinism check | `out/codesize.txt` |
| `tools/roots.tcl` | safepoints / root candidates / root slots off/on | `out/roots.txt` |
| `tools/compiletime.tcl` | planner, NIR (off/on) and total compile time, median of N | `out/compiletime.txt` |
| `tools/nativebench.tcl` | wall-clock (`botlish-native bench`) off/on; tiny kernels are placement/noise sensitive | `out/nativebench.txt` |
| `tools/ir.tcl BIN BASE-BIN BASE-NIR-DIR OUTDIR` | callgrind Ir per steady-state run: `base` (parent commit), `off`, `on` | `out/ir.txt` |
| `tools/emit-base-nir.tcl OUTDIR` | the NIR a *parent checkout* emits for the corpus (run it inside a checkout of the parent) | input of `ir.tcl` |
| `tools/fuzz.tcl ?-n N? ?-seed S? ?-generic 1? ?-dump 1?` | bounded differential fuzzing: interpreter, compile backend, native off/on x leaf inlining 0/1 (and `-specialize 0`) for values, errors and completion behavior; run under `BOTLISH_NATIVE_GC_STRESS=1` for GC stress | `out/fuzz*.txt` |

`ir.tcl` needs audit-only builds of `botlish-native` (a never-inlined frame the
callgrind `--toggle-collect` anchors on; no code is added to generated
functions): `bash audit/post-r2a-dynamic-census/tools/build-audit-native.sh WORKDIR`
in this tree for `BIN`, and the same script run from a checkout of the parent
commit for `BASE-BIN`.

The generic-entry wrapper of a ShortString1-ABI function can never run from a
Botlish program; it is exercised by the Rust tests in
`native/src/codegen/mod.rs` (`short_string_generic_entry_tests`).
