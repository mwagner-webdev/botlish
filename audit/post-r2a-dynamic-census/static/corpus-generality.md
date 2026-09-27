| program | callvalue | per-call closure allocs (closure ops outside <program>) | closure-valued fns (env=1) | flattened module-value params | generic instances | OpenInstances | open but blockescape-flattened | substr | region ops | setcontainstotal |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| bench/fib.ir | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| bench/loop-count.ir | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| bench/refined-checks.ir | 1 | 1 | 4 | 7 | 15 | 13 | 9 | 2 | 6 | 2 |
| bench/sum-refined.ir | 0 | 0 | 0 | 0 | 1 | 1 | 0 | 0 | 0 | 0 |
| bench/uri-steady.bot | 1 | 1 | 3 | 10 | 15 | 13 | 10 | 2 | 6 | 2 |
| examples/stdlib/ai_text_clean.bot | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 19 | 0 |
| examples/stdlib/csv.bot | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 2 | 11 | 0 |
| examples/stdlib/csv_chunked.bot | 0 | 0 | 0 | 0 | 2 | 0 | 0 | 2 | 11 | 0 |
| examples/stdlib/csv_geometric.bot | 0 | 0 | 0 | 0 | 1 | 0 | 0 | 2 | 9 | 0 |
| examples/stdlib/csv_records.bot | 0 | 0 | 0 | 0 | 12 | 0 | 0 | 2 | 9 | 0 |
| examples/stdlib/hashtable.bot | 0 | 0 | 0 | 0 | 6 | 0 | 0 | 0 | 0 | 0 |
| examples/stdlib/matmul.bot | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| examples/stdlib/string_replace.bot | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 4 | 0 |
| examples/stdlib/string_reverse.bot | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 1 | 0 |
| examples/surface/01-arithmetic.bot | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| examples/surface/02-recursion.bot | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| examples/surface/03-closure.bot | 0 | 1 | 2 | 0 | 1 | 1 | 0 | 0 | 0 | 0 |
| examples/surface/04-branch-value.bot | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| examples/surface/05-shadowing.bot | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| examples/surface/06-list.bot | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| examples/surface/07-loop-break.bot | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| examples/surface/08-return.bot | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| examples/surface/09-mutual-recursion.bot | 0 | 0 | 4 | 0 | 2 | 2 | 0 | 0 | 0 | 0 |
| examples/surface/10-duplicate-binding.bot | (not lowerable: examples/surface/10-duplicate-binding.bot:7:1: duplicate bind) |||||||||
| examples/surface/11-boolean-operators.bot | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| examples/surface/12-if-value.bot | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| examples/surface/13-hygiene.bot | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| examples/surface/14-modules.bot | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
