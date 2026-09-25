```
Backends:
  Tcl interp  semantic interpreter -- in-process execution
  Tcl compile Tcl source/codegen backend (not Cranelift) -- in-process execution
  Cranelift   Cranelift native machine-code backend -- in-process execution, JIT compile time excluded
  Python      reference implementation -- in-process execution
  Rust        reference implementation -- in-process execution
  Go          reference implementation -- in-process execution
```

Tcl 9.0.1, best of 5 runs, compilation excluded (Cranelift's JIT compile time specifically -- see the manifest above -- not just Tcl's).

| program | Tcl interp | Tcl compile | Cranelift | Python | Rust | Go | 🏅 | values |
|---|---:|---:|---:|---:|---:|---:|---:|---|
| fib.ir | 12239.1 ms | 82.9 ms | 182.16 us | 2.9 ms | 50.63 us | 94.28 us | 🫩 | ✅ `17711` |
| loop-count.ir | 314.0 ms | 2.0 ms | 1.76 us | 139.93 us | 0.76 us | 3.39 us | 🎉 | ✅ `3500` |
| refined-checks.ir | 433.1 ms | 10.8 ms | 544.36 us | 3.1 ms | 196.86 us | 186.68 us | 🫩 | ✅ `[400, 0]` |
| sum-refined.ir | 191.6 ms | 34.5 ms | 1.32 us | 310.21 us | 2.92 us | 2.60 us | 🎉 | ✅ `80200` |
