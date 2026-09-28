# Real-world higher-order dogfooding

## Outcome

Three new canonical surface-Botlish benchmarks were added — `bench/test-
selection.bot`, `bench/source-checks.bot`, `bench/lex-strategy.bot` — each a
realistic, deterministic, in-memory compiler/test-tooling workload that
exercises one of the previously-identified callable-opacity shapes
(returned/captured closure, callable-as-List-element, callable-selected-by-
`if`), written in the idiomatic style this repository's own recent
milestones established (`loop x in xs:` for transformation/selection,
`list::any?`/`none?`/`find` for genuine search/reduction, no `map`/`filter`).
All five pre-existing canonical `bench/*.bot` programs are byte-for-byte
unchanged (confirmed by hash below). No compiler code was touched — this is
a corpus/dogfooding milestone, not an optimization milestone, exactly as
scoped.

A structural callable census (`audit/higher-order-dogfooding/tools/
census.tcl`, observation-only, modeled on `audit/post-module-static-exact-
target-census/tools/baseline.tcl`) was run against all three new programs.
Headline findings:

- **The corpus grew from 2 to 9 static `callvalue` sites** across the 8
  canonical `bench/*.bot` programs (2 pre-existing, 7 in the 3 new files).
- **A returned closure called directly resolved to `callenv`, not
  `callvalue`**: `test-selection.bot`'s `changed_a?("lib/web.bot")` calls an
  exact, statically-known target Block through its own environment — the
  "uncertain" row of the earlier likelihood table is now answered for at
  least this shape: the compiler already retains exact target identity
  through a factory-return → binding → direct-call chain.
- **The same closure loses that exactness the instant it crosses an HOF
  parameter boundary**: passed into `list::any?`/`none?`/`find` as
  `predicate`, the very same `changed_a?` value is now `callvalue` inside
  those helpers, because the parameter itself is untyped. Two different,
  adjacent call sites of the *same value* land on opposite sides of the
  call/callvalue line.
- **A callable fetched from a List element is `callvalue`**, confirmed
  directly (`source-checks.bot`'s `checks` List, mixing 2 natives and 2
  envless Botlish functions).
- **A callable selected by `if`/`else` is `callvalue`, and identity is lost
  before the function that does the choosing even returns**: the `if`'s own
  two branches (`{native is_tcl_alnum}` vs. `{block lenient_ident_char?}`)
  join to HIR type `any` inside `choose_classifier` itself (`lex-strategy
  .bot`), not later at the caller's binding or the call.
- **A one-caller/one-target native predicate remains `callvalue`**, matching
  the earlier prediction precisely: `lex-strategy.bot`'s `fully_alnum?`
  passes `is_tcl_alnum` — its only argument anywhere in the corpus — into
  `list::all?`, and `predicate(x)` is still dynamically dispatched inside
  `all?`.
- Every ordinary direct/named call in all three new programs (21 distinct
  function definitions between them) resolved to `call`/`callenv`, never
  `callvalue` —
  the 7 new dynamic sites are exactly and only the higher-order-provenance
  shapes this milestone targeted, not a general resolution failure.

Full regression: **2619/2619 passing, 0 failed, 91 test files** (no new
test files — this milestone adds benchmarks, not tests). Backend parity
(interp/compile/cranelift, `bench/bench.tcl -runs 1`, exit 0): **no
disagreements** across all 8 canonical programs, old and new.

## Goals and non-goals

Goal: discover what higher-order call shapes arise when realistic Botlish
programs are written idiomatically, to ground the next milestone's finite-
callable-target-provenance design in real source rather than one
specially-constructed workload. Non-goals, upheld throughout: no compiler
optimization, no new language features (`leave`, `with intermediate`,
lockstep `and`, structs, flags, new iterator abstractions), no `map`/
`filter`, no refactor of the 5 pre-existing canonical programs, no `.ir`
siblings for the new sources, no special-casing or native-rewriting of
`list::any?`/`all?`/`none?`/`find`.

## Canonical workload additions

| file | models | role labels (item 62) |
|---|---|---|
| `bench/test-selection.bot` | selective test-run tooling: "which test groups are affected by this changed-file set?" | HOF closed-caller workload; returned-closure workload; same-code/different-env workload |
| `bench/source-checks.bot` | a compiler front-end lint pass: several independent lexical classifiers of a candidate identifier's leading character | callable-as-data workload; HOF closed-caller workload |
| `bench/lex-strategy.bot` | a strict-vs-relaxed identifier-character classification strategy, the kind of source-mode-specific validation a real lexer switches between | control-flow callable-join workload; HOF closed-caller workload |

3 files, not 4 — `test-selection.bot`'s own `make_changed?`/`changed?`
closure factory already satisfies scenario 5 (a genuine returned,
activation-dependent closure, called directly, then also crossing an HOF
boundary) to the letter, so a separate Workload D was unnecessary (item 27
explicitly allows this). This also means source overlap was preferred over
artificial duplication, per item 9.

## Why each workload is realistic

