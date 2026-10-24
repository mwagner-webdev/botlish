# Language server benchmark

2026-10-23, Tcl 9.0.1, 4 processors; 20 edits per session every 150-300 ms, every other one a syntax error (-malformed 1), 20 idle hovers; seed 7.

## Hover latency (ms) while editing, and once idle

| workload | scheduler | editing: median | p95 | p99 | max | idle: median | p95 | max |
|---|---|---:|---:|---:|---:|---:|---:|---:|
| csv | worker | 3 | 4 | 9 | 9 | 2 | 3 | 4 |
| csv | sync | 2 | 29 | 94 | 94 | 1 | 2 | 6 |
| 2048 | worker | 3 | 6 | 84 | 84 | 1 | 2 | 11 |
| 2048 | sync | 192 | 1460 | 1655 | 1655 | 2 | 3 | 67 |
| icy | worker | 3 | 7 | 8 | 8 | 2 | 2 | 3 |
| icy | sync | 119 | 3475 | 3478 | 3478 | 2 | 2 | 32 |
| 2048-golden | worker | 3 | 5 | 13 | 13 | 2 | 3 | 12 |
| 2048-golden | sync | 6588 | 8498 | 8499 | 8499 | 2 | 4 | 124 |

## Diagnostics, event loop and analysis work

| workload | scheduler | first diagnostics (ms) | last edit to its diagnostics (ms) | longest callback (ms) | analyses run | killed (ms of their work) | intermediate versions published |
|---|---|---:|---:|---:|---:|---:|---:|
| csv | worker | 446 | 516 | 42 (warm) | 8 of 8 submitted | 0 (0) | 1 |
| csv | sync | 291 | 424 | 250 (analysis csv.bot) | 5 of 5 submitted | 0 (0) | 4 |
| 2048 | worker | 2044 | 2187 | 115 (worker message) | 4 of 9 submitted | 4 (2192) | 1 |
| 2048 | sync | 1760 | 3123 | 1783 (analysis demo.bot) | 6 of 7 submitted | 0 (0) | 5 |
| icy | worker | 3257 | 3432 | 56 (worker message) | 2 of 7 submitted | 4 (3285) | 1 |
| icy | sync | 3204 | 6520 | 3899 (analysis headless.bot) | 6 of 7 submitted | 0 (0) | 5 |
| 2048-golden | worker | 8636 | 8363 | 153 (worker message) | 2 of 10 submitted | 7 (2526) | 1 |
| 2048-golden | sync | 7144 | 14218 | 9003 (analysis golden.bot) | 3 of 4 submitted | 0 (0) | 2 |

## Worker, transfer and memory

| workload | scheduler | server start (ms) | worker starts | worker start to hello (ms, mean) | analysis in the worker (ms, mean) | indexes and export in the worker (ms, mean) | import (ms, mean) | transferred (KiB, mean) | server RSS max (MiB) | worker RSS max (MiB) | processes |
|---|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| csv | worker | 77 | 1 | 107 | 131 | 34 | 4.1 | 167 | 29 | 28 | 2 |
| csv | sync | 77 | 0 | - | - | - | - | - | 52 | - | 1 |
| 2048 | worker | 73 | 5 | 79 | 883 | 108 | 32.8 | 1013 | 85 | 79 | 2 |
| 2048 | sync | 82 | 0 | - | - | - | - | - | 117 | - | 1 |
| icy | worker | 111 | 5 | 84 | 2964 | 68 | 28.7 | 851 | 50 | 67 | 2 |
| icy | sync | 74 | 0 | - | - | - | - | - | 99 | - | 1 |
| 2048-golden | worker | 90 | 8 | 89 | 7746 | 292 | 85.8 | 3123 | 135 | 166 | 2 |
| 2048-golden | sync | 74 | 0 | - | - | - | - | - | 208 | - | 1 |

## Worker crash recovery

| workload | crash reported after (ms) | next edit to its diagnostics (ms) | workers started | exit |
|---|---:|---:|---:|---:|
| csv | 262 | 642 | 2 | 0 |
| 2048 | 270 | 2370 | 2 | 0 |
| icy | 266 | 3213 | 2 | 0 |
| 2048-golden | 273 | 8157 | 2 | 0 |

## Equivalence

* csv: final diagnostics identical, idle hover answers identical, exit statuses 0
* 2048: final diagnostics identical, idle hover answers identical, exit statuses 0
* icy: final diagnostics identical, idle hover answers identical, exit statuses 0
* 2048-golden: final diagnostics identical, idle hover answers identical, exit statuses 0
