# Compiler warnings: the framework and `SAME-RETURN-VALUE`

## Outcome

Botlish now has a reusable compiler-warning infrastructure (`hir/warnings.tcl`)
and one warning on it, **`SAME-RETURN-VALUE`**: several distinct, reachable
exits of one function are *proven* to return the same value.

```
fn classify(x):
    if x < 0:
        return invalid
    if x > 100:
        return invalid
    valid
```
```
f.bot:3:9: warning: value `-1` (`invalid`) is returned from 2 distinct exits (SAME-RETURN-VALUE)
f.bot:5:9: note: also returned here
```

The warning states a semantic fact and stops. It does not say combine the
conditions, drop the `else`, split the failures or replace the sentinel: each of
those can be the right response, and so can keeping the repeated sentinel as the
API. A program with the fact is a correct program. This is not a style rule and
not text matching: two `return 0`s are reported because the compiler's own
exact-value facts prove the values equal, and `return zero` / `return 0` are
reported for the same reason, while two textually identical calls are not.

> Warnings preferentially report semantic facts the compiler can prove rather
> than enforce source-style fashions.

There is one global policy per compilation and nothing finer:

| mode | what happens |
|------|--------------|
| `default` | warnings are discovered, attached to the HIR, and printed on stderr |
| `off` | no warning pass runs |
| `error` | the first warning is a compilation error carrying its own code, raised before any backend runs |

**Botlish does not currently provide GCC/Clang-style `-Wfoo` controls** (no
`-Wno-foo`, `-Werror=foo`, `-Wall`, `-Wextra`, warning groups or levels), and
there is no source suppression (no annotation, pragma or lint-ignore comment).
This is intentional, not forgotten CLI work: every warning is on for everyone,
so each must be trustworthy enough to be, and uncertainty means no warning.
Warning codes are stable identities for tests, diagnostics, editor tooling and
documentation, not switches. Generated source and noise-sensitive compilation
(benchmarks, embedding) use the one global switch, `-warnings off`.

## Warning infrastructure

`hir/warnings.tcl`, loaded with the other `hir/` files. Four separate concerns:

| concern | where |
|---------|-------|
| **discovery** | a *pass* (`SameReturnValue`) reads analyzed HIR and returns warning records. It does not know whether warnings are shown, suppressed or promoted, and never changes HIR. |
| **identity** | the record's `code`, stable. |
| **policy** | one global mode per compilation, applied by `hir::warnings::run`, never inside a pass. |
| **emission** | `hir::warnings::render` (text) and the channel `run` writes to (stderr by default; `""` collects without printing). |

The pass registry is static, one line per warning:

```tcl
variable passes {
    SAME-RETURN-VALUE hir::warnings::SameReturnValue
}
```

Warning #2 is its pass plus one registry line; the record shape, ordering,
rendering, policy modes and error promotion are inherited. There is no dynamic
registration.

### Diagnostic representation

A warning is a dict `{code message primary secondary data}`:

| field | meaning |
|-------|---------|
| `code` | stable code, `SAME-RETURN-VALUE` |
| `message` | neutral text, without code or location |
| `primary` | an HIR origin (`{file f1 node .. line .. column ..}`), the anchor |
| `secondary` | related origins, source order |
| `data` | structured, pass-specific facts: `function` (block ExprId), `functionName`, `exits` (count), `sites` (ExprIds), `identity` (`value`/`binding`), `spellings`, `note` |

This is the repository's own origin vocabulary (`hir::originLocation`, factored
out of `surface::originLocation`, which now delegates to it), so a warning is
located exactly as every other diagnostic is, including inside module files.

**Rendering** follows `main.tcl`'s own `error: LOCATION: MESSAGE (KIND)` shape:

```
FILE:LINE:COL: warning: MESSAGE (CODE)
FILE:LINE:COL: note: also returned here        <- one per related location
```