**`test-selection.bot`** models the selective-test-run tooling this
repository's own CI might eventually use: given a set of changed files and
a table of test groups with their own dependencies, which test groups need
to run? This is a genuine, useful question over genuine, if synthetic-but-
representative, data (test-group names and dependency paths modeled after
this repository's own directory layout: `hir/`, `native/`, `lib/`,
`compiler/`, `bench/`).

**`source-checks.bot`** models a lint pass over candidate identifier names:
several independent classifiers of a name's own leading character (may an
identifier start with a digit? a hyphen?), organized as data because a
batch of independent per-subject checks is exactly how a real linter
structures this — not because a List was needed to manufacture `callvalue`.

**`lex-strategy.bot`** models a lexer choosing between a strict and a
relaxed identifier-character acceptance policy (the kind of source-mode-
specific validation strategy item 24 suggests) and applying whichever one
was chosen uniformly across a batch of tokens.

## Data representations chosen

Botlish has no `Struct`/`Map` yet (confirmed: `core/native.tcl` registers
no such construct, and no `type Struct`/`Map` declaration exists anywhere
in `hir/`, `core/`, or `lib/`), so none was added or invented for this
milestone (item 32's own instruction). Representation choices, and their
compromises:

- **A "test group" is the plain 2-element positional List `[name,
  dependencies]`** — the same ad hoc-record idiom `examples/stdlib/
  csv_records.bot`'s own `[storage, length]` builder pairs already use in
  this codebase. `test_name`/`test_deps` accessor functions keep the
  positional indices out of call sites.
- **The changed-file set is a genuine `ImmutableSet[str]`**
  (`immutable_set_from_list`/`immutable_set_contains`,
  `MINIMAL-IMMUTABLE-SET.md`), not a List scanned by hand — the correct
  existing representation for a membership question, not a compromise.
- **A String's own characters, where a `List[str]` of them was needed
  (`lex-strategy.bot`'s `chars_of`), are produced by ordinary recursion +
  `list_append`** — there is no `String -> List[UnicodeChar]`/`List[str]`
  conversion primitive in this language yet, so this is the same
  recursive-accumulator idiom `examples/stdlib/csv_geometric.bot`'s own
  field/record scanning already uses, not a new abstraction invented for
  this milestone.
- **No `char::codepoint`/`UnicodeChar`-based digit classification was
  used**: `char_codepoint` only accepts `UnicodeChar`, and `substring`
  (the only way to pull one character out of a `str` variable) returns
  `str`, not `UnicodeChar` — the two types don't compose the way a naive
  digit-range check would need. All character classification in the new
  corpus therefore uses the same `is_tcl_alpha`/`is_tcl_alnum`/direct `==`
  idiom `lib/web.bot`'s own `emailish?` already established, not a new
  mechanism.

## Use of returning loops

Every collection transformation/selection in the new corpus is a returning
`loop x in xs:`, never `map`/`filter`:

- `select_affected` (`test-selection.bot`): `loop test in tests: if not
  affected?(test, changed?): continue \n test` — the selection idiom.
- `invalid_names` (`source-checks.bot`): the same selection idiom, over
  `candidates`.
- `classify_leading` (`source-checks.bot`): `loop check in checks:
  check(c)` — transformation, collecting one Bool per classifier (this is
  also the callable-List-element call site).
- `classify` (`lex-strategy.bot`): `loop c in chars_of(token, 0, []):
  classifier(c)` — transformation, over the selected strategy.
- `alnum_only_tokens` (`lex-strategy.bot`): the selection idiom again, over
  `tokens`.

## Use of `any?`/`all?`/`none?`/`find`

- **`any?`**: `test-selection.bot`'s `affected?` — "does any of this test
  group's own dependencies belong to the changed set?", a genuine
  existential query over a closure parameter.
- **`none?`**: `test-selection.bot`'s `untouched_by_a?` — "none of
  docs-tests' own dependencies are in changed_a's changed set", a genuine
  universal-absence question, written directly (not `not any?(...)`).
- **`all?`**: `lex-strategy.bot`'s `fully_alnum?` — "does every character
  of this token satisfy strict classification", a genuine universal
  question, with a native predicate passed directly (the one-caller/
  one-target control).
- **`find`**: `test-selection.bot`'s `first_affected` ("the first affected
  test group in declared order") and `source-checks.bot`'s `first_invalid`
  ("the first invalid candidate in declared order"); both handle the
  checked `NotFound` error with a real `on NotFound:` handler, neither of
  which is ever actually reached by this corpus's own fixed data (both
  datasets are constructed so at least one match exists) — the handlers
  are genuine, load-bearing static obligations, not decoration, even
  though this milestone's own deterministic fixtures never dynamically
  exercise the failure branch.

No benchmark mechanically calls every helper merely to exercise it — each
use above answers a real question the workload actually needed.

## Dependency/test-selection workload

See "Why each workload is realistic" and "Data representations chosen"
above for the design; see "HOF closed-caller provenance" and "Returned-
closure provenance" below for its structural findings. Full source:
`bench/test-selection.bot`. Expected result (verified against the
interpreter and matching hand-computation): `[3, 1, "resolve-tests", true,
true]` — 3 test groups affected by `changed_a` (`resolve-tests`,
`types-tests`, `web-tests`, both sharing `hir/hir.tcl` or `lib/web.bot`), 1
affected by `changed_b` (`docs-tests`, via `README.md`), `"resolve-tests"`
the first in declared order, `true` that `changed_a?("lib/web.bot")` holds
directly, `true` that none of `docs-tests`' own dependencies are in
`changed_a`.

## Callable-list compiler-check workload

Full source: `bench/source-checks.bot`. `checks = [is_tcl_alpha,
is_tcl_alnum, is_underscore?, is_hyphen?]` mixes 2 root natives and 2
envless Botlish functions — confirmed at the NIR level (`native=2,
fnvalue=2` in the generated code: the natives load as `native` values, the
envless functions as zero-allocation `fnvalue` constants, exactly
`RETURNING-ITERABLE-LOOPS.md`'s own terminology). `classify_leading`
applies every check to one subject (a candidate identifier's own leading
character) via `loop check in checks: check(c)` — the genuine list-element-
call shape, not four independent hand-written calls with an unrelated List
sitting unused. Expected result: `[16, 5, "2fast", 11]` — 16 candidates, 5
with an invalid leading character (`"2fast"`, `"9bad_name"`, `"-flag"`,
`"-verbose"`, `""`), `"2fast"` first in declared order, 11 valid.

## Control-flow strategy workload

Full source: `bench/lex-strategy.bot`. `choose_classifier(strict_mode)`
selects between `is_tcl_alnum` (a root native, strict mode) and
`lenient_ident_char?` (an envless Botlish function additionally accepting
`_`/`-`, relaxed mode) — a genuine Native/Block join over a real runtime
condition (called with both `true` and `false`), not a compile-time
constant folded away. `classify` then consumes the selected strategy
through a returning loop over one token's own characters, with the
strategy choice living outside the traversal, exactly the recommended
idiom. Expected result: `[58, 65, 1, "café"]` — 58 characters accepted
across the 8-token corpus under strict classification, 65 under relaxed,
and exactly one token (`"café"`, all Unicode letters, no `_`/`-`) fully
alnum under `list::all?(chars, is_tcl_alnum)`.

## Same-code/different-environment case

`test-selection.bot`'s `changed_a?`/`changed_b?` are two closures built
from the **same** `make_changed?` Block (`e49`) over two different
changed-file Lists — confirmed directly at the NIR level: the whole
program produces exactly **2** `closure` and **2** `capture` instructions,
matching the 2 activations of `make_changed?` (`changed_a = make_changed?
(changed_a)`, `changed_b = make_changed?(changed_b)`), each capturing its
own freshly-built `changed_set`. Both are genuinely exercised, not merely
constructed: `changed_a?` drives `select_affected(tests, changed_a?)`,
`first_affected(tests, changed_a?)`, `untouched_by_a?`, and a direct call
(`probe`); `changed_b?` drives `select_affected(tests, changed_b?)`. Both
reach `list::any?`'s own `predicate(x)` `callvalue` site from the *same*
static call expression (`e75` in `affected?`) — direct, concrete evidence
that the compiler is not distinguishing code identity from environment
identity at that call site (both collapse to the same non-exact `block`
parameter type), exactly the generality item 48/49 asks this milestone to
produce.

## Identity vs environment

`changed_a?` and `changed_b?` share one code identity (Block `e55`,
`changed?`) and have two distinct closure-object/environment identities
(two separate `capture`/`closure` NIR instructions, two separate
`changed_set` values). This milestone's census keeps that distinction
explicit throughout rather than describing them as "two different code
targets": every table below that discusses `changed?` labels the Block
identity once and the environment/activation count separately.

## Backend parity

`tclsh9.0 bench/bench.tcl -runs 1`, native (Cranelift) built (rustc
1.98.1, `cargo build --release --manifest-path native/Cargo.toml`, clean
build): **exit code 0, no `VALUES DIFFER` on any of the 8 canonical
programs** (5 pre-existing + 3 new), interp/compile/Cranelift agreeing on
every one, native included:

```
program                  Tcl interp   Tcl compile     Cranelift
lex-strategy.bot            136.1 ms        9.2 ms      92.83 us
source-checks.bot            18.2 ms        2.7 ms      26.02 us
test-selection.bot           17.1 ms        2.7 ms      10.52 us
```

(full table, including the 5 pre-existing programs and the Python/Rust/Go
reference columns where they exist, in the run's own stdout; the three new
programs have no `bench/equivalents/{python,rust,go}` counterpart, so those
columns correctly show `n/a` rather than a spurious mismatch.) No backend
correctness discrepancy was found on any new program, so no "STOP AND
REPORT" was triggered.

## Structural callable census

Tooling: `audit/higher-order-dogfooding/tools/census.tcl` (observation
only — reads `hir::specialize`/`hir::blockescape`/`native::lower` results,
changes nothing), run against each new program; raw output in
`audit/higher-order-dogfooding/out/{test-selection,source-checks,lex-
strategy}.census.txt`. Method: for every *reachable, resolved* call
expression in every used specialization instance, the script reports the
callee's exact HIR type (Block captures/staticRefs, or Native name) and
the resolved target instance; calls whose target could not be resolved
statically have no entry there and instead appear, unambiguously, in the
NIR's own `callvalue` instruction listing (`hir::specialize`'s own per-
instance `calls` dict simply has no edge for a call it cannot resolve to a
fixed instance) — the two listings are complementary and, together, cover
every call in the program.

| program | used instances | resolved call/callenv edges | NIR `call` | NIR `callenv` | NIR `callvalue` | NIR `closure` | NIR `capture` | NIR `fnvalue` | NIR `native` |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| `test-selection.bot` | 14 | 15 | 14 | 1 | 3 | 2 | 2 | 0 | 0 |
| `source-checks.bot` | 7 | 4 | 1 | 3 | 2 | 3 | 3 | 2 | 2 |
| `lex-strategy.bot` | 11 | 14 | 11 | 0 | 2 | 0 | 0 | 1 | 2 |

`hir::blockescape::analyze`/`explain` reported **zero virtual (flattened)
bindings in all three programs** — none of the new corpus's closures were
eligible for blockescape's existing flattening mechanism (it applies to
`InstanceClosed` generic instances; every closure-carrying function in the
new corpus that reaches it is either not generic in the relevant sense, or
not closed — see "Distinguish closed instance from finite ingress" below).
This confirms items 74/9's non-goal directly: no new blockescape logic was
needed or added, and none of the existing machinery happened to apply
here either.

