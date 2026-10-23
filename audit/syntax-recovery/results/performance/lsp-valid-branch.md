# Language server benchmark

2026-10-23, Tcl 9.0.1, 4 processors; 20 edits per session every 150-300 ms, 20 idle hovers; seed 7.

## Hover latency (ms) while editing, and once idle

| workload | scheduler | editing: median | p95 | p99 | max | idle: median | p95 | max |
|---|---|---:|---:|---:|---:|---:|---:|---:|
| csv | worker | 3 | 7 | 8 | 8 | 2 | 3 | 5 |
| csv | sync | 3 | 110 | 197 | 197 | 2 | 3 | 10 |
| 2048 | worker | 3 | 5 | 104 | 104 | 2 | 3 | 14 |
| 2048 | sync | 757 | 1894 | 1904 | 1904 | 2 | 3 | 42 |
| icy | worker | 3 | 5 | 12 | 12 | 2 | 3 | 4 |
| icy | sync | 1722 | 2940 | 2990 | 2990 | 2 | 5 | 33 |
| 2048-golden | worker | 3 | 6 | 13 | 13 | 2 | 3 | 11 |
| 2048-golden | sync | 5275 | 7184 | 7185 | 7185 | 2 | 2 | 118 |

## Diagnostics, event loop and analysis work

| workload | scheduler | first diagnostics (ms) | last edit to its diagnostics (ms) | longest callback (ms) | analyses run | killed (ms of their work) | intermediate versions published |
|---|---|---:|---:|---:|---:|---:|---:|
| csv | worker | 414 | 566 | 42 (warm) | 8 of 8 submitted | 0 (0) | 1 |
| csv | sync | 399 | 550 | 326 (analysis csv.bot) | 5 of 5 submitted | 0 (0) | 4 |
| 2048 | worker | 2199 | 2217 | 131 (worker message) | 2 of 9 submitted | 6 (3755) | 1 |
| 2048 | sync | 1778 | 2097 | 1976 (analysis demo.bot) | 4 of 5 submitted | 0 (0) | 3 |
| icy | worker | 3354 | 3193 | 41 (worker message) | 2 of 7 submitted | 4 (3278) | 1 |
| icy | sync | 2909 | 6677 | 3787 (analysis headless.bot) | 4 of 5 submitted | 0 (0) | 3 |
| 2048-golden | worker | 8068 | 8840 | 158 (worker message) | 2 of 10 submitted | 7 (2556) | 1 |
| 2048-golden | sync | 8371 | 12465 | 8561 (analysis golden.bot) | 3 of 4 submitted | 0 (0) | 2 |

## Worker, transfer and memory

| workload | scheduler | server start (ms) | worker starts | worker start to hello (ms, mean) | analysis in the worker (ms, mean) | indexes and export in the worker (ms, mean) | import (ms, mean) | transferred (KiB, mean) | server RSS max (MiB) | worker RSS max (MiB) | processes |
|---|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| csv | worker | 82 | 1 | 73 | 224 | 20 | 9.4 | 277 | 30 | 29 | 2 |
| csv | sync | 114 | 0 | - | - | - | - | - | 34 | - | 1 |
| 2048 | worker | 88 | 7 | 85 | 1690 | 126 | 64.1 | 1873 | 85 | 79 | 2 |
| 2048 | sync | 110 | 0 | - | - | - | - | - | 97 | - | 1 |
| icy | worker | 88 | 5 | 83 | 2892 | 86 | 24.8 | 846 | 49 | 67 | 2 |
| icy | sync | 77 | 0 | - | - | - | - | - | 79 | - | 1 |
| 2048-golden | worker | 97 | 8 | 87 | 7744 | 231 | 90.2 | 3106 | 130 | 167 | 2 |
| 2048-golden | sync | 72 | 0 | - | - | - | - | - | 208 | - | 1 |

## Equivalence

* csv: final diagnostics identical, idle hover answers identical, exit statuses 0
* 2048: final diagnostics identical, idle hover answers identical, exit statuses 0
* icy: final diagnostics identical, idle hover answers identical, exit statuses 0
* 2048-golden: final diagnostics identical, idle hover answers identical, exit statuses 0
