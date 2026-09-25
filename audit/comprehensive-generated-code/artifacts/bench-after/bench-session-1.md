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
| fib.ir | 12281.4 ms | 83.1 ms | 182.15 us | 5.3 ms | 51.05 us | 133.77 us | 🫩 | ✅ `17711` |
| loop-count.ir | 311.5 ms | 2.1 ms | 1.78 us | 141.00 us | 0.76 us | 4.82 us | 🎉 | ✅ `3500` |
| refined-checks.ir | 427.3 ms | 10.9 ms | 556.97 us | 3.1 ms | 357.71 us | 185.38 us | 🫩 | ✅ `[400, 0]` |
| sum-refined.ir | 184.0 ms | 34.0 ms | 1.32 us | 185.73 us | 2.83 us | 2.54 us | 🎉 | ✅ `80200` |
