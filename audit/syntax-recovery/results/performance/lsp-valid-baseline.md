# Language server benchmark

2026-10-23, Tcl 9.0.1, 4 processors; 20 edits per session every 150-300 ms, 20 idle hovers; seed 7.

## Hover latency (ms) while editing, and once idle

| workload | scheduler | editing: median | p95 | p99 | max | idle: median | p95 | max |
|---|---|---:|---:|---:|---:|---:|---:|---:|
| csv | worker | 3 | 5 | 8 | 8 | 2 | 3 | 4 |
| csv | sync | 3 | 103 | 172 | 172 | 2 | 2 | 16 |
| 2048 | worker | 3 | 6 | 83 | 83 | 2 | 4 | 15 |
| 2048 | sync | 310 | 1282 | 1414 | 1414 | 3 | 4 | 64 |
| icy | worker | 3 | 7 | 8 | 8 | 1 | 3 | 4 |
| icy | sync | 1770 | 4111 | 4284 | 4284 | 3 | 4 | 53 |
| 2048-golden | worker | 3 | 6 | 12 | 12 | 1 | 2 | 11 |
| 2048-golden | sync | 6301 | 8208 | 8210 | 8210 | 3 | 4 | 173 |

## Diagnostics, event loop and analysis work

| workload | scheduler | first diagnostics (ms) | last edit to its diagnostics (ms) | longest callback (ms) | analyses run | killed (ms of their work) | intermediate versions published |
|---|---|---:|---:|---:|---:|---:|---:|
| csv | worker | 437 | 594 | 68 (warm) | 8 of 8 submitted | 0 (0) | 1 |
| csv | sync | 333 | 485 | 297 (analysis csv.bot) | 5 of 5 submitted | 0 (0) | 4 |
| 2048 | worker | 2086 | 2423 | 122 (worker message) | 2 of 9 submitted | 6 (3693) | 1 |
| 2048 | sync | 1762 | 2091 | 1840 (analysis demo.bot) | 4 of 5 submitted | 0 (0) | 3 |
| icy | worker | 3334 | 3464 | 41 (worker message) | 2 of 7 submitted | 4 (3258) | 1 |
| icy | sync | 3062 | 8156 | 4297 (analysis headless.bot) | 4 of 5 submitted | 0 (0) | 3 |
| 2048-golden | worker | 8299 | 9153 | 159 (worker message) | 2 of 10 submitted | 7 (2559) | 1 |
| 2048-golden | sync | 7786 | 15121 | 10194 (analysis golden.bot) | 3 of 4 submitted | 0 (0) | 2 |

## Worker, transfer and memory

| workload | scheduler | server start (ms) | worker starts | worker start to hello (ms, mean) | analysis in the worker (ms, mean) | indexes and export in the worker (ms, mean) | import (ms, mean) | transferred (KiB, mean) | server RSS max (MiB) | worker RSS max (MiB) | processes |
|---|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| csv | worker | 90 | 1 | 92 | 234 | 24 | 8.3 | 278 | 30 | 29 | 2 |
| csv | sync | 87 | 0 | - | - | - | - | - | 34 | - | 1 |
| 2048 | worker | 82 | 7 | 96 | 1752 | 114 | 63.7 | 1877 | 83 | 79 | 2 |
| 2048 | sync | 82 | 0 | - | - | - | - | - | 97 | - | 1 |
| icy | worker | 90 | 5 | 83 | 3020 | 90 | 24.3 | 851 | 50 | 67 | 2 |
| icy | sync | 83 | 0 | - | - | - | - | - | 78 | - | 1 |
| 2048-golden | worker | 110 | 8 | 89 | 7905 | 312 | 88.6 | 3123 | 130 | 166 | 2 |
| 2048-golden | sync | 84 | 0 | - | - | - | - | - | 208 | - | 1 |

## Equivalence

* csv: final diagnostics identical, idle hover answers identical, exit statuses 0
* 2048: final diagnostics identical, idle hover answers identical, exit statuses 0
* icy: final diagnostics identical, idle hover answers identical, exit statuses 0
* 2048-golden: final diagnostics identical, idle hover answers identical, exit statuses 0
