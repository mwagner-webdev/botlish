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
| fib.ir | 8010.2 ms | 52.4 ms | 137.46 us | 1.7 ms | 39.35 us | 75.39 us | 🫩 | ✅ `17711` |
| loop-count.ir | 228.0 ms | 1.5 ms | 1.04 us | 92.33 us | 0.29 us | 0.80 us | 🫩 | ✅ `3500` |
| refined-checks.ir | 274.8 ms | 7.3 ms | 343.03 us | 2.0 ms | 103.86 us | 127.22 us | 🫩 | ✅ `[400, 0]` |
| sum-refined.ir | 128.6 ms | 20.6 ms | 0.56 us | 129.84 us | 1.23 us | 0.69 us | 🎉 | ✅ `80200` |
