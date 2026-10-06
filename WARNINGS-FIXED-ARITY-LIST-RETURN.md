# Compiler warnings: `FIXED-ARITY-LIST-RETURN`

## Outcome

Botlish's third compiler warning, **`FIXED-ARITY-LIST-RETURN`**, is one pass
plus one registry line on the warning framework of milestones 1 and 2
(`hir/warnings.tcl`; WARNINGS-SAME-RETURN.md, WARNINGS-METHOD-ELIGIBLE.md). No
frontend fact had to be added: milestone 2's written-list provenance is
sufficient, and the written return annotation is the `declaredResult` the
resolver already records on every function block.

```botlish
fn scan_quoted(text, index, field) errors LowerUnderrun:
    character = peek(text, index)
    if character == "\"":
        if peek(text, index + 1) == "\"":
            return scan_quoted(text, index + 2, str::concat(field, "\""))

        return [field, index + 1]

    scan_quoted(text, index + 1, str::concat(field, character))
```
```
t.bot:10:13: warning: a 2-element list is returned from all 3 value exits; a struct value names the parts (FIXED-ARITY-LIST-RETURN)
t.bot:12:9: note: also returned here
t.bot:14:5: note: also returned here
```

(`tests/fixed-arity-list-return.test`, `fa-scan-quoted-rendered`: this listing
preceded by the corpus's five-line `peek`, so it starts on line 6. The anchor is
the first exit in source order, the recursive return; the notes are the literal
exit and the final-expression exit.)

