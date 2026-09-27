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
| fib.ir | 8357.2 ms | 59.6 ms | 146.19 us | 1.9 ms | 39.39 us | 75.34 us | 🫩 | ✅ `17711` |
| loop-count.ir | 188.4 ms | 1.2 ms | 1.45 us | 76.46 us | 0.43 us | 0.89 us | 🫩 | ✅ `3500` |
| refined-checks.ir | 274.0 ms | 7.1 ms | 442.79 us | 2.0 ms | 159.67 us | 147.95 us | 🫩 | ✅ `[400, 0]` |
| sum-refined.ir | 117.9 ms | 17.8 ms | 0.77 us | 134.19 us | 0.71 us | 0.65 us | 🫩 | ✅ `80200` |
