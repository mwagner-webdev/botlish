# Compiler warnings: `PROVES-NAMING`

## Outcome

Botlish's fifth compiler warning, **`PROVES-NAMING`**, is one pass plus one
registry line on the warning framework of milestones 1-4 (`hir/warnings.tcl`;
WARNINGS-SAME-RETURN.md, WARNINGS-METHOD-ELIGIBLE.md,
WARNINGS-FIXED-ARITY-LIST-RETURN.md, WARNINGS-SAME-FAILURE.md): a function
fitted with a `proves` contract (REFINEMENT-VALUES.md), of one of the two
shapes the refinement feature defines, whose written name does not follow that
shape's naming convention.

```botlish
refined type Emailish = str
fn emailish(v: str) -> bool proves v: Emailish:
    v == "a@b"
```
```
t.bot:2:1: warning: `emailish` proves a contract and returns bool; predicate names end in `?` (PROVES-NAMING)
```

(`tests/proves-naming.test`, `pn-emailish-rendered`.)

The warning states the shape and the convention and stops. It does not print
the name to use, does not rename anything, and never looks at a function
without `proves`. The response is a rename: the author's own act,
semantics-preserving and fully checked by the compiler (the rename law below
verifies exactly that, mechanically, over 2000 generated programs).

**A language finding at kickoff, resolved by a separate feature.** The brief's
second shape, the validator (`-> unit` plus `proves`), did not exist in the
language this milestone started from (`e6a871f`). Two things ruled it out:
`unit` is a keyword token, not a type name, so `-> unit` was a syntax error
("expected a result type after ->, found "unit""), and `hir/resolve.tcl`'s
`ResolveProofs` rejected a proof clause on any function not declaring `->
bool` (`PROOF-CLAUSE`; REFINEMENT-VALUES.md listed "minting without a Boolean
edge" as future work). A program with an error is never warned, so no program
the warning could run on had a validator. This was reported before any
validator work, and the decision was to implement validators fully as a
separate piece of work, by a separate agent, and to continue this milestone
according to the brief. That work is merged here (`cf68102` the compiler,
`7634621` the refinement fuzzer, `72060fa` its documentation; merge `982fca1`)
and is documented in REFINEMENT-VALUES.md, "Validators": `unit` is writable as
a type name, `ResolveProofs` admits `-> unit` with the proof rule's outcome
`normal`, and a validator call that completes normally proves its argument for
everything after it on that path. This warning's pass needed nothing from that
work beyond the language admitting the shape: it reads the declared result,
which is now `unit` for a validator. Everything the brief asks of the
validator rule -- its tests, the fuzzer's validators and their rename law, the
mutants -- runs on the merged tree.

## The two rules

> A function is reported exactly when it carries a `proves` contract, declares
> exactly one ordinary parameter, and
>
> * **predicate**: its result is `bool` and its written name does not end in
>   `?`; or
> * **validator**: its result is `unit` and its written name is neither
>   exactly `validate` nor begins with `validate_`.

One diagnostic per function. `bool` and `unit` are distinct, so a function has
at most one shape, and no name violates both rules at once. Each clause is
pinned (all in `tests/proves-naming.test`):

| clause | pinned by |
|---|---|
| carries a `proves` contract | `pn-scope-no-proves-bool-never-warned` (the load-bearing pin), `pn-scope-question-without-proves-never-warned`, `pn-scope-no-reverse-rules` |
| exactly one ordinary parameter | `pn-shape-parameter-count`, `pn-scope-out-of-shape-proves-silent`, `pn-scope-zero-parameters-unrepresentable`, `pn-cross-two-parameters-silent` |
| flags and context parameters are not ordinary | `pn-shape-flags-do-not-count`, `pn-shape-context-parameters-do-not-count` |
| the result is `bool`: predicate | `pn-predicate-violating-warns`, `pn-predicate-result-is-the-declared-bool`, `pn-cross-validate-name-predicate-shape`, `pn-cross-bare-validate-predicate-shape` |
| the result is `unit`: validator | `pn-validator-violating-warns`, `pn-cross-question-name-validator-shape` |
| any other result: silent | `pn-scope-other-results-silent-in-hir-text`, `pn-predicate-needs-a-declared-bool` |
| predicate name: trailing `?` | `pn-predicate-conforming-silent`, `pn-question-mark-boundary` |
| validator name: exactly `validate` | `pn-validator-conforming-silent`, `pn-written-name-module-function` |
| validator name: literal prefix `validate_` | `pn-validator-conforming-silent`, `pn-validator-violating-warns`, `pn-validator-prefix-is-literal-and-case-sensitive` |
| `validate_` (empty suffix) conforms | `pn-validator-empty-suffix-sharp-edge` (the sharp edge, pinned) |
| `errors` neither qualifies nor disqualifies | `pn-fallible-predicate`, `pn-fallible-and-infallible-validators` |
| one diagnostic per function | `pn-one-diagnostic-per-function`, `pn-instances-never-walked` |

The pass is `hir::warnings::ProvesNaming` with the helpers `ProvesShape`,
`WrittenName` and `ConventionalName`, appended to `hir/warnings.tcl`. It
reuses milestone 2's `MemberName` as it is.

**The `?` boundary.** A trailing `?` is the only `?` an identifier can have:
R2A2-TRAILING-QUESTION-IDENTIFIERS.md made a terminal `?` ordinary identifier
spelling and rejects an embedded or repeated one (`x?y`, `x??`) at the lexer.
So the brief's "a name with `?` only in the middle" cannot be written; what is
pinned is that both are syntax errors (`pn-question-mark-boundary`), and the
fuzzer does not generate them.

**The `validate_` prefix is taken as written**: a literal, case-sensitive
prefix match (`string first validate_ NAME == 0`). `Validate_x`, `VALIDATE_x`,
`validateX`, `validator_x`, `validates`, `x_validate` and `x_validate_y` are
reported; `validate_` with an empty suffix conforms. That last one is a
recorded sharp edge, not a defect: no nonempty-suffix constraint was invented
(`pn-validator-empty-suffix-sharp-edge`; the `empty-suffix-rejected` mutant is
killed).

## The scope guard: no `proves`, no opinion

The scope guard is this warning's defining boundary: it is what keeps it from
being a general naming linter.

* **A function without `proves` is never looked at.** The pass iterates the
  function declarations (`bind` nodes whose value is a `block`) and skips every
  block whose resolved proof contract (`proofs`) is empty before it reads
  anything else. `fn is_empty(v: str) -> bool` is silent, with a declared or an
  inferred bool result, and so is `fn emailish(v: str) -> bool` -- a name the
  warning would report if the function carried `proves`
  (`pn-scope-no-proves-bool-never-warned`, the load-bearing pin; the
  `scope-guard-dropped` mutant is the critical one, and it is killed).
* **A `?`-suffixed function without `proves` is never looked at**, whatever it
  returns (`pn-scope-question-without-proves-never-warned`).
* **The convention is scoped to the feature's own shapes.** A proves function
  with two or more ordinary parameters is silent, whatever its name
  (`pn-scope-out-of-shape-proves-silent`). Zero ordinary parameters cannot
  carry `proves` at all -- the clause must name an ordinary parameter
  (`PROOF-CLAUSE`), in source and in HIR text
  (`pn-scope-zero-parameters-unrepresentable`). A proves function whose result
  is neither `bool` nor `unit` is rejected by the frontend (`PROOF-CLAUSE`), so
  that silence is pinned on hand-edited HIR text, which `hir::parse` admits:
  `declares str`, `declares int` and no declared result are all silent
  (`pn-scope-other-results-silent-in-hir-text`).
* **There is no reverse rule.** Nothing checks that a `?` name returns `bool`,
  that a `validate_` name returns `unit`, or anything at all about a function
  without `proves` (`pn-scope-no-reverse-rules`).

Multi-parameter predicates are a possible future extension, recorded only if
corpus evidence appears (see "Future warning candidates").

## Shape decisions

**Ordinary parameters: flags and contexts do not count.** The count is the
block's `params` minus its `flags`, exactly as milestone 2 counts a callee's
ordinary parameters (`NamedCallee`). A flag is "an immutable `Bool` parameter
with a fixed default of `false`, set to `true` solely by the presence of its
flag name" (FLAGS.md): an option, not a value the proof is about -- and a proof
clause cannot name a flag (`PROOF-CLAUSE`: "is a flag, not an ordinary
parameter"). So `fn strict(v: str, flags :exact, :loose) -> bool proves v: E`
is a single-value predicate and is reported; two ordinary parameters plus flags
are not (`pn-shape-flags-do-not-count`). Context parameters (CONTEXTS.md) are
not in the block's `params` at all; a predicate with one ordinary parameter and
a context is in shape (`pn-shape-context-parameters-do-not-count`). This was
not judged unclear: both categories are the language's own separate parameter
sections, and the compiler's own ordinary count (the binding's `flagIface
ordinary`) agrees. (A block read back from HIR text records no `flags`; the
pass reads it as none.)

**The result type is the declared result the checker enforces.** The brief
asks for the result "as the checker proves it -- declared annotation or
inferred, whichever the checker's fact is". For a proves function that is the
declared result: `ResolveProofs` requires a declared `-> bool` (or, since the
validator feature, `-> unit`), so an inferred-only result cannot carry a proof
(`pn-predicate-needs-a-declared-bool`: no result, `-> str`, `-> int` are all
`PROOF-CLAUSE` errors, and a program with an error is never warned). The block's
`declaredResult` -- milestone 3's precedent, resolved by `hir::resolve` in every
compilation mode -- is the fact, and the checker proves the body against it.
Its inferred result can be narrower (a constant, or `never` for a body that
always fails), which is why the declared type is the right one: `always`
(`true`), `never_completes` (`fail Bad`) and `computed` are all predicates
(`pn-predicate-result-is-the-declared-bool`). Unknown, union, `any` and
generic results cannot be declared on a proves function, so they cannot arise;
any declared result other than `bool` or `unit` is silent.

**Fallible functions.** The grammar allows an `errors` clause after the proof
clause, on predicates and validators alike, and the pass never reads it: a
fallible predicate or validator is judged by its shape and name alone
(`pn-fallible-predicate`, `pn-fallible-and-infallible-validators`).

**Nested functions and closures.** The language allows `proves` on a nested
function (the owner check compares the function's *module* with the
refinement's owner, and a nested function in the entry program is in the entry
program). They are declarations like any other and are checked
(`pn-nested-function-and-closure`, a closure over the enclosing parameter
included); the fuzzer generates them.

## The written name, never hygiene's spelling

The name checked is the declaration's written name. Hygiene (`hir/hygiene.tcl`)
renames bindings in two ways, and the pass undoes both:

* `Rename` gives a later binding that name-based core IR would let capture an
  earlier reference (or a binding shadowing a root reference the frontend
  needs, such as `list`) the fresh name `NAME#N` and records the written name
  in the binding's `spelling`. The pass reads `spelling` first.
* `qualifyModules` renames a module's own definitions to their qualified
  spelling, `ns::name`, recording nothing (the qualified name is the canonical
  identity). The pass takes the member after the last `::`
  (`hir::warnings::MemberName`, milestone 2's helper): a module function is
  checked, and reported, under the member name its author wrote.
* HIR read back from text keeps no `spelling`, so a `#N` suffix there is
  dropped (source can never spell `#`).

This is milestone 2's `ResolutionView` lesson in reverse: there, resolution
needed the written names to be looked up; here only the written spelling
matters. Pinned: a violating `p` and a conforming `q?` that hygiene renamed
`p#1` and `q?#1` -- the conforming one silent, the violating one reported as
`p`, with no `#` in any message (`pn-written-name-hygiene-renamed`); a proves
function named `list`, renamed `list#1` because a list literal needs the root
`list`, reported as `list` (`pn-written-name-root-shadow`); a module's
violating predicate and validator reported as `check` and `check_path` and
located in the module file, while its bindings are `pth::check` and
`pth::check_path`, and its conforming `ok?` and bare `validate` silent
(`pn-written-name-module-function`); shadowing around the declaration -- a
non-proves outer function, a parameter and a local of the same name, a later
rebinding -- changes nothing (`pn-written-name-shadowing-around-the-
declaration`); and the same renamed functions read back from HIR text
(`pn-written-name-hir-text`). The `hygiene-spelling-checked` and
`qualified-name-checked` mutants are killed.

## Record, message, ordering

**Record.** The framework's `{code message primary secondary data}`:

* `primary`: the function declaration's own origin -- the `bind` of the `fn`,
  whose origin starts at the `fn` keyword (column 1 at the top level, the
  nested indentation otherwise). This is the repository's convention for a
  declaration-level fact (`pn-primary-is-the-declaration`). A module
  function's is in the module file.
* `secondary`: empty -- a single-location fact, as in milestone 2. `render`
  prints no `note:` line (`pn-render-has-no-notes`).
* `data`: `function` (the block ExprId), `functionName` (the written name) and
  `kind` (`predicate` or `validator`), nothing else; no rendered source text
  (`pn-record-data-fields`, `pn-kind-values`, `pn-no-rendered-source-in-data`).

**Message.** Two templates, one per shape (`pn-message-templates`):

```
`NAME` proves a contract and returns bool; predicate names end in `?`
`NAME` proves a contract and returns unit; validator names are `validate` or begin with `validate_`
```

The function is named, both facts are stated (it proves a contract; it returns
the shape's result), and the convention follows; nothing else. The result type
is spelled as the repository spells it: `bool` and `unit`, the spelling of the
annotation (`-> bool`), of `hir::types::show` and of every type diagnostic
(the brief's example wrote `Bool`; see "Deviations"). The validator tail
deviates from the brief's `validator names begin with \`validate\``: that
sentence is literally true of `validateX`, `validator_x` and `validates`, all
of which the rule reports, so the message would contradict its own finding;
the tail states the rule as it is.

**No suggested name.** The message never prints the name to use. For a
predicate the rewrite would be deterministic (`f?`), but for a validator it is
not: `validate_f` and the bare `validate` both conform, and which is right
depends on whether the function is a module's export -- prescribing one would
be the milestone-3 field-name mistake. Both templates are kept parallel, so
neither prints one. `pn-no-suggested-name` scans the rendered text for the
rewritten names (`emailish?`, `validate_check_email`, ...), `->`, `rename`,
`should`, `consider`, `use`, `instead`, `try`, `change`, `prefer`, `did you
mean`, `suggest` and `fix`.

**Ordering.** The inherited `Sort` (primary origin, then code, then message).
All five codes interleave by location, in both orders
(`pn-interleaving-five-codes`, `pn-interleaving-five-codes-other-order`), and a
proves function that also trips an existing code gets independent diagnostics:
a validator failing one failure from two exits (`SAME-FAILURE`) and a predicate
returning `false` from two exits (`SAME-RETURN-VALUE`)
(`pn-independent-of-other-codes`). Determinism: `pn-source-order-and-
determinism`, `pn-interleaving-deterministic`.

## Declarations, not call sites

The pass reads each function declaration once, in the generic source HIR.
There is no reachability notion at all: a declaration is warned regardless of
callers -- an uncalled violating function warns (`pn-uncalled-declaration-
warns`), and so does one declared in a statically dead branch
(`pn-no-reachability-notion`; the `reachability-added` mutant is killed). No
completion walk runs (`pn-no-completion-walk`: a trace on
`hir::completions::reachedExprs` sees 0 calls), and `hir/completions.tcl` is not
in the diff. Semantic instances live in the `semantic` side table and are never
visited: collecting over HIR stripped of that table gives the identical
warnings, and a function specialized into several instances, aliased and called
many times is one warning (`pn-instances-never-walked`,
`pn-one-diagnostic-per-function`; the `instances-visited` mutant is killed).

## Architecture

**One pass, one registry line.**

```tcl
variable passes {
    SAME-RETURN-VALUE hir::warnings::SameReturnValue
    METHOD-ELIGIBLE   hir::warnings::MethodEligible
    FIXED-ARITY-LIST-RETURN hir::warnings::FixedArityListReturn
    SAME-FAILURE      hir::warnings::SameFailure
    PROVES-NAMING     hir::warnings::ProvesNaming
}
```

`git diff hir/warnings.tcl` is two hunks: the inserted registry line, and the
section appended after `SAME-FAILURE` (a header comment and four procedures,
about 110 lines). **Framework untouched**: policy modes, `run`/`collect`/`of`,
the record shape, `Sort`, `render`, `Raise`, the stats counter,
`BOTLISH_WARNINGS` and the CLI option are byte-for-byte milestones 1-4.

**Timing and scope.** Discovery happens in `surface::lower::Finish`, after
`hir::buildSyntax`/`hir::check` and strict diagnostics, before any backend,
unchanged. A program with error diagnostics is never warned about
(`pn-compilation-with-errors-has-no-warnings`).

**What supplied the proof, and what was not needed.** Four facts the compiler
already had, per declaration: the resolved proof contract (the block's
`proofs`, `ResolveProofs`), the parameter list (`params`, `flags`), the declared
result (`declaredResult`) and the written name (the declaring binding's
`spelling`/`name`). **Not needed**: provenance (milestone 2's `written`),
annotations beyond the result, value identity (`hir::exact`), exit enumeration
(`Exits`/`Leaves`/`FallThroughs`/`BodyExprs`), reachability (structural or the
completion walk), the resolver's candidate gathering or identity, a call graph,
and any new accessor: the proof contract is a block field, so the brief's
"smallest read-only accessor" contingency was not exercised. No frontend file,
no analysis file and nothing under `native/` changed for the warning.

## No new HIR state, no semantics change

Nothing is recorded on HIR for this warning. Asserted (`pn-no-new-hir-state`):
under `default` the HIR's top-level keys are `off`'s plus `warnings` and
nothing else, every expression node has exactly the fields it has under `off`,
and the expression, binding and scope tables are identical. Beyond that, `dict
remove $hir warnings`, `hir::format`, `hir::lower` and `native::nir`
(specialized and generic) are identical under `off` and `default`
(`pn-hir-identical-across-modes`, `pn-nir-identical-across-modes`), and
`native::report`, NIR and CLIF are identical with and without the side table
and contain no warning text (`pn-machine-readable-outputs-clean`,
`pn-no-warning-text-in-machine-readable-outputs`). The proof contract, the
parameter list, the result type and the name all predate this milestone, so
specialization, inference, proof facts, optimization and the runtime are
untouched.

## Policy, inherited and re-pinned

`default` warns; `off` runs no pass (`hir::warnings::stats` gains no
`PROVES-NAMING` entry, and an execution trace shows 0 calls under `off` and 1
under `default`: `pn-off-runs-no-warning-pass`, `pn-off-runs-no-warning-pass-
via-trace`); `error` raises the sort-first warning across all five codes, as
`{CORE SEMANTIC PROVES-NAMING}` when it is this warning's (`pn-mode-error-only-
this-code` with the exact message, `pn-mode-error-first-in-sort-order` in both
orders, `pn-error-promotion-identity`), before `hir::lower`,
`native::prepareHir`, `native::evalHir` or `core::compiler::evalHir` run
(traces: 0 calls, `pn-error-stops-before-backend`), and `main.tcl -backend
cranelift -warnings error` prints no value (`pn-error-cli-stops-before-
backend`). A program whose proves functions all conform compiles under `error`
(`pn-mode-error-clean-program`). No new CLI surface: `-Wno-proves-naming` is an
unknown option in process and through `main.tcl` (`pn-no-fine-grained-options`,
`pn-cli-no-wno-option`); unknown modes are rejected (`pn-unknown-mode`,
`pn-cli-unknown-mode`); the registry is five static lines and there is no
enable/disable (`pn-no-new-modes-or-options`); `BOTLISH_WARNINGS` is unchanged,
read fresh per compilation, and the explicit option wins (`pn-environment-
default`, `pn-mode-default-is-the-default`); interleaved compilations under
different modes do not interact (`pn-policy-is-per-compilation`); `of` equals
`collect` (`pn-warnings-attached-structurally`).

## Backend independence and clean outputs

The warnings are computed from generic HIR before any backend, so the set is the
same on `interp`, `compile`, `cranelift` and `cranelift-generic`. In process, a
program carrying a predicate and a validator finding runs identically on all
four, with warnings on and off (`pn-backend-independent`, `pn-backend-
independent-off`: `[7, 0, -1, 3]` everywhere, two warnings). Through
`main.tcl`, the warning text is identical on all four backends for a five-code
program (`pn-cli-backend-independent`: 7 lines, one `PROVES-NAMING`) and for
every program of `examples/stdlib` plus the refinement example
`examples/refinement/refined-strings.bot`, all codes and notes included
(`pn-cli-backend-independent-stdlib-and-refinement`; none of them has a
`PROVES-NAMING` finding, see the corpus audit). Warnings go to stderr only
(`pn-cli-stdout-clean`).

**CI's plain corpus steps, reproduced.** The native job's example step
(`main.tcl -backend cranelift` over `examples/stdlib`, `examples/surface/0[1-8]`,
`1[1-3]` and `examples/hir/0[1-3]`) exits 0 with exactly milestones 3 and 4's
314 stderr lines (301 `METHOD-ELIGIBLE`, 8 `FIXED-ARITY-LIST-RETURN`, 2
`SAME-RETURN-VALUE`, 3 notes) and **0 `PROVES-NAMING` lines**; the Tcl jobs'
`main.tcl -backend interp` (its built-in examples) exits 0 with an empty
stderr. The refinement example, which CI does not run through `main.tcl`, was
written before this warning and gains nothing: its 43 stderr lines (the
`METHOD-ELIGIBLE` and `SAME-RETURN-VALUE` findings of `lib/web.bot` and of the
example) contain no `PROVES-NAMING` line, because both of its proves functions
(`web::emailish?`, `web::uri_query_value?`) already follow the convention. Zero
is the honest count, as milestone 4's was. @@CI-MERGED@@

## Kickoff: ownership and the item-2 inventory

**Ownership.** As in milestone 4, the parallel-agent arrangement had ended, so
this milestone owned and made the minimal adaptations itself.

**Baseline at kickoff (before the pass)**, at `e6a871f`, `interp`: the four
warning test files, `tests/flags.test` and the refinement milestone's test files
(`tests/refinement-values.test`, `tests/emailish-predicate.test`) -- 737 tests,
737 passed (`warnings` 81, `method-eligible` 145, `fixed-arity-list-return`
149, `same-failure` 99, `flags` 155, `refinement-values` 88,
`emailish-predicate` 20). The four audit fuzzers' 60-seed smoke runs:
`same-return-value` 42/18 with/without warnings, 0 failures, 0 extra groups;
`method-eligible` 43/17, 0 failures, 280/280 round trips;
`fixed-arity-list-return` 42/18, 0 failures, 42/42 conversions;
`same-failure` 36/24, 0 failures, 70 groups. The refinement milestone added a
fuzzer, `audit/refinement-values/tools/fuzz.tcl` (no suite smoke test): seed 1,
60 programs, 42 accepted, 18 rejected, 0 failures. (The compile-backend pass of
the same baseline run overlapped the pass's insertion and is not counted as a
baseline.)

**With the pass, before adaptation** (`interp`): exactly 4 failures, all
expected.

| file | test | why it fails | adaptation |
|---|---|---|---|
| `tests/warnings.test` | `warn-off-runs-no-warning-pass` | the stats pin enumerates the codes; a fifth exists | `PROVES-NAMING 1` / `2` added to the expected stats |
| `tests/method-eligible.test` | `me-off-runs-no-warning-pass` | the same stats pin | the fifth code added |
| `tests/fixed-arity-list-return.test` | `fa-no-new-modes-or-options` | the registry pin lists the codes | the fifth code added |
| `tests/same-failure.test` | `sf-no-new-modes-or-options` | the registry pin lists the codes | the fifth code added |

No pin was weakened: each still enumerates every code, now five. No
complete-set assertion broke, so no code filter was added anywhere.

**The refinement milestone's own tests and example, inventoried explicitly.**
They pass unchanged, but that alone proves nothing: every compile in
`tests/refinement-values.test` and `tests/emailish-predicate.test` passes
`-warnings off` (or runs under the harness's `off` default). So a scratch copy
of the tree was made with those 34 compile sites switched to `-warnings default
-warning-channel stderr` and both files run under `BOTLISH_WARNINGS=default`:
88/88 and 20/20 passed, with **0 `PROVES-NAMING` lines** (and 423 lines of the
other codes, from `lib/web.bot` and the programs). The census of their proves
functions: `refinement-values.test` declares `big?`, `bump?`, `calls_unknown?`,
`emailish?`, `encoded?`, `even?`, `fake?` (4), `mail?` (3), `other_mail?`,
`positive?`, `pure?`, `query?`, `reads?`, `via_helper?`, `writes?` -- all
conforming -- and `p` 13 times, every one in a program the compiler rejects
(the `PROOF-CLAUSE` and `REFINEMENT-MINT-AUTHORITY` tests), which is never
warned; `emailish-predicate.test` declares `emailish?`; the refinement fuzzer's
predicates are `p1?`, `q1?`, `p2?`, `p3?`, `n1?`; `examples/refinement/
refined-strings.bot` and `bench/refined-checks.bot` use `web::emailish?` and
`web::uri_query_value?`. So no refinement test, example or fuzzer needed an
adaptation, and no test's function names were changed.

**Verify-and-expect-unaffected, confirmed**: the four warning fuzzers' 60-seed
smoke runs give the identical summary lines with the pass (their generators
predate `proves` and emit none), the refinement fuzzer's 60-program run is
identical, and `tests/flags.test` passes 155/155.

**After adaptation**: the 7 files, 737/737 on `interp`; every file on all four
backends in "Full regression".

**The validator feature's own tests** (`tests/refinement-validators.test`, 48
tests, merged with it) name every validator by the convention and every
predicate with `?`, as its brief required, and compile cleanly under
`-warnings error` (its author's check); it needed no adaptation either.

## Tests

`tests/proves-naming.test`, **84 tests**, every compile passing its policy
explicitly (84/84 on `interp`, `compile`, `cranelift-generic` and `cranelift`;
see "Full regression"):

* **Predicates**: the motivating example rendered exactly; conforming silent;
  violating warns; the `?` boundary (present, absent, `x?y` and `x??` are
  syntax errors); the result is the declared bool (constant, always-failing and
  computed bodies); no declared bool is a `PROOF-CLAUSE` error and never
  warned; a fallible predicate by its name.
* **Validators**: `validate_f` and the bare `validate` silent; `check_email`,
  `validator_x`, `Validate_x`, `validateX` warn; `validate_` silent (the sharp
  edge); `VALIDATE_x`, `x_validate_y`, `x_validate`, `validates`, `valid` warn
  (literal, case-sensitive); fallible and infallible validators by name.
* **Scope guard** (item 4, each bullet): no proves with a bool result (the
  load-bearing pin), `?` without proves, out-of-shape proves functions (two and
  three parameters, either result, either proven parameter), no reverse rules,
  zero parameters unrepresentable, other results silent (HIR text).
* **Shape**: 0/1/2 parameters, flags (predicate and validator) and context
  parameters do not count, the two result kinds and templates.
* **Cross-shape**: `validate_emailish` returning bool warns as a predicate;
  `weird?` returning unit warns as a validator; the bare `validate` as a
  predicate warns; two parameters silent.
* **Written name**: hygiene `#N` renames (violating reported as written,
  conforming silent), the root-shadow rename of `list`, a module's functions
  under their member names and in the module file, shadowing around the
  declaration, HIR text without spellings.
* **Declarations**: nested functions and closures, an uncalled declaration, a
  declaration in a dead branch, no completion walk (trace).
* **Structure**: record shape, data fields, primary is the declaration, no
  notes, `kind`, the two templates, no suggested name, no rendered source, one
  diagnostic per function, source order and determinism, instances never
  walked.
* **Policy matrix**: five-code interleaving (both orders, determinism),
  independence from the other codes, default/off/error, the clean program
  under error, default-is-default, `BOTLISH_WARNINGS`, unknown mode, no
  `-Wno-proves-naming`, the static five-line registry, promoted identity, stats
  and trace off-pins, error diagnostics never warned, per-compilation
  interleaving, `of` equals `collect`, `error` before all four lowering entry
  points.
* **No semantics change**: HIR/format/lower, no new HIR state, NIR
  (specialized and generic), report/NIR/CLIF with and without the side table,
  no warning text in machine-readable output.
* **Backends and CLI**: four backends in process (on and off); CLI modes,
  `-Wno-proves-naming`, unknown mode, stdout/stderr separation, `-backend
  cranelift -warnings error` prints no value, identical text on all four
  backends (a five-code program, `examples/stdlib` and the refinement example).
* **The rename law at unit level**: `?`-suffixed method sugar parses and runs
  (`s.emailish?()`); renaming a predicate and a validator and their call sites
  silences both, keeps the value, and leaves the NIR identical except for the
  two functions' labels (`pn-rename-is-semantics-preserving`).
* **Fuzz smoke**: 60 seeds.

## Fuzzing and the rename law

`audit/proves-naming/tools/fuzz.tcl SEEDS FIRST`
(`audit/proves-naming/fuzz-result.txt`; `-show SEED` prints one generated
program, its module, its prediction and its renames). Each seed generates two
to seven functions from construction-known pieces, each with a unique stem (its
index is part of it) and a name drawn from a pool that conforms or violates by
construction:

* **predicates** (`v: str`, `-> bool`, `proves`; a quarter with flags, a fifth
  fallible): conforming `STEM?`; violating `STEM`, `is_STEM`, `validate_STEM`
  and the bare `validate`;
* **validators** (`v: str`, `-> unit`, `proves`; 70% fallible with one guarded
  fail, the rest infallible): conforming `validate_STEM`, the bare `validate`
  and the bare `validate_` (the sharp edge); violating `check_STEM`, `STEM`,
  `STEM?`, `Validate_STEM`, `VALIDATE_STEM`, `validateSTEM`, `validator_STEM`;
* **non-proves twins** of both shapes, named from either pool (always silent:
  the scope guard);
* **wrong-shape proves functions**: two or three ordinary parameters, bool or
  unit, either pool (always silent);
* **placements**: top level; nested in a wrapper (sometimes a closure over the
  wrapper's parameter; the wrapper is polymorphic in a second parameter and
  called with three argument types, so the nested function sits in three
  semantic instances' snapshots); in a module `pnm` (proving the module's own
  refinement, called qualified); and the hygiene case -- nested after an
  earlier reference to a top-level non-proves function of the same name, so
  hygiene renames the nested binding `NAME#N`;
* every call is written so that no other code can fire (one-argument calls,
  functional or method syntax, a flag where there is one; method syntax for
  the wrong-shape functions; one fail per validator, one exit per predicate),
  and each function's driver uses the proof (a predicate's true edge, a
  validator's normal completion), so a broken rename would not type-check;
* about a third of the programs are quiet by construction (every in-shape
  proves function conforming); `validate` and `validate_` are used at most once
  per program, module included (a method call `s.validate()` with both
  `validate` and `pnm::validate` visible is ambiguous -- a resolution error the
  first run hit), so names are collision-free by construction. `x?y` does not
  lex and is not generated.

The oracle is the construction: a proves function of one ordinary parameter
whose name was drawn from the violating pool is predicted as {FILE LINE COL
NAME KIND}. Modes:

* `default`: the `PROVES-NAMING` warnings are exactly the prediction (file,
  anchor, written name, kind); a missed or mislocated one fails, an extra one
  is printed as `EXTRA` and counted (pinned 0), a function reported twice
  fails, and any other code fails;
* `off`: compiles silently, no pass ran (stats counter and an execution trace
  on the pass), and the HIR equals default's without the side table;
* `error`: rejected with `{CORE SEMANTIC PROVES-NAMING}` iff a warning is
  predicted, compiled otherwise.

**The rename law.** For every program with a predicted warning, every predicted
function and all its call sites are renamed mechanically -- predicate `f` ->
`f?`, validator `f` -> `validate_f` (the canonical mechanical rewrite; the bare
`validate` would conform too) -- by re-rendering the generated template with the
new names (call sites are placeholders bound to the function, so the hygiene
case renames the nested function and leaves the same-named outer one alone).
The renamed program must

1. compile with no diagnostic and no warning of any code;
2. have the **identical native IR**, specialized and generic, **up to the
   renamed functions' labels**; and
3. evaluate to the identical value on the reference interpreter.

**A finding about the brief's strong form**: names *do* appear in NIR. NIR
labels each function with its spelling (`func 3 "emailish"`, a module function
`"pnm::check"`; hygiene's `#N` never, `spelling` being preferred), so a renamed
program's NIR cannot be byte-identical. The law is therefore stated exactly:
with every `func N "LABEL"` blanked the two texts are identical, every label
that differs is a predicted rename (old label to exactly the new label), and a
predicted rename whose label appears in neither text is a function that was
**inlined away** -- an infallible validator's body is `unit`, a tiny leaf
(TINY-LEAF-DEFAULT-ON.md) -- which the first validator run exposed (five seeds
failed the first formulation, which demanded a label change for every rename;
all were inlined validators). Nothing else may differ: no instruction, no
register, no call target, no ExprId.

**`?`-suffixed method sugar parses** (`s.emailish?()`, `s.mail1?(:strict)`): no
language finding there; the fuzzer renames method-syntax call sites too.

**2000 seeds (one run, at `64d1eb5`): 1203 programs with warnings, 797
without; 0 failures, 0 extra warnings; 2831 predicted warnings, all matched;
the rename law held for all 2831 renamed functions in the 1203 programs (0 law
failures): of the 5662 label checks (specialized and generic NIR), 4880
relabeled exactly and 782 were inlined validators absent from both texts.** The
generated corpus: 3018 proves predicates (1590 conforming, 1428 violating) and
3034 proves validators (1631 conforming, 1403 violating), 1466 non-proves
twins, 1481 wrong-shape proves functions; 2028 nested functions, 1438 closures,
1002 hygiene-renamed declarations, 605 module functions; 797 only-silent
programs (40%: the third that is quiet by construction plus programs that
happen to draw no violating in-shape function). The suite runs 60
(`pn-fuzz-smoke`). Before validators existed, a predicate-only version of the
generator passed 500 seeds the same way (444 of 444 renames); its discriminating
power is what the mutation step below measures.

## Mutation testing

`audit/proves-naming/tools/mutate.tcl ?SEEDS? ?PATTERN?`
(`audit/proves-naming/mutation-result.txt`), milestone-3/4 style: each mutant is
a small, local break of the pass (or its registry line), applied to a scratch
copy of the tree; the fuzzer runs first (40 seeds), and
`tests/proves-naming.test` runs for any mutant the fuzzer does not kill.

| mutant | required | killed by |
|---|---|---|
| scope guard dropped (`scope-guard-dropped`: every declared function looked at, proves or not) -- **the critical mutant** | yes | fuzz: 24 extra warnings, 19 failures (the non-proves twins with violating names) |
| parameter count ignored (`parameter-count-ignored`) | yes | fuzz: 14 extras, 11 failures (the wrong-shape proves functions) |
| result type ignored (`result-type-ignored`: any result other than unit is a predicate; "str-returning warned") | yes | unit tests: `pn-scope-other-results-silent-in-hir-text` |
| predicate rule applied to unit-returners (`predicate-rule-on-unit`) | yes | fuzz: 65 extras, 33 failures |
| validator rule applied to bool-returners (`validator-rule-on-bool`) | yes | fuzz: 44 extras, 31 failures |
| bare `validate` rejected (`bare-validate-rejected`) | yes | fuzz: 10 extras, 10 failures |
| the `validate_` prefix match broken, case-insensitive (`prefix-case-insensitive`) | yes | fuzz: 7 failures (`Validate_STEM`, `VALIDATE_STEM` missed) |
| the `validate_` prefix match broken, matched anywhere (`prefix-anywhere`) | yes | unit tests: `pn-validator-prefix-is-literal-and-case-sensitive` |
| the `?` check inverted (`question-check-inverted`) | yes | fuzz: 31 extras, 31 failures |
| written name replaced by hygiene's spelling (`hygiene-spelling-checked`: the binding's `name`) | yes | fuzz: 26 extras, 19 failures (`NAME#N`, `pnm::NAME`) |
| instances visited (`instances-visited`: each warning once more per semantic instance whose snapshot covers the function) | yes | fuzz: 17 failures (warnings reported more than once) |
| registry line removed (`registry-line-removed`) | yes | fuzz: 21 failures (every prediction missed; the smoke pin fails the same way) |
| prefix without the underscore (`prefix-without-underscore`: `validateX` conforms) | extra | fuzz: 3 failures |
| empty suffix rejected (`empty-suffix-rejected`: a nonempty-suffix constraint invented) | extra | fuzz: 8 extras, 8 failures |
| flags counted as parameters (`flags-counted`) | extra | fuzz: 8 failures |
| a reachability notion added (`reachability-added`: unreachable declarations skipped) | extra | unit tests: `pn-no-reachability-notion` |
| the qualified module spelling checked (`qualified-name-checked`: `MemberName` dropped) | extra | fuzz: 5 extras, 5 failures |

**17 of 17 mutants killed: the 12 required, 14 of all 17 by the fuzzer and 3 by
the unit tests.** Under most fuzz-killed mutants the rename law fails too (the
renamed program carries a warning the mutant invents). The three the fuzzer
cannot see are cases it deliberately or necessarily does not generate:

* `result-type-ignored`: a proves function whose result is neither `bool` nor
  `unit` cannot be written (`PROOF-CLAUSE`), so only hand-edited HIR text has
  one; the unit test edits HIR text.
* `prefix-anywhere`: the fuzzer's violating validator names never contain
  `validate_` other than as a prefix; the unit test's `x_validate_y` does.
* `reachability-added`: the fuzzer places no declaration in a dead branch; the
  unit test does.

**`instances-visited` needed design.** Milestone 4's form of this mutant
(repeat each warning per entry of the function's own `semantic byBlock`) is
**equivalent by construction** here, and that is a finding: an in-shape proves
function has exactly one ordinary parameter, declared of the refinement's
carrier, so it is never polymorphic and has no semantic instances of its own
(`pn-instances-never-walked` pins `byBlock` absent). Instances do reach it when
it is nested in a polymorphic function: each instance's snapshot covers the
nested function. So the mutant walks those snapshots, the unit test pins a
nested proves function in three instances' snapshots, and the fuzzer's wrapper
functions are polymorphic in a second parameter, called with three argument
types; the fuzzer then kills it.

The first mutation run surfaced two tool bugs, both fixed before the run
recorded here: mutation texts that open a brace they do not close must be
double-quoted in Tcl (the tool aborted), and the milestone-4 form of
`instances-visited` above.

## Corpus findings and census

`audit/proves-naming/tools/corpus.tcl`, output
`audit/proves-naming/corpus-audit.txt`, at the **pinned commit recorded in the
audit's header** (this milestone's tip; its corpus paths -- `examples`,
`bench`, `lib` -- are byte-identical to the kickoff base `e6a871f`, whose audit
gave the same output: neither this milestone nor the merged validator feature
edits the corpus). It compiles `examples/stdlib` (9), `examples/surface` (14),
`examples/refinement` (1, new since milestone 4), `bench/*.bot` (8) and
`lib/*.bot` (8) with warnings on. 36 of 40 compile standalone: the two
deliberate rejections (`09`, `10`), and `lib/list.bot` and
`lib/mutable_array.bot` (which use their own namespace without importing it,
as milestones 2-4 recorded).

**0 findings.** The expectation held: the refinement milestone rewrote
`lib/web.bot` and added `examples/refinement/` before this warning existed, and
its names already conform.

**Census of proves-fitted functions** (every function declaration whose block
carries a resolved proof contract, module functions once each; read from the
HIR and the declaration's own source line, independently of the pass, and
checked against the pass's findings -- "census and findings agree: yes"):

| where | name | ordinary parameters | result | shape | name |
|---|---|---|---|---|---|
| `lib/web.bot:107:1` | `emailish?` | 1 | `bool` | predicate | conforms |
| `lib/web.bot:230:1` | `uri_query_value?` | 1 | `bool` | predicate | conforms |

**2 proves-fitted functions, both conforming predicates; no validator, no
out-of-shape proves function.** (The corpus has no validator because the
validator feature is new and, by its brief, did not touch the corpus; the
corpus refactor is a later milestone.) So the hand-classification categories
-- rename candidate, bare-`validate` case, collision with an existing
conventional name -- are all **0**, and **false positives are 0**.

**The rename check, per finding**, has nothing to run on. Its machinery (a
curated rename applied with whole-word matching to a scratch copy of `lib/`, a
probe program compiled against both copies that must compile, lose the finding
and keep its value) was exercised once by hand on a scratch copy of the tree in
which `web::emailish?` was renamed `is_emailish` (with a temporary table entry):
the audit reported that one finding, classified, the census agreed, and the
rename back to `emailish?` held ("compiles, finding gone, same value `[true,
false]`"). That run found and fixed a bug in the tool's whole-word pattern
(it used a lookahead where a lookbehind was meant, and renamed nothing).

## Full regression

@@REGRESSION@@

## Known limitations

* **Multi-parameter proof-producing functions have no convention**, so they are
  never reported (item 4). The refinement feature allows them (a proof clause
  may name any one ordinary parameter), and the corpus has none.
* **The name rule is lexical.** `validate_` with an empty suffix conforms (the
  literal rule, pinned as a sharp edge); `validateX` does not. A name the
  author considers a validator name in another casing (`Validate_x`) is
  reported.
* **NIR is not name-free.** A rename changes the renamed function's NIR label
  (and so native symbol and debug names); the rename law states identity up
  to exactly those labels.
* **HIR text keeps no `spelling`.** A hygiene-renamed name read back from text
  is recovered by dropping its `#N` suffix, which is exact because source can
  never spell `#`.
* Only the first warning is raised under `error`, as in milestones 1-4.

## Future warning candidates

`PROVES-NAMING` moves from proposal to implemented. Still future, only for
warnings that state a provable fact in this framework (milestone 4's list,
unchanged):

* a condition that repeats an already established proof;
* manual iteration whose cardinality duplicates another domain (lockstep
  candidates);
* milestone 3's possible extension of `FIXED-ARITY-LIST-RETURN` to helper
  chains, only if a corpus audit shows helper chains matter.

**Recorded as evidence-gated: multi-parameter predicates.** A naming
convention for proof-producing functions of two or more ordinary parameters
(and so an extension of this warning to them) is recorded only for the day the
corpus shows such functions; today it has none (see the census). Nothing else
is new.

Not planned: per-warning flags, `-Wall`/`-Wextra` or levels, call-site
suppression, pragmas or lint-ignore comments, any author opt-out, a printed
suggested name or any fixit, automatic renaming, checks on functions without
`proves`, reverse rules (`?` implies bool, `validate_` implies unit), and any
new CLI option or `BOTLISH_WARNINGS` value.

## Deviations from the brief

* **The validator shape did not exist in the language** (see "Outcome"). It was
  reported at kickoff; at the user's direction it was implemented separately,
  in full, by another agent, and merged before this milestone's validator
  tests, fuzzing and mutants ran. This milestone's own diff contains no
  language change.
* **The result type is spelled `bool`, not `Bool`.** The brief's example message
  wrote `returns Bool` and also asked for the type "spelled as the repo spells
  it"; the repository spells it `bool` (the annotation `-> bool`,
  `hir::types::show`, every type diagnostic), so the message says `bool` and
  `unit`.
* **The validator tail states the rule**: `validator names are \`validate\` or
  begin with \`validate_\``, not the brief's `validator names begin with
  \`validate\``, which is literally true of `validateX`, `validator_x` and
  `validates` -- names the rule reports -- and would contradict its own
  finding. Neither template prints the name to use.
* **The NIR half of the rename law is identity up to function labels**, not
  byte identity (names appear in NIR; see "Fuzzing and the rename law"), and a
  renamed function inlined away appears in neither text.
* **A name with `?` only in the middle cannot be written** (the lexer rejects
  it); the boundary pinned is that `x?y` and `x??` are syntax errors.
* **Zero-parameter proves functions and non-bool/non-unit results are
  unrepresentable in source** (`PROOF-CLAUSE`); the zero case is pinned as a
  rejection and the other-results case on hand-edited HIR text.
* **The corpus has no finding**, so the per-finding rename check has nothing to
  run on; the tool's curated-rename machinery is in place and reports "no
  finding to rename" (see "Corpus findings and census").
* **Branch.** `AGENTS.md` says to push finished work to `main`. This session was
  assigned a development branch and told not to push elsewhere without
  permission, so the work is pushed to that branch.

## Required questions

**Warning framework**

1. *Enabled by default?* Yes.
2. *All warnings disableable globally?* Yes: `-warnings off`.
3. *All warnings promotable globally?* Yes: `-warnings error`.
4. *Per-warning `-Wfoo`?* No (`-Wno-proves-naming` is an unknown option, in
   process and through `main.tcl`).
5. *Warning groups?* No.
6. *Codes stable?* Yes: `PROVES-NAMING`.
7. *Policy per compilation?* Yes (interleaved compilations pinned).
8. *Does `off` skip the pass?* Yes: no stats entry; a trace shows 0 calls under
   `off` and 1 under `default`.
9. *Does `error` preserve the code?* Yes: `{CORE SEMANTIC PROVES-NAMING}`.
10. *Backend-independent?* Yes: all four backends, in process and through the
    CLI (identical warning text).

**`PROVES-NAMING`**

11. *Meaning?* A proves-fitted function of the feature's defined shape (one
    ordinary parameter, `bool` or `unit` result) whose written name does not
    follow the shape's convention.
12. *Applies without `proves`?* Never (`pn-scope-no-proves-bool-never-warned`,
    `pn-scope-question-without-proves-never-warned`; the `scope-guard-dropped`
    mutant is killed).
13. *Applies to multi-parameter or non-bool/non-unit proves functions?* No.
14. *Reverse rules?* None (`pn-scope-no-reverse-rules`).
15. *Bare `validate` conforming?* Yes. `validate_` (empty suffix)? Conforming,
    by the literal rule (the pinned sharp edge).
16. *Case-sensitive prefix?* Yes (`Validate_x`, `VALIDATE_x` are reported).
17. *Message prints the suggested name?* No.
18. *Fallible proves functions?* An `errors` clause neither qualifies nor
    disqualifies: fallible predicates and validators are judged by shape and
    name alone.
19. *Which name is checked?* The written declaration name: hygiene's recorded
    spelling of a `#N`-renamed binding, a module function's member name.
20. *Prescribes or renames?* No.
21. *Is this a general naming linter?* No: the scope guard (item 4) is the
    warning's boundary.

**Architecture**

22. *Stage?* `surface::lower::Finish`, unchanged.
23. *Which facts supply the proof?* The resolved proof contract (`proofs`), the
    parameter list (`params` minus `flags`), the declared result the checker
    enforces (`declaredResult`), and the written name (the declaring binding's
    `spelling`/`name`, `MemberName`). Not needed: provenance, other
    annotations, `hir::exact`, exits, reachability, the completion walk, the
    resolver's candidates, a call graph, any new accessor.
24. *New HIR state?* None (`pn-no-new-hir-state`).
25. *Reachability/walks?* None: declarations, not executions
    (`pn-no-completion-walk`, `pn-no-reachability-notion`).
26. *Record shape and secondary?* `{code message primary secondary data}`;
    `secondary` empty; `data` is `function`, `functionName`, `kind`.
27. *Deterministic ordering, five codes?* The inherited `Sort`, pinned in both
    orders.
28. *Instances?* Generic HIR once, never walked (pinned with a function in
    three instances' snapshots; the mutant is killed).
29. *Framework changes beyond the registry line?* None.
30. *Does `error` reject before backend lowering?* Yes (traces on all four
    entry points; a cranelift CLI run prints no value).
31. *Structurally collectable?* Yes: `hir::warnings::of` / `collect`.

**Verification**

32. *Corpus findings and census?* 0 findings. Census: 2 proves-fitted functions in the corpus, `web::emailish?` and `web::uri_query_value?`, both one-parameter `bool` predicates with conforming names; no validator and no out-of-shape proves function.
33. *False positives?* Zero.
34. *Rename law at which levels?* Unit (`pn-rename-is-semantics-preserving`),
    the fuzzer (2000 seeds, required) and per corpus finding (none exist; the
    tool's rename check reports nothing to rename).
35. *Warning-mode tests pass?* @@Q35@@
36. *Fuzzer and mutation results?* Fuzzer: 2000 seeds, 1203 with warnings and 797 without, 2831 predicted warnings: 0 failures, 0 extras; the rename law held for 2831 of 2831 renamed functions (4880 NIR labels renamed exactly, 782 inlined away), 0 law failures. Mutation: 17 of 17 killed (the 12 required among them): 14 by the fuzzer, 3 by the unit tests (`result-type-ignored`, `prefix-anywhere`, `reachability-added`: shapes the fuzzer does not generate).
37. *Backend parity?* Identical sets on all four (in process and CLI).
38. *Full regression?* @@Q38@@
