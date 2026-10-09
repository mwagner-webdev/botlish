# Compiler warnings: `MANY-BOOLEAN-ARGUMENTS`

## Outcome

Botlish's seventh compiler warning, **`MANY-BOOLEAN-ARGUMENTS`**, is one pass
plus one registry line on the warning framework of milestones 1-6
(`hir/warnings.tcl`; WARNINGS-SAME-RETURN.md, WARNINGS-METHOD-ELIGIBLE.md,
WARNINGS-FIXED-ARITY-LIST-RETURN.md, WARNINGS-SAME-FAILURE.md,
WARNINGS-PROVES-NAMING.md, WARNINGS-ONE-CHAR-STRING-LITERAL.md): a written call
that passes two or more boolean literals to a declared function whose
signature takes a subject and boolean options.

```botlish
fn open_file(path, append: bool, create: bool, sync: bool):
    path

open_file("file.txt", true, false, true)
```
```
f.bot:4:1: warning: the call to `open_file` passes 3 boolean literals; flags name options (MANY-BOOLEAN-ARGUMENTS)
```

(`tests/many-boolean-arguments.test`, `mb-motivating-rendered`. The brief's
`...` body is written `path`; line 3 is blank, so the call is line 4, column
1.)

The warning states the fact and names the form. It prints no flag spelling,
proposes no mapping from literals to flag names, and rewrites nothing. It is
**deliberately not autofixable**: a flag defaults to `false`, so a mis-mapped
rewrite keeps a valid argument count and is silently wrong -- the fuzzer
measured it (every mis-mapped rewrite compiled; see "Fuzzing") -- and which
`true` means which option is intent, not proof.

The three goals:

1. **One pass plus one registry line**, framework untouched: `git diff 23dbfd8
   -- hir/warnings.tcl` is two hunks, the inserted registry line and the
   appended section (a header comment and four procedures, 168 lines in all).
   No frontend, analysis, lowering, runtime or native file changed.
2. **The idiom is declared**: FLAGS.md, "Boolean arguments" (new): options are
   flags; boolean parameters remain right for data bools and computed values; a
   named binding is the alternative where flags do not apply; with the
   non-autofixable rationale, the graduation criteria and the flag-variable
   revisit trigger.
3. **The item-2 inventory was run and its adaptations made here**: the six
   code-enumerating pins, and nothing else -- every complete-set assertion,
   every fuzzer (checked individually, with an instrumented run) and the
   warnings-on sweep came back unaffected (see "Kickoff").

