
## default

| program | String objects old | String objects new | heap allocs old | heap allocs new | text-buffer allocs old | text-buffer allocs new | frees old | frees new | bytes old | bytes new | empty reuses |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| ai_text_clean | 109 | 109 | 218 | 109 | 109 | 0 | 218 | 109 | 4534 | 2899 | 0 |
| csv | 6 | 6 | 12 | 6 | 6 | 0 | 12 | 6 | 259 | 169 | 0 |
| csv_chunked | 6 | 6 | 12 | 6 | 6 | 0 | 12 | 6 | 259 | 169 | 0 |
| csv_geometric | 6 | 6 | 12 | 6 | 6 | 0 | 12 | 6 | 259 | 169 | 0 |
| csv_records | 18 | 18 | 36 | 18 | 18 | 0 | 36 | 18 | 792 | 522 | 0 |
| lex-strategy | 198 | 198 | 396 | 198 | 198 | 0 | 396 | 198 | 8121 | 5151 | 0 |
| refined-checks | 6807 | 6807 | 13614 | 6807 | 6807 | 0 | 13614 | 6807 | 279497 | 177392 | 0 |
| source-checks | 21 | 21 | 42 | 21 | 21 | 0 | 42 | 21 | 864 | 549 | 0 |
| string_replace | 35 | 32 | 67 | 32 | 32 | 0 | 67 | 32 | 1501 | 901 | 3 |
| string_reverse | 4 | 4 | 8 | 4 | 4 | 0 | 8 | 4 | 174 | 114 | 0 |
| uri-steady | 16000 | 16000 | 32000 | 16000 | 16000 | 0 | 32000 | 16000 | 686000 | 446000 | 0 |
| **total** | 23210 | 23207 | 46417 | 23207 | 23207 | 0 | 46417 | 23207 | 982260 | 634035 | 3 |

## off

| program | String objects old | String objects new | heap allocs old | heap allocs new | text-buffer allocs old | text-buffer allocs new | frees old | frees new | bytes old | bytes new | empty reuses |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| ai_text_clean | 61 | 61 | 122 | 61 | 61 | 0 | 122 | 61 | 2566 | 1651 | 0 |
| csv | 6 | 6 | 12 | 6 | 6 | 0 | 12 | 6 | 259 | 169 | 0 |
| csv_chunked | 6 | 6 | 12 | 6 | 6 | 0 | 12 | 6 | 259 | 169 | 0 |
| csv_geometric | 6 | 6 | 12 | 6 | 6 | 0 | 12 | 6 | 259 | 169 | 0 |
| csv_records | 18 | 18 | 36 | 18 | 18 | 0 | 36 | 18 | 792 | 522 | 0 |
| lex-strategy | 198 | 198 | 396 | 198 | 198 | 0 | 396 | 198 | 8121 | 5151 | 0 |
| refined-checks | 6804 | 6804 | 13608 | 6804 | 6804 | 0 | 13608 | 6804 | 279368 | 177308 | 0 |
| source-checks | 21 | 21 | 42 | 21 | 21 | 0 | 42 | 21 | 864 | 549 | 0 |
| string_replace | 5 | 3 | 8 | 3 | 3 | 0 | 8 | 3 | 208 | 83 | 2 |
| string_reverse | 4 | 4 | 8 | 4 | 4 | 0 | 8 | 4 | 174 | 114 | 0 |
| uri-steady | 16000 | 16000 | 32000 | 16000 | 16000 | 0 | 32000 | 16000 | 686000 | 446000 | 0 |
| **total** | 23129 | 23127 | 46256 | 23127 | 23127 | 0 | 46256 | 23127 | 978870 | 631885 | 2 |
