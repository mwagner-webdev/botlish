sessions: 5 (each: best of 5 runs)
| program | backend | median | min | max | spread (max/min - 1) |
|---|---|---:|---:|---:|---:|
| fib.ir | Cranelift | 182.16 us | 182.15 us | 182.18 us | 0% |
| fib.ir | Go | 94.36 us | 94.22 us | 133.77 us | 42% |
| fib.ir | Python | 2.9 ms | 2.8 ms | 5.3 ms | 89% |
| fib.ir | Rust | 50.63 us | 50.62 us | 84.06 us | 66% |
| fib.ir | Tcl compile | 83.1 ms | 82.6 ms | 83.8 ms | 1% |
| fib.ir | Tcl interp | 12252.1 ms | 12099.0 ms | 12316.1 ms | 2% |
| loop-count.ir | Cranelift | 1.80 us | 1.76 us | 3.19 us | 81% |
| loop-count.ir | Go | 3.46 us | 3.39 us | 4.82 us | 42% |
| loop-count.ir | Python | 141.00 us | 139.93 us | 241.13 us | 72% |
| loop-count.ir | Rust | 0.76 us | 0.76 us | 0.76 us | 0% |
| loop-count.ir | Tcl compile | 2.1 ms | 2.0 ms | 4.1 ms | 105% |
| loop-count.ir | Tcl interp | 314.0 ms | 308.4 ms | 318.6 ms | 3% |
| refined-checks.ir | Cranelift | 544.36 us | 535.44 us | 556.97 us | 4% |
| refined-checks.ir | Go | 186.68 us | 185.38 us | 188.02 us | 1% |
| refined-checks.ir | Python | 3.1 ms | 3.1 ms | 3.1 ms | 0% |
| refined-checks.ir | Rust | 197.33 us | 195.84 us | 357.71 us | 83% |
| refined-checks.ir | Tcl compile | 11.1 ms | 10.8 ms | 11.2 ms | 4% |
| refined-checks.ir | Tcl interp | 433.1 ms | 427.3 ms | 451.0 ms | 6% |
| sum-refined.ir | Cranelift | 1.32 us | 1.32 us | 1.33 us | 1% |
| sum-refined.ir | Go | 2.56 us | 2.54 us | 3.13 us | 23% |
| sum-refined.ir | Python | 185.73 us | 183.71 us | 310.21 us | 69% |
| sum-refined.ir | Rust | 2.92 us | 2.83 us | 2.94 us | 4% |
| sum-refined.ir | Tcl compile | 34.1 ms | 33.8 ms | 34.5 ms | 2% |
| sum-refined.ir | Tcl interp | 186.0 ms | 184.0 ms | 191.6 ms | 4% |
