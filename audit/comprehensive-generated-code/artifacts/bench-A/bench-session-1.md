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
| fib.ir | 12281.0 ms | 83.2 ms | 182.38 us | 2.9 ms | 50.98 us | 94.30 us | 🫩 | ✅ `17711` |
| loop-count.ir | 313.5 ms | 2.1 ms | 1.79 us | 139.31 us | 0.76 us | 3.38 us | 🎉 | ✅ `3500` |
| refined-checks.ir | 445.7 ms | 10.9 ms | 553.00 us | 3.1 ms | 196.71 us | 188.53 us | 🫩 | ✅ `[400, 0]` |
| sum-refined.ir | 192.7 ms | 34.0 ms | 1.32 us | 173.97 us | 2.92 us | 2.61 us | 🎉 | ✅ `80200` |
