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
| fib.ir | 12252.1 ms | 83.8 ms | 182.15 us | 3.1 ms | 50.62 us | 94.43 us | 🫩 | ✅ `17711` |
| loop-count.ir | 315.9 ms | 2.3 ms | 1.80 us | 140.46 us | 0.76 us | 3.47 us | 🎉 | ✅ `3500` |
| refined-checks.ir | 442.3 ms | 11.1 ms | 535.44 us | 3.1 ms | 197.33 us | 186.68 us | 🫩 | ✅ `[400, 0]` |
| sum-refined.ir | 189.8 ms | 33.8 ms | 1.33 us | 184.28 us | 2.92 us | 3.13 us | 🎉 | ✅ `80200` |
