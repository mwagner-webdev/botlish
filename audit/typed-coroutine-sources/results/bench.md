# Typed coroutine sources: consumer costs (bench.tcl)

N = 200000 symbols per run; best of 7 runs (native::measure, compile excluded); allocations of one run.

| program | backend | best (ms) | ns / symbol | allocations | value |
|---|---|---:|---:|---:|---|
| plain | cranelift | 1.90 | 9.5 | 1 | int 1620332025 |
| plain | cranelift-unfused | 15.52 | 77.6 | 3 | int 1620332025 |
| narrowed | cranelift | 1.98 | 9.9 | 1 | int 1620332025 |
| narrowed | cranelift-unfused | 15.68 | 78.4 | 3 | int 1620332025 |
| enum | cranelift | 24.61 | 123.1 | 400003 | int 200000 |
| enum | cranelift-unfused | 39.77 | 198.8 | 400005 | int 200000 |
