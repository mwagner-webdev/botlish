# Emission claims: the census

## The modular census

| case | claim | compiler | prototype | exploratory | concrete truth | finding |
|---|---|---|---|---|---|---|
| `caller-only-safe-digit` | `digit` | rejected | disproven | proved | false for (0) | rejected, disproven by a run |
| `caller-only-safe-arith` | `hexchar` | rejected | disproven | proved | false for (-1) | rejected, disproven by a run |
| `unused-correct` | `digit_of_nibble` | proven | proven | unused | no counterexample found | certified |
| `unused-wrong` | `digit_wrong` | rejected | disproven | unused | false for (10) | rejected, disproven by a run |
| `unrelated-helper-caller` | `emit_digit` | proven | proven | proved | no counterexample found | certified |
| `domain-parameter` | `digit_value` | proven | proven | unused | no counterexample found | certified |
| `fail-after-yield-handled` | `s` | rejected | disproven | proved | false for (1) | rejected, disproven by a run |
| `sentinel-overflow` | `big` | rejected | disproven | proved | false for () | rejected, disproven by a run |
| `guard-handler-continues` | `g` | rejected | disproven | proved | false for (0) | rejected, disproven by a run |
| `guard-other-binding` | `g2` | rejected | disproven | proved | false for (48, -2) | rejected, disproven by a run |
| `guard-derived-value` | `g3` | rejected | disproven | proved | false for (57) | rejected, disproven by a run |
| `separate-coroutine-ignored` | `outer` | proven | proven | proved | no counterexample found | certified |
| `forwarded-values` | `seven` | proven | - | - | no counterexample found | certified |
| `forwarded-values` | `forward` | rejected | not-proved | rejected | no counterexample found | not certified, no counterexample found |
| `zero-iterations` | `digits` | rejected | disproven | rejected | false for (0) | rejected, disproven by a run |
| `recursion-may-be-empty` | `ones` | rejected | disproven | rejected | false for (0) | rejected, disproven by a run |
| `recursion-may-be-empty` | `ones1` | proven | proven | proved | no counterexample found | certified |
| `never-returns` | `forever` | proven | proven | proved | no counterexample found | certified |
| `adjacent-numbers` | `pair` | rejected | disproven | rejected | false for (0, 0) | rejected, disproven by a run |
| `lookahead-two` | `abc` | rejected | disproven | rejected | false for () | rejected, disproven by a run |
| `lookahead-two` | `ab_only` | proven | proven | proved | no counterexample found | certified |
| `caught-before-yield` | `guarded` | proven | - | - | no counterexample found | certified |
| `caught-before-yield` | `safe` | proven | proven | proved | no counterexample found | certified |
| `caught-after-prefix` | `twice` | rejected | disproven | proved | false for (1) | rejected, disproven by a run |
| `end-yield-negative` | `m` | rejected | disproven | proved | false for (0) | rejected, disproven by a run |

| finding | claims |
|---|---:|
| rejected, disproven by a run | 14 |
| certified | 10 |
| not certified, no counterexample found | 1 |

## The exploratory census's mistakes

| mistake | file | exploratory | compiler (claims of emit_probes.bot not proven, their kinds) | agrees |
|---|---|---|---|---|
| `plus-sign` | number_emit.bot | EMIT-REJECTED | rejected: EMIT-REJECTED | yes |
| `minus-only` | number_emit.bot | EMIT-INCOMPLETE | rejected: EMIT-INCOMPLETE, EMIT-REJECTED | yes |
| `exponent-sign-end` | number_emit.bot | EMIT-INCOMPLETE | rejected: EMIT-INCOMPLETE, EMIT-REJECTED | yes |
| `leading-zero` | number_emit.bot | EMIT-REJECTED | rejected: EMIT-REJECTED | yes |
| `leading-digit-latent` | number_emit.bot | EMIT-REJECTED | rejected: EMIT-REJECTED | yes |
| `digit-overflow` | number_emit.bot | EMIT-REJECTED | rejected: EMIT-REJECTED | yes |
| `wrong-digit-value` | number_emit.bot | accepted | accepted | yes |
| `unguarded-text` | number_emit.bot | EMIT-REJECTED | rejected: EMIT-INCOMPLETE, EMIT-REJECTED | yes |
| `weak-guard` | number_emit.bot | EMIT-REJECTED | rejected: EMIT-REJECTED | yes |
| `terminal-value` | number_emit.bot | EMIT-TERMINAL-VALUE | rejected: EMIT-TERMINAL-VALUE | yes |
| `end-as-symbol` | number_emit.bot | EMIT-END-SYMBOL | rejected: EMIT-END-SYMBOL | yes |
| `unclosed-string` | string_emit.bot | EMIT-INCOMPLETE | rejected: EMIT-BOUNDARY, EMIT-INCOMPLETE | yes |
| `after-token` | string_emit.bot | EMIT-AFTER-TOKEN | rejected: EMIT-AFTER-TOKEN | yes |
| `raw-controls` | string_emit.bot | EMIT-REJECTED | rejected: EMIT-REJECTED | yes |
| `raw-backslash` | string_emit.bot | EMIT-REJECTED | rejected: EMIT-AFTER-TOKEN, EMIT-BOUNDARY, EMIT-INCOMPLETE, EMIT-REJECTED | yes |
| `short-unicode-escape` | string_emit.bot | EMIT-REJECTED | rejected: EMIT-REJECTED | yes |
| `hex-digit-off-by-one` | string_emit.bot | EMIT-REJECTED | rejected: EMIT-REJECTED | yes |
| `surrogate-scalar` | string_emit.bot | EMIT-REJECTED | rejected: EMIT-REJECTED | yes |
| `unchecked-codes` | string_emit.bot | EMIT-REJECTED | rejected: EMIT-END-SYMBOL, EMIT-REJECTED | yes |
| `bytes-unencoded` | string_emit.bot | EMIT-BYTE-CHARACTER,EMIT-REJECTED | rejected: EMIT-BYTE-CHARACTER, EMIT-REJECTED | yes |
| `byte-out-of-range` | string_emit.bot | EMIT-REJECTED | rejected: EMIT-REJECTED | yes |
| `utf8-by-length` | string_emit.bot | EMIT-REJECTED | rejected: EMIT-REJECTED | yes |
| `strict-escape-unsplit` | string_emit.bot | EMIT-REJECTED | rejected: EMIT-REJECTED | yes |
| `missing-separator` | value_emit.bot | EMIT-BOUNDARY | rejected: EMIT-BOUNDARY, EMIT-REJECTED | yes |
| `missing-colon` | value_emit.bot | accepted | accepted | yes |
| `unbalanced` | value_emit.bot | accepted | accepted | yes |
| `flat-serializer` | value_emit.bot | EMIT-REJECTED | rejected: EMIT-BOUNDARY, EMIT-REJECTED | yes |
| `never-completes` | number_emit.bot | accepted | accepted | yes |
| `corrupted-text` | number_emit.bot | accepted | accepted | yes |
| `surrogate-input` | emit_probes.bot | accepted | accepted | yes |
| `member-out-of-range` | value_emit.bot | accepted | accepted | yes |

31 of 31 decided as the exploratory checker decided.

