# Native scalar machine-code audit corpus

**Temporary diagnostic snapshot.** Regenerate with:

```sh
tclsh9.0 native/generate-scalar-audit.tcl
```

This directory is not a canonical build product. It may be removed once the
scalar audit (see /docs/SCALAR-ASM-AUDIT.md) and any follow-up fixes it leads to
are complete.

## Compiler revision

- git commit: 26bbb449141966f819958d191eb7e2c3c07bcbcc
- Tcl: 9.0.1
- rustc 1.99.1 (58cf8f9c3 2026-10-13)
- cranelift-codegen: 0.135.2
- target: x86_64 (System V ABI, Linux ELF64)
- backend flags: cranelift, -specialize 1 (default), -repr-opt 1 (default)
- disassembly: objdump -dr --no-show-raw-insn -M intel, on the unlinked
  object (native::object) -- Botlish-generated code only, no linked runtime
  or libc disassembly

## Corpus summary

- bench/ files attempted: 4
- examples/stdlib/ files attempted: 9
- native-compilable programs: 13
- unsupported/failed programs: 0
- total native functions inspected: 178
- total committed disassembly bytes of machine code: 75111

## Status

| file | status | asm / vcode | notes |
|---|---|---|---|
| bench/fib.bot | compiled / inspected | [bench/fib.asm](bench/fib.asm) / [bench/fib.vcode](bench/fib.vcode) | 2 functions, 181 bytes |
| bench/loop-count.bot | compiled / inspected | [bench/loop-count.asm](bench/loop-count.asm) / [bench/loop-count.vcode](bench/loop-count.vcode) | 3 functions, 274 bytes |
| bench/sum-refined.bot | compiled / inspected | [bench/sum-refined.asm](bench/sum-refined.asm) / [bench/sum-refined.vcode](bench/sum-refined.vcode) | 3 functions, 277 bytes |
| bench/refined-checks.bot | compiled / inspected | [bench/refined-checks.asm](bench/refined-checks.asm) / [bench/refined-checks.vcode](bench/refined-checks.vcode) | 30 functions, 9545 bytes |
| examples/stdlib/ai_text_clean.bot | compiled / inspected | [examples-stdlib/ai_text_clean.asm](examples-stdlib/ai_text_clean.asm) / [examples-stdlib/ai_text_clean.vcode](examples-stdlib/ai_text_clean.vcode) | 6 functions, 2273 bytes |
| examples/stdlib/csv.bot | compiled / inspected | [examples-stdlib/csv.asm](examples-stdlib/csv.asm) / [examples-stdlib/csv.vcode](examples-stdlib/csv.vcode) | 11 functions, 5422 bytes |
| examples/stdlib/csv_chunked.bot | compiled / inspected | [examples-stdlib/csv_chunked.asm](examples-stdlib/csv_chunked.asm) / [examples-stdlib/csv_chunked.vcode](examples-stdlib/csv_chunked.vcode) | 14 functions, 7445 bytes |
| examples/stdlib/csv_geometric.bot | compiled / inspected | [examples-stdlib/csv_geometric.asm](examples-stdlib/csv_geometric.asm) / [examples-stdlib/csv_geometric.vcode](examples-stdlib/csv_geometric.vcode) | 18 functions, 6502 bytes |
| examples/stdlib/csv_records.bot | compiled / inspected | [examples-stdlib/csv_records.asm](examples-stdlib/csv_records.asm) / [examples-stdlib/csv_records.vcode](examples-stdlib/csv_records.vcode) | 51 functions, 21495 bytes |
| examples/stdlib/hashtable.bot | compiled / inspected | [examples-stdlib/hashtable.asm](examples-stdlib/hashtable.asm) / [examples-stdlib/hashtable.vcode](examples-stdlib/hashtable.vcode) | 24 functions, 12723 bytes |
| examples/stdlib/matmul.bot | compiled / inspected | [examples-stdlib/matmul.asm](examples-stdlib/matmul.asm) / [examples-stdlib/matmul.vcode](examples-stdlib/matmul.vcode) | 7 functions, 4755 bytes |
| examples/stdlib/string_replace.bot | compiled / inspected | [examples-stdlib/string_replace.asm](examples-stdlib/string_replace.asm) / [examples-stdlib/string_replace.vcode](examples-stdlib/string_replace.vcode) | 5 functions, 3011 bytes |
| examples/stdlib/string_reverse.bot | compiled / inspected | [examples-stdlib/string_reverse.asm](examples-stdlib/string_reverse.asm) / [examples-stdlib/string_reverse.vcode](examples-stdlib/string_reverse.vcode) | 4 functions, 1208 bytes |

See /docs/SCALAR-ASM-AUDIT.md for the analysis of this
corpus (per-function classification, findings, severity, and the milestone
recommendation).
