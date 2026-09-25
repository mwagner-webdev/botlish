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
| fib.ir | 12730.1 ms | 82.4 ms | 182.20 us | 2.9 ms | 50.66 us | 94.26 us | 🫩 | ✅ `17711` |
| loop-count.ir | 313.8 ms | 2.0 ms | 1.76 us | 143.33 us | 0.93 us | 3.39 us | 🎉 | ✅ `3500` |
| refined-checks.ir | 427.3 ms | 10.9 ms | 541.45 us | 3.0 ms | 195.37 us | 191.29 us | 🫩 | ✅ `[400, 0]` |
| sum-refined.ir | 191.8 ms | 36.7 ms | 1.32 us | 185.04 us | 2.94 us | 2.60 us | 🎉 | ✅ `80200` |
