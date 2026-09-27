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
| fib.ir | 8245.9 ms | 54.7 ms | 138.13 us | 1.9 ms | 32.51 us | 75.37 us | 🫩 | ✅ `17711` |
| loop-count.ir | 214.4 ms | 1.3 ms | 1.05 us | 129.15 us | 0.29 us | 0.94 us | 🫩 | ✅ `3500` |
| refined-checks.ir | 292.5 ms | 8.1 ms | 258.57 us | 2.1 ms | 115.45 us | 149.56 us | 🫩 | ✅ `[400, 0]` |
| sum-refined.ir | 136.5 ms | 19.8 ms | 0.56 us | 119.27 us | 0.70 us | 0.71 us | 🎉 | ✅ `80200` |
