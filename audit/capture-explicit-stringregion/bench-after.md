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
| fib.ir | 10218.2 ms | 76.0 ms | 169.91 us | 3.4 ms | 53.53 us | 92.61 us | 🫩 | ✅ `17711` |
| loop-count.ir | 259.2 ms | 1.8 ms | 1.42 us | 110.42 us | 0.56 us | 5.07 us | 🎉 | ✅ `3500` |
| refined-checks.ir | 365.8 ms | 9.4 ms | 464.25 us | 2.3 ms | 130.75 us | 197.24 us | 🫩 | ✅ `[400, 0]` |
| sum-refined.ir | 154.3 ms | 20.9 ms | 0.77 us | 153.33 us | 4.86 us | 4.03 us | 🎉 | ✅ `80200` |
