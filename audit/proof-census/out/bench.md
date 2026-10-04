# bench/bench.tcl, this container (4 vCPU), Tcl 9.0.1, go1.24.7; two samples.

## Sample 1 (-runs 5)
| program | Tcl interp | Tcl compile | Cranelift | Python | Rust | Go | 🏅 | values |
|---|---:|---:|---:|---:|---:|---:|---:|---|
| fib.bot | 10038.1 ms | 72.2 ms | 136.39 us | 2.3 ms | 56.12 us | 94.66 us | 🫩 | ✅ `17711` |
| loop-count.bot | 248.4 ms | 1.8 ms | 1.07 us | 107.69 us | 0.55 us | 5.08 us | 🎉 | ✅ `3500` |
| refined-checks.bot | 334.2 ms | 9.3 ms | 610.58 us | 2.4 ms | 133.27 us | 186.67 us | 🫩 | ✅ `[400, 0]` |
| sum-refined.bot | 141.5 ms | 17.3 ms | 0.86 us | 145.33 us | 3.88 us | 4.02 us | 🎉 | ✅ `80200` |

## Sample 2 (-runs 9)
| program | Tcl interp | Tcl compile | Cranelift | Python | Rust | Go | 🏅 | values |
|---|---:|---:|---:|---:|---:|---:|---:|---|
| fib.bot | 10787.0 ms | 71.3 ms | 136.27 us | 2.2 ms | 55.95 us | 96.06 us | 🫩 | ✅ `17711` |
| loop-count.bot | 248.8 ms | 1.7 ms | 1.08 us | 106.15 us | 0.55 us | 5.06 us | 🎉 | ✅ `3500` |
| refined-checks.bot | 335.2 ms | 9.3 ms | 590.87 us | 2.3 ms | 131.10 us | 184.66 us | 🫩 | ✅ `[400, 0]` |
| sum-refined.bot | 139.0 ms | 17.4 ms | 0.87 us | 143.68 us | 3.87 us | 4.02 us | 🎉 | ✅ `80200` |
