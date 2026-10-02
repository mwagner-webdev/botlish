# One-allocation String audit (STRING-ALLOCATION.md)

Observation-only tools and their measured output. Nothing here changes a plan or
a lowering. Run everything with `LANG=C.utf8 LC_ALL=C.utf8`; the Python tools
need `valgrind` and `python3`, the Tcl tools `tclsh9.0`.

The comparisons are *old runtime versus new runtime on byte-identical NIR*: the
String storage change is below NIR, so `emit-nir.tcl` run in a checkout of the
parent commit and in this tree emits identical text (verified: 68/68 files), and
both drivers then execute exactly the same programs.

| tool | what it measures | output |
|---|---|---|
| `tools/emit-nir.tcl ROOT OUT` | the corpus NIR under four short-String configurations, from the checkout at ROOT | input of the others |
| `tools/materialize.py OLD NEW OUT` | cost of one runtime String materialization (`shorttostr` / `asciitostr`): allocation side, free side, churn life cycle, exclusive-Ir breakdown, malloc/free calls | `out/materialize.json` |
| `tools/constructors.py OLD NEW OUT` | the same, per general constructor (concat, substring, lowercase, decode, flat construct) | `out/constructors.json` |
| `tools/ir.py OLD NEW NIRDIR OUT` | callgrind Ir per steady-state run and per between-run reset, plus malloc/free calls, over the corpus x four configurations | `out/ir-raw/ir.json` |
| `tools/census.py OLD-CENSUS NEW NIRDIR` | String objects, heap allocations, text-buffer allocations/frees, frees, bytes, empty reuses | `out/census.md` |
| `tools/codesize.py OLD NEW NIRDIR` | whole-program machine code and driver section sizes | `out/codesize.txt` |
| `tools/compiletime.py OLD NEW NIRDIR` | Cranelift compile time | `out/compiletime.txt` |
| `tools/fuzz-general.tcl ?-n N? ?-seed S? ?-generic 1?` | differential fuzzing of general String construction (interpreter, compile backend, native x switches; run under `BOTLISH_NATIVE_GC_STRESS=1` for stress) | `out/fuzz-*.txt` |
| `tools/report.py IR MATERIALIZE CONSTRUCTORS` | renders the JSON as the report's Markdown tables | `out/tables.md` |
| `tools/cgsum.py` | callgrind output reducer used by the above | |
| `tools/old-census.patch` | patch for the parent commit's runtime that counts the old text buffers exactly (the "before" column of the census) | |
| `programs/large-string.bot` | large-String control (doubling to ~2.5 MB, rotate, churn) | |

`OLD`/`NEW` for the Python tools are audit-only builds (a never-inlined frame the
callgrind `--toggle-collect` anchors on; no code is added to any runtime helper),
built in each tree by
`bash audit/post-r2a-dynamic-census/tools/build-audit-native.sh WORKDIR` from the
repository root of that tree (the root `.cargo/config.toml` forces frame
pointers, which the stack-map GC walker needs).
