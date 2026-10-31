## Checking check_all.bot's 22 claims (ms, median of 3)

| checker | front end | check | summaries computed | summaries reused | solve rounds | of the check: composing, certifying (ms) |
|---|---:|---:|---:|---:|---:|---|
| exploratory: whole run | 7663 (front end, specialization and range analysis) | 1590 | - | - | - | - |
| modular, certificates, summaries shared | 7177 | 372 | 140 | 60 | 44 | 87, 32 |
| modular, bodies, summaries shared | 7098 | 279 | 148 | 54 | 44 | 0, 31 |
| modular, every claim from scratch (one run per function) | - | 1169 | 348 | 0 | - | - |

Per claim (the default run, in order; a claim's summaries include those an earlier claim made final):

| claim | ms | summaries reachable | computed | reused |
|---|---:|---:|---:|---:|
| `number_emit::integer` json_number | 23.4 | 5 | 10 | 0 |
| `number_emit::integer_text` json_number | 7.0 | 1 | 2 | 0 |
| `string_emit::string` json_string | 15.4 | 5 | 10 | 0 |
| `string_emit::string` json_string_strict | 14.6 | 5 | 10 | 0 |
| `string_emit::string_ascii` json_string | 27.8 | 13 | 20 | 10 |
| `string_emit::string_ascii` json_string_strict | 32.8 | 17 | 28 | 6 |
| `string_emit::string_bytes` json_string_bytes | 37.0 | 6 | 12 | 0 |
| `string_emit::string_codes` json_string | 10.6 | 5 | 2 | 4 |
| `string_emit::string_codes` json_string_strict | 9.7 | 5 | 2 | 4 |
| `value_emit::literal_null` json_literal | 1.9 | 1 | 2 | 0 |
| `value_emit::literal_true` json_literal | 1.7 | 1 | 2 | 0 |
| `value_emit::literal_false` json_literal | 1.8 | 1 | 2 | 0 |
| `number_emit::integer_source` json_number | 5.3 | 1 | 3 | 1 |
| `number_emit::integer_text_source` json_number | 2.7 | 1 | 2 | 2 |
| `string_emit::string_source` json_string | 9.0 | 1 | 4 | 2 |
| `string_emit::string_ascii_source` json_string_strict | 15.3 | 1 | 4 | 2 |
| `string_emit::string_bytes_source` json_string_bytes | 6.6 | 1 | 3 | 1 |
| `string_emit::string_codes_source` json_string | 0.8 | 1 | 2 | 4 |
| `value_emit::value` json_text | 50.9 | 2 | 10 | 12 |
| `value_emit::value_stacked` json_text | 55.1 | 3 | 4 | 10 |
| `value_emit::text_source` json_text | 49.7 | 1 | 3 | 1 |
| `value_emit::stacked_source` json_text | 41.8 | 1 | 3 | 1 |

## The library from a program that calls none of it (ms)

| run | front end | check |
|---|---:|---:|
| no store | 3278 | 127 |
| store, first compilation (proves, writes) | 3073 | 149 |
| store, next compilation (validates, reuses) | 2923 | 20 (validation 6) |
| with the counterexample search (2 claims disproven) | 2883 | 7800 |

## Run time (cranelift, fused; ns per emitted symbol, best of 5)

| workload | what | symbols | ns/symbol |
|---|---|---:|---:|
| `digits_domain` | digit_of: proved from the declared domain, no check | 20000 | 11.0 |
| `digits_guarded` | digit_checked: a guard per symbol | 20000 | 16.6 |
| `digits_unchecked` | digit_unchecked: no check, no certificate | 20000 | 10.4 |
| `digits_validated` | digit_unchecked fed to the recognizer as emitted | 20000 | 15.8 |
| `strings_static` | json_string: proved, no check | 52500 | 24.0 |
| `strings_validated` | json_string fed to json_string_strict as emitted | 52500 | 31.9 |
