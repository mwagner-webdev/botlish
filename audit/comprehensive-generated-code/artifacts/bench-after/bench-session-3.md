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
| fib.ir | 12316.1 ms | 83.7 ms | 182.16 us | 2.9 ms | 84.06 us | 94.22 us | 🫩 | ✅ `17711` |
| loop-count.ir | 318.6 ms | 2.0 ms | 3.19 us | 241.13 us | 0.76 us | 3.46 us | 🎉 | ✅ `3500` |
| refined-checks.ir | 451.0 ms | 11.1 ms | 541.93 us | 3.1 ms | 195.84 us | 188.02 us | 🫩 | ✅ `[400, 0]` |
| sum-refined.ir | 186.0 ms | 34.3 ms | 1.32 us | 191.21 us | 2.93 us | 2.56 us | 🎉 | ✅ `80200` |
