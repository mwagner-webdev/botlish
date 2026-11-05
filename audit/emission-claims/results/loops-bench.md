# Counted-loop entry: the checker's costs

`tclsh9.0 audit/emission-claims/tools/loops-bench.tcl -runs 5` (EMISSION-COUNTED-LOOP-PRECISION-MILESTONE-1.md, section 15), on the 4-core container: each scenario a fresh process, the certificate memo off, times the median of 5. `before` is the rule before that milestone, in the same compiler (hir::emission::Entered answering 0); `selective-peeled` the selective field with its first character written before the loop (the former spelling), `selective-loop` the shipped one; `loops` tests/emission-claims.test's ec-loop-entered-guards.

| workload | rule | claims proven | check ms (median) | of it: certificates ms | summaries computed / reused | rounds | loop evaluations | loop walks |
|---|---|---:|---:|---:|---:|---:|---:|---:|
| csv | before | 49 / 52 | 694.935 | 51.39 | 212 / 152 | 104 | 56 | 104 |
| csv | current | 52 / 52 | 664.709 | 48.09 | 207 / 121 | 104 | 44 | 80 |
| json | before | 22 / 22 | 243.657 | 34.229 | 140 / 60 | 44 | 32 | 48 |
| json | current | 22 / 22 | 246.94 | 32.967 | 140 / 60 | 44 | 32 | 48 |
| selective-peeled | before | 40 / 40 | 514.307 | 41.795 | 164 / 98 | 80 | 44 | 80 |
| selective-peeled | current | 40 / 40 | 499.438 | 39.026 | 164 / 98 | 80 | 44 | 80 |
| selective-loop | before | 38 / 40 | 537.471 | 39.326 | 170 / 128 | 80 | 56 | 104 |
| selective-loop | current | 40 / 40 | 508.85 | 38.107 | 164 / 98 | 80 | 44 | 80 |
| loops | before | 0 / 12 | 15.581 | 0.0 | 26 / 0 | 24 | 24 | 48 |
| loops | current | 8 / 12 | 27.252 | 10.636 | 26 / 0 | 24 | 24 | 48 |
