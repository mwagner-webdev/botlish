| class (% of ALL executed instructions per run) | fib | loop-count | sum-refined | refined-checks | (probe) refined-checks-ascii | (suppl.) uri-steady | (suppl.) ai_text_clean 10K | (suppl.) csv 1000 |
|---|---:|---:|---:|---:|---:|---:|---:|---:|
| instructions per run | 2,378,489 | 17,545 | 12,437 | 5,437,827 | 3,884,225 | 44,138,830 | 36,848,115 | 45,154,179 |
| **generated code, total** | **100.0%** | **100.0%** | **100.0%** | **33.5%** | **46.9%** | **10.2%** | **10.0%** | **11.7%** |
| frame (prologue/epilogue/zero slots) | 31.3% | 14.4% | 22.7% | 6.5% | 9.1% | 2.4% | 0.6% | 1.9% |
| register moves | 24.1% | 20.0% | 16.1% | 9.1% | 12.8% | 2.2% | 1.8% | 2.6% |
| tagged Int (tag test, overflow, retag, untag) | 15.7% | 28.5% | 25.7% | 3.7% | 5.2% | 0.9% | 0.4% | 1.2% |
| Bool word (materialize + test) | 7.2% | 11.4% | 0.0% | 2.6% | 3.6% | 0.6% | 2.0% | 0.9% |
| stack traffic (root publish, spills, out-params) | 7.2% | 8.6% | 12.9% | 4.3% | 6.0% | 1.6% | 0.7% | 2.1% |
| completion checks | 0.0% | 0.0% | 0.0% | 1.2% | 1.6% | 0.4% | 0.1% | 0.5% |
| call instructions | 2.4% | 2.9% | 3.2% | 1.1% | 1.6% | 0.5% | 0.7% | 0.6% |
| heap/VM/const memory | 0.0% | 0.0% | 0.0% | 1.0% | 1.4% | 0.3% | 1.0% | 0.5% |
| other generated code (arith, cmp, jcc, jmp, imm, lea) | 12.0% | 14.3% | 19.3% | 4.1% | 5.7% | 1.5% | 2.8% | 1.5% |
| **runtime helpers (Rust, exclusive)** | **0.0%** | **0.0%** | **0.0%** | **61.4%** | **50.3%** | **40.6%** | **44.3%** | **39.8%** |
| **Rust std inlined out of helpers** | **0.0%** | **0.0%** | **0.0%** | **4.2%** | **0.0%** | **6.5%** | **28.2%** | **2.5%** |
| **libc (malloc/free/memcpy/memcmp)** | **0.0%** | **0.0%** | **0.0%** | **0.8%** | **2.8%** | **42.6%** | **17.4%** | **46.0%** |
