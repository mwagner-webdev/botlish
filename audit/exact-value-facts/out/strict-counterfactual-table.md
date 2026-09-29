| site | previous required workaround | category | after exact-value milestone | reason |
|---|---|---|---|---|
| `bench/lex-strategy.bot:57:20` | as_str | generic relationship | still necessary | `c` is an element of `chars_of(token, 0, [])`, whose result is its caller's accumulator (a relational type); annotation candidate `chars_of result` |
| `bench/lex-strategy.bot:79:63` | as_str | genuine annotation | still necessary | `list_get(tokens, i)`: `tokens` is an untyped parameter, index `i` is not exact and no literal reaches it; annotation candidate `total_valid tokens` |
| `bench/source-checks.bot:89:40` | annotation | generic relationship | still necessary | callable with typed parameter requirements erased into `list::find` |
| `bench/test-selection.bot:57:16` | as_list | record-shaped List / struct | still necessary | `test_deps(test)` = `list_get(test, 1)` of the positional `[name, deps]` record: the parameter is arbitrary |
| `bench/test-selection.bot:61:26` | as_list | genuine annotation | still necessary | loop element of untyped `tests` (`select_affected tests`); its elements are the positional records |
| `bench/test-selection.bot:71:15` | as_list | generic relationship | still necessary | `found` is `list::find`'s result (the handler's literal `["<none>", []]` is joined with `any`) |
| `bench/test-selection.bot:68:31` | annotation | generic relationship | still necessary | `is_affected?` erased into `list::find` |
| `lib/web.bot:204:70` | as_int | genuine annotation | still necessary | `list_get(bytes, i)`, `bytes` an untyped parameter; annotation candidate `esc_bytes bytes` |
| `examples/stdlib/csv.bot:66:28` | as_int | record-shaped List / struct | still necessary | `[field, index]` scan pair: `scanned` is a function result (`scan_field`/`scan_record`), not a locally known aggregate |
| `examples/stdlib/csv.bot:81:24` | as_int | record-shaped List / struct | still necessary | `[field, index]` scan pair: `scanned` is a function result (`scan_field`/`scan_record`), not a locally known aggregate |
| `examples/stdlib/csv_chunked.bot:106:28` | as_int | record-shaped List / struct | still necessary | `[field, index]` scan pair: `scanned` is a function result (`scan_field`/`scan_record`), not a locally known aggregate |
| `examples/stdlib/csv_chunked.bot:120:24` | as_int | record-shaped List / struct | still necessary | `[field, index]` scan pair: `scanned` is a function result (`scan_field`/`scan_record`), not a locally known aggregate |
| `examples/stdlib/csv_geometric.bot:52:22` | as_mutarray | record-shaped List / struct | still necessary | `[storage, length]` builder pair read with `list_get(builder, 0/1)` in `geo_append`; `storage` is also a MutableArray |
| `examples/stdlib/csv_geometric.bot:52:31` | as_int | record-shaped List / struct | still necessary | `[storage, length]` builder pair read with `list_get(builder, 0/1)` in `geo_append`; `storage` is also a MutableArray |
| `examples/stdlib/csv_geometric.bot:101:28` | as_int | record-shaped List / struct | still necessary | `[field, index]` scan pair: `scanned` is a function result (`scan_field`/`scan_record`), not a locally known aggregate |
| `examples/stdlib/csv_geometric.bot:115:24` | as_int | record-shaped List / struct | still necessary | `[field, index]` scan pair: `scanned` is a function result (`scan_field`/`scan_record`), not a locally known aggregate |
| `examples/stdlib/csv_records.bot:126:22` | as_mutarray | record-shaped List / struct | still necessary | `[storage, length]` builder pair read with `list_get(builder, 0/1)` in `geo_append`; `storage` is also a MutableArray |
| `examples/stdlib/csv_records.bot:126:31` | as_int | record-shaped List / struct | still necessary | `[storage, length]` builder pair read with `list_get(builder, 0/1)` in `geo_append`; `storage` is also a MutableArray |
| `examples/stdlib/csv_records.bot:172:28` | as_int | record-shaped List / struct | still necessary | `[field, index]` scan pair: `scanned` is a function result (`scan_field`/`scan_record`), not a locally known aggregate |
| `examples/stdlib/csv_records.bot:186:24` | as_int | record-shaped List / struct | still necessary | `[field, index]` scan pair: `scanned` is a function result (`scan_field`/`scan_record`), not a locally known aggregate |
| `examples/stdlib/csv_records.bot:311:29` | as_mutarray | record-shaped List / struct | still necessary | `dest` is the positional `[newControls, newKeys, newValues]` record; the slot is a MutableArray |
| `examples/stdlib/csv_records.bot:416:46` | as_list | generic relationship | still necessary | element of the `records` accumulator returned through recursion (`csv_parse`'s result type is relational) |
| `examples/stdlib/csv_records.bot:429:28` | as_list | generic relationship | still necessary | element of the `records` accumulator returned through recursion (`csv_parse`'s result type is relational) |
| `examples/stdlib/csv_records.bot:452:20` | as_mutarray | MutableArray | still necessary | `first`/`second` are `list_get(rows, i)`: a MutableArray table read out of a List of tables |
| `examples/stdlib/csv_records.bot:452:45` | as_mutarray | MutableArray | still necessary | `first`/`second` are `list_get(rows, i)`: a MutableArray table read out of a List of tables |
| `examples/stdlib/csv_records.bot:452:81` | as_mutarray | MutableArray | still necessary | `first`/`second` are `list_get(rows, i)`: a MutableArray table read out of a List of tables |
| `examples/stdlib/csv_records.bot:452:99` | as_mutarray | MutableArray | still necessary | `first`/`second` are `list_get(rows, i)`: a MutableArray table read out of a List of tables |
| `examples/stdlib/csv_records.bot:453:32` | as_mutarray | MutableArray | still necessary | `first`/`second` are `list_get(rows, i)`: a MutableArray table read out of a List of tables |
| `examples/stdlib/csv_records.bot:453:55` | as_mutarray | MutableArray | still necessary | `first`/`second` are `list_get(rows, i)`: a MutableArray table read out of a List of tables |
| `examples/stdlib/csv_records.bot:453:77` | as_mutarray | MutableArray | still necessary | `first`/`second` are `list_get(rows, i)`: a MutableArray table read out of a List of tables |
| `examples/stdlib/csv_records.bot:453:100` | as_mutarray | MutableArray | still necessary | `first`/`second` are `list_get(rows, i)`: a MutableArray table read out of a List of tables |
| `examples/stdlib/csv_records.bot:453:124` | as_mutarray | MutableArray | still necessary | `first`/`second` are `list_get(rows, i)`: a MutableArray table read out of a List of tables |
| `examples/stdlib/hashtable.bot:226:29` | as_mutarray | record-shaped List / struct | still necessary | `dest` is the positional `[newControls, newKeys, newValues]` record; the slot is a MutableArray |
| `examples/stdlib/hashtable.bot:362:47` | annotation | generic relationship | still necessary | `ht_collect_pair` erased into `ht_fold` |
| `examples/stdlib/matmul.bot:38:23` | as_list | genuine annotation | still necessary | `list_get(a, i)`: `a` is an untyped matrix parameter (List[List[int]], homogeneous, not a record) |
