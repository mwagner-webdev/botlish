| workload | expressions | from lib/ | builds | analysis, ms | library floor, ms | floor builds | floor share |
|---|---:|---:|---:|---:|---:|---:|---:|
| csv | 322 | 57 (18%) | 1 | 171 | 16 | 1 | 10% |
| 2048 | 1777 | 702 (40%) | 2 | 1129 | 399 | 2 | 35% |
| icy | 1558 | 101 (6%) | 1 | 776 | 40 | 1 | 5% |
| 2048-golden | 5374 | 1490 (28%) | 3 | 6470 | 699 | 1 | 32% |

"floor share" = the floor's time per build x the workload's builds / the workload's analysis time: the part of the analysis a per-build reuse of the library's analysis could at most remove.