The warning states the shape -- arity and exit count -- and names the
language's preferred form. It does not rewrite, suggest field names, or claim
the list return is wrong. Its preference is not invented here: struct values
have named parts and destructure, Lists deliberately do not
(STRUCT-DESTRUCTURING.md's language policy and its `LIST-DESTRUCTURING`
diagnostic). This milestone writes that design down as an idiom,
**MULTI-VALUE-RESULTS.md** ("if a result carries more than one value, name the
parts"), the `METHOD-SUGAR.md` analogue the warning points at. An author whose
result really is a list says so at the declaration (`-> list`,
`-> List[T]`), and the warning is silent.

Coordination: a parallel agent owns the corpus and the failures default-on
warnings induce elsewhere. This milestone edited no corpus file. It first left
the breakage it causes in `tests/warnings.test` and `tests/method-eligible.test`
to that agent, as the brief assigned. That was then reversed: the 8 tests were
adapted here, test-only and without weakening any pin, because only this
milestone creates them (see "Parallel work"). The corpus was audited at a pinned
commit, `faae181`.

### Why a third preference-shaped warning belongs

Milestone 2 admitted a preference-shaped warning on four conditions, and this
one meets the same four:

* **The fact is compiler-proven.** Every reachable value exit of the function
  is a written list literal of one arity. The provers are the frontend's
  written-form provenance (milestone 2), the binding/alias identity
  `SAME-RETURN-VALUE` uses (`hir::exact::AliasRoot`), the resolver's candidate
  identity (`hir::resolve::CandidateIdentity`), HIR reachability and the
  completion proof's walk. No new analysis was written.
* **The preference is the language's own design.** Structs destructure and
  Lists do not, on purpose (MULTI-VALUE-RESULTS.md, STRUCT-DESTRUCTURING.md).
  The warning points at that decision the way `METHOD-ELIGIBLE` points at
  METHOD-SUGAR.md.
* **The function's author has first-class control at the declaration.** A
  list-typed result annotation is a real type declaration the checker
  enforces. It is the only opt-out (below).
* **Uncertainty means silence.** Every case the pass cannot establish is
  silent: computed lists, unit, recursion it cannot see, `if`-valued returns,
  core-IR input.

This warning has **the widest gap between fact and advice of the three**, and
the report treats that gap openly (see "Heterogeneity is not required, and the
honest gap").

## The shape theorem

> A function is reported exactly when it has **at least one literal exit**, and
> **every reachable value exit** is either a **written list literal of arity
> N** (N >= 2), a **binding whose initializer is a written list call of N
> elements** (item 11), or a **direct self-call** (item 12) -- all with the
> **same N**.

One warning per function. When it fires, the message's exit count is exactly
the function's number of reachable value exits, and every one of them carries
the shape by definition. Any single mismatch silences. Each clause is pinned:

| clause | pinned by (tests/fixed-arity-list-return.test) |
|---|---|
| at least one literal exit | `fa-all-self-calls-silent`, `fa-reach-range-pruned-literal-leaves-only-self-calls` |
| every reachable value exit | `fa-mixed-arity-silent`, `fa-computed-*`, `fa-struct-exit-silent`, the `fa-unit-*` family, `fa-reach-*` |
| written list literal | `fa-two-elements-warn`, `fa-three-elements-warn`, `fa-core-ir-input-silent`, `fa-hir-text-input-silent` |
| arity N >= 2 | `fa-arity-boundary` (0 and 1 silent, 2 and 3 warn), `fa-single-exit-one-element-silent` |
| binding whose initializer is a literal | `fa-alias-initializer-literal`, `fa-alias-chain-to-root`, `fa-rebinding-*` |
| direct self-call | `fa-scan-quoted`, `fa-self-call-and-literal`, `fa-aliased-self-call`, `fa-method-sugar-self-call` |
| same N | `fa-alias-beside-literal-other-arity`, `fa-mixed-arity-silent` |
| one warning per function, count = exits | `fa-one-warning-per-function`, `fa-record-data-fields`, `fa-message-text` |

The pass is `hir::warnings::FixedArityListReturn` with the helpers
`FixedArityIn`, `DeclaresListResult`, `ShapeExits`, `FallThroughs`, `ExitShape`,
`InitializerArity` and `SelfCall`, appended to `hir/warnings.tcl`.

## What counts as an exit

Exits are inherited unchanged from milestone 1 (`Exits`, `Leaves`,
`BodyExprs`, `SynthesizedBranch`, called as they are). They are the terminal
completions of a `block`: every reachable `return` that targets the function,
wherever it sits (loops, branches, on-handlers), plus the final-expression
value (the body's last expression, or the last expression of each reachable
branch of a written `if`, recursively). An exit is a source operation. Returns
of nested functions and closures belong to those functions. The synthesized
boolean `if` is never opened, and `elif` is a nested `if`.

Three **deliberate deviations** from `SAME-RETURN-VALUE`'s treatment, each
documented in the pass header and pinned:

| case | SAME-RETURN-VALUE | this warning | why | pinned by |
|---|---|---|---|---|
| unit exit | skipped | **mismatch: silence** | below | `fa-unit-*` (9 tests), `fa-unit-milestone1-policy-differs` |
| `fail` | a different completion kind, never grouped | the same: **does not block** | below | `fa-fail-guard-warns`, `fa-fail-final-contributes-no-exit`, `fa-fail-all-silent`, `fa-fail-in-branch-beside-literals` |
| self-call exit | an ordinary call (no recursion notion) | **counts, inherits N** | below | `fa-self-call-and-literal`, `fa-scan-quoted` |

### Unit exits are a mismatch, not a skip (item 5)

Milestone 1's rationale for *skipping* unit: "a procedural function with several
unit exits collapses no interesting domain information, only noise". That is
right for a warning about *repeated values*, because repeated `unit` says
nothing. It would be wrong here. Skipping unit exits would manufacture this
warning's claim, "every exit is a list", for functions that return "a list or
nothing". In `fn f(x): if x: [a, b]` the else-less `if` falls through with
unit, so the function is an optional and not a fixed-arity result. So a
reachable unit exit is a value exit that does not carry the shape, and it
silences.

Unit exits are: a bare `return` (HIR's `return unit`), `return unit`, a final
`unit`, a final destructuring statement (which lowers to its bindings followed
by `unit`), a final binding statement (`s = r` completes with unit, not with
`r`'s list: `fa-unit-final-binding-of-alias`), and, the one the inherited
`Leaves` does not see, **the implicit fall-through of an else-less final
`if`**. `Leaves` skips an empty branch body. `FallThroughs` walks the same
final-expression path and reports each written `if` with a missing branch whose
outcome HIR does not decide away (`hir::types::KnownOutcome`, the decision
`hir::types::If` itself makes; `if true: [a, b]` has no fall-through and warns:
`fa-unit-fallthrough-decided-away`). An else-less `if` that is *not* the last
statement falls through to the next statement and is no exit
(`fa-unit-non-final-elseless-if-is-no-exit`). The pins are the else-less-if
optional itself and its with-else control, the bare-`return`-plus-list-final
variant, and `return unit`, final `unit`, destructuring, final binding, an
else-less `if` whose branch returns, and an elif chain with and without `else`.

### `fail` does not block (item 6)

`fail` is not a value exit (inherited), so the procedural guard warns:

```botlish
fn f(xs) errors Empty:
    if xs == []:
        fail Empty
    [xs, list::length(xs)]
```

This is the common shape. A "fail blocks" rule would miss most guard-before-
result functions. A body that ends in `fail` contributes no exit, and an
all-`fail` function has no value exit and is silent. An exit whose value can
never complete (type `never`) is likewise not a value exit (inherited from
`Group`; `fa-never-completing-exit-is-no-value-exit`).

### Self-recursion (item 12)

* A **direct self-call exit** -- a call whose callee
  `hir::resolve::CandidateIdentity` resolves to the binding the function is
  bound to, plainly (`f(...)`), through an alias (`g = f` inside `f`), or
  written with method sugar (it is an ordinary call by then) -- counts as an
  exit, appears in the count and the notes, and inherits N: its value is the
  function's value. It contributes no N.
* At least one literal (or alias-of-literal) exit is required, so a function
  whose exits are all self-calls is silent.
* Soundness of inheritance comes from the uniformity rule. A self-call matters
  only when every literal exit agrees on N. The claim "this function returns
  N-element lists" is supported by the literal exits and carried through the
  self-calls, whose values are by induction one of those literals.
* **Indirect and mutual recursion are silent.** A call to anything other than
  the function itself is an ordinary call of unknown shape. No call-graph
  worklist was added. Botlish cannot express top-level mutual recursion at all
  (a binding is visible only after its definition: STRICT-REFERENCE-
  DETERMINISM.md; `mutual:` is a design, MUTUAL-RECURSION.md). The expressible
  forms are pinned silent: recursion through a nested helper, a nested function
  and its enclosing function calling each other, and recursion through a
  function value passed in.
* Termination is trivial: the pass walks syntax, and nothing in it recurses on
  the call graph (`fa-self-call-termination-trivial` pins a function that
  recurses forever at run time).

### Arity, element types, literal-ness (items 7-10)

* **N >= 2.** A written 0- or 1-element exit is a mismatch, and a function whose
  uniform arity would be 0 or 1 is never reported. A one-element list holds a
  single value, so there is nothing to name. Zero elements is an empty
  sequence. The bound is one constant, `minListArity`, read by both the
  candidate gate and the uniformity check, so a mutation of it is not
  equivalent (see "Mutation testing").
* **No element analysis.** The pass reads no types, no equality, no exact
  values and no heterogeneity. Arity is the call's argument count. `[y, m, d]`
  counts like `[table, index]`, and `[compute(x), y + 1]` counts
  (`fa-element-types-irrelevant`, `fa-computed-elements-count`).
* **Literal-shaped means milestone 2's provenance.** A literal is a call
  carrying `written {form list}`. Anything else is a mismatch: `list::append`,
  `str::concat`, a method-sugar construction, an operator, a call of another
  list-returning function, an `if`/`loop`/handled value. A call without the
  marker (core IR, `.hir` input) is never a literal, which is the fail-safe
  direction. The standing argument against deriving literal-ness from callee
  or origin sniffing is milestone 2's "Provenance" section and is not repeated
  here.
* **Computed and mutable values are silent.** A `MutableArray`, a parameter,
  an alias of either, and an alias of a computed list are mismatches.

### Alias-of-literal exits and the verified rebinding rule (item 11)

`r = [a, b]; ...; return r` must not be missed. An exit counts as shape N when
`hir::exact::AliasRoot`, the alias resolution `SAME-RETURN-VALUE` already
uses, takes the exit's reference to its root binding `B`, `B` is a `local`
declared by a non-duplicate `bind`, and that bind's value is a written list
call of N elements (`InitializerArity`). Only a `ref` exit is followed, so the
binding statement `s = r` (unit) is never mistaken for `r`
(`fa-unit-final-binding-of-alias`).

**Verified precondition: rebinding is shadowing, never assignment.** Botlish
has no assignment and no mutable binding. A second binding of a name in the
same scope is the `DUPLICATE` error (`examples/surface/10-duplicate-
binding.bot`: "Binding is not assignment"). The program is rejected, and under
`-strict 0` it keeps an error diagnostic and is never warned about
(`fa-rebinding-same-scope-is-an-error`). A binding of the same name inside a
branch is a new binding (`05-shadowing.bot`), renamed `name#N` by hygiene, with
its own initializer. Each binding therefore has exactly one initializer, and an
immutable binding holds that initializer's value. A List value is immutable,
so the alias is that literal. The pins: single binding (`fa-alias-initializer-
literal`); a chain `s = r; t = s` through the root; a branch shadow of another
arity, silent; a branch shadow of the same arity, two alias exits; an alias
beside a literal of the same and of another arity; a top-level binding
initialized by a literal (`fa-alias-module-level-binding`). "Mutated binding"
has no Botlish instance. A mutable *value* is a `MutableArray`, never a list
literal, and is silent (`fa-alias-of-mutable-silent`).

### Structs, mixed shapes, single exits (items 13-14)

A struct exit is not a list. Mixed arity is silent, and so are mixed struct and
list exits. The last is a migration property: a half-converted function does
not nag, and one function never produces two partial warnings
(`fa-mixed-struct-list-silent`). The converted `scan_quoted` is silent
(`fa-converted-scan-quoted-silent`).

**Single-exit functions warn.** The uniformity fact holds trivially for one
exit, and the conversion applies no matter how many exits produce the result.
This differs on purpose from `SAME-RETURN-VALUE`'s two-exit threshold, which
exists because one exit cannot repeat a value. The message reads "from the only
value exit" (`fa-single-exit-warns`; one 1-element exit is silent). In the
corpus, 7 of the 8 findings are single-exit.

## The annotation: the author's voice (item 15)

A function whose declaration carries a **written result annotation of a list
type** has declared "this result is a list", and the warning is silent:

```botlish
fn coords(dx: int, dy: int) -> List[int]:
    [dx, dy]
```

* **Recording: reused, nothing added.** The parser keeps `-> T` as the
  function's `resultType`, `surface::lower` passes it to
  `hir::syntax::blockNode` as `declaredResult`, and `hir::resolve` normalizes it
  onto the block's `declaredResult` field for every function block, in every
  compilation mode (the warning mode is not consulted anywhere in that path).
  `hir::format` prints it (`declares List[int]`), `hir::parse` reads it back,
  and the module loader's `RemapFile` copies the node with it. So the
  `nomethod`-style recording milestone 2 had to add already exists for this
  fact. It is robust because it is the checker's own input: the field
  `hir::range::verifyDeclaredResults` proves and specialization reads. Pinned:
  the field is identical under `off` and `default` and the whole HIR is
  identical (`fa-annotation-is-the-existing-declared-result`), the format/parse
  round trip, and respect through a module import
  (`fa-annotation-through-module-import`: the annotated module function is
  silent, its unannotated twin warns, located in the module file).
* **Written and list-typed.** `DeclaresListResult`: a non-empty
  `declaredResult` whose `hir::types::kindOf` is `list`. That covers `List[T]`
  for every `T` (nested included), the bare `list` (`List[any]`), and any
  refinement of `list`. The element type is irrelevant.
* **The annotation decides, not the shape.** An annotated function's exits are
  never examined. An execution trace on `ShapeExits` shows 0 calls for an
  annotated function whose exits mismatch anyway
  (`fa-annotation-decides-not-the-shape`).
* **A non-list annotation does not silence.** The type system has a wider type
  that admits uniform list exits, `any`: `fn coords(dx, dy) -> any: [dx, dy]`
  compiles and warns (`fa-annotation-any-does-not-silence`). A struct
  annotation over list exits is a checker error (`function result does not
  prove declared type P`), so that program is never warned about
  (`fa-annotation-struct-is-a-checker-error`). There is no universal-mute
  annotation.
* **Wrong annotations are checker errors.** `-> List[int]` over untyped
  parameters is rejected (the result does not prove `List[int]`). That is why
  the examples type their parameters. `-> list` is provable for any function
  whose exits are lists.
* **Wherever annotations can be written.** Top level, modules
  (`fa-annotation-through-module-import`) and nested functions
  (`fa-annotation-nested-function`).
* **Not a suppression pragma.** As with `nomethod`, the annotation is a
  declaration-level property of the function, decided by its author, with
  independent semantic consequences. The checker must prove it, and every
  caller sees the declared type. It changes what the program *is* (its
  function's contract). The warning's silence is a consequence of that fact,
  not an instruction to the compiler about a diagnostic. **No other author-side
  opt-out exists or was added**: no `notuple` modifier (a syntax error,
  `fa-annotation-no-other-opt-out`), no lint comment (a comment silences
  nothing, same test), no warn-only flag (which would be suppression in
  disguise).

## Heterogeneity is not required, and the honest gap (item 16)

Requiring two or more distinct element types across positions was considered
and **rejected**. The design fact the warning serves (Lists do not destructure,
on purpose, against tuple folklore) applies to `[year, month, day]` exactly as
to `[table, index]`. A genuine list already has a first-class answer in the
annotation. The corpus shows heterogeneity would also have been the wrong
discriminator. `csv_records.bot`'s `sample_checks` is heterogeneous by element
type (`int`, strings, `bool`) and is a genuine list of check results (annotate).
The csv_chunked builder state is heterogeneous and a real product (convert). The
author's judgement separates them, and element types do not.

The consequence, stated plainly: **this warning has the widest fact-to-advice
gap of the three.** The provable fact is the uniform shape. "A struct would be
better" does not follow from it for a function that really returns a
fixed-shape list. The mitigations, together:

* **Acting on the warning is checked, though less completely than the brief
  assumed.** After conversion, every read of the result by field name is
  checked statically: a missing or misspelled field is `UNKNOWN-FIELD`, and a
  projection on a result of unknown struct type (`any`) is a `TYPE` error,
  because projections are resolved statically. A leftover positional read that
  flows into a *source* function whose inferred parameter type is a list
  (`list::get(r, 0, d)`) is a compile-time `TYPE` error. **But a leftover
  direct native read (`list::at(r, 1)`, `list::length(r)`, `loop x in r`)
  compiles** and fails at run time with a kind error ("list::at: expected list,
  got {p0: 1, p1: 2}"). Botlish checks native argument kinds at run time, even
  under `-strict 1` (`str::length(5)` compiles too). **A leftover `==` against a
  list literal compiles and is silently `false`.** These are pinned as the
  checker actually is, in `fa-conversion-*` (two of them marked GAP). So a
  conversion cannot silently mis-read a part. It either fails to compile or
  fails loudly at run time, with one exception: comparing the converted result
  with a list using `==`. This is the warning's analogue of milestone 2's
  round-trip law, weaker than the brief stated (see "Deviations from the
  brief").
* **The annotation** is a one-line, machine-checked way to say "this really is
  a list". In the corpus, six of eight findings are answered by it, and each
  one compiles, loses the finding and keeps its value (corpus audit,
  "annotation check").
* **Every conservative silence** in items 9-13. Uncertainty means silence.
* **An oracle-based fuzzer** with a conversion law, **mutation testing** of the
  pass, and a **hand-audited corpus review** (below).

**The false-positive bar.** A finding is a false positive when the author,
knowing the idiom, would neither convert nor annotate. The corpus audit
applies that judgement by hand to every finding.

## Reachability: the direction-of-error argument, restated (item 21)

Two tiers, as in milestone 1. HIR's structural `reachable` flags (inside the
inherited `Exits`/`Leaves`; `FallThroughs` adds the decided-outcome check) come
first. Then, only for a **candidate**, the completion proof's recording walk
(`hir::completions::reachedExprs`: parameters unconstrained, empty-narrowed
branches never entered) prunes proven-unreachable exits. A candidate is a
function with a literal exit of arity >= 2. The walk runs once per candidate
and never for other functions (`fa-reach-walk-only-for-candidates`, by trace).
The gate must be "a literal exit exists" and not "the function would warn
without pruning", because pruning can be what makes it warn.

Milestone 1's sentence -- the walk "can only remove exits, never add one", so
its errors point toward missed warnings -- does **not** carry over unchanged.
Here, removing an exit can **create** a warning, because a pruned mismatching
exit no longer breaks uniformity. The correct argument is about soundness of
the claim, not about the direction of a change. The walk removes an exit only
when it is proven unable to execute. So after pruning, every exit that *can*
execute is one of the remaining exits, all of which carry shape N, and the
statement "every reachable value exit returns an N-element list" is true. An
imprecise walk (one that fails to prove an exit unreachable) keeps the exit,
which can only cause a mismatch and silence. The error direction of
*imprecision* is still a missed warning. *Precision* can add a warning, and
only a true one. Pinned: a range-unreachable 3-element exit beside a reachable
2-element exit warns with the 2-element shape (`fa-reach-range-pruned-enables-
warning`), and the feasible control is silent (`fa-reach-range-feasible-
control`). A range-unreachable unit exit no longer silences. Pruning the only
literal leaves self-calls alone, which is silent.

One practical corollary for acting on such a finding: the type checker does not
share the range-pruned reachability. The unreachable exit's type still joins
the function's result type, so a mechanical conversion must also conform or
delete that dead exit. Otherwise the result is no longer a single struct type
and field projections are rejected. The fuzzer's conversion law includes this
step.

## Provenance and annotation representation

Nothing new is represented. The pass reads two existing facts:

| fact | where it lives | recorded by | mode-independent | visible to |
|---|---|---|---|---|
| written list literal | `written {form list ns NS}` on the HIR call | milestone 2 (`surface::lower` `withWritten`, `hir::resolve`) | yes (milestone 2's pin, re-pinned by `fa-hir-identical-across-modes`) | the warning passes only |
| written return annotation | `declaredResult` on the `block` | `hir::resolve` from the parser's `resultType` | yes (`fa-annotation-is-the-existing-declared-result`) | the checker, specialization, `hir::format`/`hir::parse`, and now this pass |

Because the annotation existed before this milestone and is a real type, it is
*not* invisible to the checker or to code generation, and it never was. What is
pinned is that this milestone changes nothing. HIR, `hir::format`,
`hir::lower`, NIR (specialized and generic), CLIF and `native::report` are
identical under `off` and `default`. An annotated function and its unannotated
twin lower to the same core IR and the same value
(`fa-annotation-changes-nothing-else`). Nothing under `native/` changed.

## Architecture

**One pass, one registry line.**

```tcl
variable passes {
    SAME-RETURN-VALUE hir::warnings::SameReturnValue
    METHOD-ELIGIBLE   hir::warnings::MethodEligible
    FIXED-ARITY-LIST-RETURN hir::warnings::FixedArityListReturn
}
```

The diff of `hir/warnings.tcl` above the `SAME-RETURN-VALUE` section is that one
line. Everything else is appended after `METHOD-ELIGIBLE`, including the
pass-local constant `minListArity`. **Framework untouched**: policy modes,
`run`/`collect`/`of`, the record shape, `Sort`, `render`, `Raise`, the stats
counter, `BOTLISH_WARNINGS` and the CLI option are byte-for-byte milestones
1-2. No frontend file changed, so the item-15 plumbing on the `nomethod` pattern
turned out to be unnecessary.

**Timing and scope.** Discovery happens in `surface::lower::Finish`, after
`hir::buildSyntax`/`hir::check` and strict diagnostics, before any backend. A
program with error diagnostics is never warned about. The pass reads the final
generic source HIR once per source function. Semantic instances live in the
`semantic` side table and are never walked. A function analyzed as three
instances gives one warning (`fa-generic-hir-once-instances-never-walked`, and
the `instances-visited` mutant).

**Record.** The same dict, `{code message primary secondary data}`:

* `primary`: the first exit's origin (a `return` node or a final-expression
  leaf), in `hir::originLocation`'s vocabulary. Module code is located in the
  module file, including inside loops and handlers (milestone 1's `RemapFile`
  fix; `fa-reach-module-code-located-in-module`).
* `secondary`: the other exits in source order, rendered as `note: also
  returned here`.
* `data`: `function` (block ExprId), `functionName`, `arity` (N), `exits`
  (count), `sites` (every exit's ExprId, source order: the `return` node, or
  the leaf), `selfCalls` (the sites among them that are self-call exits,
  possibly empty), and `note` (the note text `render` uses, as in milestone 1).
  No rendered source text and no field names.

**Message.** One template, pinned (`fa-message-text`):

```
a N-element list is returned from all K value exits; a struct value names the parts
a N-element list is returned from the only value exit; a struct value names the parts
```

It names struct values, states the shape (arity, exit count), and contains no
imperative, no rewrite, no suggested literal and no field names
(`fa-message-is-not-prescriptive` scans for `use`, `convert`, `should`, `field:`,
`{`, `->`, ...).

**Ordering.** The inherited `Sort`, by primary origin, then code, then message.
All three codes interleave by location (`fa-interleaving-three-codes` and its
other-order twin). A function whose two literal exits are the same exact list
gets both `SAME-RETURN-VALUE` and this warning at one location, ordered by code
(`fa-interleaving-same-location`).

**Policy.** Unchanged and re-pinned: `default` warns, `off` runs no pass
(`hir::warnings::stats` has no `FIXED-ARITY-LIST-RETURN` entry, and an execution
trace on the pass shows 0 calls under `off` and 1 under `default`), and `error`
raises the sort-first warning across all three codes as `{CORE SEMANTIC CODE}`
before `hir::lower`, `native::prepareHir`, `native::evalHir` or
`core::compiler::evalHir` run (traces: 0 calls). `main.tcl -backend cranelift
-warnings error` prints no value. `-Wno-fixed-arity-list-return` is an unknown
option, in process and through `main.tcl`. An unknown mode is rejected.
`BOTLISH_WARNINGS` is read fresh per compilation and the explicit option wins.
Interleaved compilations under different modes do not interact.

## Corpus findings

`audit/fixed-arity-list-return/tools/corpus.tcl`, output
`audit/fixed-arity-list-return/corpus-audit.txt`, at the **pinned commit
`faae181`** (the corpus paths clean; `faae181` was `origin/main` and this
milestone's base). It compiles `examples/stdlib` (9), `examples/surface` (14;
`09`/`10` are the deliberate rejections), `bench/*.bot` (8) and `lib/*.bot` (8).
35 of 39 compile standalone. The four that do not are the two rejections, and
`lib/list.bot` and `lib/mutable_array.bot` (which use their own namespace
without importing it, a pre-existing state that milestone 2's audit already
recorded).

**8 distinct findings** (8 functions, 8 (function, arity) patterns), all
classified by hand:

| # | where | function | shape | element types (informational) | hand classification |
|---|---|---|---|---|---|
| 1 | `examples/stdlib/csv_chunked.bot:29` | `chunked_new` | 3-element, 1 exit | heterogeneous (`List[never]`, `mutarray`, `int`) | **convert**: the ChunkedBuilder state `[completedChunks, currentChunk, filled]`; the file's own header names the three parts, and callers read them back with `list::at(builder, 0/1/2)`. STRUCTS.md already called it "a definite struct candidate" |
| 2 | `examples/stdlib/csv_chunked.bot:44` | `chunked_append` | 3-element, 2 exits | heterogeneous | **convert**: the same state |
| 3 | `examples/stdlib/ai_text_clean.bot:84` | `sample` | 6-element, 1 exit | same-element (`str`) | **annotate**: the sample's list of check results, printed as the program's value and compared with `# expect: [...]`; never read by position |
| 4 | `examples/stdlib/csv_records.bot:515` | `sample_checks` | 7-element, 1 exit | heterogeneous (`int`, `any`..., `bool`) | **annotate**: the sample's observation vector (`# expect: [2, "Alice", ...]`), consumed whole |
| 5 | `examples/stdlib/hashtable.bot:379` | `sample_checks` | 6-element, 1 exit | heterogeneous (`bool`..., `any`) | **annotate**: the same kind of observation vector |
| 6 | `examples/stdlib/string_replace.bot:49` | `sample` | 5-element, 1 exit | same-element (`str`) | **annotate** |
| 7 | `examples/stdlib/string_reverse.bot:31` | `sample` | 5-element, 1 exit | same-element (`str`) | **annotate** |
| 8 | `examples/surface/13-hygiene.bot:7` | `pair` | 2-element, 1 exit | same-element (`any`) | **annotate**: the example is about list-literal syntax itself (a parameter named `list` does not change what `[a, b]` means); its result is deliberately a list |

Totals by item 29's categories:

* multi-value results the refactor would convert (heterogeneous parts): **2**
  (csv_chunked's builder state);
* same-element fixed-arity findings, each reviewed by hand: **4** (#3, #6, #7,
  #8), all **author would annotate**, none "author would convert". The other
  two "annotate" findings (#4, #5) are heterogeneous by element type and still
  genuine lists, the case that shows why heterogeneity is not the rule;
* annotated list functions in the corpus: **0** (the audit lists them and
  verifies none warns; there are none to list at this commit);
* single-exit findings: **7** of 8;
* **false positives under item 16's bar: 0.** Every finding is one the author,
  knowing the idiom, would convert or annotate.

**The classifications were checked mechanically in scratch copies** (the corpus
was not edited). For each of the six "annotate" findings, adding `-> list` to
the declaration compiles, removes the finding, and leaves the program's value
identical. For the two "convert" findings, a curated struct conversion of
`csv_chunked.bot` (`{completed, current, filled}` and `builder.completed`
etc. for the six positional reads) compiles, removes both findings, and
produces the identical value (`[["name", "age"], ["Alice", "30"], ["Bob",
"40"]]`). That is the optional corpus-level conversion law, on the one
convertible program.

**Near misses** (silent functions with a literal exit of arity >= 2): one,
`bench/source-checks.bot`'s `classify_leading` (`return [false, false, false,
false]` beside a final collecting loop, a computed list). It is silent for the
right reason, and STRUCTS.md classifies its result as a test probe.

**The motivating functions are not in today's corpus.** `scan_quoted`,
`scan_unquoted` and `scan_record_rest` were converted to anonymous structs by
the STRUCTS.md milestone, before this one. The brief expected them among the
findings, and at `faae181` they are already silent struct functions. As a
supplementary check (not corpus), the audit extracts the historical list-form
scanners from
`audit/strict-reference-determinism/experiment/csv_records-A-callee-first.bot`.
It adds the error declarations today's compiler requires and stand-ins for the
builder helpers, and compiles them. **`scan_unquoted` (2 exits, 1 self-call),
`scan_quoted` (3 exits, 2 self-calls) and `scan_record_rest` (3 exits, 1
self-call) all warn**, anchored at their first exit. `scan_field` and
`scan_record` are silent: each returns the result of *another* list-returning
function, a helper chain that v1 does not follow. That is the one place the
coinductive extension (below) would have found more. The live corpus has no
list-returning helper chain, so per item 12 the extension stays unbuilt.

**Library findings.** None. `lib/*.bot` carries no `FIXED-ARITY-LIST-RETURN`
finding at `faae181`, so no program that imports a library prints one, and the
milestone-1/2 fuzzers' library baselines are unaffected.

## Tests

`tests/fixed-arity-list-return.test`, **149 tests**, every compile passing its
policy explicitly (149/149 on `interp`, `compile`, `cranelift-generic`,
`cranelift`; see "Full regression"):

* **Motivating shapes:** `scan_quoted` (anchor and notes exact, rendering
  exact), `scan_record_rest` (two literals and a self-call), the csv_chunked
  builder shape, a fully literal function.
* **Shape and arity:** 2 and 3 warn; the 0/1/2/3 boundary in one test; `[]` and
  1-element exits mismatch; single exit warns, single 1-element silent; mixed
  arity; element types irrelevant; computed elements; nested literals use the
  outer arity.
* **Literal-ness:** `list::append`, `str::concat`, a method-sugar construction,
  a computed-only function, an operator, a function-value call, a call of
  another list-returning function, `return if`, an `if`-valued binding, a
  collecting loop, a handled value, core-IR input, `.hir`-text input.
* **Computed/mutable/struct:** mutable value, parameter, struct, mixed
  struct/list, the converted scanner.
* **Unit (item 5):** else-less `if` (and its with-`else` control), bare
  `return`, `return unit`, final `unit`, destructuring, final binding, else-less
  `if` with a returning branch, elif with and without `else`, the decided-away
  fall-through, the milestone-1 contrast, a non-final else-less `if`.
* **`fail`:** guard warns, final `fail`, all-`fail`, `fail` in a branch, a
  never-completing exit.
* **Aliases (item 11):** initializer literal, chain, beside a literal (same and
  other arity), alias of computed/parameter/mutable, top-level binding,
  same-scope rebinding (`DUPLICATE`, never warned), branch shadow (other and
  same arity), the binding statement is not an exit.
* **Self-recursion:** counted and inherited (`selfCalls` data), all-self-call,
  aliased, method-sugar, indirect via nested helper, mutual pair, higher-order,
  nested function's own recursion, a nested function calling the enclosing one,
  termination.
* **Annotation (item 15):** silences (with the unannotated control), bare
  `list`, `List[str]`/`List[List[int]]`, `-> any` warns, struct annotation is a
  checker error, the annotation decides (trace: exits never examined), nested,
  module import, the existing `declaredResult` in every mode, format/parse round
  trip, no other opt-out.
* **Reachability:** dead branch, code after return, range-pruned exit enabling
  the warning, feasible control, range-pruned unit, range-pruned only literal,
  the walk only for candidates (trace), loops, on-handler return, module
  location.
* **Structure:** nested functions and closures own their exits, boolean
  operators never opened, operators never literal, record shape, data fields,
  secondary = other exits, message text, not prescriptive, no rendered source in
  data, one warning per function, source order, determinism, instances never
  walked.
* **Policy matrix:** three-code interleaving (both orders, and the same
  location), determinism, default/off/error (only this code; the sort-first of
  three), clean program, default-is-default, `BOTLISH_WARNINGS`, unknown mode,
  no `-Wfoo`, the registry is three static lines, promoted identity, stats and
  trace off-pins, error diagnostics never warned, per-compilation interleaving,
  `of` equals `collect`, `error` before all four lowering entry points.
* **No semantics change:** HIR/format/lower, NIR (specialized and generic),
  report/NIR/CLIF with and without the side table, no warning text in any
  machine-readable output, the annotation changes nothing else.
* **Backends:** four backends in process (on and off).
* **The conversion's checker as it is:** field reads checked, converted reads
  compile, leftover via a source function is `TYPE`, leftover `list::at` is a
  run-time kind error (GAP), leftover `==` is silently `false` (GAP).
* **CLI:** modes, `-Wno-fixed-arity-list-return`, unknown mode, stdout/stderr
  separation, `-backend cranelift -warnings error` prints no value, identical
  warning text (with notes) on all four backends over `examples/stdlib`.
* **Fuzz smoke:** 60 seeds.

## Fuzzing

`audit/fixed-arity-list-return/tools/fuzz.tcl SEEDS FIRST`
(`audit/fixed-arity-list-return/fuzz-result.txt`; `-show SEED` prints one
generated program, its prediction and its conversion). Each seed generates one
to three functions `g0..g2(x, a, b)` from construction-known pieces:

* exits: written literals of 0-3 elements (elements from a pool of unknown and
  known values of mixed types), alias bindings and alias chains, self-calls (a
  base guard first, so runs terminate) and aliased self-calls, computed lists (a
  method-sugar `append`), calls of a list-returning helper, struct values,
  parameters, bare `return`, `return unit`, final `unit`, final destructuring,
  a final binding, else-less final `if`s;
* non-exits: `fail` guards and finals, dead branches (`if 1 == 2`),
  range-unreachable branches (`if x < 0:` / `if x > 5:`) holding a matching or
  mismatching exit, nested functions with their own (predicted) warnings;
* `-> list` on functions whose exits are all list-typed (always silent),
  `-> any` (no effect), and self-call-only functions (one variant hiding its
  only literal behind a range-unreachable branch).

About a third of the programs contain only silent functions. Every call that
would otherwise be `METHOD-ELIGIBLE` is written with method syntax, so the only
other code that can appear is `SAME-RETURN-VALUE`. Over the 2000 seeds: 4003
generated functions; 393 programs with guarded self-calls and 412 with final
self-calls, 173 aliased self-calls, 464 alias bindings (202 chains), 734
range-unreachable and 628 dead branches, 819 `fail`s, 614 nested functions,
480 `-> list`, 457 `-> any`, 314 self-call-only functions, 517 one-element
literals, 312 struct exits, 327 helper calls, 232 computed lists, 232 bare
returns, 295 `return unit`, 84 final destructurings and 66 final bindings.

The oracle is independent of the compiler. From construction it knows each
function's value exits (dead and range-unreachable ones are not exits) and
applies the theorem: warn or silent, and for a warning the anchor
(line:column of the first exit) and the note lines. Each program is compiled
under all three modes:

* `default`: the warnings must be exactly the predicted functions with the
  predicted anchor and notes. A missed or mislocated one fails. An extra one is
  printed as `EXTRA`, counted, and must be 0 in the summary. A function reported
  twice fails.
* `off`: compiles silently, no pass ran (stats counter and an execution trace),
  and the HIR equals default's without the side table.
* `error`: rejected iff default warned, with the sort-first warning's code (so
  `{CORE SEMANTIC FIXED-ARITY-LIST-RETURN}` whenever that is a predicted
  warning), and always rejected when a warning is predicted. Item 27's "iff a
  warning is predicted" is generalized this way because a program can also
  carry `SAME-RETURN-VALUE`.

**The conversion law (the weakened analogue of milestone 2's round-trip law),
in exact terms.** There is no exact round trip: converting changes types at
call sites and shrinks the error surface (`list::at` is fallible, `r.pk` is
total). For every program with a predicted warning, the converted program is
built from the same construction:

1. every predicted function's literal exits `[e0, ..., eN-1]`, and every alias
   initializer an exit reads, become `{p0: e0, ..., pN-1: eN-1}`. Self-calls are
   unchanged. A **range-unreachable** exit of the function is conformed to the
   same N-field struct, because the type checker still joins it (dead `if 1 ==
   2` branches are not typed and stay). `-> any` is dropped, because a
   projection is resolved statically and never on `any`;
2. each generated caller of a predicted function reads its result positionally
   (`r.at(0)` and `r.at(N - 1)`, constant indexes below N). Those reads become
   `r.p0` and `r.p(N-1)`;
3. the law: the converted program **compiles with no diagnostic and no
   `FIXED-ARITY-LIST-RETURN` warning**, and running it on the interpreter gives
   the **same value** as the original for every driver call (each caller is run
   for x in `[0, 1, 2, 3, 4, 7]`, collecting values, failures included as their
   handler values). The exception is a run in which the original raised
   `IndexNotFound`, an out-of-range positional read. A converted program may
   legally complete there, because `r.pk` cannot fail. Every generated read has
   a constant index below N, so this excluded set is empty by construction. It
   is still counted, and the summary pins it at 0.

A conversion that does not compile, leaves a warning, or changes a value is a
fuzzer failure.

**2000 seeds (1341 with warnings, 659 without): 0 failures, 0 extra warnings,
1341 of 1341 conversions hold, 0 excluded runs.** The suite runs 60
(`fa-fuzz-smoke`). The generator's first versions had two bugs of its own, both
caught by the compiler rather than the oracle: constant driver arguments made
some calls statically-known failures (which Botlish rejects even when handled),
and a twice-chosen aliased self-call duplicated its binding. Neither involved
the warning.

## Mutation testing

`audit/fixed-arity-list-return/tools/mutate.tcl ?SEEDS? ?PATTERN?`
(`audit/fixed-arity-list-return/mutation-result.txt`) breaks the pass one line
at a time in a scratch copy of the tree. It runs the fuzzer (40 seeds), then
`tests/fixed-arity-list-return.test` for any mutant the fuzzer does not kill.

| mutant (one line) | required | killed by |
|---|---|---|
| unit exit treated as skip (`return ""` -> `continue` in the unit arm) | yes | fuzz: 14 extra warnings (optionals reported as tuples), 7 failures |
| alias exits ignored (`InitializerArity` result dropped) | yes | fuzz: 6 failures (missed predictions) |
| self-call ignored (`return self` -> `return other`) | yes | fuzz: 5 failures (misses `scan_quoted`'s shape) |
| all-self-call warned | yes | fuzz: 5 extras, 1 failure |
| arity 1 allowed (`minListArity 1`) | yes | fuzz: 19 extras, 4 failures |
| non-`list` written forms accepted as literal | yes | fuzz: 7 extras, 5 failures |
| annotation not respected | yes | fuzz: 5 extras, 3 failures |
| reachability ignored (walk pruning removed) | yes | fuzz: 7 failures, 5 extras |
| instances visited (one warning per semantic instance) | yes | fuzz: 17 failures (functions reported more than once) |
| fall-through not enumerated | extra | fuzz: 9 extras, 5 failures |
| self alias not followed (plain binding comparison) | extra | fuzz: 4 failures |
| mixed arity accepted | extra | fuzz: 1 extra, 1 failure (an earlier generator left it to the unit tests: 4 failing) |

**12 of 12 mutants killed, all 12 by the fuzzer.** Two design notes came from
this step. The arity bound originally lived in two lines (the candidate gate
and the uniformity check), which made a one-line "arity 1 allowed" mutant
equivalent. It is now one constant. And the first run killed `mixed-arity-
accepted` only with the unit tests, which led to more frequent mixed arity in
the generator.

## Parallel work: coordination, and the breakage this milestone causes

This milestone wrote the pass, the registry line,
`tests/fixed-arity-list-return.test`, `audit/fixed-arity-list-return/`,
MULTI-VALUE-RESULTS.md, this report, the README's warnings section, and a
paragraph in AGENTS.md's "Compiler warnings" (what to re-run when changing the
facts this warning reads).
It also adapted 8 tests in two existing test files (below). **No corpus file
(`examples/`, `bench/`, `lib/`) was edited.** The annotation needed no recording,
so no frontend file changed either.

**The breakage, and its adaptation in this milestone.** Adding a third code
breaks 8 existing tests. Each is a pin that listed the registry's codes, or
asserted a complete warning set (often "no warning at all"), over a program that
really has the fixed shape:

| file | test | why it fails with the pass | the finding is | adaptation |
|---|---|---|---|---|
| `tests/warnings.test` | `warn-off-runs-no-warning-pass` | the stats pin lists the codes, and a third exists | -- | the third code added to the expected stats |
| `tests/warnings.test` | `warn-exact-list` | complete set; `f` returns `[1, 2]` from both exits | true (2 exits) | `shown` -> `sameReturnShown` |
| `tests/warnings.test` | `warn-lists-with-unknown-elements-not-same` | asserts no warning at all; `f` returns `[y, 1]` twice | true | `codes` -> `sameReturnCodes` |
| `tests/warnings.test` | `warn-same-binding`, `warn-alias-of-binding` | complete set; the helper `compute(a): [a, a + 1]` | true (single exit) | `shown` -> `sameReturnShown` |
| `tests/warnings.test` | `warn-different-bindings-not-same` | asserts no warning; the same helper | true (single exit) | `codes` -> `sameReturnCodes` |
| `tests/method-eligible.test` | `me-off-runs-no-warning-pass` | the same stats pin | -- | the third code added |
| `tests/method-eligible.test` | `me-list-literal-never-eligible` | asserts no warning at all; `fn t(a, b): [a, b]` | true (single exit) | only `METHOD-ELIGIBLE` codes counted |

The brief assigned these to the parallel agent ("expected breakage you must
report but not fix"), and the first version of this milestone, including its
first merge to `main`, left them failing. That split was wrong for these 8. They
are not failures default-on warnings induce in the corpus, which is the
parallel agent's work. They are consequences of adding this code, and they exist
only on a tree that already has the pass, so an agent working without it would
never see them. Leaving them made `main` red. They were therefore adapted here,
as milestone 2 adapted milestone 1's tests (WARNINGS-METHOD-ELIGIBLE.md,
"Deviations from the brief"): `sameReturnShown`/`sameReturnCodes` are the
file's existing code filters (their comment now names this warning too), and the
stats pins gained the third code. No pin was weakened: each still asserts the
complete set of its own warning code. `tests/warnings.test` passes 81/81 and
`tests/method-eligible.test` 145/145 on all four backends. **Not affected:**
complete-set tests over programs that import a library (no `lib/*.bot` finding
exists), the milestone-1 fuzzer's library baseline and the milestone-2 fuzzer
(their generated programs return no list literal; both smoke runs pass in the
regression), and `tests/flags.test`'s `-warnings error` test.

**Pinned commit, and the tree moving.** The corpus audit ran at `faae181`,
which was `origin/main` and this milestone's base. The parallel agent's commits
already on `main` there (bench scripts passing `-warnings off`, a test-file
cleanup) do not touch the audited sources. **During the milestone `origin/main`
moved to `ffbd610`.** It gained the contexts milestone (`context struct`, `with
context`, context parameters: new HIR constructs, parser, native lowering), an
AGENTS.md section on concurrent test runs, and a scalar-asm corpus
regeneration. None of these is the parallel agent's warning fixes. The branch
merged it (`6b5e7a8`, no conflicts) and everything was re-run on the merged
tree:

* the corpus audit on the merged tree (this pass, `origin/main`'s corpus: the
  audited paths are byte-identical to `ffbd610`) is **identical to the
  `faae181` audit** apart from its commit header. Same 8 findings, same
  classifications, same scratch checks. The two snapshots agree. The contexts
  milestone added `examples/linux/context-hello.bot` and `lib/linux/io.bot`,
  outside the audit's corpus definition. They carry **no** finding
  (`context-hello.bot` compiles with `io.bot`, 0 warnings; `io.bot` does not
  compile standalone, `CONTEXT-FUNCTION-VALUE`);
* `tests/fixed-arity-list-return.test` 149/149 on all four backends;
  `tests/warnings.test` 75/81 and `tests/method-eligible.test` 143/145 (the same
  8); `tests/contexts.test` with warnings **on** (`BOTLISH_WARNINGS=default`)
  74/74 with no finding, so the pass handles the new constructs;
* the full regression on the merged tree (below).

## Full regression

All runs are on the committed pass (`aa96155`, which is this milestone's code,
tests and tools on top of the pinned `faae181`). `tests/all.tcl` ran on both Tcl
backends with the harness default policy (`BOTLISH_WARNINGS=off`), each
backend in its own git worktree, in parallel. The suite had **5808 tests before
this milestone**: 5957 minus the 149 new ones, since no other test file changed.

* **`interp`: 5957 tests, 5949 passed, 8 failed. `compile`: 5957 tests, 5945
  passed, 4 skipped (the existing `coreScoping` constraint), 8 failed.** The 8
  failures are the same on both backends and are exactly the breakage listed
  under "Parallel work": 6 in `tests/warnings.test` (`warn-off-runs-no-
  warning-pass`, `warn-exact-list`, `warn-lists-with-unknown-elements-not-
  same`, `warn-same-binding`, `warn-alias-of-binding`, `warn-different-
  bindings-not-same`) and 2 in `tests/method-eligible.test` (`me-off-runs-no-
  warning-pass`, `me-list-literal-never-eligible`). Each is a stats pin or a
  complete-set pin over a program that really has the fixed shape. They were
  left failing at first and then adapted in this milestone (below and "Parallel
  work"). **No other test of the 5808 failed.**
* `tests/fixed-arity-list-return.test`: **149/149 on each of `interp`,
  `compile`, `cranelift-generic` and `cranelift`.**
* `tests/warnings.test` 75/81 and `tests/method-eligible.test` 143/145 on both
  Tcl backends before the adaptation (the failures above), and **81/81 and
  145/145 after it on each of `interp`, `compile`, `cranelift-generic` and
  `cranelift`**. Their fuzz smoke tests (`warn-fuzz-smoke`,
  `me-fuzz-smoke`) pass. The milestone-1 and milestone-2 fuzzers also pass 300
  seeds each on the committed tree (`same-return-value`: 197 with warnings, 103
  without, 0 failures, 0 extra groups; `method-eligible`: 211/89, 0 failures, 0
  extras, 1518 of 1518 round trips).
* `tests/native-coverage.tcl` (the suite on `cranelift`, as CI's native job):
  5957 tests: 2440 native, 3379 independent of the backend, 70
  passed-partial, 60 unsupported (the constructs it already classifies, the
  same 60 as milestone 2), and **8 "failed"**. The tool's heading calls these
  "native backend bugs", which is only its label for any failure. They are
  exactly the same 8 expected warning-pin failures, and none involves native
  code.
* CI's plain native example step (`main.tcl -backend cranelift` over
  `examples/stdlib`, `examples/surface/0[1-8]`, `1[1-3]` and
  `examples/hir/0[1-3]`) exits 0. Stderr has 314 lines of warnings: 8
  `FIXED-ARITY-LIST-RETURN` (the 7 stdlib findings and `13-hygiene`'s), 301
  `METHOD-ELIGIBLE`, 2 `SAME-RETURN-VALUE`, and their notes. Stdout carries
  none of it.
* This milestone's fuzzer passes 2000 seeds, and the mutation tool kills 12/12,
  both on the committed tree (above). The corpus audit is the committed
  `corpus-audit.txt`.
* **Second snapshot: the tree merged with `origin/main` `ffbd610`** (`bcf18ae`,
  the contexts milestone in; see "Parallel work"), native backend rebuilt
  first, each run in its own worktree: **`interp` 6030 tests, 6022 passed, 8
  failed; `compile` 6030, 6018 passed, 4 skipped, 8 failed; native coverage
  6030 tests (2470 native, 3421 independent, 71 passed-partial, 60
  unsupported) with the same 8 failed.** The failures are the same 8 named
  above, and nothing else failed. The fuzzer passes 300 seeds on the merged tree
  (204/96, 0 failures, 0 extras, 204/204 conversions). The later commit
  `c612319` only renames the CLI tests' scratch files to pid-unique names
  (AGENTS.md's new rule on concurrent runs). Its 6 CLI tests pass.
* **After the adaptation**, on `main` at `c2ce620`, which also includes
  `origin/main`'s later work keeping test scratch files out of the checkout:
  **`interp` 6030 tests, 6030 passed, 0 failed; `compile` 6030 tests, 6026
  passed, 4 skipped (the existing constraint), 0 failed; native coverage 6030
  tests (2470 native, 3429 independent, 71 passed-partial, 60 unsupported),
  0 failed.** These were run in one checkout, each with a private `-tmpdir`, as
  AGENTS.md now describes. The two adapted files also pass on
  `cranelift-generic`.
* The GC-stress job (`BOTLISH_NATIVE_GC_STRESS=1`, CI on push to `main`) was not
  run locally: nothing under `native/` changed, and the pass runs before any
  backend and changes no HIR.

## Known limitations

* **Helper chains are not followed.** A function that returns the result of
  *another* list-returning function (the historical `scan_field`) is silent.
  This is v1's syntactic self-recursion only. The corpus at `faae181` has no
  such chain.
* **`if`-valued and loop-valued returns are not opened.** `return if c: [a, b]
  else: [b, a]` and `r = if ...; r` are silent (the value is an `if`), as is a
  handled call's value.
* **A fall-through that only range facts exclude still silences.** The
  completion walk records expressions, and a missing `else` has none. An
  else-less final `if` whose `else` outcome is excluded only by range facts
  (not by HIR's decided outcome) keeps its unit exit. This is a missed warning,
  never a wrong one.
* **Interprocedural unreachability is not used.** A structurally reachable
  function nobody calls still warns.
* **The conversion's safety net has holes** (item 16): a leftover `list::at` on a
  converted result fails at run time rather than at compile time, and a
  leftover `==` against a list is silently `false`.
* **A pruning-enabled finding needs its dead exit handled on conversion**,
  because the type checker joins range-unreachable exits.
* **Single-exit findings dominate** (7 of 8 in the corpus): a function that
  builds and returns one list literal is reported. This is by design (item 14),
  and the annotation answers the genuine-list cases.
* Only the first warning is raised under `error`, as in milestones 1-2.

## Future warning candidates

`FIXED-ARITY-LIST-RETURN` moves from proposal to implemented. Still future,
only for warnings that state a provable fact in this framework:

* `SAME-FAILURE`: the same declared failure from several exits (one registry
  line and a pass);
* a condition that repeats an already established proof;
* manual iteration whose cardinality duplicates another domain (lockstep
  candidates);
* a possible extension of *this* warning, not a new code: the coinductive
  generalization from self-calls to helper chains (a call-graph worklist).
  Build it only if a corpus audit shows helper chains matter. The historical
  scanners show where it would apply; today's corpus has none.

Not planned: per-warning flags, warning groups or levels, call-site
suppression, any author opt-out beyond the result type, a warn-only modifier,
automatic rewriting or field-name suggestion, element-type or heterogeneity
analysis, and a reverse warning (struct results suggested as lists).

The deferred corpus refactor consumes this warning. Its two findings to convert
are csv_chunked's builder state (the curated conversion in the audit tool is a
ready patch), and its six findings to annotate take `-> list`.

## Deviations from the brief

* **The conversion's checker is weaker than item 16 says.** The brief states
  that "positional `list::at(r, k)` call sites become type errors". In Botlish
  as it is, they do not: native argument kinds are checked at run time, even
  with `-strict 1`, so `list::at(convertedStruct, 1)` compiles and fails at run
  time. Leftover reads through source functions are compile-time errors, field
  reads are checked statically, and `==` against a list is silently `false`.
  This report and the tests state the checker as it is.
* **The motivating functions are not corpus findings.** `scan_quoted` and
  `scan_record_rest` were already converted to structs (STRUCTS.md). They are
  demonstrated on the historical list-form source as a supplementary check.
* **No annotation recording was added.** Item 15 anticipated it might be
  needed. The checker's own `declaredResult` is the written annotation, so the
  milestone has no non-pass code at all.
* **Spellings.** The brief's `-> list[int]` is `-> List[int]` in Botlish (applied
  types are capitalized; bare `list` is `List[any]`). `-> List[int]` needs
  parameters typed so the checker can prove the result.
* **Mutual recursion** is pinned in the forms Botlish can express (nested
  functions, function values); top-level mutual recursion is a compile error.
* **The fuzzer's `error` check** is "rejected iff any warning, with the
  sort-first code", because generated programs can also carry
  `SAME-RETURN-VALUE`. A predicted `FIXED-ARITY-LIST-RETURN` warning always
  rejects.
* **`data` also carries `note`** (the note text `render` reads), as milestone 1's
  record did.
* **Ownership of the 8 breaking pins (reversed).** The brief gave the
  `tests/warnings.test` stats pin, and by extension the other complete-set
  pins, to the parallel agent, and asked for no existing test file to be
  edited. The 8 pins were left failing at first, including on the first merge
  to `main`. They were then adapted in this milestone, test-only, because only
  this milestone creates them (see "Parallel work"). Acceptance condition 15
  ("existing tests ... untouched by this milestone") therefore does not hold
  for these two files. It still holds for every other test file and for the
  whole corpus.
* **Branch.** `AGENTS.md` says to push finished work to `main`. This session was
  assigned a development branch and told not to push elsewhere without
  permission, so the work was pushed to that branch first. It was merged into
  `main` (a fast-forward) when asked to.

## Required questions

**Warning framework**

1. *Enabled by default?* Yes.
2. *All warnings disableable globally?* Yes: `-warnings off`.
3. *All warnings promotable globally?* Yes: `-warnings error`.
4. *Per-warning `-Wfoo`/`-Wno-foo`?* No (`-Wno-fixed-arity-list-return` is an
   unknown option, in process and through `main.tcl`).
5. *Warning groups?* No.
6. *Codes stable?* Yes: `FIXED-ARITY-LIST-RETURN`.
7. *Policy per compilation?* Yes (interleaved compilations pinned).
8. *Does `off` skip the pass?* Yes: no stats entry; a trace shows 0 calls under
   `off` and 1 under `default`.
9. *Does `error` preserve the code?* Yes:
   `{CORE SEMANTIC FIXED-ARITY-LIST-RETURN}`.
10. *Backend-independent?* Yes: all four backends, in process and through the
    CLI (identical warning text, notes included, over `examples/stdlib`).

**`FIXED-ARITY-LIST-RETURN`**

11. *Meaning?* Every reachable value exit of one function is a written list
    literal of the same arity N >= 2. Self-calls inherit N, aliases resolve to
    their initializer literals, and at least one literal exit is required.
12. *Source-text matching?* No: the frontend's written-form provenance.
13. *Reuses existing machinery?* Yes: milestone-1 exits (`Exits`, `Leaves`) and
    the completion walk, milestone-2 provenance, `hir::exact::AliasRoot`,
    `hir::resolve::CandidateIdentity`, `hir::types::KnownOutcome`, the block's
    `declaredResult`, HIR reachability, the framework.
14. *Computed lists?* Never.
15. *Unit exit?* A mismatch, so silence (the documented deviation).
16. *`fail` guards?* Do not block.
17. *Self-call exit?* Counts, inherits N, contributes no N; all-self-call is
    silent.
18. *Indirect/mutual recursion?* Silent (no worklist in v1).
19. *Alias-of-literal exit?* Counts. Rebinding is shadowing (a same-scope
    rebinding is the `DUPLICATE` error), so each binding has one initializer.
20. *Mixed arity?* Silent.
21. *Struct exit / mixed struct+list?* Silent.
22. *One-element lists?* Never.
23. *Single-exit functions?* Warn (unlike `SAME-RETURN-VALUE`'s two-exit
    threshold).
24. *Heterogeneity required?* No (rejected; the annotation covers genuine
    lists).
25. *`-> List[T]` annotation?* Silences (`-> list` too). A non-list
    annotation (`-> any`) does not.
26. *Prescribes conversion or suggests field names?* No.
27. *Unreachable exits?* Ignored: structural reachability plus the
    candidate-gated completion walk, with the restated soundness argument.

**Architecture**

28. *Stage?* `surface::lower::Finish`, unchanged.
29. *Which analyses supply the proof?* Milestone-1 exit enumeration and
    completion walk, milestone-2 written provenance, binding/alias identity,
    the resolver's candidate identity, the checker's `declaredResult`, HIR
    reachability, the framework.
30. *Annotation/provenance representation and mode-independence?* Both are
    existing fields recorded in every mode: `written {form list ns NS}` on the
    call (milestone 2) and `declaredResult` on the block (the resolver). HIR is
    identical under `off` and `default` (pinned).
31. *Record shape and secondary locations?* `{code message primary secondary
    data}`. `secondary` is the other exits, rendered as `note: also returned
    here`.
32. *Deterministic ordering, including three-code interleaving?* The inherited
    `Sort`: primary origin, then code, then message. Pinned in both orders and
    at one shared location.
33. *Duplicates across instances?* None: the generic source HIR is read once and
    instances are never walked (pinned, and killed as a mutant).
34. *Framework changes beyond the registry line?* None. No frontend plumbing
    was needed either: the annotation is the checker's existing
    `declaredResult`.
35. *Do the warning or its recordings affect HIR/NIR/optimization/runtime?* No
    (pinned across modes; nothing under `native/` changed; nothing new is
    recorded).
36. *Does `error` reject before backend lowering?* Yes (traces on all four
    entry points; a cranelift CLI run prints no value).
37. *Structurally collectable?* Yes: `hir::warnings::of` / `collect`.
38. *Conversion law at which levels?* The fuzzer (required): 1341 of 1341. The
    corpus (optional): the one convertible program, csv_chunked, converts with
    an identical value. The unit tests also pin the checker's behaviour on
    converted call sites, gaps included.

**Verification**

39. *Corpus findings: how many, which categories, at which commit?* 8 at
    `faae181`, and identically 8 on the tree merged with `origin/main`
    `ffbd610`: 2 convert (heterogeneous builder state) and 6 annotate (4
    same-element, all hand-reviewed as annotate; 2 heterogeneous genuine lists).
    7 are single-exit, and 0 annotated list functions exist.
40. *False positives under the convert-or-annotate bar?* Zero.
41. *Warning-mode tests pass?* Yes. `tests/fixed-arity-list-return.test` 149/149,
    `tests/warnings.test` 81/81 and `tests/method-eligible.test` 145/145, each on
    the four backends. The last two include the 8 adapted pins (stats pins and
    complete-set pins over true findings) listed under "Parallel work".
42. *Fuzzer and mutation results?* 2000 seeds, 1341 with warnings and 659
    without: 0 failures, 0 extras, 1341/1341 conversions, 0 excluded runs.
    12 of 12 mutants killed, all by the fuzzer.
43. *Backend parity?* Identical warning sets on all four backends (pinned).
44. *Full regression?* The new file passes 100% (149/149 on all four
    backends). `tests/all.tcl` on `interp` and `compile` ran 5957 tests (5808
    before this milestone), and native coverage ran the same suite on
    `cranelift`. On the tree merged with `origin/main` `ffbd610`, each ran 6030
    tests. Every run failed exactly the 8 pins listed under "Parallel work"
    (6 in `tests/warnings.test`, 2 in `tests/method-eligible.test`) and nothing
    else. Those 8 were then adapted in this milestone. On `main` at `c2ce620`
    the suite has **0 failures**: 6030 tests on `interp`, 6030 on `compile`
    (4 skipped), and 6030 in native coverage.
