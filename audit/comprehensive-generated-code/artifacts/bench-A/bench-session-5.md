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
| fib.ir | 12637.0 ms | 82.9 ms | 182.20 us | 5.3 ms | 70.35 us | 145.22 us | 🫩 | ✅ `17711` |
| loop-count.ir | 310.9 ms | 2.2 ms | 2.06 us | 142.85 us | 0.76 us | 4.55 us | 🎉 | ✅ `3500` |
| refined-checks.ir | 453.5 ms | 11.3 ms | 546.55 us | 3.1 ms | 197.65 us | 188.02 us | 🫩 | ✅ `[400, 0]` |
| sum-refined.ir | 203.9 ms | 36.8 ms | 2.97 us | 187.03 us | 2.83 us | 2.54 us | 🫩 | ✅ `80200` |
