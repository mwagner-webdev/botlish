# Language server benchmark

2026-10-23, Tcl 9.0.1, 4 processors; 40 edits per session every 150-300 ms, 20 idle hovers; seed 7.

## Hover latency (ms) while editing, and once idle

| workload | scheduler | editing: median | p95 | p99 | max | idle: median | p95 | max |
|---|---|---:|---:|---:|---:|---:|---:|---:|
| csv | worker | 3 | 8 | 14 | 14 | 2 | 3 | 5 |
| csv | sync | 3 | 168 | 269 | 269 | 1 | 2 | 7 |
| 2048 | worker | 3 | 5 | 94 | 94 | 2 | 2 | 14 |
| 2048 | sync | 241 | 1421 | 1599 | 1599 | 2 | 3 | 46 |
| icy | worker | 3 | 8 | 66 | 66 | 2 | 2 | 4 |
| icy | sync | 6 | 805 | 965 | 965 | 2 | 4 | 34 |
| 2048-golden | worker | 3 | 5 | 20 | 20 | 2 | 3 | 11 |
| 2048-golden | sync | 3586 | 7328 | 7415 | 7415 | 2 | 4 | 131 |

## Diagnostics, event loop and analysis work

| workload | scheduler | first diagnostics (ms) | last edit to its diagnostics (ms) | longest callback (ms) | analyses run | killed (ms of their work) | intermediate versions published |
|---|---|---:|---:|---:|---:|---:|---:|
| csv | worker | 411 | 544 | 53 (warm) | 11 of 11 submitted | 0 (0) | 1 |
| csv | sync | 297 | 436 | 315 (analysis csv.bot) | 13 of 13 submitted | 0 (0) | 12 |
| 2048 | worker | 1882 | 2017 | 116 (worker message) | 2 of 16 submitted | 13 (7056) | 1 |
| 2048 | sync | 1825 | 2508 | 1762 (analysis demo.bot) | 6 of 7 submitted | 0 (0) | 5 |
| icy | worker | 1173 | 1453 | 61 (worker message) | 4 of 13 submitted | 8 (3602) | 1 |
| icy | sync | 990 | 1632 | 1015 (analysis headless.bot) | 7 of 8 submitted | 0 (0) | 6 |
| 2048-golden | worker | 8350 | 7934 | 206 (worker message) | 2 of 11 submitted | 8 (7912) | 1 |
| 2048-golden | sync | 7705 | 16083 | 8606 (analysis golden.bot) | 4 of 5 submitted | 0 (0) | 3 |

## Worker, transfer and memory

| workload | scheduler | server start (ms) | worker starts | worker start to hello (ms, mean) | analysis in the worker (ms, mean) | indexes and export in the worker (ms, mean) | import (ms, mean) | transferred (KiB, mean) | server RSS max (MiB) | worker RSS max (MiB) | processes |
|---|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| csv | worker | 102 | 1 | 82 | 220 | 20 | 9.0 | 276 | 30 | 28 | 2 |
| csv | sync | 87 | 0 | - | - | - | - | - | 34 | - | 1 |
| 2048 | worker | 77 | 14 | 80 | 1477 | 97 | 68.7 | 1870 | 84 | 79 | 2 |
| 2048 | sync | 86 | 0 | - | - | - | - | - | 97 | - | 1 |
| icy | worker | 75 | 9 | 84 | 866 | 78 | 28.3 | 910 | 57 | 56 | 2 |
| icy | sync | 73 | 0 | - | - | - | - | - | 72 | - | 1 |
| 2048-golden | worker | 71 | 9 | 94 | 7410 | 242 | 106.5 | 3138 | 138 | 175 | 2 |
| 2048-golden | sync | 77 | 0 | - | - | - | - | - | 212 | - | 1 |

## Worker crash recovery

| workload | crash reported after (ms) | next edit to its diagnostics (ms) | workers started | exit |
|---|---:|---:|---:|---:|
| csv | 258 | 585 | 2 | 0 |
| 2048 | 264 | 2171 | 2 | 0 |
| icy | 262 | 1149 | 2 | 0 |
| 2048-golden | 273 | 8431 | 2 | 0 |

## Memory over a long session (MiB resident after each round: server / worker)

| workload | scheduler | round 1 | round 10 | round 20 | round 30 | round 40 | max |
|---|---|---:|---:|---:|---:|---:|---:|
| csv | worker | 27/28 | 30/28 | 30/28 | 29/28 | 30/28 | 30 / 28 |
| csv | sync | 33/- | 34/- | 34/- | 34/- | 34/- | 34 / - |
| 2048 | worker | 78/87 | 97/87 | 97/79 | 97/79 | 97/87 | 97 / 87 |
| 2048 | sync | 94/- | 97/- | 97/- | 98/- | 98/- | 98 / - |
| icy | worker | 49/58 | 56/59 | 56/59 | 56/59 | 56/59 | 56 / 62 |
| icy | sync | 68/- | 71/- | 71/- | 71/- | 71/- | 71 / - |
| 2048-golden | worker | 124/173 | 156/175 | 156/175 | 158/175 | 158/175 | 158 / 175 |
| 2048-golden | sync | 206/- | 211/- | 211/- | 211/- | 211/- | 211 / - |

## Equivalence

* csv: final diagnostics identical, idle hover answers identical, exit statuses 0
* 2048: final diagnostics identical, idle hover answers identical, exit statuses 0
* icy: final diagnostics identical, idle hover answers identical, exit statuses 0
* 2048-golden: final diagnostics identical, idle hover answers identical, exit statuses 0
