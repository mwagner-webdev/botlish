## A. The library's claims, checked from each caller alone

Modular checker (definition level, no certificate store):

| claim | safe | full | invalid | compose | unused |
|---|---|---|---|---|---|
| `emitlib::digit_checked` digit_symbol | proven | proven | proven | proven | proven |
| `emitlib::digit_checked_source` digit_symbol | proven | proven | proven | proven | proven |
| `emitlib::digit_of` digit_symbol | proven | proven | proven | proven | proven |
| `emitlib::digit_unchecked` digit_symbol | disproven | disproven | disproven | disproven | disproven |
| `emitlib::json_string` json_string_strict | proven | proven | proven | proven | proven |
| `emitlib::json_string_source` json_string_strict | proven | proven | proven | proven | proven |
| `emitlib::member` json_text | proven | proven | proven | proven | proven |
| `emitlib::pair_glued` json_text | disproven | disproven | disproven | disproven | disproven |

The same checker with observed facts (`-facts observed`: each claim entered with what the program's own calls pass -- the exploratory model, for comparison):

| claim | safe | full | invalid | compose | unused |
|---|---|---|---|---|---|
| `emitlib::digit_checked` digit_symbol | proven | proven | proven | not-proved | not-proved |
| `emitlib::digit_checked_source` digit_symbol | not-proved | proven | proven | not-proved | not-proved |
| `emitlib::digit_of` digit_symbol | proven | not-proved | not-proved | not-proved | not-proved |
| `emitlib::digit_unchecked` digit_symbol | proven | not-proved | not-proved | not-proved | not-proved |
| `emitlib::json_string` json_string_strict | proven | proven | not-proved | proven | not-proved |
| `emitlib::json_string_source` json_string_strict | not-proved | proven | not-proved | not-proved | not-proved |
| `emitlib::member` json_text | not-proved | not-proved | not-proved | proven | not-proved |
| `emitlib::pair_glued` json_text | not-proved | not-proved | not-proved | not-proved | not-proved |

Exploratory checker (EMITTER-COROUTINE-EXPLORATION.md: facts of the program's own calls):

| claim | safe | full | invalid | compose | unused |
|---|---|---|---|---|---|
| `emitlib::digit_checked` digit_symbol | proved | proved | proved | EMIT-UNUSED | EMIT-UNUSED |
| `emitlib::digit_checked_source` digit_symbol | EMIT-UNUSED | proved | proved | EMIT-UNUSED | EMIT-UNUSED |
| `emitlib::digit_of` digit_symbol | proved | EMIT-UNUSED | EMIT-UNUSED | EMIT-UNUSED | EMIT-UNUSED |
| `emitlib::digit_unchecked` digit_symbol | proved | EMIT-REJECTED | EMIT-REJECTED | EMIT-UNUSED | EMIT-UNUSED |
| `emitlib::json_string` json_string_strict | EMIT-NOT-SYMBOL | EMIT-NOT-SYMBOL | EMIT-UNUSED | EMIT-NOT-SYMBOL | EMIT-UNUSED |
| `emitlib::json_string_source` json_string_strict | EMIT-UNUSED | EMIT-NOT-SYMBOL | EMIT-UNUSED | EMIT-UNUSED | EMIT-UNUSED |
| `emitlib::member` json_text | EMIT-UNUSED | EMIT-UNUSED | EMIT-UNUSED | EMIT-NOT-SYMBOL | EMIT-UNUSED |
| `emitlib::pair_glued` json_text | EMIT-UNUSED | EMIT-UNUSED | EMIT-UNUSED | EMIT-UNUSED | EMIT-UNUSED |

compose.bot's own claims (through the library's certificates): digits: proven, object: proven

Time per caller (ms): modular total / its front end / its check (no counterexample search); exploratory total:

| caller | modular | front end | check | exploratory |
|---|---:|---:|---:|---:|
| safe | 3250 | 3147 | 101 | 3405 |
| full | 3476 | 3364 | 111 | 4054 |
| invalid | 3077 | 2899 | 176 | 3444 |
| compose | 3282 | 3133 | 147 | 3355 |
| unused | 3288 | 3182 | 104 | 3004 |

## B. One certificate store across the five compilations

| caller | proved | reused | check ms |
|---|---:|---:|---:|
| safe | 10 | 0 | 98 |
| full | 0 | 10 | 20 |
| invalid | 0 | 10 | 20 |
| compose | 2 | 10 | 79 |
| unused | 0 | 10 | 18 |

## C. Invalidation (store of B, checked from unused.bot)

| change | re-proved | reused | not proven | check ms |
|---|---|---:|---|---:|
| a comment changed in emitlib.bot |  | 10 | emitlib::digit_unchecked digit_symbol (not-proved), emitlib::pair_glued json_text (not-proved) | 19 |
| a new, unrelated caller program |  | 10 | emitlib::digit_unchecked digit_symbol (not-proved), emitlib::pair_glued json_text (not-proved) | 40 |
| json_string's policy: '/' escaped as \/ | `emitlib::json_string` | 9 | emitlib::digit_unchecked digit_symbol (not-proved), emitlib::pair_glued json_text (not-proved) | 61 |
| a helper's code: hex_digit's letters uppercase | `emitlib::json_string` | 9 | emitlib::digit_unchecked digit_symbol (not-proved), emitlib::pair_glued json_text (not-proved) | 57 |
| the recognizer: json_lex's escapes lose `\/` | `emitlib::json_string`, `emitlib::member`, `emitlib::json_string_source` | 7 | emitlib::digit_unchecked digit_symbol (not-proved), emitlib::pair_glued json_text (not-proved) | 93 |
| number_emit's helper: magnitude's loop written another way | `number_emit::integer` | 9 | emitlib::digit_unchecked digit_symbol (not-proved), emitlib::pair_glued json_text (not-proved) | 38 |

## D. Invocation level: `emitlib::digit_unchecked` where it is called

| program | caller | arguments there | verdict |
|---|---|---|---|
| safe.bot | `src_unchecked` | 3 | proven |
| invalid.bot | `src_bad` | -1 | not-proved |
| unused.bot | `emitlib::digit_unchecked_source` | -inf..+inf | not-proved |
