# Native scalar machine-code audit corpus

**Temporary diagnostic snapshot.** Regenerate with:

```sh
tclsh9.0 native/generate-scalar-audit.tcl
```

This directory is not a canonical build product. It may be removed once the
scalar audit (see /SCALAR-ASM-AUDIT.md) and any follow-up fixes it leads to
are complete.

## Compiler revision

- git commit: 61fc665ab32f429cfbb95dcf5fb2b129c9b08c69
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
- native-compilable programs: 13
- unsupported/failed programs: 0
- total native functions inspected: 179
- total committed disassembly bytes of machine code: 82330

## Status

| file | status | asm / vcode | notes |
|---|---|---|---|
| bench/fib.ir | compiled / inspected | [bench/fib.asm](bench/fib.asm) / [bench/fib.vcode](bench/fib.vcode) | 2 functions, 394 bytes |
| bench/loop-count.ir | compiled / inspected | [bench/loop-count.asm](bench/loop-count.asm) / [bench/loop-count.vcode](bench/loop-count.vcode) | 3 functions, 418 bytes |
| bench/sum-refined.ir | compiled / inspected | [bench/sum-refined.asm](bench/sum-refined.asm) / [bench/sum-refined.vcode](bench/sum-refined.vcode) | 3 functions, 292 bytes |
| bench/refined-checks.ir | compiled / inspected | [bench/refined-checks.asm](bench/refined-checks.asm) / [bench/refined-checks.vcode](bench/refined-checks.vcode) | 25 functions, 16284 bytes |
| examples/stdlib/ai_text_clean.bot | compiled / inspected | [examples-stdlib/ai_text_clean.asm](examples-stdlib/ai_text_clean.asm) / [examples-stdlib/ai_text_clean.vcode](examples-stdlib/ai_text_clean.vcode) | 5 functions, 3003 bytes |
| examples/stdlib/csv.bot | compiled / inspected | [examples-stdlib/csv.asm](examples-stdlib/csv.asm) / [examples-stdlib/csv.vcode](examples-stdlib/csv.vcode) | 11 functions, 4731 bytes |
| examples/stdlib/csv_chunked.bot | compiled / inspected | [examples-stdlib/csv_chunked.asm](examples-stdlib/csv_chunked.asm) / [examples-stdlib/csv_chunked.vcode](examples-stdlib/csv_chunked.vcode) | 20 functions, 10103 bytes |
| examples/stdlib/csv_geometric.bot | compiled / inspected | [examples-stdlib/csv_geometric.asm](examples-stdlib/csv_geometric.asm) / [examples-stdlib/csv_geometric.vcode](examples-stdlib/csv_geometric.vcode) | 15 functions, 5333 bytes |
| examples/stdlib/csv_records.bot | compiled / inspected | [examples-stdlib/csv_records.asm](examples-stdlib/csv_records.asm) / [examples-stdlib/csv_records.vcode](examples-stdlib/csv_records.vcode) | 55 functions, 21624 bytes |
| examples/stdlib/hashtable.bot | compiled / inspected | [examples-stdlib/hashtable.asm](examples-stdlib/hashtable.asm) / [examples-stdlib/hashtable.vcode](examples-stdlib/hashtable.vcode) | 26 functions, 12868 bytes |
| examples/stdlib/matmul.bot | compiled / inspected | [examples-stdlib/matmul.asm](examples-stdlib/matmul.asm) / [examples-stdlib/matmul.vcode](examples-stdlib/matmul.vcode) | 7 functions, 4160 bytes |
| examples/stdlib/string_replace.bot | compiled / inspected | [examples-stdlib/string_replace.asm](examples-stdlib/string_replace.asm) / [examples-stdlib/string_replace.vcode](examples-stdlib/string_replace.vcode) | 4 functions, 2322 bytes |
| examples/stdlib/string_reverse.bot | compiled / inspected | [examples-stdlib/string_reverse.asm](examples-stdlib/string_reverse.asm) / [examples-stdlib/string_reverse.vcode](examples-stdlib/string_reverse.vcode) | 3 functions, 798 bytes |

See /SCALAR-ASM-AUDIT.md at the repository root for the analysis of this
corpus (per-function classification, findings, severity, and the milestone
recommendation).
