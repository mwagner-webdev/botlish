## Mutants

57 mutants, 52 killed, 5 survived: undeclared-as-nothing, negation-strict, fingerprint-ignores-types, range-mod-wrap, range-mod-below

| mutant | rule | result |
|---|---|---|
| `declared-narrowed` | parameter-domain initialization: an Int parameter enters as 0..9, not every Int | killed (match, 2 s: failed: ec-declared-domain, ec-hole-edge, ec-unused) |
| `undeclared-as-nothing` | an undeclared parameter's value: no value at all, so a yield of it is unreachable (where the prototype's `caller-facts-leak` read the program's calls) | survived (whole files, 73 s: ) |
| `negation-strict` | branch negation: `x < K` false read as `x > K` (K itself dropped) | survived (whole files, 73 s: ) |
| `negation-equality` | branch negation: `x == K` false read as true | killed (match, 2 s: failed: ec-hole-edge, ec-lift-components, ec-trusted-scalar) |
| `minus-extra-point` | interval subtraction removes the point below the hole too | killed (match, 1 s: failed: ec-hole-edge, iset-hole-edges, iset-hole-rule, iset-minus-hole) |
| `inter-wide` | interval intersection keeps the larger upper bound | killed (match, 3 s: failed: ec-arithmetic, ec-dfa-accept-before, ec-dfa-after, ec-dfa-beyond, ec-dfa-continuations, ec-dfa-incomplete, ...) |
| `sub-as-add` | arithmetic transfer: `-` computed as hir::range::add | killed (match, 1 s: failed: ec-arithmetic, ec-context-sensitive, iset-arith-sound--) |
| `lift-first-component` | a two-operand transfer reads only the first component of its left operand | killed (match, 1 s: failed: ec-lift-components, iset-arith-sound-*, iset-arith-sound-+, iset-arith-sound--, iset-arith-sound-bit_and, iset-arith-sound-bit_or, ...) |
| `narrow-order-ignored` | an order comparison narrows to the other side's hull bound, off by one (hir::range::Narrowed's `<`) | killed (match, 1 s: failed: iset-narrow-sound-lt) |
| `handler-keeps-guard` | guard failure facts: a handler starts with the facts of the call's success | killed (match, 1 s: failed: ec-guard-facts) |
| `guard-any-binding` | guard success facts: the guard's set given to every binding, not only its argument | killed (match, 1 s: failed: ec-guard-facts) |
| `fail-not-a-failure-point` | error-handler propagation: a `fail` records no failure state | killed (match, 1 s: failed: ec-exploratory-false-proofs, ec-fail-after-yield) |
| `natives-never-fail` | error-handler propagation: no native call may fail | killed (match, 1 s: failed: ec-native-may-fail) |
| `handlers-unreached` | error-handler propagation: a handler starts nowhere | killed (match, 1 s: failed: ec-exploratory-false-proofs, ec-fail-after-yield, ec-native-may-fail) |
| `loop-one-round` | loop fixed points: the loop body analyzed for one round only | killed (match, 2 s: failed: ec-loop-second-iteration) |
| `peel-later-is-first` | loop fixed points: a counted loop's later iterations read as its first | killed (match, 3 s: failed: ec-loop-first-iteration, ec-loop-later-iterations) |
| `unroll-short` | an exactly counted loop unrolled one iteration short | killed (match, 1 s: failed: ec-loop-exact-count) |
| `join-first-state` | function-summary joins: a call's exits from its first entry state only | killed (match, 6 s: failed: ec-join-states) |
| `recursion-one-round` | recursive helper summaries: the solve stops after one round | killed (match, 1 s: failed: ec-recursion-same-context) |
| `summary-context-free` | function summaries keyed without their arguments: a helper's first argument context stands for every later one | killed (match, 1 s: failed: ec-context-sensitive) |
| `accept-before-taken` | DFA acceptance: the outermost token ending before a symbol read as ending on it (core::dfa::Unread) | killed (match, 6 s: failed: ec-conformance, ec-dfa-beyond) |
| `reconsider-dropped` | delegation return: a callee's unread symbol waited past instead of reconsidered by `then STATE` (core::dfa::Resume) | killed (match, 5 s: failed: ec-conformance, ec-dfa-accept-before) |
| `more-as-one` | `accept before N` read as `accept before 1` (core::dfa::Unread) | killed (match, 3 s: failed: ec-conformance, ec-outcome-model) |
| `end-not-checked` | EOF: a completion never checked against the end | killed (match, 2 s: failed: ec-dfa-incomplete, ec-early-return, ec-loop-exact-count, ec-recursion) |
| `boundary-same-depth` | token boundary: an obligation discharged when its frame takes the symbol | killed (match, 3 s: failed: ec-boundary-adjacent, ec-boundary-branch, ec-boundary-nested) |
| `boundary-never` | token boundary: a helper's exit never carries its obligation | killed (match, 4 s: failed: ec-boundary-adjacent, ec-boundary-branch, ec-boundary-nested) |
| `reattach-dropped` | token boundary: a certificate's open obligations dropped at its caller | killed (match, 1 s: failed: ec-boundary-nested) |
| `certificate-violations-dropped` | certificate composition: symbols of the helper's language the caller rejects not reported | killed (match, 1 s: failed: ec-compose-weaker-certificate) |
| `valid-ignores-functions` | cached certificate invalidation: a memo certificate valid whatever its functions' code | killed (match, 9 s: failed: ec-memo-invalidate) |
| `valid-ignores-recognizers` | cached certificate invalidation: a memo certificate valid whatever its recognizers | killed (match, 11 s: failed: ec-memo-invalidate) |
| `fingerprint-ignores-constants` | a function's fingerprint without its constants | killed (match, 10 s: failed: ec-fingerprint, ec-memo-invalidate) |
| `fingerprint-ignores-types` | a function's fingerprint without the type facts it reads (a module binding's declared domain) | survived (whole files, 71 s: ) |
| `statement-without-exits` | a certificate's statement digest without its exits | killed (match, 1 s: failed: ec-statement-digest) |
| `trusted-scalar-narrow` | a native result set narrower than the implementation: a scalar value is never a control | killed (match, 0 s: failed: ec-trusted-scalar, iset-registered-scalar-value) |
| `coroutine-yields-counted` | coroutine boundaries: a value resumed from another coroutine read as a digit | killed (match, 1 s: failed: ec-separate-coroutine) |
| `reverify-trusts-text` | trust: a HIR read from interchange text keeps its certificates unverified | killed (match, 2 s: failed: ec-cache, ec-interchange-forged) |
| `clones-followed` | trait specializations: a clone's selected implementations followed, certifying one program's selection | killed (match, 0 s: failed: ec-trait-unsupported) |
| `trait-call-followed` | a trait operation read as an ordinary call | killed (match, 1 s: failed: ec-trait-unsupported) |
| `dependent-reports` | a claim whose code holds another diagnostic still reports its own (restating poison) | killed (match, 0 s: failed: ec-recovery-dependent) |
| `budget-certifies` | an exhausted budget certifies what a round found | killed (match, 1 s: failed: ec-budget) |
| `unknown-value-silent` | a yield of a value of no known Int set is skipped, not reported | killed (match, 0 s: failed: ec-not-symbol, ec-unknown-value) |
| `unresolved-claim-dropped` | a claim naming no recognizer is dropped without a diagnostic | killed (match, 1 s: failed: ec-recognizer-later-message, ec-recognizer-resolution) |
| `range-add-low` | addition's lower bound from the wrong corner | killed (match, 1 s: failed: iset-arith-sound-+) |
| `range-sub-swap` | subtraction's lower bound subtracts the other's minimum | killed (match, 1 s: failed: iset-arith-sound--, iset-negation) |
| `range-mul-corners` | multiplication's bound from three of its four corners | killed (match, 2 s: failed: iset-arith-sound-*) |
| `range-mod-wrap` | mod of a range crossing a multiple of its divisor keeps one part | survived (whole files, 74 s: ) |
| `range-mod-sign` | mod of exact operands by a negative divisor, Tcl's remainder (negative) instead of Euclidean | killed (match, 0 s: failed: iset-arith-sound-mod, iset-mod-exact) |
| `range-mod-below` | an operand range up to the divisor read as itself (x = d is 0, not d) | survived (whole files, 72 s: ) |
| `range-shift-right-bound` | shift_right's upper bound by the largest shift, not the smallest | killed (match, 1 s: failed: iset-arith-sound-shift_right) |
| `range-narrowed-le` | `x <= y` narrows below y's maximum | killed (match, 0 s: failed: ec-order-narrowing, iset-narrow-sound-lteq, iset-order-edges) |
| `range-narrowed-gt` | `x > y` narrows two past y's minimum | killed (match, 1 s: failed: iset-narrow-sound-gt) |
| `range-induction-exclusive` | a counted loop `to` its end excludes one value too many | killed (match, 3 s: failed: iset-induction-sound) |
| `range-registered-gap` | a registered result set's components read one short | killed (match, 1 s: failed: iset-registered-scalar-value) |
| `range-typefact-domain` | a declared integer domain read as its lower bound only | killed (match, 1 s: failed: ec-domain-parameter) |
| `intset-bound-drops` | past the component budget, components dropped instead of the hull | killed (match, 0 s: failed: iset-component-budget) |
| `intset-not-equal-wide` | `x != K` removes K's neighbours too | killed (match, 1 s: failed: ec-hole-edge, iset-hole-edges, iset-hole-rule, iset-narrow-sound-noteq) |
| `dfa-consume-next` | the outcome model's consuming code continues in the next state | killed (match, 2 s: failed: ec-conformance) |
