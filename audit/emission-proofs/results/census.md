## Modular cases

| case | claim | modular | observed facts | exploratory | concrete truth | finding |
|---|---|---|---|---|---|---|
| `caller-only-safe-digit` | `digit` | disproven | proven | proved | false for (0) | exploratory false proof: caller facts |
| `caller-only-safe-arith` | `hexchar` | disproven | proven | proved | false for (-1) | exploratory false proof: caller facts |
| `unused-correct` | `digit_of_nibble` | proven | not-proved | unused | no counterexample found | exploratory had no facts |
| `unused-wrong` | `digit_wrong` | disproven | not-proved | unused | false for (10) | exploratory had no facts |
| `unrelated-helper-caller` | `emit_digit` | proven | proven | proved | no counterexample found | agree |
| `domain-parameter` | `digit_value` | proven | not-proved | unused | no counterexample found | exploratory had no facts |
| `fail-after-yield-handled` | `s` | disproven | not-proved | proved | false for (1) | exploratory false proof: unsound rule |
| `sentinel-overflow` | `big` | disproven | not-proved | proved | false for () | exploratory false proof: unsound rule |
| `guard-handler-continues` | `g` | disproven | proven | proved | false for (0) | exploratory false proof: caller facts |
| `guard-other-binding` | `g2` | disproven | proven | proved | false for (48, -2) | exploratory false proof: caller facts |
| `guard-derived-value` | `g3` | disproven | proven | proved | false for (57) | exploratory false proof: caller facts |
| `separate-coroutine-ignored` | `outer` | proven | proven | proved | no counterexample found | agree |
| `forwarded-values` | `forward` | not-proved | not-proved | rejected | no counterexample found | agree |
| `zero-iterations` | `digits` | disproven | proven | rejected | false for (0) | agree |
| `recursion-may-be-empty` | `ones` | disproven | not-proved | rejected | false for (0) | agree |
| `recursion-may-be-empty` | `ones1` | proven | proven | proved | no counterexample found | agree |
| `never-returns` | `forever` | proven | proven | proved | no counterexample found | agree |
| `adjacent-numbers` | `pair` | disproven | not-proved | rejected | false for (0, 0) | agree |
| `lookahead-two` | `abc` | disproven | not-proved | rejected | false for () | agree |
| `lookahead-two` | `ab_only` | proven | proven | proved | no counterexample found | agree |
| `caught-before-yield` | `safe` | proven | proven | proved | no counterexample found | agree |
| `caught-after-prefix` | `twice` | disproven | not-proved | proved | false for (1) | exploratory false proof: unsound rule |
| `end-yield-negative` | `m` | disproven | proven | proved | false for (0) | exploratory false proof: caller facts |

| finding | claims |
|---|---:|
| exploratory false proof: caller facts | 6 |
| exploratory had no facts | 3 |
| agree | 11 |
| exploratory false proof: unsound rule | 3 |

## The exploratory census under the modular checker

