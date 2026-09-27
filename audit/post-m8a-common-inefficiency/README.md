# Post-M8.a common-inefficiency census: artifacts

Raw data for
[POST-M8A-COMMON-INEFFICIENCY-CENSUS.md](../../POST-M8A-COMMON-INEFFICIENCY-CENSUS.md).
Nothing here is a build product or a production change: every tool is
observation-only, and the one piece of instrumentation (`tools/audit-native.patch`)
is applied to a *scratch copy* of `native/`, never to the tree.

| path | contents |
|---|---|
| `baseline/` | `environment.txt`; `bench-session-{1..5}.md` (five independent runs of the canonical `tclsh9.0 bench/bench.tcl -runs 5 -markdown`); `summary.md` (median/min/max per program and backend); `variants.txt` (native-only: M8.a on, `-virtual-construction-opt 0`, `-specialize 0`; 5 sessions x best of 5 and of 200 runs) |
| `static/<program>/probe/` | `audit/comprehensive-generated-code/tools/probe.tcl` output on the current tree: NIR, per-instance specialization, parameter entry ranges, call facts, completion facts, call effects, GC-root report, object-file disassembly, per-function op counts |
| `static/<program>/construction/` | `audit/m8a-virtual-construction/tools/census.tcl` output: construction sites/barriers, per-function code size with M8.a off/on, allocation reports off/on, the product-shaped List census |
| `dynamic/alloc-<program>.txt` | `native::allocationReport` per program (first run with allocation sites, steady state): per-kind counts/bytes, semantic vs private plan objects, GC, copies, UTF-8 seek bytes, construction counters |
| `dynamic/class-matrix.md` | executed-instruction classes x workloads (canonical, the ASCII probe, three supplemental workloads) |
| `profiles/<program>/{cranelift,vc-off,generic}/` | callgrind profiles of the timed runs: `program.nir`, `jitmap.txt` (JIT function ranges and code bytes), `callgrind.out`, `profile.txt` (per-function exclusive cost, Botlish->Botlish and Botlish->helper call counts with inclusive cost), `instr.txt` (every executed JIT instruction with its execution count and class), `mix.txt` (executed instruction mix per function), `moves.txt` (dead/redundant/by-purpose register moves), `static-mix.txt` (the same classes, unweighted: static code) |
| `profiles/probes/refined-checks-ascii/` | the same for `probes/refined-checks-ascii.ir` |
| `profiles/supplemental/` | the same for supplemental workloads (supporting evidence only): `uri-steady`, `ai_text_clean` 10K ascii/emoji, `csv` 1000 rows, `string_reverse` 10K |
| `probes/refined-checks-ascii.ir` | `bench/refined-checks.ir` with its one non-ASCII address replaced by an ASCII address of identical per-character control flow (the non-ASCII counterfactual) |
| `candidate-matrix.md` | every candidate x workload estimate, with its per-instruction derivation |
| `tools/` | everything that produced the above (below) |

Tools:

| tool | what |
|---|---|
| `tools/baseline.sh OUTDIR [SESSIONS]` | the canonical timing baseline + `variants.tcl` |
| `tools/variants.tcl [SESSIONS] [RUNS...]` | native-only timing under the census configurations |
| `tools/build-audit-native.sh WORKDIR` | copies `native/` to WORKDIR, applies `audit-native.patch`, builds there; prints the binary path |
| `tools/audit-native.patch` | audit-only: a named, never-inlined `botlish_audit_run` frame around each timed run (the callgrind `--toggle-collect` anchor, so JIT compilation and between-run `Vm::reset` are excluded) and an env-gated (`BOTLISH_AUDIT_JITMAP`), compile-time-only dump of every JIT function's address range and bytes. No generated code and no runtime helper changes: machine-code sizes and values were verified identical to the production binary for all four programs |
| `tools/emit-nir.tcl`, `tools/emit-supplemental-nir.tcl` | the NIR `bench.tcl` (resp. the M8.a workload driver) would run |
| `tools/profile.sh`, `tools/profile-all.sh` | callgrind (`--dump-instr=yes --cache-sim=yes --branch-sim=yes --toggle-collect=botlish_audit_run`) + `cgprof.py` |
| `tools/cgprof.py` | callgrind parser: attributes JIT code by address (via the jitmap), counts calls, classifies every executed JIT instruction |
| `tools/moves.py` | dead / redundant / by-purpose register-move census (block-local, conservative) |
| `tools/static-mix.py` | static (unweighted) per-function machine-code census with the same classes |
| `tools/class-matrix.py` | the workloads x classes table |
| `tools/alloc.tcl` | allocation census per program |

Reproduce (Linux, `LANG=C.utf8 LC_ALL=C.utf8`, Tcl 9.0.1, release `native/`,
valgrind 3.22):

```sh
bash audit/post-m8a-common-inefficiency/tools/baseline.sh audit/post-m8a-common-inefficiency/baseline 5
AB=$(bash audit/post-m8a-common-inefficiency/tools/build-audit-native.sh /tmp/auditbuild | tail -1)
bash audit/post-m8a-common-inefficiency/tools/profile-all.sh "$AB" audit/post-m8a-common-inefficiency/profiles
bash audit/post-m8a-common-inefficiency/tools/profile.sh "$AB" audit/post-m8a-common-inefficiency/probes/refined-checks-ascii.ir 20 \
    audit/post-m8a-common-inefficiency/profiles/probes/refined-checks-ascii
for w in "uri-steady 5" "ai_text_clean-ascii-10K 5" "ai_text_clean-emoji-10K 5" "csv-1000 3" "string_reverse-10K 5"; do
    set -- $w; bash audit/post-m8a-common-inefficiency/tools/profile.sh "$AB" supplemental:$1 $2 \
        audit/post-m8a-common-inefficiency/profiles/supplemental/$1
done
for p in fib loop-count sum-refined refined-checks; do
    tclsh9.0 audit/comprehensive-generated-code/tools/probe.tcl bench/$p.ir audit/post-m8a-common-inefficiency/static/$p/probe
    tclsh9.0 audit/m8a-virtual-construction/tools/census.tcl bench/$p.ir audit/post-m8a-common-inefficiency/static/$p/construction
    tclsh9.0 audit/post-m8a-common-inefficiency/tools/alloc.tcl bench/$p.ir audit/post-m8a-common-inefficiency/dynamic/alloc-$p.txt
    python3 audit/post-m8a-common-inefficiency/tools/moves.py audit/post-m8a-common-inefficiency/profiles/$p/cranelift
    python3 audit/post-m8a-common-inefficiency/tools/static-mix.py audit/post-m8a-common-inefficiency/profiles/$p/cranelift
done
```

Instruction counts, call counts, allocation and copy counters are
deterministic (identical across reruns). Timings were taken on a shared
4-vCPU cloud container and are noisy (see the report's timing section);
no conclusion in the report rests on a timing difference alone.
