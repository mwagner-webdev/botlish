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
| fib.ir | 12572.6 ms | 89.8 ms | 182.28 us | 2.8 ms | 50.62 us | 94.22 us | 🫩 | ✅ `17711` |
| loop-count.ir | 309.4 ms | 2.0 ms | 1.80 us | 139.40 us | 0.76 us | 3.39 us | 🎉 | ✅ `3500` |
| refined-checks.ir | 434.4 ms | 10.9 ms | 547.33 us | 3.6 ms | 195.53 us | 358.69 us | 🫩 | ✅ `[400, 0]` |
| sum-refined.ir | 189.4 ms | 34.4 ms | 1.32 us | 291.85 us | 2.92 us | 2.55 us | 🎉 | ✅ `80200` |
