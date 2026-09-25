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
| fib.ir | 12099.0 ms | 82.6 ms | 182.18 us | 2.8 ms | 50.62 us | 94.36 us | 🫩 | ✅ `17711` |
| loop-count.ir | 308.4 ms | 4.1 ms | 1.80 us | 142.51 us | 0.76 us | 3.46 us | 🎉 | ✅ `3500` |
| refined-checks.ir | 433.0 ms | 11.2 ms | 549.15 us | 3.1 ms | 222.48 us | 186.17 us | 🫩 | ✅ `[400, 0]` |
| sum-refined.ir | 186.0 ms | 34.1 ms | 1.33 us | 183.71 us | 2.94 us | 2.55 us | 🎉 | ✅ `80200` |
