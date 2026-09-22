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
| fib.ir | 10351.9 ms | 76.6 ms | 181.09 us | 2.2 ms | 56.91 us | 94.71 us | 🫩 | ✅ `17711` |
| loop-count.ir | 264.0 ms | 1.7 ms | 1.41 us | 112.02 us | 0.55 us | 5.31 us | 🎉 | ✅ `3500` |
| refined-checks.ir | 354.2 ms | 9.2 ms | 502.67 us | 2.3 ms | 132.02 us | 182.64 us | 🫩 | ✅ `[400, 0]` |
| sum-refined.ir | 150.6 ms | 20.7 ms | 0.77 us | 153.23 us | 4.58 us | 4.02 us | 🎉 | ✅ `80200` |
