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
| fib.ir | 12395.9 ms | 83.9 ms | 182.16 us | 2.9 ms | 50.63 us | 94.33 us | 🫩 | ✅ `17711` |
| loop-count.ir | 316.5 ms | 2.7 ms | 2.47 us | 184.74 us | 0.92 us | 4.05 us | 🎉 | ✅ `3500` |
| refined-checks.ir | 433.7 ms | 10.9 ms | 541.22 us | 3.2 ms | 361.25 us | 186.30 us | 🫩 | ✅ `[400, 0]` |
| sum-refined.ir | 199.0 ms | 37.9 ms | 1.91 us | 179.56 us | 2.92 us | 3.05 us | 🎉 | ✅ `80200` |
