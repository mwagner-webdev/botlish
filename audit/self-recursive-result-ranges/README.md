# Self-recursive result Ranges: audit tools and artifacts

Report: `/SELF-RECURSIVE-RESULT-RANGES.md`. Observation only; nothing here
changes the compiler. Run from the repository root with Tcl 9.0.1 and the
release native backend built (`cargo build --release --manifest-path
native/Cargo.toml`); `LANG=C.utf8 LC_ALL=C.utf8`.

| tool | purpose |
|---|---|
| `tools/census.tcl PROGRAM.bot...` | self-recursive instances per program: solved/rejected + reason + result before/after, and whether the NIR differs with `-recursive-result-range-opt 0` vs `1` |
| `tools/asm.tcl PROGRAM.bot OPT PREFIX` | NIR, GC-root report and disassembly with the analysis off (0) / on (1); prints per-function code bytes |
| `tools/compiletime.tcl ?-n N? ?-opt 0\|1? PROGRAM.bot...` | median compile-time phases (adapted from `audit/exact-callable`) |
| `tools/budget.tcl ?-reps N? ?-widths "..."? ?-limit N?` | state-budget scaling: analysis time off/on, state count, precision, fits-small |
| `tools/fuzz.tcl ?-n N? ?-seed S?` | randomized soundness check against the reference interpreter |
| `native/explain-native.tcl PROGRAM OUTDIR` | writes `recursive-ranges.txt` (proof or rejection reason, with the state trace) next to the other explain outputs |

`out/` holds the committed results: `census.txt`, `compiletime.txt`,
`budget.txt`, `fuzz.txt`, and `fib/` (NIR, assembly, GC-root report and
callgrind census/mix with the analysis off (`opt0`) and on (`opt1`)). The
callgrind profiles use `audit/post-r2a-dynamic-census/tools/{build-audit-
native,profile-nir}.sh` unchanged (21 runs, run 0 excluded).
