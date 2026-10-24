# Language server benchmark

2026-10-23, Tcl 9.0.1, 4 processors; 20 edits per session every 150-300 ms, every other one a syntax error (-malformed 1), 20 idle hovers; seed 7.

## Hover latency (ms) while editing, and once idle

| workload | scheduler | editing: median | p95 | p99 | max | idle: median | p95 | max |
|---|---|---:|---:|---:|---:|---:|---:|---:|
| csv | worker | 3 | 5 | 8 | 8 | 2 | 3 | 4 |
| csv | sync | 3 | 99 | 261 | 261 | 2 | 3 | 6 |
| 2048 | worker | 3 | 8 | 87 | 87 | 2 | 2 | 13 |
| 2048 | sync | 747 | 1961 | 1968 | 1968 | 1 | 2 | 41 |
| icy | worker | 3 | 7 | 7 | 7 | 2 | 4 | 4 |
| icy | sync | 1609 | 3013 | 3149 | 3149 | 2 | 3 | 39 |
| 2048-golden | worker | 3 | 6 | 14 | 14 | 2 | 3 | 20 |
| 2048-golden | sync | 5841 | 7749 | 7751 | 7751 | 2 | 3 | 146 |

## Diagnostics, event loop and analysis work

| workload | scheduler | first diagnostics (ms) | last edit to its diagnostics (ms) | longest callback (ms) | analyses run | killed (ms of their work) | intermediate versions published |
|---|---|---:|---:|---:|---:|---:|---:|
| csv | worker | 436 | 480 | 66 (warm) | 8 of 8 submitted | 0 (0) | 1 |
| csv | sync | 362 | 459 | 363 (analysis csv.bot) | 5 of 5 submitted | 0 (0) | 4 |
| 2048 | worker | 2199 | 2735 | 110 (worker message) | 3 of 9 submitted | 5 (2344) | 1 |
| 2048 | sync | 1762 | 2849 | 2048 (analysis demo.bot) | 5 of 6 submitted | 0 (0) | 4 |
| icy | worker | 3213 | 3486 | 54 (worker message) | 2 of 7 submitted | 4 (3251) | 1 |
| icy | sync | 3108 | 6109 | 3271 (analysis headless.bot) | 4 of 5 submitted | 0 (0) | 3 |
| 2048-golden | worker | 8323 | 8494 | 166 (worker message) | 2 of 10 submitted | 7 (2543) | 1 |
| 2048-golden | sync | 8230 | 12873 | 8403 (analysis golden.bot) | 3 of 4 submitted | 0 (0) | 2 |

## Worker, transfer and memory

| workload | scheduler | server start (ms) | worker starts | worker start to hello (ms, mean) | analysis in the worker (ms, mean) | indexes and export in the worker (ms, mean) | import (ms, mean) | transferred (KiB, mean) | server RSS max (MiB) | worker RSS max (MiB) | processes |
|---|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| csv | worker | 87 | 1 | 88 | 215 | 35 | 7.7 | 276 | 33 | 30 | 2 |
| csv | sync | 78 | 0 | - | - | - | - | - | 56 | - | 1 |
| 2048 | worker | 113 | 6 | 85 | 1703 | 149 | 52.5 | 1606 | 96 | 79 | 2 |
| 2048 | sync | 80 | 0 | - | - | - | - | - | 130 | - | 1 |
| icy | worker | 75 | 5 | 87 | 2954 | 90 | 31.4 | 846 | 50 | 68 | 2 |
| icy | sync | 128 | 0 | - | - | - | - | - | 107 | - | 1 |
| 2048-golden | worker | 83 | 8 | 91 | 7656 | 268 | 85.2 | 3106 | 134 | 167 | 2 |
| 2048-golden | sync | 121 | 0 | - | - | - | - | - | 208 | - | 1 |

## Worker crash recovery

| workload | crash reported after (ms) | next edit to its diagnostics (ms) | workers started | exit |
|---|---:|---:|---:|---:|
| csv | 260 | 645 | 2 | 0 |
| 2048 | 271 | 2672 | 2 | 0 |
| icy | 268 | 2906 | 2 | 0 |
| 2048-golden | 282 | 8165 | 2 | 0 |

## Equivalence

* csv: final diagnostics identical, idle hover answers identical, exit statuses 0
* 2048: final diagnostics identical, idle hover answers identical, exit statuses 0
* icy: final diagnostics identical, idle hover answers identical, exit statuses 0
* 2048-golden: final diagnostics identical, idle hover answers identical, exit statuses 0
