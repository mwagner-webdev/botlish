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
| fib.ir | 7640.1 ms | 58.5 ms | 181.72 us | 2.0 ms | 55.16 us | 75.60 us | 🫩 | ✅ `17711` |
| loop-count.ir | 225.5 ms | 2.0 ms | 1.01 us | 98.48 us | 0.29 us | 0.89 us | 🫩 | ✅ `3500` |
| refined-checks.ir | 311.7 ms | 7.2 ms | 258.46 us | 2.0 ms | 107.32 us | 147.99 us | 🫩 | ✅ `[400, 0]` |
| sum-refined.ir | 112.3 ms | 21.0 ms | 0.56 us | 173.86 us | 0.99 us | 0.74 us | 🎉 | ✅ `80200` |
