# Proof/fact census: probes, tools and outputs

Report: `/PROOF-FACT-CENSUS.md`. Observation only, except the three narrow
soundness fixes the report describes (commit "Fix three proof soundness bugs
found by the proof-fact census"). Run from the repository root with Tcl 9.0.1,
`LANG=C.utf8 LC_ALL=C.utf8`, and the release native backend built
(`cargo build --release --manifest-path native/Cargo.toml`).

| tool | purpose |
|---|---|
| `tools/census.tcl ?-nir? PROGRAM.bot...` | per program: static diagnostics (`-strict 0`), every call of an error-declaring callee with its declared errors, the `effectiveErrors`/`mayReturnNormally` the completion proof stored on the HIR node, each argument's `hir::range` fact per specialization instance, and (`-nir`) the NIR emitted for that call |
| `tools/values.tcl ?-root DIR? PROGRAM.bot...` | each program's outcome on interp, compile, cranelift and cranelift-generic, strict and `-strict 0`; `-root` loads another checkout's compiler (the "before" column) |
| `tools/compiletime.tcl PROGRAM.bot...` | median front-end time and a re-run of each proof pass alone: `hir::errorsets::verify`, `hir::specialize::analyze`, `hir::range::analyze` |
| `tools/regioncheck-experiment.sh ?RUNS?` | deletes the one proven-redundant `op regioncheck` from `bench/refined-checks.bot`'s NIR and times both NIR files with the native driver (no compiler change) |

`native/explain-native.tcl PROGRAM OUTDIR` (existing) gives the per-instance
range facts, induction provenance, raw-ABI plan, NIR and CLIF the journeys in
the report quote.

Probes (`probes/`), one transfer edge each; the letter matches the report's
proof journeys and sections:

| probe | edge |
|---|---|
| `a-counted-loop-at` | counted loop `0..list::length(xs)` reading `list::at` (journey A) |
| `b-mutarray-capacity` | `mutable_array::set`/`at` to `capacity(a)` and to the allocation size (B) |
| `c-slice` | `str::substring` under a conjunctive guard; `LowerUnderrun`/`UpperOverrun` separately (C) |
| `d-early-return` | `if i < 0 or i >= list::length(xs): return` then `list::at` (D) |
| `e-struct-domain-projection` | `abi::U8` field domain into `byte::from_int` (E) |
| `f-closed-abi-u64`, `f2-closed-int-vs-struct` | exact constant through a closed call: Int parameter vs struct field (F) |
| `g-induction-declared-param`, `h-recursive-slice` | recursion: `==` vs `>=` guards, induction, `string_reverse`'s shape (G, H) |
| `i-get-in-counted-loop` | `list::get` in a proven loop (I) |
| `k-method-spelling`, `k2-bound-name-spelling` | method spelling vs qualified vs bound-name spelling |
| `l-loop-forms`, `q-countloop-interval` | every numeric loop form, lockstep; the loop variable's interval |
| `m-listloop-checked` | `loop x in xs` element access |
| `n-call-specific-transport` | actual-argument facts into a callee's call-specific walk |
| `o-lowercase-length` | soundness of the `str::lowercase` length rule |
| `p-param-inference-narrowing` | parameter contract inference vs branch narrowing |
| `r-return-facts`, `s-struct-facts`, `u-handler-exit` | return, struct and handled-call value transport |
| `t-relational-prover-pairs` | the two relational provers; alias keying |
| `v-allocate-size` | a successful `allocate(n)` does not make `n >= 0` known |
| `z-soundness-neighbours` | eight minimal unsound neighbours that must stay rejected |
| `sound-a-*`, `sound-b-*`, `sound-c-*` | the three soundness bugs (and the control for B) |

`out/` holds the committed results: `census.txt` (all probes, `-nir`, after the
fixes), `values.txt` (all non-soundness probes), `soundness-values.txt` (the
soundness probes with the parent commit's compiler and with the fixes),
`bench.md` (two runs of the core benchmark set), `regioncheck-experiment.txt`
and `compiletime.txt`.
