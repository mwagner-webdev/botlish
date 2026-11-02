## Costs (ms, median of 3 runs, each a fresh process)

**examples/dfa/json/emit_probes.bot's 22 claims** (the prototype's check_all.bot):

| measure | integrated | prototype (MODULAR-EMISSION-PROOFS-MILESTONE-1.md) |
|---|---:|---:|
| check, summaries shared | 399.637 | 372 |
| of it: products with certificates' languages | 93.742 | 87 |
| of it: certificates | 52.8 | 32 |
| each claim checked alone, fresh state | 797.634 | 1169 |
| summaries computed / reused (shared) | 140 / 60 | 140 / 60 |
| summaries computed (each alone) | 448 | 348 |
| fixpoint rounds | 44 | 44 |
| whole compilation with the claims | 5105.942 | - |
| whole compilation, claims removed | 3558.465 | - |

**examples/dfa/json/emitlib.bot from a program that calls none of it** (10 claims, number_emit's among them):

| measure | integrated | prototype |
|---|---:|---:|
| check, no memo | 100.193 | 127 |
| check, a later compilation reusing the memo's certificates | 16.86 | 20 |
| of it: validation | 7.432 | 6 |
| certificates reused | 10 | 10 |
| check after a helper's change (hex_digit) | 53.07 | 59 |
| claims re-proved after it | 1 | 1 |
| check per imported, uncalled claim | 10.0 | - |

**A rejected claim's diagnostics** (invalid_emitter.bot): check 53.154 ms, 2 diagnostics.

**Interchange** (emit_probes.bot): 1914947 bytes with its claims' records, 1869862 without claims (2.4% more); decoding re-proves: 382.341 ms.

**Native code** (emitlib::json_string_source driven and fused): fused NIR equal with and without the claims: 1; coroutine allocations 0 and 0; table loads, switches, dfa#transition: 0.