**The headline measurement: zero.** The corpus has no function with a
`bool` parameter at all -- declared, trusted-inferred, or even checked-only
twice -- and no function declaring flags; no native takes a `bool`. So the
warning has no corpus finding and adds no line to CI's stderr. That is the
outcome milestones 4 and 5 also had; here it is structural (see "Corpus
census"), and it is reported as the result, not hidden.

## Calls made where the brief left a choice

* **The yield caveat, resolved.** The checker's own fact for a parameter's
  type is `hir::signatures::entryTypes`: the declared annotation, else the
  TRUSTED inferred contract (INTRINSIC-FUNCTION-CONTRACT-INFERENCE.md: a
  requirement the body cannot be typed without -- forwarding to a declared
  parameter, a declared result -- which every call must prove and the body is
  compiled with). An untyped parameter the body merely tests (`if a:`) has only
  a CHECKED contract: an `if` validates its condition at run time
  (`NOT-BOOLEAN`), the body is never compiled assuming it, and an `any`-typed
  argument still reaches the run-time check. That is a requirement, not a
  proof, so it is not counted. **In practice the warning therefore requires
  annotations**: `fn f(x, a, b): if a and b: ...` is silent, `fn f(x, a, b):
  sink(x, a, b)` with `sink(x, a: bool, b: bool)` warns (trusted), and `fn f(x,
  a: bool, b: bool)` warns. Pinned in `mb-yield-caveat-condition-use-is-not-a-
  proof`, with each parameter's `hir::signatures::of` report. The corpus
  census measures what counting checked contracts would add: nothing (no
  corpus function has two).
* **The method-sugar receiver counts.** Method sugar *is* the call
  `f(receiver, ...)` (FLAGS.md: the receiver is the first ordinary argument;
  METHOD-SUGAR.md), so `true.first(false, 1)` passes two literals, at
  positions 1 and 2 (`mb-method-sugar-receiver-position`, and the
  `receiver-excluded` mutant is killed).
* **A literal at any ordinary position counts**, the subject's included
  (`last(true, true, 1 == 1)` passes 2): the theorem counts literals "at
  ordinary parameter positions", and `true` carries no name wherever it is
  passed (`mb-literal-at-a-subject-position-counts`). The gate is about the
  *signature* (two proven bools and a subject); the threshold is about the
  *call* (two literals).
* **Aliases of a declared function are that declaration.** The resolver's
  candidate identity follows `g = f` (milestone 3's SelfCall uses it; FLAGS.md
  resolves a flag interface the same way), so `g("p", true, false, true)`
  warns and names `open_file` -- the declaration whose signature would change
  (`mb-alias-of-a-declared-function-warns`). A name bound to anything else (a
  branch's value, a call result) is a function value and silent. This reads
  the brief's "an alias of function type" as a binding of a function-typed
  *value*; milestone 2's `NamedCallee`, which never follows an alias, would
  have made alias calls silent too -- see "Deviations".
* **The callee is named by its declaration**: the declaring binding's name
  (hygiene's `spelling` when it renamed it), a module function by its
  qualified name (`opts::open`), a native by its registered name -- the shape
  milestone 2's `NamedCallee` gives.
* **Positions are 1-based** in `data`, as the repository's diagnostics count
  arguments ("argument 1 of native +").
* **A call that cannot match its declaration is silent**: argument count not
  the declaration's (an unflagged function keeps its run-time `ARITY`), so the
  "ordinary positions" are undefined and the call cannot run
  (`mb-arity-mismatch-silent`; the `arity-check-dropped` mutant is killed).

## The theorem

> A call site is reported exactly when it is a **written call** (`function` or
> `method` form) to a **declared callee** whose signature has **at least two
> ordinary parameters the checker proves `bool` and at least one ordinary
> non-`bool` parameter**, and the call passes **two or more written
> `true`/`false` literals** at ordinary parameter positions.

One diagnostic per call site. Everything else is silent. Each clause is pinned
(all in `tests/many-boolean-arguments.test`):

| clause | pinned by |
|---|---|
| a written call: `{form function}` or `{form method}` | `mb-synthesized-calls-silent`, `mb-same-literals-in-a-written-call-fire`, `mb-core-ir-input-silent`, `mb-hir-text-input-silent`, `mb-method-and-functional-spellings-agree` |
| to a declared callee (source, alias, native; never a value) | `mb-function-value-callees-silent`, `mb-alias-of-a-declared-function-warns`, `mb-native-callee-fires`, `mb-nested-and-recursive-callees`, `mb-module-call-located-in-the-module`, `mb-arity-mismatch-silent` |
| >= 2 ordinary parameters proven `bool` | `mb-one-bool-parameter-silent`, `mb-zero-and-one-parameter-callees-silent`, `mb-unprovable-parameter-types-silent`, `mb-yield-caveat-condition-use-is-not-a-proof`, `mb-refined-bool-parameter-is-not-canonical-bool` |
| ... flags never counted (gate and threshold) | `mb-flags-excluded`, `mb-flags-never-make-the-gate`, `mb-flags-never-make-the-threshold`, `mb-desugarings-pass-no-bool-literal` |
| ... context parameters are not parameters; `errors` irrelevant | `mb-context-parameters-not-counted`, `mb-errors-clause-irrelevant` |
| >= 1 ordinary non-`bool` parameter (the subject) | `mb-gate-subject-boundary`, `mb-all-bool-of-any-arity-silent` |
| >= 2 written `true`/`false` literals at ordinary positions | `mb-literal-count-boundary`, `mb-mixed-literal-and-computed`, `mb-false-counts`, `mb-positions`, `mb-method-sugar-receiver-position`, `mb-literal-at-a-subject-position-counts` |
| ... nothing else is evidence | `mb-bindings-silent`, `mb-provably-constant-bindings-silent`, `mb-computed-bools-silent`, `mb-synthesized-bool-refs-enumerated` |
| structurally reachable | `mb-dead-branch-silent`, `mb-after-return-silent`, `mb-contrast-with-one-char-string-literal`, `mb-range-infeasible-branch-warns`, `mb-uncalled-function-warns`, `mb-no-completion-walk` |
| one diagnostic per call site | `mb-per-site`, `mb-instances-never-walked`, `mb-trait-program-warned-as-written` |

The pass is `hir::warnings::ManyBooleanArguments` with the helpers
`BoolLiteralPositions`, `OptionCallee` and `OptionShape`, appended to
`hir/warnings.tcl`.

## The gate: signature shape, flags excluded

**Two or more ordinary `bool` parameters.** The ordinary parameters are the
block's `params` minus its `flags` -- milestone 2's and milestone 5's count,
reused (`OptionCallee`). Context parameters are not in `params` at all (they
are locals bound to the installed context), and an `errors` clause is not
read. **Flags are never counted**: the flag transport (FLAGS.md, "What each
layer holds") makes each declared flag one more trailing `bool` parameter of
the block and appends one `bool` constant per declared flag to every call's
`args` -- `true` for a supplied flag, `false` for an omitted one, *root
references to `true`/`false`, exactly the shape of a written literal*. So the
exclusion is not a formality: without it a flag-only signature `fn g(path,
flags :x, :y)` called `g("p", :x, :y)` has two `bool` parameters, a subject
and two `true` arguments. The pass reads only the first `ordinary` types and
the first `ordinary` arguments. `mb-flags-excluded` pins both the firing
mixed signature and the silent flag-only one (and that the call's `args` hold
5 entries for 3 ordinary arguments); `mb-flags-never-make-the-gate` (one
ordinary bool plus flags) and `mb-flags-never-make-the-threshold` (one
ordinary literal plus supplied flags) pin each half separately. The
**`flags-counted` mutant** -- the ordinary count replaced by the whole
`params` length -- is killed by the fuzzer with 17 failures and 24 extra
warnings, and it also breaks the conversion law for 12 of 13 convert-now
callees: once a callee is converted, its own flag constants make it warn
again. That is precisely "a function that already follows the idiom must not
self-report".

**At least one non-`bool` ordinary parameter: the subject gate.** A function
whose ordinary parameters are all `bool` takes data bools: `xor(a: bool, b:
bool)`, `and3(a, b, c)`, or `elif.test`'s `run(a: bool, b: bool, c: bool)`
called `run(true, true, true)` -- in the only existing test file whose
functions declare two or more `bool` parameters, silent by this gate (see
"Kickoff"). Flags accompany a
subject; there is none. `mb-gate-subject-boundary` pins the boundary in one
program (all-bool silent; one non-bool and two bool fires; two bool and one
non-bool fires) and `mb-all-bool-of-any-arity-silent` two, three and four
bools. **The `xor` class is the gate's named boundary.**

**Parameter types are the checker's own fact.** A parameter counts as `bool`
exactly when its entry type (`hir::signatures::entryTypes`: declared, else
trusted inferred) is the canonical `bool`. Untyped (polymorphic), `any`,
`int`, and checked-only parameters are not provably `bool`: they are not
counted, and they are subjects (`mb-unprovable-parameter-types-silent`; the
yield caveat above). A refinement of `bool` (`refined type On = bool`) is not
the canonical `bool`; a literal cannot be passed to it anyway (membership is a
proof), so it is a subject (`mb-refined-bool-parameter-is-not-canonical-bool`).
Botlish has no union types, so "union-of-non-bool" has no representative. For
a native, the registry's parameter types are its declaration (they are
checked contracts too -- a native's `-param-types` are validated on every
call -- but they are the only signature a native has, and the brief includes
natives by them).

**Declared callees only.** The callee must be a reference whose binding
resolves, through plain aliases, to a non-duplicate `bind` of a block (a
`fn`, a nested function, a module function), or to a root native of fixed
arity. A call through a function value is silent: a parameter (`g(x, true,
false, true)`), a call result (`make()(2, true, false, true)` -- which the
resolver's exact-callable provenance *does* resolve, its `target` names the
block; the pass never reads `target`), a struct field (`s.h(...)`), a binding
of a branch's value (`mb-function-value-callees-silent`). The signature that
would have to change belongs to no declaration the warning can name. The
`function-value-callees-counted` mutant -- which falls back to the call's
`target` -- is killed by the fuzzer's `getK()(...)` sites (an improvement the
mutant forced; see "Mutation testing").

**The gate reads the declaration once per call site and never aggregates.** No
per-callee grouping, no anchoring at the declaration (`mb-per-site`; the
`first-site-per-callee` mutant is killed). The per-callee alternative is the
recorded revisit trigger (FLAGS.md, "Boolean arguments"), not built.

**The `validate_pair` class: the other named boundary.** A callee past the gate
whose callers pass computed or bound bools -- `validate_pair(a, b, strict,
lenient)` called with `config.strict` -- is a function whose bools are values
the caller decides, not options the caller picks. Its computed call sites are
silent (no evidence), and it is not convertible: the fuzzer catalogues it as
*computed-caller*, never a failure. Where the same callee also has a
literal-passing call site, that site warns -- the fact is about the call -- but
the conversion law does not apply to the callee.

## The evidence: written literals only -- anonymity as design

The evidence is an argument that is a **reference to the root `true` or
`false`** at an ordinary position (`BoolLiteralPositions`): `true` and `false`
are keywords, and the frontend lowers each written token to exactly that
(`surface/lower.tcl`, `bool` -> `^true` / `^false`). `false` counts exactly as
`true` does (`mb-false-counts`; the `false-excluded` mutant is killed). The
count in the message is the literal count: 1 is silent, 2 and 3 fire
(`mb-literal-count-boundary`), and `f(true, compute(), false)` fires with
count 2 at positions 2 and 4 (`mb-mixed-literal-and-computed`).

**Named bindings are silent by design, not by conservatism.** The warning's
theory of harm is anonymity: `true` carries no name. `append = true;
open_file("f", append, create, sync)` already says what it means, whatever the
compiler knows about `append`. So no exact value is read, no alias is
followed, no constant is propagated: `mb-provably-constant-bindings-silent`
shows the compiler *does* know the arguments' exact values (`{val {bool
true}}` from `hir::exact::Of`) and the call is still silent. This is milestone
6's literals-only rule at full strength; there it was the conservative choice,
here it is the point. The **`binding-reads-counted` mutant** (an argument
whose exact value is a bool counts) is killed by the fuzzer: 11 failures, 45
extra warnings.

**Computed bools are no evidence and do not count**: `f(1 == 1, 2 == 2)` has
zero literals, `f(true, compute())` one (`mb-computed-bools-silent`, with `not
false`, `true and true`, `false or false` among them); the
`computed-args-counted` mutant is killed.

**Robustness: where root `true`/`false` references come from.** The frontend
builds one in exactly three ways, and `mb-synthesized-bool-refs-enumerated`
(a source audit over `hir/` and `surface/`) pins them, so a fourth fails a
test: the written keyword; `Bool`, only inside the branches of the `!=`,
`not`, `and`, `or` desugarings (an `if` node's value, never an argument); and
the flag transport's appended constants (after the ordinary arguments, never
read). `mb-desugarings-pass-no-bool-literal` builds every option argument of a
written call from those desugarings: the arguments are `if` nodes, and the
call's only root `true` is its supplied flag at position 5. So a root
`true`/`false` reference at an ordinary position of a written call *is* a
written literal; no origin text is sniffed. (A parenthesized `(true)` is the
same node: HIR records no parentheses, and it is the same anonymous token.)

## The provenance requirement and the synthesized calls

A candidate carries `written {form function}` or `{form method}`; every other
form (`list`, `operator`) and a call with no marker is silent; written-ness
is never derived any other way (milestone 2's provenance section).
`mb-synthesized-calls-silent` pins `true != false` (the `==` call of the
desugaring), `[true, false]`, `true == false` and a struct literal of bool
fields (no call at all) silent, and `mb-same-literals-in-a-written-call-fire`
the same literals in a written call warning beside them.

**A finding about the synthesized cases.** The brief expected that without the
marker `true != false` and `[true, false]` would fire. They would not, today:
every synthesized call targets a native that takes no `bool` (`==` takes `any,
any`; `list` is variadic and has no fixed arity), so the gate silences them
as well. The marker requirement is therefore currently *redundant with the
gate for source programs*, and it is still the rule: it is the principled
statement (a call nobody wrote is nobody's call site), it guards any future
synthesized call to a declared function, and **there is an input where it is
the only guard: HIR text**. `hir::format`/`hir::parse` keep the declared
`bool` parameter types (`block s3 (b2 path, b3 append:bool, ...)`) but not the
provenance marker, so a parsed program has calls with literals to a
signature past the gate and no marker. `mb-hir-text-input-silent` pins it (the
source HIR warns, the parsed one never, and its entry types are still `bool
bool bool`), `mb-core-ir-input-silent` pins core IR (no types at all). The
**`synthesized-calls-counted` mutant** (the provenance check dropped) is killed
by the fuzzer through its per-seed HIR-text check (every seed's HIR is read
back from text and must have no warning of this code) -- a check the first
mutation run showed was needed (see "Mutation testing").

## Reachability: milestone 2's rule, contrasted

A structurally unreachable call site is skipped (HIR's `reachable` flag:
statically decided branches, code after a completion): the fact is about a
call the program makes, and a call that cannot execute makes no call. It is
structural only:

* no completion walk: `hir::completions::reachedExprs` is traced at 0 calls
  while the pass runs (`mb-no-completion-walk`), so a call under a branch the
  range facts prove infeasible -- structurally reachable, pruned only by the
  completion walk -- **warns** (`mb-range-infeasible-branch-warns`; the
  `reachability-added` mutant, which prunes by the completion walk, is killed
  by the fuzzer's range placements);
* no interprocedural unreachability: a call in a function nobody calls warns,
  and so does one in a function *declared* in a dead branch -- its body is
  structurally reachable relative to its own entry, and milestone 2's
  `METHOD-ELIGIBLE` agrees on the same call (`mb-uncalled-function-warns`).
  The conservative direction, as ever.

**The contrast with milestones 5 and 6, pinned in one program**
(`mb-contrast-with-one-char-string-literal`): in one dead branch,
`"x".open_file(true, false, true)` gives `ONE-CHAR-STRING-LITERAL` for `"x"` (its fact is
about written source: `oc-dead-branch-literal-warns`'s shape) and no
`MANY-BOOLEAN-ARGUMENTS` (its fact is about a call). The
`reachability-removed` mutant is killed by the fuzzer's dead and after-return
placements.

## Message, record, ordering

**Message.** One template (`mb-message-template`):

```
the call to `NAME` passes N boolean literals; flags name options
```

It states the count, names the callee, names the form, and nothing else. The
code is fact-shaped; prescriptive names (`PREFER-FLAGS`, `BOOLEAN-FLAGS`) were
rejected as in every milestone. The repository spells the type `bool` (the
milestone-5 lesson), and the message's prose says "boolean literals". **No flag spelling** appears in any message, data field or rendered
text -- printing `:append` would prescribe the mapping (the milestone-3
field-name lesson at warning level): `mb-no-flag-spelling-anywhere` scans the
message, the data and the rendered line for any `:name` spelling, the
parameter names, `->`, ` use `, `instead`, `prefer`, `did you mean`,
`rename`, `fix`, `should`, `consider`, `replace`, `rewrite`, `suggest`,
`default`, `arity`, `mapping`, `true means`, `false means`. No arity-safety
advice, no "the default is false" lecture: that rationale lives in FLAGS.md.
The `flag-spelling-printed` mutant is killed by seven unit tests.

**Record.** The framework's `{code message primary secondary data}`
(`mb-record-shape`, `mb-record-data-fields`):

* `primary`: the written call's own origin (`mb-primary-is-the-call`): the
  callee name's column for a functional call, the receiver's for a method
  call;
* `secondary`: **empty** -- a single-location fact, as in milestones 2, 5 and
  6; no `note:` lines (`mb-render-has-no-notes`);
* `data`: `call` (the call's ExprId), `callee` (the repository's target
  representation, `{block ExprId}` / `{native NAME}`, equal to the call's own
  `target` for a declared callee), `calleeName`, `literals` (the count) and
  `positions` (the 1-based ordinary positions carrying literals). No rendered
  source text.

**Ordering.** The inherited `Sort`. All seven codes interleave by location in
both orders (`mb-interleaving-seven-codes`, `-other-order`,
`-deterministic`), and a multi-bool call inside a construct that trips other
codes is an independent diagnostic: `["-", "+", open_file(x, true, false,
true)]` returned from a function gives `FIXED-ARITY-LIST-RETURN`, two
`ONE-CHAR-STRING-LITERAL`s, this warning and `METHOD-ELIGIBLE` (the same call,
same location: `MANY-...` sorts before `METHOD-...` by code)
(`mb-independent-of-other-codes`). A module's call is located in the module
file (`mb-module-call-located-in-the-module`).

## Architecture

**One pass, one registry line.**

```tcl
variable passes {
    SAME-RETURN-VALUE hir::warnings::SameReturnValue
    METHOD-ELIGIBLE   hir::warnings::MethodEligible
    FIXED-ARITY-LIST-RETURN hir::warnings::FixedArityListReturn
    SAME-FAILURE      hir::warnings::SameFailure
    PROVES-NAMING     hir::warnings::ProvesNaming
    ONE-CHAR-STRING-LITERAL hir::warnings::OneCharStringLiteral
    MANY-BOOLEAN-ARGUMENTS  hir::warnings::ManyBooleanArguments
}
```

(The existing lines are untouched, so their alignment is milestone 1-6's.)
**Framework untouched**: policy modes, `run`/`collect`/`of`, the record shape,
`Sort`, `render`, `Raise`, the stats counter, `BOTLISH_WARNINGS` and the CLI
option are byte-for-byte milestones 1-6.

**Timing and scope.** `surface::lower::Finish`, unchanged: after
`hir::buildSyntax`/`hir::check` and strict diagnostics, before any backend. A
program with error diagnostics is never warned about
(`mb-compilation-with-errors-has-no-warnings`). A monomorphized trait program
is warned about as written (`traitSource`): a trait-polymorphic function's
call is one warning, though the call exists once per witness after
monomorphization (`mb-trait-program-warned-as-written`). Semantic instances
are never visited (`mb-instances-never-walked`: several instances cover the
call; stripping the `semantic` side table changes nothing; the
`instances-visited` mutant is killed).

**What supplied the proof.** The call's `written` provenance (milestone 2),
its `reachable` flag and `args`, the callee reference resolved through aliases
by `hir::resolve::CandidateIdentity` (milestone 3), the block's `params` and
`flags` (FLAGS.md), `hir::signatures::entryTypes` (the checker's declared and
trusted parameter types), and for a native the registry's `arity` and
`paramTypes`. **Not needed**: exact values (`hir::exact`, deliberately), the
call's resolved `target` (it would admit function values), the completion
walk, the frontend's written spelling beyond the provenance form, origin or
source text, annotations, a call graph, any new helper outside the pass.

## No new HIR state, no semantics change

Nothing is recorded on HIR for this warning (`mb-no-new-hir-state`: under
`default` the top-level keys are `off`'s plus `warnings`, every expression
node has exactly its `off` fields, and the expression, binding and scope
tables are identical; `mb-call-nodes-unchanged`: a warned call node is
identical under both modes and carries only the fields written calls have
had). `dict remove $hir warnings`, `hir::format`, `hir::lower` and
`native::nir` (specialized and generic) are identical under `off` and
`default` (`mb-hir-identical-across-modes`, `mb-nir-identical-across-modes`),
and `native::report`, NIR and CLIF are identical with and without the side
table and contain no warning text (`mb-machine-readable-outputs-clean`,
`mb-no-warning-text-in-machine-readable-outputs`). Every fact the pass reads
predates the milestone; nothing under `native/` changed.

## Policy, inherited and re-pinned

`default` warns; `off` runs no pass (no stats entry; a trace sees 0 calls under
`off` and 1 under `default`: `mb-off-runs-no-warning-pass`, `-via-trace`);
`error` raises the sort-first warning across all seven codes, as `{CORE
SEMANTIC MANY-BOOLEAN-ARGUMENTS}` when it is this warning's
(`mb-mode-error-only-this-code` with the exact message,
`mb-mode-error-first-in-sort-order` in both directions,
`mb-error-promotion-identity`), before `hir::lower`, `native::prepareHir`,
`native::evalHir` or `core::compiler::evalHir` run (0 traced calls,
`mb-error-stops-before-backend`), and `main.tcl -backend cranelift -warnings
error` prints no value (`mb-error-cli-stops-before-backend`). A program whose
options are flags, whose bool arguments are named or computed and whose
data-bool calls pass literals compiles under `error`
(`mb-mode-error-clean-program`). No new CLI surface:
`-Wno-many-boolean-arguments` is an unknown option in process and through
`main.tcl` (`mb-no-fine-grained-options`, `mb-cli-no-wno-option`); unknown
modes are rejected (`mb-unknown-mode`, `mb-cli-unknown-mode`); the registry is
seven static lines and there is no enable/disable (`mb-no-new-modes-or-
options`); `BOTLISH_WARNINGS` is unchanged and read fresh per compilation
(`mb-environment-default`, `mb-mode-default-is-the-default`); interleaved
compilations do not interact (`mb-policy-is-per-compilation`); `of` equals
`collect` (`mb-warnings-attached-structurally`).

## Backend independence and clean outputs

The warnings are computed from generic HIR before any backend, so the set is the
same on `interp`, `compile`, `cranelift` and `cranelift-generic`
(`mb-backend-independent`, `-off`: the same value `[6, 4, 10, -12]` and two
warnings everywhere). Through `main.tcl`, the warning text is identical on all
four backends for a seven-code program (`mb-cli-backend-independent`: 9 lines,
one of them this warning's) and over `examples/stdlib` and the refinement
example (`mb-cli-backend-independent-corpus`). Warnings go to stderr only
(`mb-cli-stdout-clean`).

**CI's plain corpus steps, reproduced, with the count reported honestly.**
The native job's example step (`main.tcl -backend cranelift` over
`examples/stdlib`, `examples/surface/0[1-8]`, `1[1-3]` and
`examples/hir/0[1-3]`, run at `2c1d889` with `BOTLISH_WARNINGS` unset) **exits 0
with 376 stderr lines -- exactly milestone 6's count, 0 of them this
warning's**: 301 `METHOD-ELIGIBLE`, 62 `ONE-CHAR-STRING-LITERAL`, 8
`FIXED-ARITY-LIST-RETURN`, 2 `SAME-RETURN-VALUE` and 3 notes. The Tcl jobs'
`main.tcl -backend interp` and `-backend compile` (their built-in `.ir`
examples) exit 0 with an empty stderr. Zero new lines is the expected and
legitimate outcome (the corpus declares no `bool` parameter; see "Corpus
census"), as milestones 4 and 5 showed for theirs.

## Kickoff: ownership and the item-2 inventory

**Ownership.** As in milestones 4-6, this milestone owned and made the minimal
adaptations itself.

**Baseline at kickoff (before the pass)**, at `23dbfd8` (`main`), on `interp`
and `compile`: the six warning test files, `tests/flags.test`, the refinement
trio, `tests/str-char-at.test` and `tests/value-display.test` -- **976 tests,
976 passed on each** (warnings 81, method-eligible 145, fixed-arity-list-return
149, same-failure 99, proves-naming 84, one-char-string-literal 85, flags 155,
refinement-values 88, refinement-validators 48, emailish-predicate 20,
str-char-at 14, value-display 8). The fuzzers' 60-seed smoke runs:
`same-return-value` 42/18 with/without warnings, 0 failures, 0 extra groups;
`method-eligible` 43/17, 0 failures, 280/280 round trips;
`fixed-arity-list-return` 42/18, 0 failures, 42/42 conversions;
`same-failure` 36/24, 0 failures, 70 groups; `proves-naming` 33/27, 0
failures, 76/76 renames; `one-char-string-literal` 42/18, 0 failures, spelling
law 158/158; the refinement fuzzer (`-seed 1 -count 60`) 38 accepted, 22
rejected, 0 failures.

**With the pass, before adaptation** (`interp`, the same 976 tests): **6
failures, all of them the code-enumerating pins** -- the brief's expected
group, and nothing else:

| file | test | adaptation |
|---|---|---|
| `tests/warnings.test` | `warn-off-runs-no-warning-pass` | `MANY-BOOLEAN-ARGUMENTS 1` / `2` added to the expected stats |
| `tests/method-eligible.test` | `me-off-runs-no-warning-pass` | the seventh code added |
| `tests/fixed-arity-list-return.test` | `fa-no-new-modes-or-options` | the seventh code added to the registry pin |
| `tests/same-failure.test` | `sf-no-new-modes-or-options` | the same |
| `tests/proves-naming.test` | `pn-no-new-modes-or-options` | the same |
| `tests/one-char-string-literal.test` | `oc-no-new-modes-or-options` | the same |

**Complete-set assertions over programs with multi-bool-literal calls: none
broke, and none exist.** The six warning test files' complete-set assertions
all passed with the pass registered; their programs pass no two bool literals
to a signature past the gate. No error-mode acceptance pin changed (milestone
6's precedent was not needed), and no program was edited.

**The fuzzers, checked individually, not assumed.** Each fuzzer ran its 60-seed
smoke with the pass registered *and* instrumented: a wrapper sources the
fuzzer with an execution trace on `hir::warnings::ManyBooleanArguments` that
counts the pass's runs and the warnings it returns.

| fuzzer | pass runs | `MANY-BOOLEAN-ARGUMENTS` warnings | summary line |
|---|---|---|---|
| `same-return-value` (milestone 1) | 181 | 0 | identical to baseline |
| `method-eligible` (2) | 400 | 0 | identical |
| `fixed-arity-list-return` (3) | 162 | 0 | identical |
| `same-failure` (4) | 120 | 0 | identical |
| `proves-naming` (5) | 153 | 0 | identical |
| `one-char-string-literal` (6) | 256 | 0 | identical |
| refinement (`-seed 1 -count 60`) | 0 (compiles with `-warnings off`) | 0 | identical |

The brief's prime suspects are silent for a structural reason: no generator
writes a `: bool` annotation anywhere (a grep over the six fuzzers), and their
callees -- `fa`'s `fn gF(x, a, b)`, `sf`'s `fn gF(x, a, xs)` -- take untyped
parameters, which are not proven `bool`, so no generated callee passes the
gate. No oracle needed teaching and no filter was added.

**The milestone-5/6 sweep, applied here.** The files whose compiles run under
`off` were re-run in a scratch copy with every explicit `-warnings off` switched
to `-warnings default -warning-channel stderr` (28, 9, 6, 4 and 2 sites in the
refinement trio, `str-char-at` and `value-display`; 2 in `tests/helpers.tcl`:
`sourceAgree`, `refinedChecksSourceHir`), under `BOTLISH_WARNINGS=default` (which
switches `tests/flags.test`'s and `tests/elif.test`'s default-mode compiles
on). `tests/elif.test` was added to the sweep because it is the one test file
that declares functions with two or more `bool` parameters (a grep over
`tests/`). Each file ran twice -- with the pass, and in a second scratch copy
with only the registry line removed:

| file | result (with the pass) | `MANY-BOOLEAN-ARGUMENTS` lines | all warning lines, with / without the pass | adaptation |
|---|---|---|---|---|
| `tests/flags.test` | 154/155 | 0 | 130 / 130 | none; `flags-standalone-executable` fails identically without the pass (a `METHOD-ELIGIBLE` line on `main.tcl`'s stderr makes `exec` raise; milestone 6 recorded the same) |
| `tests/refinement-values.test` | 88/88 | 0 | 492 / 492 | none |
| `tests/refinement-validators.test` | 48/48 | 0 | 24 / 24 | none |
| `tests/emailish-predicate.test` | 20/20 | 0 | 1732 / 1732 | none |
| `tests/str-char-at.test` | 14/14 | 0 | 31 / 31 | none |
| `tests/value-display.test` | 8/8 | 0 | 72 / 72 | none |
| `tests/elif.test` | 44/45 | 0 | 341 / 341 | none; `elif-standalone-executable` fails identically without the pass (`METHOD-ELIGIBLE` lines on stderr) |

`tests/elif.test` is worth a sentence: its `run(a: bool, b: bool, c: bool)`
is called `run(true, true, true)`, `run(false, true, true)`, ... -- three bool
literals per call -- and is silent because `run` has no subject: the `xor`
class, in the wild. Its `pick(log, a: bool, b: bool, c: bool)` has a subject
and three bools, and every call passes `a, b, c` (parameters): silent by the
evidence rule. Both boundaries, in an existing test file, untouched.

Outside the warning files, the only test that compiles under an explicit
warnings mode is `flags-warnings-none` (`-warnings error` over flag programs);
it passes. `tests/flags.test` has no multi-bool-literal call to a gated
signature; its 37 `true, false`-shaped lines are expected-result values
(`{[7, true, false, false]}`) of calls that pass flags.

**After adaptation**: the 12 item-2 files, 976/976 on `interp` and on
`compile`; on all four backends in "Full regression".

## Tests

`tests/many-boolean-arguments.test`, **90 tests**, every compile passing its
policy explicitly (90/90 on `interp`, `compile`, `cranelift-generic` and
`cranelift`):

* **Theorem**: the motivating call rendered exactly; the 1/2/3 literal
  boundary in one program; mixed literal/computed (count 2 at positions 2 and
  4); `false` counting; two identical calls, two warnings; positions first,
  middle and last; the method-sugar receiver at position 1; a literal at the
  subject position; the functional and method spellings giving the same data.
* **Gate**: the subject boundary in one program; all-bool callees of two to
  four parameters; flags excluded (mixed signature fires on its ordinary
  literals only; flag-only silent; flags never complete the gate nor the
  threshold); one bool parameter; zero and one parameter; untyped, `any`,
  `int` parameters; the yield caveat (checked vs trusted, with
  `hir::signatures::of`); a refinement of bool; a native callee by registry
  types (a probe registration, milestone-2 style) and the census pin that no
  registered native takes a bool; function values (parameter, call result,
  field, branch value) silent; aliases warn naming the declaration; arity
  mismatch silent; context parameters; an `errors` clause; nested and
  recursive callees.
* **Evidence**: bindings silent, including provably constant ones (the
  anti-heroic-proving pin, with the exact values shown); computed bools;
  synthesized calls (`true != false`, `[true, false]`, `true == false`, a
  struct of bools) silent beside a written call that fires; the source audit
  of root `true`/`false` construction; every desugaring passing no literal;
  core IR and HIR text input silent.
* **Reachability**: dead branch, code after return; the milestone-6 contrast
  in one program; range-infeasible branch warns; uncalled and dead-declared
  functions warn (with `METHOD-ELIGIBLE` agreeing); no completion walk
  (trace).
* **Structure**: record shape, data fields, primary is the call, no notes,
  the template, no flag spelling or advice anywhere, source order and
  determinism, a module's call in the module file, instances never walked, a
  trait program warned as written.
* **Policy matrix**: seven-code interleaving (both orders, determinism),
  independence from other codes, default/off/error, the policy program carries
  only this code, error only this code, sort-first across seven codes, the
  clean program, default-is-default, `BOTLISH_WARNINGS`, unknown mode, no
  `-Wno-many-boolean-arguments`, the seven-line registry, promoted identity,
  stats and trace off-pins, error diagnostics never warned, per-compilation
  interleaving, `of` equals `collect`, `error` before all four entry points.
* **No semantics change**: HIR/format/lower, no new HIR state, call nodes
  unchanged, NIR (specialized and generic), report/NIR/CLIF with and without
  the side table, no warning text in machine-readable output.
* **Backends and CLI**: four backends in process (on and off); CLI modes,
  `-Wno-many-boolean-arguments`, unknown mode, stdout/stderr separation,
  `-backend cranelift -warnings error` prints no value, identical text on all
  four backends (a seven-code program, and the stdlib corpus with the
  refinement example).
* **Fuzz smoke**: 60 seeds, with the conversion law.

## Fuzzing and the conversion law

`audit/many-boolean-arguments/tools/fuzz.tcl SEEDS FIRST`
(`audit/many-boolean-arguments/fuzz-result.txt`; `-show SEED` prints a program,
its predictions and each callee's class). Each seed builds a program **model**
-- callees and call sites known by construction -- and renders it to source;
the conversion law renders the same model again with one callee converted.

* **Callees** `oK` have 0-3 parameters of a proven-`bool` kind -- declared
  `: bool`, or *inferred*: untyped and forwarded to `weight`'s declared `bool`
  parameter, the checker's trusted contract -- 0-2 of an unprovable kind --
  *unproven* (untyped, only tested: `p.pick(W)`, whose parameter is a checked
  condition) or `: any` -- and 0-2 subjects (`: int`, or untyped and used in
  arithmetic), in random order; 0-2 flags; and, in 30% of the programs, a
  context parameter of a context struct `C` on some callees (never counted).
  The body sums one weighted term per parameter and flag (distinct powers of
  two), so every argument's value shows in the result. Some callees have no
  call site (the *no-sites* class). In 40% of the programs three **probe
  natives** are registered (milestone 2's style): `str::fz_opts` (`int, bool,
  bool`: past the gate), `str::fz_xor` (`bool, bool`) and `str::fz_one`
  (`int, bool`).
* **Call sites** pass an `Int` at each subject and, at every other position, a
  written literal, a computed bool (`N == N` / `N == M`, `N` unique per site)
  or a named binding (`yes`/`no`), per the site's mode (all literals, all
  computed, all bindings, mixed; 40% of the callees have only literal callers,
  the convert-now candidates). They are spelled functionally, with method
  sugar (never a computed receiver) or through an alias (`aK = oK`); they
  supply a random subset of the callee's flags; and they sit at the top
  level, in a nested function, in a closure, in a statically dead branch,
  after a `return`, under a range-infeasible branch, or in a function nobody
  calls. Unflagged callees are sometimes also passed to a parameter `g` and
  called through it, and returned by `getK()` and called on the result
  (`getK()(...)`, which the resolver's exact-callable provenance resolves to
  the callee: the pass must still be silent). `[true, false]` and `true !=
  false` appear in half of the results. About a third of the programs are
  quiet (at most one literal per gated call).
* Names and values are collision-free by construction; no String literal, one
  exit per function, no list result, no `fail`, no `proves`: the only other
  code that can fire is `METHOD-ELIGIBLE`.

**The oracle** is the model: a site warns iff it is a written call to a
declared callee (source, alias or native; never a value) past the gate (two
parameters of a proven-`bool` kind and one of any other), passes two or more
literals, and is in a reachable placement (everything but dead and
after-return); the anchor is the call's start and the count the literal count.
It also predicts **`METHOD-ELIGIBLE` exactly** (a reachable functional,
non-alias call to a declared callee of two or more ordinary parameters whose
first argument is not an operator expression), so nothing is filtered. Modes:

* **default** -- this warning's set is exactly the prediction, counts
  included (missed or mislocated fails; unpredicted is EXTRA, counted, pinned
  0; a site twice fails); `METHOD-ELIGIBLE`'s set is exactly its prediction;
  any third code fails;
* **off** -- compiles silently, no pass ran (stats counter and an execution
  trace on the pass), HIR identical to default's without its side table;
* **error** -- rejected iff any warning is predicted, with the code of the
  **sort-first predicted warning across both codes** (location, then code:
  at one call `MANY-...` precedes `METHOD-...`), milestone 3's generalization;
* **HIR text** -- every seed's HIR, read back from `hir::format` text (which
  keeps the declared `bool` types and loses the provenance marker), has no
  warning of this code: the input where provenance is the only guard.

**The conversion law, conditional (the milestone-3 shape).** A source callee
past the gate is **convert-now** when it has at least one call site, every
call site -- in every placement, aliases included -- passes a literal at every
proven-`bool` position, and it is never used as a value. For each, the model
is rendered with that callee converted: its proven-`bool` parameters become
flags named like the parameters (`flags :b1, :b2`, ahead of its own flags; the
context section stays last), each call's `true` at parameter `P` becomes `:P`,
each `false` is dropped, and a method call whose receiver was converted is
spelled functionally. The rewritten program must compile, have **no warning
of this code for that callee and exactly the original's for every other
callee**, and **evaluate to the identical value** on the reference
interpreter. A callee with a computed or bound bool at a proven-`bool`
position (*computed-caller*: the `validate_pair` class), one used as a value
(*function-value*), a native, one below the gate, and one with no site are
catalogued, never a failure. The law tests a mapping -- the parameter names
-- on programs where every call passes literals; it prescribes none.

**The mis-mapping catalog** (the non-autofixable rationale, measured): every
convert-now callee with two or more converted parameters is also rewritten
with its first two flags **swapped at every call**. The mis-mapped program must
still compile -- there is no arity check to catch it -- and whether its value
changed is recorded.

**2000 seeds** (at `1c59bf2`, three concurrent runs of consecutive seeds:
1-667, 668-1334, 1335-2000): **1030 programs with warnings, 970 without; 0
failures, 0 extra warnings; the conversion law held for 893 of 893
convert-now callees** -- each rewrite compiled, lost every warning of its
callee, kept every other callee's, and evaluated to the identical value. The
HIR-text check read all 2000 programs back (0 unreadable) and found no
warning. The callee catalog:

| class | callees | outcome |
|---|---|---|
| convert-now | 893 | conversion law held for all 893 |
| computed-caller (the `validate_pair` class) | 1671 | catalogued |
| function-value | 443 | catalogued (silent at the value calls; never converted) |
| native (three probes per native program) | 2400 | catalogued |
| below the gate (`xor`-shaped, one bool, unprovable bools) | 2594 | silent by the gate |
| no call site | 398 | nothing to state |

**The mis-mapping catalog: all 893 mis-mapped rewrites compiled; 374 changed
the program's value and 519 did not** (a swap is invisible wherever every call
passes the two options equally). That is the non-autofixable rationale,
measured: a wrong literal-to-flag mapping is never rejected, and more than half
the time it does not even change this run's value.

The generated corpus: placements top 4870, nested 1569, closure 1557, dead
1633, after-return 1563, range-infeasible 1637, uncalled 1636; spellings
functional 10106, method 3870, alias 489; 660 quiet programs, 599 with a
context struct, 800 with the probe natives. The suite runs 60
(`mb-fuzz-smoke`).

## Mutation testing

`audit/many-boolean-arguments/tools/mutate.tcl ?SEEDS? ?PATTERN?`
(`audit/many-boolean-arguments/mutation-result.txt`), milestone-3/4/5/6 style:
each mutant is a small, local break of the pass (or its registry line),
applied to a scratch copy of the tree (every replaced text must occur exactly
once, else the tool fails); the fuzzer runs first (40 seeds), and
`tests/many-boolean-arguments.test` runs for any mutant the fuzzer does not
kill. A mutated tree whose fuzzer prints no summary is reported `BROKEN
MUTANT` and fails the tool, never counted as a kill.

| mutant | required | killed by |
|---|---|---|
| **flags counted** (`flags-counted`: the ordinary count is the whole `params` length -- gate and threshold both see the flag constants) | yes, the critical one | fuzz: 17 failures, 24 extra warnings; the conversion law fails for 12 of 13 convert-now callees (a converted callee warns about its own flags) |
| the subject gate dropped (`subject-gate-dropped`: `xor` fires) | yes | fuzz: 4 failures, 12 extras |
| non-bool literals counted (`non-bool-literals-counted`: any `const` argument -- an Int, a String literal -- counts) | yes | fuzz: 24 failures, 58 extras |
| 1 literal fires (`one-literal-fires`) | yes | fuzz: 4 failures, 14 extras |
| `false` excluded (`false-excluded`) | yes | fuzz: 18 failures, 15 extras (counts differ) |
| binding reads counted (`binding-reads-counted`: an argument whose `hir::exact::Of` is a bool counts -- the anti-heroic-proving mutant) | yes | fuzz: 11 failures, 45 extras |
| computed args counted (`computed-args-counted`: an operator call such as `1 == 1` counts) | yes | fuzz: 8 failures, 35 extras |
| synthesized calls counted (`synthesized-calls-counted`: the provenance check dropped) | yes | fuzz: 23 failures (the HIR-text check: a parsed program, which has no marker, warns) |
| function-value callees counted (`function-value-callees-counted`: a callee that is no declared reference falls back to the call's resolved `target`) | yes | fuzz: 1 failure, 6 extras (the `getK()(...)` sites) |
| unprovable-typed params counted (`unprovable-params-counted`: checked contracts count as bool) | yes | fuzz: 2 failures, 6 extras |
| instances visited (`instances-visited`: each warning once more per semantic instance whose snapshot covers the call) | yes | fuzz: 12 failures (sites reported more than once) |
| a reachability notion removed (`reachability-removed`: the structural flag ignored) | yes (as extra) | fuzz: 2 failures, 12 extras (dead and after-return placements) |
| a reachability notion added (`reachability-added`: candidates pruned by the completion walk of their enclosing function) | yes (as extra) | fuzz: 6 failures (range-infeasible placements missed) |
| registry line removed (`registry-line-removed`) | yes | fuzz: 19 failures (every prediction missed) |
| first-site-per-value grouping (`first-site-per-callee`: one warning per callee, its first site) | yes | fuzz: 12 failures |
| aliases not followed (`aliases-not-followed`: milestone 2's `NamedCallee` identity) | extra | fuzz: 1 failure (an alias site missed) |
| the receiver excluded (`receiver-excluded`: a method call's position 1 never counts) | extra | fuzz: 7 failures, 6 extras (counts differ) |
| natives excluded (`natives-excluded`) | extra | fuzz: 5 failures |
| the arity check dropped (`arity-check-dropped`) | extra | unit tests: `mb-arity-mismatch-silent` (the fuzzer never writes a call that cannot match) |
| a flag spelling printed (`flag-spelling-printed`: the message appends a mapping) | extra | unit tests: 7 failing -- `mb-no-flag-spelling-anywhere`, `mb-message-template`, `mb-motivating-rendered`, `mb-mode-error-only-this-code`, `mb-literal-count-boundary`, `mb-alias-of-a-declared-function-warns`, `mb-cli-modes` |

**20 of 20 mutants killed: the 15 the brief lists (its kill list, the
reachability notion removed and added counted separately), 18 of all 20 by
the fuzzer and 2 by the unit tests.** What the fuzzer cannot see is message
wording and calls that cannot match their declaration, which it never
generates; the unit tests own them.

**Three tool improvements the mutants forced, each made before the run
recorded here** (the milestone-3/5/6 pattern):

1. **`function-value-callees-counted`**, designed before the first run, falls
   back to the call's `target` -- and only a call-result callee
   (`make()(...)`) has a resolved `target` among function values (a call
   through a parameter does not). A fuzzer that only called through
   parameters could not see it, so the generator gained the `getK()(...)`
   sites; the mutant is killed by them.
2. **`synthesized-calls-counted` was first reported `BROKEN MUTANT`**, not
   killed: the mutated pass warned on the HIR-text input as intended, but the
   fuzzer's HIR-text check read those warnings' file locations and crashed on
   their `{ir ...}` origins. The guard did its job (a crash is never a kill);
   the check now counts this code's warnings, and kills the mutant with 23
   failures.
3. **`unprovable-params-counted` survived the fuzzer** in the first run
   (killed only by `mb-yield-caveat-condition-use-is-not-a-proof`): the
   generator made the deciding shape -- a checked-only parameter that is a
   callee's only subject, or the would-be second bool of a one-bool callee --
   too rarely in 40 seeds. The generator now gives callees 0-2 unprovable
   parameters (two thirds of them checked-only), and the fuzzer kills it. The
   2000-seed run above uses the improved generator.

## Corpus census and findings

`audit/many-boolean-arguments/tools/corpus.tcl`, output
`audit/many-boolean-arguments/corpus-audit.txt`, at the **pinned commit
`1c59bf2`** recorded in its header (corpus paths clean: `examples`, `bench` and
`lib` are `main`'s at `23dbfd8`, unedited by this milestone). It compiles
`examples/stdlib` (9), `examples/surface` (14), `examples/refinement` (1),
`examples/io` (3), `examples/abi` (1), `examples/linux` (4), `bench/*.bot` (8)
and `lib/*.bot` (9) with warnings on, and -- new here -- a one-line loader
program (`import NS`) for every library module, the subdirectory modules
included (`abi::bytes`, `abi::x86_64`, `io::path`, `linux::io`,
`linux::path`: 14 modules), so a module no example loads is still censused.
44 of 49 programs compile standalone (the two deliberate rejections,
`lib/io.bot`'s `CONTEXT-FUNCTION-VALUE` and `lib/list.bot`'s and
`lib/mutable_array.bot`'s `MISSING-IMPORT`, as milestones 2-6 recorded); all 14
modules load.

**The census** (the deliverable whatever the findings):

| census table | rows |
|---|---|
| functions with 2+ ordinary parameters the checker proves `bool` (declared or trusted inferred) | **0** |
| functions with 2+ ordinary parameters that are `bool` by declaration, trusted contract or *checked contract only* (what counting checked contracts would add: the yield caveat measured) | **0** |
| functions that already declare flags (the idiom) | **0** |
| functions with exactly one ordinary `bool`-ish parameter (below the gate) | 9, all checked-only |
| natives whose registry parameter types include `bool` (the stdlib-design pressure list) | **0** of 71 |

The corpus declares no `bool` parameter anywhere (the only `bool` in a
parameter list is the result of a `Fn{args: [str], return: bool}` predicate
type in `lib/web.bot`) and no flag. The nine single-option functions are
untyped parameters the body tests: `bench/lex-strategy.bot`'s `total_valid(tokens,
strict_mode, i, acc)` (called `total_valid(tokens, true, 0, 0)` and `(tokens,
false, 0, 0)`, its recursion forwarding the parameter), `classify`,
`valid_chars` and `choose_classifier` beneath it; `examples/stdlib/
csv_records.bot`'s `csv_records_generic(text, presize)` (called with `false`
and `true`) and the three helpers it forwards `presize` to; and
`examples/surface/04-branch-value.bot`'s `choose(flag)` (called
`choose(false)`). Each is one option of one function, so it is below both the
gate and the threshold, and each is checked-only, so it would not count even
with a second one. They are the corpus's option-shaped bools -- `:strict` and
`:presize` would read better -- and the warning is silent about them by design
(one literal names nothing worse than one argument); the census records them,
nothing proposes them.

**Findings: 0. False positives: 0. Corpus edited: no.** With no finding, there
is no convert-now, computed-caller or deliberate classification to make and no
per-finding conversion law to verify (the brief's "few or zero is a legitimate
answer"). The CI corpus steps accordingly gain no line (see "Backend
independence").

**The tool, self-tested.** A zero from a new tool proves little, so the tool was
run (`-root`) on a scratch copy of the tree with one planted program -- an
options function called with literals, through an alias with a binding, with
method sugar; a checked-only two-option function; a flag-declaring function;
and a single-option function. It reported the 2 findings, classified them
*computed-caller* (the alias call passes the binding `yes`), filled every
census table, and, with the binding changed to a literal, classified all 3
call sites convert-now and **exited non-zero** with "the conversion law must be
verified for each in a scratch copy": the tool has no automatic corpus
rewrite, so a future convert-now finding cannot be classified silently. The
independent false-positive check re-reads, per finding, the source text of
every counted argument's span (it must be exactly `true` or `false`) and the
callee's signature through `hir::signatures::of` (two proven-`bool` ordinary
parameters and a subject).

## The idiom, the non-autofixable rationale and the graduation criteria

**The idiom, declared** (FLAGS.md, "Boolean arguments", new): a call that passes
boolean literals is unreadable (`true` carries no name); two or more make a
signature unusable at the call site; flags are the language's answer for
options (`:append` names the option at the call); boolean *parameters* remain
right for data bools and for values callers compute; a named binding is the
alternative where flags do not apply. The warning points at that statement
(the milestone-3/6 lesson: a warning must not precede its declared idiom).
README §23 describes the warning and its scope, and the flag-parameter bullet
in README's language summary points at the idiom.

**Why the warning is not autofixable.** Conversion needs a mapping from each
literal to a flag name, and there is no safety net for a wrong one: a flag
defaults to `false`, so a rewrite that drops or swaps an option still passes
the right number of ordinary arguments, and the arity check that catches a
mis-mapped rewrite of positional arguments has no counterpart. Measured: the
fuzzer's mis-mapped rewrites (two flags swapped at every call of a
convert-now callee) all compiled -- 893 of 893 -- and 374 of them changed the
program's value while 519 did not. And the mapping is intent, not proof: the only
names in sight are the parameter names, and the call is unreadable precisely
because `true` carries no name -- recovering it from the declaration is
circular. The conversion law (below) *tests* a mapping, the parameter names,
on programs whose every call passes literals; it prescribes none to users.

**Graduation criteria and the revisit trigger (future work, not
implemented)** -- recorded in FLAGS.md: revisit (graduate or redesign) when
either the language makes the literal-to-flag mapping declared and total (for
example call-site option syntax for positional bools), or **flag-variables
land** (a flag's value carried in a variable; today a flag is not a value,
`FLAG-NOT-A-VALUE`). That second one is the recorded revisit trigger: the
evidence rule and the per-site choice are then re-examined together -- a
flag-variable passed to a `bool` parameter is named, hence silent today, and
may deserve to be evidence of its own; grouping per callee, or anchoring at
the declaration, may then be the better design. Nothing of it is built.

## Full regression

All runs are on this milestone's code as committed at `2c1d889` (the pass, its
tests, fuzzer, mutants and corpus tool; later commits change documentation and
audit outputs only, none of which a test runs). The native backend is built
from that tree (nothing under `native/` changed). `tests/all.tcl` ran on both
Tcl backends with the harness's default policy (`BOTLISH_WARNINGS=off`), each
with a private `-tmpdir` (AGENTS.md, "Running tests concurrently"), in
parallel with `tests/native-coverage.tcl`. This milestone adds 90 tests
(`tests/many-boolean-arguments.test`) and changes 6 existing tests' expected
results in place; no `test` line is added or removed outside the new file
(`git diff 23dbfd8 -- tests/`), so the kickoff base `23dbfd8` had 6715 - 90 =
6625 (derived, not a separate run).

* **`interp`: 6715 tests, 6715 passed, 0 failed. `compile`: 6715 tests, 6711
  passed, 4 skipped (the existing `coreScoping` constraint), 0 failed.**
* **`tests/native-coverage.tcl`** (the suite on `cranelift`, as CI's native
  job): 6715 tests: 2652 native, 3935 independent of the backend, 68
  passed-partial, 60 unsupported (the constructs it already classifies, the
  same 60 as milestones 2-6), **0 failed**.
* **`cranelift-generic`**, file by file: `tests/many-boolean-arguments.test`
  90, the six adapted warning files (81, 145, 149, 99, 84, 85),
  `tests/flags.test` 155, the refinement trio (88, 48, 20),
  `tests/str-char-at.test` 14 and `tests/value-display.test` 8: **1066 tests,
  1066 passed**.
* **`tests/many-boolean-arguments.test`: 90/90 on each of `interp`, `compile`,
  `cranelift-generic` and `cranelift`.** The item-2 files after adaptation pass
  on all four backends (`interp` and `compile` in the full runs, `cranelift`
  in native coverage, `cranelift-generic` file by file), and their fuzz smoke
  tests (`warn-`, `me-`, `fa-`, `sf-`, `pn-`, `oc-`, `mb-fuzz-smoke`,
  `validator-fuzz-smoke`) pass.
* CI's plain example steps, reproduced at `2c1d889`: the native job's
  `main.tcl -backend cranelift` corpus step exits 0 with 376 stderr lines (0 of
  them this warning's, the count unchanged); the Tcl jobs' `main.tcl -backend
  interp` and `-backend compile` exit 0 with an empty stderr (see "Backend
  independence and clean outputs").
* The fuzzer passes 2000 seeds with the conversion law (`fuzz-result.txt`, at
  `1c59bf2`, whose fuzzer and pass are `2c1d889`'s); the mutation tool kills
  20/20 (`mutation-result.txt`, at `2c1d889`); the corpus audit is
  `corpus-audit.txt`, at `1c59bf2`.
* A first attempt at the full runs was stopped by this session's background
  time limit after about two thirds of the files (101 and 102 of 157, 0
  failures so far); it was discarded and all three suites were rerun to
  completion, the results above.
* The GC-stress job (`BOTLISH_NATIVE_GC_STRESS=1`, CI on push to `main`) was not
  run locally: nothing under `native/` changed, and the pass runs before any
  backend and changes no HIR (pinned).

## Known limitations

* **The warning effectively requires annotated options.** An untyped option
  the body only tests has a checked contract, not a proven type, and is not
  counted (the yield caveat above). The corpus declares no `bool` parameter,
  so the warning is latent there: zero findings, zero CI lines. Counting
  checked contracts would add nothing to the corpus either (no function has
  two), but it would weaken the gate's meaning from "proven" to "required".
* **A function declared in a dead branch** has a structurally reachable body,
  so its calls warn (as `METHOD-ELIGIBLE`'s do); a branch the range facts prove
  infeasible is structurally reachable too. Both are the conservative
  direction of a structural rule.
* **Natives are judged by their registry parameter types**, which are run-time
  checked contracts; no registered native takes a `bool`, so this is latent.
* **The corpus tool has no automatic rewrite**: a convert-now corpus finding
  makes it exit non-zero until the conversion law is verified for it in a
  scratch copy and recorded (there are none at the pinned commit; the tool's
  classification was self-tested on a scratch copy with a planted program --
  see "Corpus census").
* **The literal's parentheses are invisible**: `(true)` is the same node as
  `true` and counts; it is the same anonymous token.
* Only the first warning is raised under `error`, as in milestones 1-6.
* Successor note (REFACTOR-WARNINGS-CLEAN.md): the corpus still has no finding
  of this code, and is now held there: a gate
  (`audit/refactor/tools/gate.tcl`, CI) fails on any new one in `examples/`,
  `bench/` or `lib/`. The nine single-option bools of the census stay
  recorded, not converted.

## Future warning candidates

`MANY-BOOLEAN-ARGUMENTS` moves from proposal to implemented. New, recorded as
future work and not built: its **autofix graduation** (a declared, total
literal-to-flag mapping) and the **flag-variable extension** (the revisit
trigger: evidence beyond literals, and per-callee grouping or
declaration-level anchoring, re-examined together). Still future, unchanged
from milestone 6: `ONE-CHAR-STRING-LITERAL`'s autofix graduation; a condition
that repeats an already established proof; manual iteration whose
cardinality duplicates another domain; milestone 3's possible helper-chain
extension; and, evidence-gated, multi-parameter predicates. Nothing else is
new.

Not planned: per-warning flags, `-Wall`/`-Wextra` or levels, call-site
suppression, pragmas or lint-ignore comments, any author opt-out, a printed
flag spelling or mapping, any fixit or automatic rewriting, exact-value,
alias-flow or constant-propagation tracking of arguments, counting computed or
bound bools, a signature-blunt (declaration-only) mode, counting flags, and
any new CLI option or `BOTLISH_WARNINGS` value.

## Deviations from the brief

* **Aliases of a declared function warn** (`g = open_file; g(...)`), naming
  the declaration. The brief's "milestone 2's `NamedCallee`/candidate-identity
  pattern" contains both: `NamedCallee` never follows an alias, the candidate
  identity does. The candidate identity was chosen because the brief also
  names "the callee's resolved declaration" and because an alias call is
  exactly what flags support (FLAGS.md resolves a flag interface through
  aliases), so the conversion law covers alias call sites (the fuzzer spells
  calls through aliases). Calls through function *values* stay silent. **This
  is the decision most worth the user's review**; reverting it is a one-line
  change (`aliases-not-followed` is a mutant the fuzzer kills, so the tests
  would need the alias pins inverted).
* **The provenance requirement is currently redundant with the gate for source
  programs**: no synthesized call targets a declared function or a native that
  takes a `bool`. It is kept as the rule; HIR text is the input where it is the
  only guard, and that is what pins it.
* **A literal at the subject position counts** (`last(true, true, ...)`): the
  theorem's "at ordinary parameter positions" taken literally.
* **The motivating example's body** is `path` (the brief's `...` is not
  Botlish).
* **Zero corpus findings and an empty census** at the pinned commit (the
  brief's expectation was "few or zero"); the census is delivered in full,
  including the checked-contract and flag-declaring tables that make the zero
  legible.
* **Branch.** `AGENTS.md` says to push finished work to `main`. This session was
  assigned a development branch and told not to push elsewhere without
  permission, so the work is pushed to that branch.

## Required questions

**Warning framework**

1. *Enabled by default?* Yes.
2. *All warnings disableable globally?* Yes: `-warnings off`.
3. *All warnings promotable globally?* Yes: `-warnings error`.
4. *Per-warning `-Wfoo`?* No (`-Wno-many-boolean-arguments` is an unknown
   option, in process and through `main.tcl`).
5. *Warning groups?* No.
6. *Codes stable?* Yes: `MANY-BOOLEAN-ARGUMENTS`.
7. *Policy per compilation?* Yes (interleaved compilations pinned).
8. *Does `off` skip the pass?* Yes: no stats entry; a trace shows 0 calls under
   `off` and 1 under `default`.
9. *Does `error` preserve the code?* Yes: `{CORE SEMANTIC
   MANY-BOOLEAN-ARGUMENTS}`.
10. *Backend-independent?* Yes: all four backends, in process and through the
    CLI (identical warning text).

**`MANY-BOOLEAN-ARGUMENTS`**

11. *Meaning?* A written call passing two or more boolean literals to a
    declared callee whose signature has at least two provably-`bool` ordinary
    parameters and at least one non-`bool` one.
12. *Signature-blunt?* No: a declaration alone never warns; the evidence is the
    call's literals (`mb-bindings-silent`, `mb-computed-bools-silent`: the
    same signatures, no warning).
13. *Computed or bound bools at the call?* Never count, never fire (the
    anonymity principle), including provably constant bindings.
14. *`false` counts?* Yes.
15. *All-`bool`-parameter callees?* Silent (the subject gate; the `xor` class).
16. *Flags counted toward the gate or the threshold?* Never (the critical
    mutant is killed).
17. *Synthesized calls?* Never: provenance (and, today, the gate as well);
    marker-less HIR text and core IR are silent.
18. *Function-value callees?* Silent (parameter, call result, field, branch
    value); an alias of a declared function is that declaration and warns.
19. *Native callees?* Included, by registry parameter types (a probe native
    fires); no registered native takes a `bool` today.
20. *Unreachable call sites?* Skipped, structurally (milestone 2's rule); the
    contrast with milestone 6 is pinned in one program.
21. *Grouped per callee?* No: per call site (the revisit trigger is recorded,
    not built).
22. *Message prints a flag mapping?* Never.
23. *Autofixable?* No (a flag defaults to `false`: no arity safety net; the
    mapping is intent); graduation criteria recorded in FLAGS.md.
24. *Author opt-out?* None.

**Architecture**

25. *Stage?* `surface::lower::Finish`, unchanged.
26. *Which facts supply the proof?* Call provenance (`written`), argument
    expressions (root `true`/`false` references), callee resolution
    (`hir::resolve::CandidateIdentity` to a declaring `bind` of a block, or a
    native's registry entry), the block's `params` and `flags`, parameter types
    (`hir::signatures::entryTypes`), structural reachability. Not needed:
    exact values, the call's `target`, the completion walk, origin or source
    text, annotations beyond the types, a call graph, any helper outside the
    pass.
27. *New HIR state?* None (`mb-no-new-hir-state`, `mb-call-nodes-unchanged`).
28. *Walks?* Structural flags only; no completion walk (traced at 0).
29. *Record shape and secondary?* `{code message primary secondary data}`;
    `secondary` empty; `data` is `call`, `callee`, `calleeName`, `literals`,
    `positions`.
30. *Deterministic ordering, seven codes?* The inherited `Sort`, pinned in both
    orders.
31. *Instances?* Generic HIR once, never walked (the mutant is killed).
32. *Framework changes beyond the registry line?* None.
33. *Does `error` reject before backend lowering?* Yes (traces on all four
    entry points; a cranelift CLI run prints no value).
34. *Structurally collectable?* Yes: `hir::warnings::of` / `collect`.

**Verification**

35. *Corpus census and findings, at which commit?* At `1c59bf2` (corpus
    paths clean, `main`'s at `23dbfd8`): 44 corpus programs and 14 library
    modules; **0 findings**; census -- 0 functions with two or more
    proven-`bool` ordinary parameters, 0 with two or more `bool`-ish ones even
    counting checked contracts, 0 declaring flags, 9 with exactly one
    checked-only `bool` (below the gate), 0 natives with a `bool` parameter.
    Zero is the legitimate answer here: the corpus declares no `bool`
    parameter.
36. *False positives?* Zero (no finding; the independent check -- each counted
    argument's source text and the callee's signature through
    `hir::signatures::of` -- was exercised on a planted scratch program).
37. *Conversion law at which levels and over which class?* The fuzzer, over the
    convert-now class: 893 of 893 callees (2000 seeds), each rewrite
    compiling, losing its callee's warnings, keeping the others' and the
    program's value; computed-caller (1671), function-value (443) and native
    (2400) callees catalogued, never a failure. The corpus level is vacuous (no
    finding); the corpus tool fails on any convert-now finding until its law is
    recorded. The mis-mapping catalog: 893 of 893 swapped rewrites compiled,
    374 changed the value.
38. *Warning-mode tests pass?* `tests/many-boolean-arguments.test` 90/90 on
    `interp`, `compile`, `cranelift-generic` and `cranelift`. The adapted files
    -- `tests/warnings.test` 81, `tests/method-eligible.test` 145,
    `tests/fixed-arity-list-return.test` 149, `tests/same-failure.test` 99,
    `tests/proves-naming.test` 84, `tests/one-char-string-literal.test` 85 --
    and `tests/flags.test` 155, the refinement trio (88, 48, 20),
    `tests/str-char-at.test` 14 and `tests/value-display.test` 8 pass on all
    four backends (see "Full regression"). Each fuzzer's smoke run was
    accounted for individually: pass runs 181, 400, 162, 120, 153, 256 and 0,
    this warning's findings 0 in all seven, every summary line identical to
    its baseline.
39. *Fuzzer and mutation results?* Fuzzer: 2000 seeds, 1030 with warnings and
    970 without, 0 failures, 0 extras, `METHOD-ELIGIBLE` predicted exactly, HIR
    text silent for all 2000, conversion law 893/893. Mutation: 20 of 20 killed
    (the brief's 15 among them): 18 by the fuzzer, 2 by the unit tests
    (`arity-check-dropped`, `flag-spelling-printed`); three mutants forced tool
    improvements (`getK()(...)` sites, the HIR-text check counting by code,
    more checked-only parameters).
40. *Backend parity?* Identical warning sets on all four backends in process,
    and identical warning text through `main.tcl` (a seven-code program; the
    stdlib corpus and the refinement example).
41. *Full regression?* At `2c1d889`: 6715 tests on `interp` (6715 passed) and
    `compile` (6711 passed, 4 skipped by the existing constraint), 0 failures
    each; native coverage 6715 tests, 0 failed (2652 native, 3935 independent,
    68 passed-partial, 60 unsupported); `cranelift-generic` 1066/1066 over the
    item-2 files and the new one; CI's plain example steps exit 0, the native
    one with 376 stderr lines -- unchanged, 0 `MANY-BOOLEAN-ARGUMENTS` (301
    `METHOD-ELIGIBLE`, 62 `ONE-CHAR-STRING-LITERAL`, 8 `FIXED-ARITY-LIST-RETURN`,
    2 `SAME-RETURN-VALUE`, 3 notes) -- the Tcl ones with none. The adaptations
    changed 6 existing tests' expected results (the code-enumerating pins) and
    nothing else; every complete-set assertion, every fuzzer and the
    warnings-on sweep were checked and left unchanged ("Kickoff").
