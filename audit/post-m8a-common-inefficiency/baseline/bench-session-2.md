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
| fib.ir | 8082.0 ms | 63.8 ms | 136.31 us | 2.6 ms | 39.35 us | 87.57 us | 🫩 | ✅ `17711` |
| loop-count.ir | 202.1 ms | 1.5 ms | 1.60 us | 92.53 us | 0.37 us | 0.80 us | 🫩 | ✅ `3500` |
| refined-checks.ir | 245.0 ms | 6.3 ms | 317.11 us | 2.1 ms | 177.47 us | 208.50 us | 🫩 | ✅ `[400, 0]` |
| sum-refined.ir | 131.9 ms | 17.0 ms | 0.68 us | 126.58 us | 0.99 us | 0.71 us | 🎉 | ✅ `80200` |
