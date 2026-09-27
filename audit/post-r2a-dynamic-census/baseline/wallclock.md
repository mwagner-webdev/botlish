# Wall-clock control (production binary; tools/wallclock.py; JIT excluded)

sessions=7 runs/session=200 (first run of each session excluded from the all-runs median)
| program | median of session bests (µs) | best (µs) | median of all runs (µs) | session-best range (µs) |
|---|---:|---:|---:|---:|
| frozen | 660.3 | 552.3 | 729.3 | 552.3-724.6 |
| pre-r2 | 305.2 | 249.7 | 327.7 | 249.7-318.3 |
| r2 | 205.3 | 167.7 | 220.2 | 167.7-214.4 |
| r2a | 727.3 | 705.4 | 929.8 | 705.4-915.7 |
| r2a2 | 726.0 | 613.0 | 788.0 | 613.0-766.8 |
| cf-exact-target | 521.8 | 445.3 | 575.2 | 445.3-554.8 |
| string-region-off | 812.1 | 672.2 | 896.5 | 672.2-862.8 |

## Canonical `bench.tcl` (3 sessions, `tclsh9.0 bench/bench.tcl -runs 5 -markdown bench/refined-checks.ir`; best of 5, JIT excluded)

| session | Tcl interp | Tcl compile | Cranelift | Python | Rust | Go | values |
|---|---:|---:|---:|---:|---:|---:|---|
| 1 | 257.7 ms | 7.5 ms | 559.51 us | 1.6 ms | 90.42 us | 106.27 us | `[400, 0]` |
| 2 | 236.5 ms | 8.0 ms | 770.50 us | 1.6 ms | 103.74 us | 133.33 us | `[400, 0]` |
| 3 | 277.4 ms | 6.2 ms | 707.19 us | 2.9 ms | 107.84 us | 117.16 us | `[400, 0]` |