**Error promotion** raises `core::semanticError CODE "LOCATION: MESSAGE (also at
LOC, LOC)"`, so the identity is the warning's own: `{CORE SEMANTIC
SAME-RETURN-VALUE}`, printed by `main.tcl` as `(CORE SEMANTIC
SAME-RETURN-VALUE)`, never a generic failure.

**Primary location policy.** The primary is the *first* exit in source order and
the others are secondary locations. Adding another matching exit later in the
function does not move the warning; one group is one diagnostic (never one per
pair, never one per location).

**Ordering.** Warnings are sorted by primary origin (file, line, column, offset),
then code, then message (`hir::warnings::Sort`), never by function order, id
allocation or dictionary order.

### Compiler API

Policy is a per-compilation option of every source entry point:

```tcl
surface::compile SOURCE ?FILE? ?-strict 1|0? ?-warnings default|off|error? ?-warning-channel CHAN?
surface::readProgramFile PATH ?same options?
surface::lowerToHir AST ?same options?
```
```sh
tclsh9.0 main.tcl -warnings default|off|error FILE.bot
```

* The warnings of a compilation are structured data on its HIR:
  `hir::warnings::of $hir`. They are a side table (`warnings`, like `semantic`)
  that no analysis, lowering or backend reads and `hir::format` does not print.
  Under `off` the key is absent.
* `hir::warnings::collect $hir` is discovery without policy (every warning,
  ordered); `hir::warnings::run $hir MODE ?CHANNEL?` is policy over discovery.
* **No global mutable mode.** Every compilation carries its own mode; interleaved
  compilations under different modes do not interact (pinned). The one piece of
  process-global state is `hir::warnings::stats`, a counter of pass runs that
  exists only so a test can *prove* a pass did not run.
* A compilation given no `-warnings` runs under the environment's
  `BOTLISH_WARNINGS` (`default|off|error`, read fresh by each compilation, never
  compiler state), else `default`. An explicit option always wins. It exists for
  hosts, `BOTLISH_WARNINGS=off tclsh9.0 bench/bench.tcl`, and the test harness.
* `main.tcl` rejects an unknown option (`-Wno-same-return-value` is
  `unknown option`) instead of treating it as a file name, and rejects an unknown
  mode.
* `native::report` (and `native::nir`, `native::clif`, ...) take already-built
  HIR; they compile no source, so there is nothing for them to collect, show or
  disable, and their machine-readable results never contain warning text
  (pinned: `native::report` is identical for the same program with and without
  the side table). Warnings go to stderr, never to program stdout, serialized
  HIR, NIR or a result channel.

### Policy modes: what `off` skips

`off` returns the HIR untouched before discovery: `SameReturnValue` is not
called. Nothing the compilation needs is conditional on the mode: the analyses
the warning *consumes* (HIR typing and reachability, `hir::exact` facts, the
completion proof) run in every mode because compilation needs them, and the
warning adds only its own consumption. The one extra computation a warning does
(`hir::completions::reachedExprs`, below) runs only for a function that already
has a candidate warning, only with warnings on. Pinned two ways: the
`hir::warnings::stats` counter (empty under `off`, `{SAME-RETURN-VALUE 1}` after
one `default` compile) and an execution trace on the pass proc (0 calls under
`off`, 1 under `default`).

Warnings never influence specialization, HIR or NIR content, optimization, type
inference, proof facts or runtime behavior: they read the final HIR. Pinned: the
HIR (`dict remove $hir warnings`), `hir::format`, `hir::lower` and `native::nir`
are identical under `off` and `default`.

`error` rejects in the frontend's last step (`surface::lower::Finish`), before
`hir::lower`, `native::prepareHir`, `native::evalHir` or `core::compiler::evalHir`
can be reached; pinned by execution traces on all four (0 calls) and by a
`main.tcl -backend cranelift -warnings error` run that prints no value.

### Warning timing

Warnings are discovered in `surface::lower::Finish`, after `hir::buildSyntax`
(resolution, `hir::check`, types, ranges, completion proofs) and after strict
diagnostics are raised, before any backend. A program with error diagnostics
(including `-strict 0` programs that kept them) is never warned about: a program
the compiler rejects has no trustworthy facts to warn from. Warnings are
backend-independent. Warnings belong to the source frontend: `.bot` programs get them; `.hir` and `.ir` inputs (which have no source origins to point at) compile as before. There is no code in Cranelift, NIR lowering, the Tcl
compiler or the interpreter; the interpreter does not rediscover them.

## `SAME-RETURN-VALUE`

**Meaning.** Several distinct, reachable exits of one function are proven to
return the same value. The wording is neutral:
`value `X` is returned from N distinct exits` (or ``the value of `b` is returned
from N distinct exits``), with the exits as locations.

**Exits of a function.** The terminal completions of a `block`:

1. every reachable `return` whose target is the function, wherever it sits in
   the body (inside loops, branches and on-handlers included), and
2. the function's **final-expression value**: the body's last expression, or,
   when that is a written `if`/`elif`/`else`, the last expression of each
   reachable branch, recursively.

*Decision (item 7): the final expression is an exit.* A function that falls off
its end completes exactly like one that returned there, so
`if x: return 0` / `0` is two exits of `0`. No synthetic return machinery is
added: the leaves are read from the HIR as it is, as `hir/escape.tcl`'s `Exits`
already does for its own purposes. One caveat the frontend forces: the `if` the
frontend synthesizes for `a and b`, `a or b`, `not a` and `a != b` (its branches
all carry the operator's one origin, where a written `if` has a distinct `then`
and `else`/end origin) is one expression, not branches the programmer wrote, so
it is never opened (`a or b` is not "true from two exits").

An exit is a *source operation*: reaching it through several control-flow
predecessors is still one exit. Returns of a nested function or closure belong
to that function, which is analyzed on its own. `fail` is not a return and is
never grouped with one; a tail call is an ordinary call (no tail-call
special-casing); recursion cannot loop (the pass walks syntax, and the
completion walk it consults uses its existing recursion guard and budget).

**Value proof source (no new theorem prover).** Two exits return the same value
when `hir::exact::Identity` proves it. That helper was extracted from the
exact-value analysis (`hir/exactvalue.tcl`, `EXACT-VALUE-FACTS.md`) because the
question "are these two expressions provably the same value?" is not
warning-specific; it adds no fact the compiler did not already derive:

| identity | when | what counts as the same |
|----------|------|--------------------------|
| `{value V}` | `hir::exact::Of` yields a fully exact value (a scalar `Int`/`Bool`/`String`/`UnicodeChar`/`unit`, or a List whose elements are all exact), followed through immutable aliases, decided `if`s, exact `+ - *`, `list_get` of exact Lists, ... | structurally equal exact values (`core::value::equal`), never by object identity |
| `{binding B}` | the expression reads the value of immutable binding `B` after following `y = x` aliases (a parameter, loop element or local; mutable values included) | the same alias root binding |
| none | everything else | never grouped |

So: same literal, a literal and an immutable alias of it, branch-local aliases,
alias chains, a module-level sentinel (`invalid = -1`), the same immutable
binding returned twice, and the exact same *mutable* binding returned twice all
warn. Never grouped: unknown parameters (two different ones), calls (however
identical they look: a call may have effects or yield distinct values),
arithmetic over unknowns, separately constructed mutable values
(`mutable_array_allocate(1)` twice is two values), Lists with an unproven
element, and structs (no exact struct fact exists; a struct *binding* returned
twice still warns, as any binding does). Nothing reads a runtime `==`. The
claim made is the one proven, "same exact value / same binding", and the
user-facing phrase is "the same value".

**Reachability, from existing facts.** An exit counts only if it can execute:

* HIR's structural reachability (`reachable` on each expression: statically
  decided branches, code after an expression that cannot complete), and then,
  only for a function that would otherwise warn,
* the completion proof's own walk (`hir::completions::reachedExprs`, a
  recording mode of the existing `hir/completions.tcl` walker: the same walk
  `checkBlock` makes, parameters unconstrained, a branch whose narrowed range
  is empty never entered). It prunes what HIR's structural flag cannot: for
  `if x < 0: if x > 5: return 1 ...`, the inner `return 1` is not an exit.
  It can only remove exits, never add one; "unknown" keeps the exit, so the
  direction of any error is a missed warning, not a false one.

**Grouping.** Exits are grouped by identity. A value with at least two exits is
**one** warning; each repeated value of a function is its own warning
(`A A B B B C` -> a warning for A and one for B, none for C); a single exit is
never a warning.

**Unit policy (item 25): repeated `unit` is not reported.** `return`, `return
unit`, a final `unit`, and a destructuring statement's `unit` all produce the
unit value. Procedural functions routinely have several, and a warning for them
collapses no interesting domain information; the compiler has no corpus
evidence they are useful. An exit whose type is `unit` is skipped whatever its
identity. `Bool` is not special-cased: repeated `false` is reported.

**Generic vs specialized (items 52-55).** The pass reads the generic,
source-level HIR once per source function. It never walks semantic instances or
specializations, so a function specialized ten ways is one warning, source
locations are the source's own, and only an equality the *source* analysis
proves is reported; an equality only one instance would prove is not. There is
no consensus algorithm among specializations and no specialization-dependent
warning. Closed single-instance functions get exactly the facts the source
analysis has, no more.

**Errors, handlers, loops.** `fail` is a different completion kind: never
grouped. A `return` inside an on-handler body is a normal return of the
enclosing function (the HIR node's target is the function) and participates; a
`return` inside any loop form is a terminal exit. `elif` is a nested `if`
before analysis and needs no support. Method sugar is an ordinary call by the
time HIR exists.

## Test harness convention

The harness (`tests/helpers.tcl`) sets `BOTLISH_WARNINGS=off` as the process
default, because a warning is stderr output and tcltest counts any test-file
stderr as an error (`exec main.tcl` also fails on it): the first full run with
default warnings failed existing tests that compile corpus programs. It is only
the default for a compilation that is given no policy, and, through the
environment, for the `main.tcl` children executable tests spawn. `tests/
warnings.test` passes its policy explicitly on every compile, so it exercises
default, off and error regardless; the user-facing default is exercised by its
`main.tcl` cases and by CI's plain `main.tcl` corpus runs. Unrelated tests were
not edited. Benchmark and analysis scripts that compile corpus sources pass
`-warnings off` explicitly (`bench/*.tcl`, `native/explain-native.tcl`,
`native/generate-*.tcl`).

## Corpus findings

Observational only; the corpus is frozen and was **not** edited.
`audit/same-return-value/tools/corpus.tcl` compiles every program of
`examples/stdlib` (9), `examples/surface` (14; `09`/`10` are deliberate
rejection examples and do not compile), `bench/*.bot` (8) and `lib/*.bot` (7)
with warnings on and lists each distinct warning once
(`audit/same-return-value/corpus-audit.txt`). Programs embedded as text inside
`bench/*.tcl` scripts are not part of this audit.

**4 `SAME-RETURN-VALUE` warnings**, each inspected by hand:

| # | where | what | classification |
|---|-------|------|----------------|
| 1 | `examples/stdlib/csv_records.bot:325` `ht_find_insert` | `return index` from 2 exits (an empty slot at `index`; the key found at `index`) | **intentional same result**: the result is "the slot to use", two reasons yield the same slot; not a sentinel. Benchmark artifact of the hash-table corpus. |
| 2 | `examples/stdlib/hashtable.bot:187` `ht_find_insert` | the same function in the other corpus program | same as #1 (the same source, two corpus files) |
| 3 | `lib/web.bot:163` `domain?` (nested in `emailish?`) | `false` from 4 exits (three rejections inside the loop, plus the fall-through after it) | **intentional same sentinel**: a predicate that rejects in several ways. Legitimate: the return is `Bool`, and the API is `Bool`. |
| 4 | `lib/web.bot:175` `emailish?` | `false` from 3 exits (the leaves of a nested `if`/`else` tree) | **duplicated branch structure**: the nest of `if`s that all end in `false` is a conjunction spelled as nesting |

No false positives: every finding is a true statement of what the function
does. The two `web.bot` findings appear whenever a program loads `lib/web.bot`
(e.g. `bench/uri-steady.bot`), because warnings concern all code
in the HIR; this is a known limitation (below). None of the four is a "possible
richer error split" (the functions are predicates and a slot search; nothing
there is an error in disguise).

## Tests

* `tests/warnings.test` (81 tests). Literals (`Int`, `Bool`, `String`,
  `UnicodeChar`, exact List), different kinds and values never grouping;
  aliases (alias vs literal, chains, module sentinels, branch-local, alias of
  alias); same binding (local, parameter, alias of a binding, mutable binding,
  alias of a mutable binding); unknown values; repeated calls; separate mutable
  construction; final-expression policy, elif chains, boolean-operator
  synthesis, else-less final `if`; loops (list and counted), handlers, failures
  versus returns; nested functions and closures; unreachable exits (static and
  range-pruned, with a feasible control); recursion; unit suppression
  (explicit, bare, final, destructuring, via alias); method sugar as a call;
  grouping (three exits one group, A/B/C, interleaving with the final value);
  record shape, rendering, neutral message, ordering, determinism, emission
  channel; the policy matrix (default, off, error, default-is-default,
  environment default, unknown mode, no `-Wfoo` option, promoted identity);
  the pass not running when off (counter and trace); no HIR/`format`/lowering/
  NIR/`native::report` change; per-compilation interleaving; backend
  independence in process (the same HIR on all four backends) and through the
  CLI (identical warning text on all four); `-warnings error` stopping before
  any lowering (traces and a native-backend CLI run); stdout/stderr
  separation; a module warning located in the module file; a short fuzz run.
* `tests/surface-modules.test` (+1): a module's expressions inside every loop
  form and on-handler keep the module's file origin (below).

## Fuzzing

`audit/same-return-value/tools/fuzz.tcl SEEDS FIRST`. Each seed generates one
function of 2-8 terminal paths from a pool of exits whose values are known by
construction: literals, module aliases and alias chains, branch-local aliases,
a parameter, a shared local binding and an alias of it, calls (unique), mutable
allocations (unique), statically unreachable exits (`if 1 == 2`), and
range-unreachable exits (`if p0 < 0: if p0 > 5`); the final path is a `return`
or a final value at random. An oracle independent of the compiler groups the
exits by construction key and predicts the warnings and their exit lines. Each
program is compiled under all three modes: `default` must produce exactly the
predicted groups, `off` must compile silently and run no pass and produce an
identical HIR, `error` must reject with `{CORE SEMANTIC SAME-RETURN-VALUE}` iff
a warning exists. Compiler-proven extra groups are reported as `EXTRA` for
inspection rather than failing. **2000 seeds (1335 with warnings, 665 without):
0 failures, 0 missed constructed groups, 0 extra groups.** The test suite runs
60 seeds.

## Fix found along the way

`surface/modules.tcl`'s `RemapFile` (which repoints a module's origins at its
own file id) did not descend into `listloop`, `countloop`, `lockloop` or `handle`
nodes, so every expression inside those in a *module* kept the entry file's id:
the first corpus audit reported `lib/web.bot`'s `domain?` exits as `bench/
uri-steady.bot:163`. This pre-existing mislocation affected every diagnostic
inside those constructs in module code, not only warnings. Fixed and pinned
(the new surface-modules test fails without the fix). Origins are diagnostic-only;
no analysis reads them.

## Full regression

`tests/all.tcl` on both Tcl backends, default test-harness policy
(`BOTLISH_WARNINGS=off`), against a suite of 4680 tests before this milestone:

* **`interp`: 4762 tests, `compile`: 4762 tests** (82 new: 81 in
  `tests/warnings.test`, 1 in `tests/surface-modules.test`).
* The two backends were run as parallel processes. Every failure of either run
  was in a file that writes fixed-name scratch files or directories shared by
  the two processes (`direct-hir-native.test`'s executable fixtures in both
  runs, `ascii.test`'s `ascii-boundary-*.bot` once): another process removed the
  file or directory first. Those two files pass 33/33 on each backend when run
  alone, and no other file failed.
* `tests/warnings.test` passes 81/81 on `interp`, `compile`, `cranelift` and
  `cranelift-generic`.
* The first full run, made before the harness default existed, failed every
  existing test that compiled a program with a repeated return, for the reason
  recorded under "Test harness convention"; that is why the harness default
  exists.
* `tests/native-coverage.tcl` (the suite on `cranelift`, as CI's native job):
  4796 tests, 0 failed (1988 native, 2679
  independent of the backend, 69 passed-partial, 60 unsupported for the
  constructs it already classifies).
* CI's plain example steps (`main.tcl -backend interp`, and `main.tcl -backend
  cranelift` over the corpus, surface and HIR samples) exit 0; the two corpus
  warnings of `csv_records.bot` and `hashtable.bot` are printed on stderr only.
* The fuzzer: 2000 seeds, 0 failures (`audit/same-return-value/fuzz-result.txt`).

## Known limitations

* Library warnings are shown: a warning inside `lib/*.bot` appears for any
  program that loads that module, because the pass sees all code in the HIR.
  (There is no "system header" notion; and with the corpus frozen, two
  `web.bot` warnings print for every `uri-steady` run until the warning-driven
  refactor.)
* Struct and non-trivial immutable values have no exact-value fact, so equal
  struct literals are not grouped (only a shared binding is); likewise Lists
  past the exact-value bounds (8 elements, 3 levels).
* Source-level analysis only: an equality that holds only in a specialization,
  or only through interprocedural facts, is not reported.
* Reachability is "not proven unreachable": an exit hidden behind a condition
  only the interprocedural Range pass could refute still counts.
* Only the first warning is raised under `error` (like the first diagnostic of
  `-strict 1`).
* A body's synthesized boolean `if` is recognized by its origins (all branches
  carry the operator's origin); core-IR-built HIR has distinct origins and never
  contains `and`/`or`.
* Successor note (REFACTOR-WARNINGS-CLEAN.md): the warning-driven refactor
  merged all six corpus findings (the two slot searches, `ht_delete`, and
  `web.bot`'s `domain?`, `emailish?` and `valid_from?`), so no library carries
  a `SAME-RETURN-VALUE` finding and `uri-steady` prints none; a gate
  (`audit/refactor/tools/gate.tcl`, CI) fails on any new one.

## Future warning candidates

Only warnings that state a provable semantic fact, in the same framework:

* `SAME-FAILURE`: the same declared failure from several exits (a repeated
  `fail NAME`; deliberately separate from returns, whose completion kind it is
  not). One registry line and a pass.
* a condition that repeats an already established proof;
* manual iteration whose cardinality duplicates another domain (lockstep
  candidates);
* an ordinary call provably eligible for the preferred method syntax.

Not planned: style rules (`no else`, `always else`), "a sentinel should be an
error", automatic rewriting. A warning that cannot cite a compiler proof does
not belong in a default-on, non-suppressible system.

## Required questions

**Warning framework**

1. *Enabled by default?* Yes (`default` mode; `BOTLISH_WARNINGS` can only change
   the default of a compilation that is given no option).
2. *All warnings disableable globally?* Yes: `-warnings off`.
3. *All warnings promotable globally to errors?* Yes: `-warnings error`.
4. *Per-warning `-Wfoo`/`-Wno-foo` flags?* No.
5. *Warning groups (`-Wall`/`-Wextra`)?* No.
6. *Codes stable?* Yes (`SAME-RETURN-VALUE`).
7. *Policy per compilation, not global mutable state?* Yes: an option of every
   compile entry point; the only global state is a pass-run counter used by
   tests.
8. *Does `off` skip warning-specific passes/work?* Yes: the pass is not called
   (counter and trace pin it); the analyses compilation needs run in every mode.
9. *Does `error` preserve the code?* Yes: `{CORE SEMANTIC SAME-RETURN-VALUE}`.
10. *Backend-independent?* Yes: discovery precedes any backend; identical on
    `interp`, `compile`, `cranelift`, `cranelift-generic`.

**`SAME-RETURN-VALUE`**

11. *Meaning:* multiple distinct reachable function exits are proven to return
    the same value.
12. *Source-text equality?* No.
13. *Reuses existing value/proof analysis?* Yes: `hir::exact` facts (and the
    completion proof's walk for reachability).
14. *Unknown equality warns?* No.
15. *Repeated identical calls assumed equal?* No.
16. *Immutable aliases proven equal trigger it?* Yes.
17. *The exact same mutable binding returned twice?* Yes.
18. *Separately constructed mutable values merely matching in syntax?* No.
19. *Unreachable returns ignored?* Yes (structural and range-pruned).
20. *Multiple matching exits grouped into one warning?* Yes.
21. *Several groups per function?* Yes.
22. *Repeated `unit` warned on?* No (implemented policy).
23. *Prescribes combining conditions, removing `else`, or replacing sentinels
    with errors?* No.
24. *A repeated sentinel still legal?* Yes.

**Architecture**

25. *Stage:* `surface::lower::Finish`, after `hir::buildSyntax`/`hir::check` and
    strict diagnostics, before any backend.
26. *Existing analyses:* HIR typing and reachability (`reachable`, `never`,
    decided branches), `hir::exact` (exact values, aliases) via
    `hir::exact::Identity`, and the completion proof walk
    (`hir::completions::reachedExprs`).
27. *Representation:* `{code message primary secondary data}` dicts; side table
    `warnings` on HIR.
28. *Related locations:* `secondary`, a list of HIR origins, rendered as `note:`
    lines and, under `error`, as "(also at ...)".
29. *Deterministic ordering:* `hir::warnings::Sort` by primary origin, code,
    message; exits are in source order by pre-order position.
30. *Duplicates across semantic instances prevented:* the pass reads the generic
    source HIR once per source function and never visits instances.
31. *Do warnings affect HIR/NIR generation?* No (pinned).
32. *Does `error` reject before backend lowering?* Yes (pinned).
33. *Collectable structurally?* Yes: `hir::warnings::of $hir`,
    `hir::warnings::collect`.
34. *Did off demonstrably avoid the warning pass?* Yes: stats counter and an
    execution trace.

**Verification**

35. *Corpus warnings (unreformed):* 4 (two distinct functions in `web.bot`, one
    `ht_find_insert` in each of two corpus files).
36. *Categories:* intentional same result (slot search, 2), intentional same
    sentinel (Bool predicate rejection, 1), duplicated branch structure (1).
37. *False positives:* none.
38. *Warning-mode tests pass?* Yes: `tests/warnings.test` 81/81 on `interp`,
    `compile`, `cranelift`, `cranelift-generic`.
39. *Fuzzer:* 2000 seeds, no incorrect warnings, no missed constructed cases, no
    extra groups.
40. *Every backend saw the same warning set?* Yes (in process on one HIR, and
    through `main.tcl` on all four backends over the stdlib corpus).
41. *Full regression:* Yes: 4762 tests on each Tcl backend (4680 before this milestone), the only failures being fixed-name scratch-file collisions between the two parallel runs (the affected files pass alone); see "Full regression".
