## Mutants of the modular checker: the first run (before the four tests its survivors asked for)

30 of 34 killed

| mutant | rule | result |
|---|---|---|
| `declared-narrowed` | parameter-domain initialization: an Int parameter enters as 0..9, not every Int | killed (match, 4 s): ep-declared-domain, ep-hole-edge, ep-unused |
| `caller-facts-leak` | call-site fact leakage: a claim entered with what the program's calls pass (the exploratory model) by default | killed (whole file, 134 s): ep-store-invalidate, ep-store-reuse |
| `negation-strict` | branch negation: `x < K` false read as `x > K` (K itself dropped) | killed (match, 14 s): ep-loop-later-iterations, ep-order-narrowing, ep-recursion-second-round |
| `negation-equality` | branch negation: `x == K` false read as true | killed (match, 3 s): ep-hole-edge, ep-lift-components |
| `minus-extra-point` | interval subtraction removes the point below the hole too | killed (match, 2 s): ep-hole-edge |
| `inter-wide` | interval intersection keeps the larger upper bound | killed (match, 9 s): ep-arithmetic, ep-dfa-accept-before, ep-dfa-after, ep-dfa-beyond, ep-dfa-incomplete, ep-dfa-lookahead-two, ep-negation-holes, ep-order-narrowing |
| `sub-as-add` | arithmetic transfer: `-` computed as hir::range::add | killed (match, 2 s): ep-arithmetic, ep-context-sensitive |
| `lift-first-component` | a two-operand transfer reads only the first component of its left operand | **SURVIVES** |
| `narrow-order-ignored` | an order comparison narrows to the other side's hull bound, off by one | killed (match, 3 s): ep-hole-edge, ep-order-narrowing |
| `handler-keeps-guard` | guard failure facts: a handler starts with the facts of the call's success | killed (match, 1 s): ep-guard-facts |
| `guard-any-binding` | guard success facts: the guard's set given to its argument even when the argument is no binding's reference (the next yield's binding) | killed (match, 1 s): ep-guard-facts |
| `fail-not-a-failure-point` | error-handler propagation: a `fail` records no failure state | killed (match, 5 s): ep-exploratory-false-proofs, ep-fail-after-yield |
| `natives-never-fail` | error-handler propagation: no native call may fail | killed (match, 1 s): ep-native-may-fail |
| `handlers-unreached` | error-handler propagation: a handler starts nowhere | killed (match, 5 s): ep-exploratory-false-proofs, ep-fail-after-yield, ep-native-may-fail |
| `loop-one-round` | loop fixed points: the loop body analyzed for one round only | **SURVIVES** |
| `peel-later-is-first` | loop fixed points: a counted loop's later iterations read as its first | killed (match, 6 s): ep-loop-first-iteration, ep-loop-later-iterations |
| `unroll-short` | an exactly counted loop unrolled one iteration short | killed (match, 7 s): ep-loop-exact-count |
| `join-first-state` | function-summary joins: a call's exits from its first entry state only | **SURVIVES** |
| `recursion-one-round` | recursive helper summaries: the solve stops after one round | **SURVIVES** |
| `summary-context-free` | function summaries keyed without their arguments | killed (match, 2 s): ep-arithmetic, ep-context-sensitive |
| `accept-before-taken` | DFA acceptance: the outermost token ending before a symbol read as ending on it | killed (match, 8 s): ep-conformance, ep-dfa-beyond |
| `reconsider-dropped` | delegation return: a callee's unread symbol dropped instead of reconsidered by `then STATE` | killed (match, 8 s): ep-conformance, ep-dfa-accept-before |
| `more-as-one` | `accept before N` read as `accept before 1` | killed (match, 3 s): ep-conformance |
| `end-not-checked` | EOF: a completion never checked against the end | killed (match, 10 s): ep-dfa-incomplete, ep-early-return, ep-loop-exact-count, ep-recursion |
| `boundary-same-depth` | token boundary: an obligation discharged when its frame takes the symbol | killed (match, 6 s): ep-boundary-adjacent, ep-boundary-nested |
| `boundary-never` | token boundary: a helper's exit never carries its obligation | killed (match, 5 s): ep-boundary-adjacent, ep-boundary-nested |
| `reattach-dropped` | token boundary: a certificate's open obligations dropped at its caller | killed (match, 4 s): ep-boundary-nested |
| `certificate-violations-dropped` | certificate composition: symbols of the helper's language the caller rejects not reported | killed (match, 1 s): ep-compose-weaker-certificate |
| `valid-ignores-functions` | cached certificate invalidation: a stored certificate valid whatever its functions' code | killed (match, 20 s): ep-store-invalidate |
| `valid-ignores-recognizers` | cached certificate invalidation: a stored certificate valid whatever its recognizers | killed (match, 18 s): ep-store-invalidate |
| `fingerprint-ignores-constants` | a function's fingerprint without its constants | killed (match, 23 s): ep-fingerprint, ep-store-invalidate |
| `statement-without-exits` | a certificate's statement digest without its exits | killed (match, 0 s): ep-statement-digest |
| `trusted-scalar-narrow` | a trusted native fact narrower than the implementation: a scalar value is never a control | killed (match, 1 s): ep-trusted-scalar |
| `coroutine-yields-counted` | coroutine boundaries: a value resumed from another coroutine read as a digit | killed (match, 1 s): ep-separate-coroutine |

Surviving: lift-first-component, loop-one-round, join-first-state, recursion-one-round
