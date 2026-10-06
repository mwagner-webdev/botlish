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

**TBD-VALIDATORS: the language finding and the validator feature.** At kickoff
the brief's validator shape did not exist in the language ...

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

TBD

## Kickoff: ownership and the item-2 inventory

TBD

## Tests

TBD

## Fuzzing and the rename law

TBD

## Mutation testing

TBD

## Corpus findings and census

TBD

## Full regression

TBD

## Known limitations

TBD

## Future warning candidates

TBD

## Deviations from the brief

TBD

## Required questions

TBD
