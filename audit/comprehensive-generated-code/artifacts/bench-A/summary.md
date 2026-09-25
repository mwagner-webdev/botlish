sessions: 5 (each: best of 5 runs)
| program | backend | median | min | max | spread (max/min - 1) |
|---|---|---:|---:|---:|---:|
| fib.ir | Cranelift | 182.20 us | 182.16 us | 182.38 us | 0% |
| fib.ir | Go | 94.30 us | 94.22 us | 145.22 us | 54% |
| fib.ir | Python | 2.9 ms | 2.8 ms | 5.3 ms | 89% |
| fib.ir | Rust | 50.66 us | 50.62 us | 70.35 us | 39% |
| fib.ir | Tcl compile | 83.2 ms | 82.4 ms | 89.8 ms | 9% |
| fib.ir | Tcl interp | 12572.6 ms | 12281.0 ms | 12730.1 ms | 4% |
| loop-count.ir | Cranelift | 1.80 us | 1.76 us | 2.47 us | 40% |
| loop-count.ir | Go | 3.39 us | 3.38 us | 4.55 us | 35% |
| loop-count.ir | Python | 142.85 us | 139.31 us | 184.74 us | 33% |
| loop-count.ir | Rust | 0.76 us | 0.76 us | 0.93 us | 22% |
| loop-count.ir | Tcl compile | 2.1 ms | 2.0 ms | 2.7 ms | 35% |
| loop-count.ir | Tcl interp | 313.5 ms | 309.4 ms | 316.5 ms | 2% |
| refined-checks.ir | Cranelift | 546.55 us | 541.22 us | 553.00 us | 2% |
| refined-checks.ir | Go | 188.53 us | 186.30 us | 358.69 us | 93% |
| refined-checks.ir | Python | 3.1 ms | 3.0 ms | 3.6 ms | 20% |
| refined-checks.ir | Rust | 196.71 us | 195.37 us | 361.25 us | 85% |
| refined-checks.ir | Tcl compile | 10.9 ms | 10.9 ms | 11.3 ms | 4% |
| refined-checks.ir | Tcl interp | 434.4 ms | 427.3 ms | 453.5 ms | 6% |
| sum-refined.ir | Cranelift | 1.32 us | 1.32 us | 2.97 us | 125% |
| sum-refined.ir | Go | 2.60 us | 2.54 us | 3.05 us | 20% |
| sum-refined.ir | Python | 185.04 us | 173.97 us | 291.85 us | 68% |
| sum-refined.ir | Rust | 2.92 us | 2.83 us | 2.94 us | 4% |
| sum-refined.ir | Tcl compile | 36.7 ms | 34.0 ms | 37.9 ms | 11% |
| sum-refined.ir | Tcl interp | 192.7 ms | 189.4 ms | 203.9 ms | 8% |