**An open attribution question, reported rather than resolved (per items 24/
41's "do not speculate beyond what the facts support")**: several used
instances in all three programs show non-empty `hir::captures` lists whose
entries are references to *other top-level function bindings* in the same
program (e.g. `affected?`'s own block captures `[list::any?, test_deps]`;
`chars_of`'s own block captures `[chars_of]`, itself, for its own
recursion). `hir::staticRefs` — the module-static-value mechanism
(`MODULE-STATIC-RETAINED-VALUES.md`) that would otherwise keep such a
reference out of `hir::captures` — is empty everywhere in all three
programs, because module-static treatment applies only to `namespace`-
scoped module bindings (`lib/*.bot`), and these three new files are plain
top-level programs (like `fib.bot`), not `namespace`-scoped modules. Yet
the measured NIR `closure`/`capture` counts (2/2, 3/3, 0/0 respectively)
are far lower than "one real heap closure per non-empty-`hir::captures`
instance" would predict, and blockescape reports zero flattening. This
milestone did not trace exactly which lowering step (native lowering's own
direct-call-vs-value-escape distinction is the most likely candidate, per
`RETURNING-ITERABLE-LOOPS.md`'s own architecture notes) reconciles the two
numbers — doing so would be exactly the kind of "no new specialization
keys/blockescape logic" architecture investigation this milestone's own
scope excludes. It is recorded here as a genuine open structural question
for whichever milestone next touches closure materialization, not
resolved or guessed at further.

## Likelihood-table predicted vs. observed

| row | prediction | observed | confidence | where exactness was retained/lost |
|---|---|---|---|---|
| function argument → parameter called | callvalue | **callvalue**, every instance (5 of 5 new HOF predicate sites) | confirmed | lost at the untyped `predicate` parameter of `list::any?`/`all?`/`none?`/`find` itself (`lib/list.bot`, unchanged, pre-existing) |
| same, one caller / one target | callvalue | **callvalue** (`lex-strategy.bot`'s `fully_alnum?` → `list::all?(chars, is_tcl_alnum)`, `is_tcl_alnum`'s only argument anywhere in the corpus) | confirmed | same — the helper's own parameter type, not the caller's exactness, decides |
| same, non-generic HOF instance | probably callvalue | **callvalue** (`list::any?<any, block>` in `test-selection.bot` is a single, not-generic-flagged used instance) | confirmed | same |
| callable fetched from List | probably callvalue | **callvalue** (`source-checks.bot`'s `checks` element call, `classify_leading`'s `check(c)`) | confirmed | lost the moment 2 natives and 2 Blocks are joined into one List element type |
| callable chosen by if/else | probably callvalue | **callvalue** (`lex-strategy.bot`'s `classifier(c)`) | confirmed | lost **inside `choose_classifier` itself**: its own `if`/`else` expression's HIR type is already `any` before the function returns — not at the `classifier` binding, and not at the call |
| specific returned closure then called | uncertain: callenv or callvalue | **callenv** (`test-selection.bot`'s `changed_a?("lib/web.bot")`, `probe`) | resolved for this shape | retained: `make_changed?`'s return, `changed_a?`'s binding, and the direct call all carry the exact Block `e55` type; `callenv` (not `call`) because that Block genuinely captures `changed_set` |
| local alias `g = f; g(x)` | likely direct | not exercised — no artificial alias was added (none arose naturally in any of the 3 workloads; item 50 forbids adding one merely as a control) | not tested | — |
| direct named function | direct | **`call`/`callenv`**, 100% of resolved edges (33 across the 3 programs — see census table) | confirmed | never lost — every ordinary named call resolves |

## HOF closed-caller provenance

For every `list::any?`/`all?`/`none?`/`find` instance used by the new
workloads (`lib/list.bot`, unmodified, per item 51-52's non-goal):

| instance | used from | specializer genericity | callable type visible inside helper | `predicate(x)` form |
|---|---|---|---|---|
| `list::any?<any, block>` | `test-selection.bot`'s `affected?` (called with `changed_a?`, `changed_b?`, and, via `is_affected?`, `changed?` again) | non-generic instance (resolved to key `<any, block>`) | bare `block` (non-exact) | `callvalue` |
| `list::none?<List[str], block>` | `test-selection.bot`'s `untouched_by_a?` | non-generic instance | bare `block` | `callvalue` |
| `list::find<List[list], block>` | `test-selection.bot`'s `first_affected` (argument `is_affected?`) | non-generic instance | bare `block` | `callvalue` |
| `list::find<List[str], block>` | `source-checks.bot`'s `first_invalid` (argument `invalid_name?`) | non-generic instance | bare `block` | `callvalue` |
| `list::all?<List[str], native>` | `lex-strategy.bot`'s `fully_alnum?` (argument `is_tcl_alnum`, direct) | non-generic instance (resolved to key `<List[str], native>`) | bare `native`/`callable` (non-exact — the specialization key collapses to the kind, not the identity) | `callvalue` |

Every one of the 5 instances is a single used instance (no instance was
used generically across genuinely different call-site argument shapes
within these 3 programs). Importantly, **`hir::specialize`'s own `generic`
flag is false for all 5** — each was resolved to a concrete specialization
key (`<any, block>`, `<List[str], native>`, etc.), never falling back to
the literal `<generic>` label this same census shows elsewhere (e.g.
`test-selection.bot`'s `changed?<generic>`, `is_affected?<generic>`). Since
`hir::specialize::closed` (`InstanceClosed`) is only meaningful for a
`generic` instance (per this census tool's own logic, mirroring
`audit/post-module-static-exact-target-census/tools/baseline.tcl`), the
`InstanceClosed`/"open" question **does not apply** to any of these 5 — it
is not that they were checked and found not-closed; closedness simply
isn't a property a non-generic, already-resolved instance has. What *is*
directly confirmed for all 5: the specialization key being resolved (to
`block`/`native`, i.e. a kind, not an identity) is precisely what still
leaves `predicate(x)` dynamically dispatched inside every one of them —
the parameter is untyped in `lib/list.bot`'s own source, independent of
how exact the caller's own argument was, exactly the reason `RETURNING-
ITERABLE-LOOPS.md` already established for this pre-existing shape. This
corpus's own `<generic>`-labeled instances (`changed?`, `is_affected?`,
`test_deps<generic>`) are a separate, genuinely open/closed-eligible
population — `test_deps<generic>` is flagged `CLOSED`, `changed?`/
`is_affected?` are flagged `not-closed; OPEN` — but none of the three is
itself an HOF helper instance, so item 43's specific "closed instance
whose predicate call is still callvalue" scenario simply has no
candidate in this corpus to confirm or refute either way; recorded here
rather than forced.

## Callable-list provenance

`source-checks.bot`'s `checks` List:

- **List element type**: the literal `[is_tcl_alpha, is_tcl_alnum,
  is_underscore?, is_hyphen?]` mixes 2 exact `{native NAME}` types and 2
  exact `{block B}` types; `classify_leading`'s own `check` element
  binding (from `loop check in checks: check(c)`) has HIR type bare
  `block` at that binding — the loop's own element binding widens to the
  kind, not the identity, the moment the source list itself is not
  uniformly one exact type.
- **Exact function identities retained anywhere after List construction**:
  no — confirmed by the absence of any resolved call edge for `check(c)`
  in the census's "call sites" table (it appears only in the NIR
  `callvalue` listing).
- **Call form**: `callvalue`.
- **Would a future finite closed-caller theorem help this case?** No —
  this is a genuinely different provenance problem from a closed HOF
  caller set: the List's own element type, not the call site's caller
  population, is where exactness is lost. A finite-target theorem over
  *callers of a function* has nothing to say about *elements of a
  heterogeneous List*; this case would need collection-value provenance
  (e.g., "this List literal's elements are known exactly, in order")
  instead — outside this milestone's scope to design or speculate about
  further than naming the distinction.

## If-join provenance

`lex-strategy.bot`'s `choose_classifier`:

- **Exact callable types entering the join**: `{native is_tcl_alnum}`
  (`is_tcl_alnum`, strict branch) and `{block e49}` (`lenient_ident_char?`,
  relaxed branch) — both exact, confirmed the same way every other exact
  reference in this census is confirmed (bare `ref` to a root native /
  local envless function).
- **What `hir::types::lub` produces**: HIR type `any` — directly measured
  (the whole `if` expression inside `choose_classifier<bool>` has type
  `any`), not merely a bare `block`/`native` kind atom. A Native and a
  Block type do not have a non-trivial common supertype in this type
  system's current lattice, so the join goes all the way to `any`.
- **Does the local binding preserve anything more precise?** No —
  `classify`'s own `classifier = choose_classifier(strict_mode)` binding
  has whatever `choose_classifier<bool>`'s own return type is, which is
  already `any` by the time it returns; there is nothing left to lose at
  the binding.
- **Call form**: `callvalue`.
- **Where identity is lost**: **inside `choose_classifier` itself**, at
  the `if`/`else` join — not at the `classifier` binding, and not at the
  `classifier(c)` call site. Both of those merely inherit the already-lost
  type.

## Returned-closure provenance

`test-selection.bot`'s `make_changed?`:

- **Exact Block the factory returns**: `e55` (`changed?`), the same Block
  identity for every call to `make_changed?` (confirmed: both
  `changed_a?` and `changed_b?` show `-> Block e55` in the census).
- **What it captures**: `changed_set` (one lexical capture, genuinely
  used — `immutable_set_contains(changed_set, path)` — never a fake
  unused capture).
- **Factory's inferred return type**: exact, `block e55 1 any` (arity 1,
  bare `any` result type since `changed?`'s own result isn't further
  refined) — not merely "some callable".
- **Type the caller binding receives**: the same exact `block e55 1 any`
  — `changed_a?`/`changed_b?` are both typed exactly, not widened at the
  `=` binding.
- **Direct invocation**: lowers to **`callenv`** (`changed_a?("lib/web
  .bot")`, the `probe` binding) — not `call` (the target genuinely
  captures `changed_set`, so it needs its own environment threaded) and
  not `callvalue` (the target Block is exactly known).
- **Passing that same value to a HOF**: yes, loses the exactness —
  `affected?`'s own `changed?` parameter (untyped) receives it as bare
  `block`, and `list::any?`'s own `predicate` parameter (also untyped)
  receives it the same way; both downstream calls (`affected?`'s own
  `list::any?(test_deps(test), changed?)`, and transitively `predicate(x)`
  inside `any?`/`none?`/`find`) are `callvalue`.
- **Two environments of the same Block**: yes — `changed_a?`/`changed_b?`
  (see "Same-code/different-environment case" above). The census
  correctly reports both as the same Block `e55` with two separate
  `capture`/`closure` NIR instructions, i.e. the same code target with
  two distinct environment/activation identities, never described as two
  different code targets.

## Returned closure through HOF

- **Identity at factory result**: exact, `block e55 1 any` (see above).
- **Identity at the HOF call argument**: still exact at the *argument
  expression itself* — `list::find(tests, is_affected?)`'s own argument
  `is_affected?` is an exact `block e98` (the nested closure wrapping
  `affected?`/`changed?`); one level further in, `affected?`'s own
  `changed?` argument to `list::any?` is likewise exact `block e55` *at
  the call expression*, per the census's "arg:" line for call `e75`.
- **Identity inside the helper's own predicate parameter**: lost — bare
  `block` inside `any?`/`find` alike, regardless of how exact the calling
  expression was. **The information loss happens exactly at the
  parameter boundary of the untyped HOF helper, not earlier** — this
  milestone's census shows the same boundary losing exactness twice
  (once directly at `list::any?`'s `predicate`, once at `list::find`'s
  `predicate` via the nested `is_affected?` closure), always at the same
  place: crossing into the helper's own body.

## Direct-call controls

- **Module/local named direct call**: `test_name`/`test_deps` (local,
  `test-selection.bot`); `web::` is not used by the new corpus (no web
  workload was natural here), but `list::any?`/`none?`/`find`/`all?`
  themselves are module direct calls, confirmed `call`/`callenv` at every
  one of their own 5 call sites (see "HOF closed-caller provenance" —
  it's specifically the *helpers' own internal* `predicate(x)` that's
  dynamic, never the caller's own call *into* the helper).
- **Local alias**: none arose naturally; none was added (see likelihood
  table above).
- **Native direct call**: `is_tcl_alpha`/`is_tcl_alnum` (`source-checks
  .bot`'s `checks` list — direct references, not wrapped), `is_tcl_alnum`
  (`lex-strategy.bot`'s `choose_classifier`'s strict branch and
  `fully_alnum?`'s direct `list::all?` argument).

All resolve `call`/`callenv`; none is `callvalue` — direct, corroborating
evidence that the 7 new `callvalue` sites are caused specifically by
higher-order provenance loss (HOF parameter, List element, `if` join), not
a general failure to resolve ordinary calls.

## New static `callvalue` count

| scope | count |
|---|---|
| 5 pre-existing canonical `bench/*.bot` (before this milestone) | 2 (both are the *same* source call site — `web::emailish?`'s own `scan_while` predicate call, `lib/web.bot`, unmodified by this or the prior milestone — appearing once each in `refined-checks.bot`'s and `uri-steady.bot`'s own compiled NIR, since both pull in the whole `web` namespace's compiled functions, not only the ones each program actually calls) |
| 3 new canonical `bench/*.bot` (this milestone) | 7 (`test-selection.bot`: 3; `source-checks.bot`: 2; `lex-strategy.bot`: 2) |
| **8 canonical `bench/*.bot` total, after this milestone** | **9** |

Of the 7 new sites: **5 are HOF predicate-parameter calls** (reusing
`lib/list.bot`'s own 4 pre-existing call-site shapes — `any?`×1, `none?`
×1, `find`×2, `all?`×1 — now realistically exercised by 3 new programs
rather than only by `tests/list-stdlib.test`'s synthetic fixtures); **1
comes from a callable-List element** (`source-checks.bot`'s `check(c)`,
genuinely new source shape, first of its kind in this corpus); **1 comes
from an `if`-joined callable** (`lex-strategy.bot`'s `classifier(c)`,
likewise genuinely new). **0 new sites come from a returned closure
called directly** — that shape resolved to `callenv`, not `callvalue`
(see "Returned-closure provenance"); the returned closure only becomes
`callvalue` once it crosses into an HOF parameter, which is counted under
the 5 HOF sites above, not as its own category.

## New corpus role classification

| file | HOF closed-caller | callable-as-data | control-flow join | returned closure | same-code/diff-env |
|---|:---:|:---:|:---:|:---:|:---:|
| `test-selection.bot` | ✓ | | | ✓ | ✓ |
| `source-checks.bot` | ✓ | ✓ | | | |
| `lex-strategy.bot` | ✓ | | ✓ | | |

## Full regression

```
LANG=C.utf8 LC_ALL=C.utf8 tclsh9.0 tests/all.tcl
```

Native built first (`cargo build --release --manifest-path native/Cargo
.toml`, rustc 1.98.1 via `rustup toolchain install stable --profile
minimal && rustup default stable`, per `AGENTS.md`'s own instructions —
the sandbox's preinstalled 1.94.1 was too old for the pinned
`cranelift-*`/`wasmtime-internal-*` crates).

**Total 2619, Passed 2619, Skipped 0, Failed 0, Sourced 91 Test Files.**
Identical file count and pass count to the pre-milestone baseline — this
milestone added no new test files (only new canonical benchmarks; per item
37, "do not duplicate the entire benchmark in tests" — nothing in the new
workloads' own logic was novel enough at the language-semantics level to
need dedicated focused tests beyond what `bench/bench.tcl`'s own backend-
parity check already provides for a canonical benchmark).

`BOTLISH_NATIVE_GC_STRESS=1` was not run for this milestone: per
`AGENTS.md`, it is required specifically "before touching anything in
`native/` that affects stack walking, roots, or allocation" — this
milestone touched no `native/` source at all (only `bench/*.bot` and a new
observation-only `audit/` Tcl script), so it is out of scope here; CI's own
`gc-stress` job on `main` will exercise the new canonical benchmarks
automatically on the next push, per the same document.

## Benchmark smoke

```
tclsh9.0 bench/bench.tcl -runs 1
```

Exit code 0. All 8 canonical programs (5 pre-existing + 3 new) agree
across `interp`/`compile`/`cranelift`; no `VALUES DIFFER` anywhere. See
"Backend parity" above for the new programs' own timing row.

## Existing benchmark invariance

```
sha256sum bench/fib.bot bench/loop-count.bot bench/sum-refined.bot bench/refined-checks.bot bench/uri-steady.bot
```

`git diff --stat` against all 5 pre-existing canonical files reports no
output (byte-for-byte unchanged); `git status --short bench/` shows only
the 3 new files as untracked additions. The old/new corpus boundary is
therefore clean: 5 unmodified pre-existing programs, 3 new ones, nothing
in between.

## Required source questions

1. **Which new canonical `.bot` programs were added?**
   `bench/test-selection.bot`, `bench/source-checks.bot`, `bench/lex-
   strategy.bot`.
2. **What real-world/compiler task does each model?** See "Canonical
   workload additions" table.
3. **Which use returning loops?** All three (see "Use of returning
   loops").
4. **Which use `any?`?** `test-selection.bot`.
5. **Which use `all?`?** `lex-strategy.bot`.
6. **Which use `none?`?** `test-selection.bot`.
7. **Which use `find`?** `test-selection.bot`, `source-checks.bot`. (Not a
   failure that `source-checks.bot`/`lex-strategy.bot` don't use every
   helper — each use above answers a genuine question the workload
   needed, per item 30/53's own instruction not to force it.)
8. **Which contain genuine capturing closures?** `test-selection.bot`
   (`make_changed?`/`changed?`, and the nested `is_affected?` inside
   `first_affected`); `source-checks.bot` and `lex-strategy.bot` contain
   only envless local functions and functions whose own `hir::captures`
   list names sibling top-level functions, not independent runtime data
   (see the census's own "open attribution question" note) — neither
   genuinely captures runtime *data* the way `changed_set` is captured.
9. **Which contain a List whose elements are callables?**
   `source-checks.bot` (`checks`).
10. **Which bind a callable produced by an `if`?** `lex-strategy.bot`
    (`classifier = choose_classifier(strict_mode)`).

## Required call-shape questions

11. **Static `callvalue` sites before this milestone**: 2.
12. **After**: 9.
13. **New sites that are HOF predicate-parameter calls**: 5.
14. **New sites from callable-List elements**: 1.
15. **New sites from an `if`-joined callable**: 1.
16. **New sites from a returned closure**: 0 (called directly, it is
    `callenv`; it only becomes `callvalue` once it also crosses an HOF
    parameter, already counted under #13).
17. **Expected sites that turned out to be direct `call`/`callenv`
    instead**: the returned-closure-called-directly shape
    (`changed_a?(...)`) — predicted "uncertain," observed `callenv`.

## Required HOF questions

18-23. See "HOF closed-caller provenance" table and its discussion above
   for the exact target per caller, `InstanceClosed` status, visible
   callable type inside the helper, and `predicate(x)` form for every one
   of the 5 instances. One-caller/one-target case: yes
   (`list::all?<List[str], native>`, argument `is_tcl_alnum`, its only use
   in the corpus); it remains `callvalue`.

## Required callable-list questions

24-28. See "Callable-list provenance" above: element type collapses to
   bare `block` at the loop's own element binding; no exact identity
   survives past List construction; call form `callvalue`; a finite
   closed-caller theorem would not help (this needs collection-value
   provenance instead, not investigated further here, per item 28's own
   instruction not to speculate beyond the facts or implement anything).

## Required if-join questions

29-33. See "If-join provenance" above: exact branch types `{native
   is_tcl_alnum}`/`{block e49}`; `hir::types::lub` produces `any`; the
   local binding preserves nothing more precise (there is nothing left to
   preserve); call form `callvalue`; identity is lost inside
   `choose_classifier` itself, at the join, not at the binding or the
   call.

## Required returned-closure questions

34-40. See "Returned-closure provenance" and "Returned closure through
   HOF" above: exact Block `e55`; captures `changed_set`; factory return
   type exact `block e55 1 any`; caller binding receives the same exact
   type; direct invocation lowers to `callenv`; passing the same value to
   a HOF (`list::any?`/`find`) does lose additional information, at the
   helper's own untyped parameter; two environments of the same Block
   (`changed_a?`/`changed_b?`) are correctly distinguished by the analysis
   as one code target with two capture/closure instructions, never
   described as two code targets.

## Required prediction table

See "Likelihood-table predicted vs. observed" above.

## Required benchmark questions

41. **Do all new `.bot` programs have deterministic `# expect:` values?**
    Yes — all three, verified against the interpreter and by hand.
42. **Do interp/compile/cranelift agree?** Yes, exit 0, no disagreements.
43. **Were any historical `.ir` fixtures used as canonical input?** No.
44. **Were any old canonical `.bot` files refactored?** No (hash-confirmed
    unchanged).
45. **Can all new programs enter the next census automatically through
    current `.bot` discovery?** Yes — `bench/bench.tcl`'s own `glob
    -directory ... *.bot` already picked up all three with no change to
    `bench.tcl` itself, confirmed by the benchmark-smoke run above.

## Recommended scope for the next census

Per the existing dynamic-census tooling's own corpus definition
(`audit/post-r2a-dynamic-census/tools/corpus.tcl`: `bench/*.ir` (historical
only, exclude going forward per `CANONICAL-SURFACE-BENCHMARKS.md`),
`bench/*.bot`, `examples/stdlib/*.bot`, `examples/surface/*.bot`), the
next fresh source-grounded dynamic census should walk:

- **`bench/*.bot`** — all 8 (5 pre-existing + 3 new from this milestone).
- **`examples/stdlib/*.bot`** — 9 files, already part of the existing
  corpus-tool's own default set.
- **`examples/surface/*.bot`** — 14 files, likewise already included.
- **No `bench/*.ir`** — historical-reproduction-only, not canonical source
  (per `CANONICAL-SURFACE-BENCHMARKS.md`, already excluded from this
  milestone's own scope).
- **No new synthetic analysis-only fixtures** — none were created by this
  milestone; the 3 new programs are themselves meaningful workloads, not
  microfixtures, satisfying item 75's stop condition throughout.

This milestone's own structural (static) census above is the input that
census should build on; it deliberately did not attempt dynamic call
counts beyond what `bench/bench.tcl`'s own timing run already exercises
(item 40's "lightweight, don't build a new profiler" scoping) — the full
dynamic instrumentation is explicitly the next milestone's job, not this
one's.
