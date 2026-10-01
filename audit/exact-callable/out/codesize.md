| program | functions before | functions after | bytes before | bytes after | delta |
|---|---:|---:|---:|---:|---:|
| bench/fib | 2 | 2 | 292 | 292 | +0 |
| bench/loop-count | 3 | 3 | 287 | 287 | +0 |
| bench/refined-checks | 24 | 26 | 8903 | 9089 | +186 |
| bench/sum-refined | 3 | 3 | 286 | 286 | +0 |
| examples-stdlib/ai_text_clean | 5 | 5 | 3081 | 3081 | +0 |
| examples-stdlib/csv | 11 | 11 | 5723 | 5723 | +0 |
| examples-stdlib/csv_chunked | 20 | 20 | 10168 | 10168 | +0 |
| examples-stdlib/csv_geometric | 20 | 20 | 7578 | 7578 | +0 |
| examples-stdlib/csv_records | 56 | 56 | 23245 | 23245 | +0 |
| examples-stdlib/hashtable | 26 | 26 | 12732 | 12732 | +0 |
| examples-stdlib/matmul | 7 | 7 | 4734 | 4734 | +0 |
| examples-stdlib/string_replace | 4 | 4 | 2618 | 2618 | +0 |
| examples-stdlib/string_reverse | 3 | 3 | 990 | 990 | +0 |
| **total** | | | 80637 | 80823 | +186 (+0.23%) |

### bench/refined-checks
| function | before | after |
|---|---:|---:|
| `domain?<generic>` | 1244 | 1076 |
| `local_char?<str>` | - | 176 |
| `scan_while<any, block(e239)>` | - | 440 |
| `scan_while<any, native(is_tcl_alpha)>` | - | 456 |
| `scan_while<generic>` | 496 | - |
| `web::emailish?<str>` | 601 | 379 |

