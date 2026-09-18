# Native scalar machine-code audit corpus

**Temporary diagnostic snapshot.** Regenerate with:

```sh
tclsh9.0 native/generate-scalar-audit.tcl
```

This directory is not a canonical build product. It may be removed once the
scalar audit (see /SCALAR-ASM-AUDIT.md) and any follow-up fixes it leads to
are complete.

## Compiler revision

- git commit: 945d84b318601aab19cf7ca487440f0169aa0703
- Tcl: 9.0.1
- rustc 1.98.1 (48a229cea 2026-09-01)
- cranelift-codegen: 0.135.2
- target: x86_64 (System V ABI, Linux ELF64)
- backend flags: cranelift, -specialize 1 (default), -repr-opt 1 (default)
- disassembly: objdump -dr --no-show-raw-insn -M intel, on the unlinked
  object (native::object) -- Botlish-generated code only, no linked runtime
  or libc disassembly

## Corpus summary

- bench/ files attempted: 4
- examples/stdlib/ files attempted: 9
- native-compilable programs: 12
- unsupported/failed programs: 1
- total native functions inspected: 163
- total committed disassembly bytes of machine code: 90186

## Status

| file | status | assembly | notes |
|---|---|---|---|
| bench/fib.ir | compiled / inspected | [bench/fib.asm](bench/fib.asm) | 2 functions, 680 bytes |
| bench/loop-count.ir | compiled / inspected | [bench/loop-count.asm](bench/loop-count.asm) | 3 functions, 798 bytes |
| bench/sum-refined.ir | compiled / inspected | [bench/sum-refined.asm](bench/sum-refined.asm) | 3 functions, 787 bytes |
| bench/refined-checks.ir | unsupported | [bench/refined-checks.status.txt](bench/refined-checks.status.txt) | ir {1 2}: e39: native lowering does not support native uriEscape: the native "uriEscape" has no native implementation |
| examples/stdlib/ai_text_clean.bot | compiled / inspected | [examples-stdlib/ai_text_clean.asm](examples-stdlib/ai_text_clean.asm) | 5 functions, 3663 bytes |
| examples/stdlib/csv.bot | compiled / inspected | [examples-stdlib/csv.asm](examples-stdlib/csv.asm) | 11 functions, 6228 bytes |
| examples/stdlib/csv_chunked.bot | compiled / inspected | [examples-stdlib/csv_chunked.asm](examples-stdlib/csv_chunked.asm) | 21 functions, 13355 bytes |
| examples/stdlib/csv_geometric.bot | compiled / inspected | [examples-stdlib/csv_geometric.asm](examples-stdlib/csv_geometric.asm) | 15 functions, 7365 bytes |
| examples/stdlib/csv_records.bot | compiled / inspected | [examples-stdlib/csv_records.asm](examples-stdlib/csv_records.asm) | 59 functions, 30234 bytes |
| examples/stdlib/hashtable.bot | compiled / inspected | [examples-stdlib/hashtable.asm](examples-stdlib/hashtable.asm) | 30 functions, 17970 bytes |
| examples/stdlib/matmul.bot | compiled / inspected | [examples-stdlib/matmul.asm](examples-stdlib/matmul.asm) | 7 functions, 4991 bytes |
| examples/stdlib/string_replace.bot | compiled / inspected | [examples-stdlib/string_replace.asm](examples-stdlib/string_replace.asm) | 4 functions, 2943 bytes |
| examples/stdlib/string_reverse.bot | compiled / inspected | [examples-stdlib/string_reverse.asm](examples-stdlib/string_reverse.asm) | 3 functions, 1172 bytes |

See /SCALAR-ASM-AUDIT.md at the repository root for the analysis of this
corpus (per-function classification, findings, severity, and the milestone
recommendation).