| case | exploratory | modular kinds | modular verdicts of failing claims | agrees |
|---|---|---|---|---|
| `plus-sign` | EMIT-REJECTED | EMIT-REJECTED | integer: disproven (1); integer_source: disproven (1); value: not-proved; value_stacked: not-proved; 2 more | yes |
| `minus-only` | EMIT-INCOMPLETE | EMIT-INCOMPLETE, EMIT-REJECTED | integer: disproven (-1); integer_source: disproven (-1); value: not-proved; value_stacked: not-proved; 2 more | yes |
| `exponent-sign-end` | EMIT-INCOMPLETE | EMIT-INCOMPLETE, EMIT-REJECTED | integer: disproven (-1); integer_source: disproven (-1); value: not-proved; value_stacked: not-proved; 2 more | yes |
| `leading-zero` | EMIT-REJECTED | EMIT-REJECTED | integer: disproven (-1); integer_source: disproven (-1); value: not-proved; value_stacked: not-proved; 2 more | yes |
| `leading-digit-latent` | EMIT-REJECTED | EMIT-REJECTED | integer: not-proved; integer_source: not-proved; value: not-proved; value_stacked: not-proved; 2 more | yes |
| `digit-overflow` | EMIT-REJECTED | EMIT-REJECTED | integer: not-proved; integer_source: not-proved; value: not-proved; value_stacked: not-proved; 2 more | yes |
| `wrong-digit-value` | accepted | accepted |  | yes |
| `unguarded-text` | EMIT-REJECTED | EMIT-INCOMPLETE, EMIT-REJECTED | integer_text: not-proved; integer_text_source: not-proved | yes |
| `weak-guard` | EMIT-REJECTED | EMIT-REJECTED | integer_text: not-proved; integer_text_source: not-proved | yes |
| `terminal-value` | EMIT-TERMINAL-VALUE | EMIT-TERMINAL-VALUE | integer_source: not-proved | yes |
| `end-as-symbol` | EMIT-END-SYMBOL | EMIT-END-SYMBOL | integer: disproven (0); integer_source: disproven (0); value: not-proved; value_stacked: not-proved; 2 more | yes |
| `unclosed-string` | EMIT-INCOMPLETE | EMIT-BOUNDARY, EMIT-INCOMPLETE | string: disproven (""); string: disproven (""); string_source: disproven (""); value: not-proved; 3 more | yes |
| `after-token` | EMIT-AFTER-TOKEN | EMIT-AFTER-TOKEN | string: disproven (""); string: disproven (""); string_source: disproven ("") | yes |
| `raw-controls` | EMIT-REJECTED | EMIT-REJECTED | string: disproven ("\n"); string: disproven ("\n"); string_codes: disproven ([0]); string_codes: disproven ([0]); 6 more | yes |
| `raw-backslash` | EMIT-REJECTED | EMIT-AFTER-TOKEN, EMIT-BOUNDARY, EMIT-INCOMPLETE, EMIT-REJECTED | string: disproven ("\\"); string: disproven ("\\"); string_codes: not-proved; string_codes: not-proved; 6 more | yes |
| `short-unicode-escape` | EMIT-REJECTED | EMIT-REJECTED | string: disproven (""); string: disproven (""); string_ascii: disproven (""); string_ascii: disproven (""); 11 more | yes |
| `hex-digit-off-by-one` | EMIT-REJECTED | EMIT-REJECTED | string: not-proved; string: not-proved; string_ascii: not-proved; string_ascii: not-proved; 11 more | yes |
| `surrogate-scalar` | EMIT-REJECTED | EMIT-REJECTED | string_codes: disproven ([55296]); string_codes: disproven ([55296]); string_codes_source: disproven ([55296]) | yes |
| `unchecked-codes` | EMIT-REJECTED | EMIT-END-SYMBOL, EMIT-REJECTED | string_codes: disproven ([-1]); string_codes: disproven ([-1]); string_codes_source: disproven ([-1]) | yes |
| `bytes-unencoded` | EMIT-BYTE-CHARACTER,EMIT-REJECTED | EMIT-BYTE-CHARACTER, EMIT-REJECTED | string_bytes: disproven ("é"); string_bytes_source: disproven ("é") | yes |
| `byte-out-of-range` | EMIT-REJECTED | EMIT-REJECTED | string_bytes: disproven ("é"); string_bytes_source: disproven ("é") | yes |
| `utf8-by-length` | EMIT-REJECTED | EMIT-REJECTED | string_bytes: not-proved; string_bytes_source: not-proved | yes |
| `strict-escape-unsplit` | EMIT-REJECTED | EMIT-REJECTED | string_ascii: not-proved; string_ascii_source: not-proved | yes |
| `missing-separator` | EMIT-BOUNDARY | EMIT-BOUNDARY, EMIT-REJECTED | value: not-proved; text_source: not-proved | yes |
| `missing-colon` | accepted | accepted |  | yes |
| `unbalanced` | accepted | accepted |  | yes |
| `flat-serializer` | EMIT-REJECTED | EMIT-BOUNDARY, EMIT-REJECTED | flat_source: not-proved | yes |
| `never-completes` | accepted | accepted |  | yes |
| `corrupted-text` | accepted | accepted |  | yes |
| `surrogate-input` | accepted | accepted |  | yes |
| `member-out-of-range` | accepted | accepted |  | yes |

31 of 31 cases: the modular checker rejects exactly the cases the exploratory one rejected.
