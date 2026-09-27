sessions: 5 (each: best of 5 runs)
| program | backend | median | min | max | spread (max/min - 1) |
|---|---|---:|---:|---:|---:|
| fib.ir | Cranelift | 138.13 us | 136.31 us | 181.72 us | 33% |
| fib.ir | Go | 75.39 us | 75.34 us | 87.57 us | 16% |
| fib.ir | Python | 1.9 ms | 1.7 ms | 2.6 ms | 53% |
| fib.ir | Rust | 39.35 us | 32.51 us | 55.16 us | 70% |
| fib.ir | Tcl compile | 58.5 ms | 52.4 ms | 63.8 ms | 22% |
| fib.ir | Tcl interp | 8082.0 ms | 7640.1 ms | 8357.2 ms | 9% |
| loop-count.ir | Cranelift | 1.05 us | 1.01 us | 1.60 us | 58% |
| loop-count.ir | Go | 0.89 us | 0.80 us | 0.94 us | 17% |
| loop-count.ir | Python | 92.53 us | 76.46 us | 129.15 us | 69% |
| loop-count.ir | Rust | 0.29 us | 0.29 us | 0.43 us | 48% |
| loop-count.ir | Tcl compile | 1.5 ms | 1.2 ms | 2.0 ms | 67% |
| loop-count.ir | Tcl interp | 214.4 ms | 188.4 ms | 228.0 ms | 21% |
| refined-checks.ir | Cranelift | 317.11 us | 258.46 us | 442.79 us | 71% |
| refined-checks.ir | Go | 147.99 us | 127.22 us | 208.50 us | 64% |
| refined-checks.ir | Python | 2.0 ms | 2.0 ms | 2.1 ms | 5% |
| refined-checks.ir | Rust | 115.45 us | 103.86 us | 177.47 us | 71% |
| refined-checks.ir | Tcl compile | 7.2 ms | 6.3 ms | 8.1 ms | 29% |
| refined-checks.ir | Tcl interp | 274.8 ms | 245.0 ms | 311.7 ms | 27% |
| sum-refined.ir | Cranelift | 0.56 us | 0.56 us | 0.77 us | 38% |
| sum-refined.ir | Go | 0.71 us | 0.65 us | 0.74 us | 14% |
| sum-refined.ir | Python | 129.84 us | 119.27 us | 173.86 us | 46% |
| sum-refined.ir | Rust | 0.99 us | 0.70 us | 1.23 us | 76% |
| sum-refined.ir | Tcl compile | 19.8 ms | 17.0 ms | 21.0 ms | 24% |
| sum-refined.ir | Tcl interp | 128.6 ms | 112.3 ms | 136.5 ms | 22% |
