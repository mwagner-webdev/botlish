# `elif`

A small syntax milestone: the direct spelling of a chain of conditions.

```
if a:
    first
elif b:
    second
elif c:
    third
else:
    fourth
```

`elif` is **surface syntax for `else:` holding one nested `if`**, under the
existing conditional semantics. It adds no conditional abstraction to the
compiler: nothing after the parser knows `elif` exists.

## Syntax

```
if-expression =
    "if" CONDITION ":" SUITE
    { "elif" CONDITION ":" SUITE }
    [ "else" ":" SUITE ]
```

* Any number of `elif` clauses, including none. The final `else` is optional.
* An `if` chain is a value exactly where an `if` is: the right side of `=` and
  the value of `return` (and a statement).
* `elif` is a reserved word (a lexer keyword, like `else`). It can no longer
  name a binding or a function. A grep of the repository found no source
  program using it as a name.
* An `elif` or `else` belongs to the open `if` at the same indentation. The
  suite of an inner `if` ends at its dedent before the next clause keyword is
  looked at, so there is one ownership rule and no dangling-else ambiguity.
* An `else` ends the chain.

Rejected, with a diagnostic at the offending token:

| Source | Diagnostic |
|---|---|
| `elif x:` with no `if` (also after any other statement, first in a suite, or indented deeper than its `if`) | `"elif" without a matching "if"` |
| `elif` after `else` | `"elif" after "else": an "else" ends the if chain` |
| a second `else` | `"else" without a matching "if"` (the existing diagnostic, unchanged) |
| `elif:` | `expected an expression, found ":"` |
| `elif b` | `expected ":" after the "elif" condition, found end of line` |
| `elif b:` with no block | `expected an indented block, found ...` |
| `else if b:` | `expected ":" after "else", found "if"` (unchanged) |

## Parser changes (`surface/`)

* `lexer.tcl`: `elif` joins the keyword list; the "line that starts like a
  statement closes unclosed brackets" heuristic (`UnclosedBefore`) treats it
  like `else`. Nothing else in the lexer changed.
* `parser.tcl`: `If` collects `if`/`elif` clauses in a loop (no recursion per
  clause) and an optional `else`, then folds them from the last clause to the
  first. `Statement` rejects a leading `elif`. The `after` text of a clause's
  missing-colon message names its own keyword (`the "elif" condition`), the
  same message shape `if` has. No new diagnostic style.

## Surface representation

No new node kind. The parser builds each `elif` clause as an ordinary `if`
node standing alone in a synthetic `suite` that is the previous clause's `else`:

```
if a: A elif b: B else: C
 =  if(a, A, else: suite[ if(b, B, else: C) ])
```

Both the clause's `if` node and the synthetic suite carry an extra `elif 1`
field. It is read only by `surface::formatAst` (the surface printer), which
prints the shape back as `elif` rather than as a visibly nested `else:`/`if`.
A written `else:` containing an `if` has no marker and still prints nested.
Everything else that walks the AST (ids, children, lowering, module remapping)
is unchanged. Node ids nest like the written equivalent: `if/else/if/...`.

## Normalization

`surface/lower.tcl` did not change. The nested shape lowers through the
existing `if` rule, so the HIR is `If(a, A, If(b, B, C))` -- the same HIR
nodes, scopes and `elseBody`s as the nested spelling.

* **Evaluation order and once-only.** Each condition is a single HIR node
  evaluated by the single existing `if`; the later conditions live in the else
  branch, so they run only if every earlier one was false.
* **Scope, completions, typing, branch joins, analyses.** Identical to the
  nested spelling, because the HIR is identical.
* **No final `else`.** The last clause's missing `else` is the empty branch
  (value `unit`) the existing lowering already gives an `if` without `else`.

## Source locations

Normalization keeps clause-level locations:

* the clause's `if` node origin spans its `elif` keyword through the end of the
  chain, and so does the synthetic else suite of the previous clause (which is
  therefore the origin of that `if`'s `elseScope`);
* its condition and its own suite keep their own spans (`elif b:` -> the origin
  of `b` is the position of `b`, the clause's `thenScope` is the first body
  line);
* for a last `elif` without `else`, the empty else scope is the zero-width end
  of the chain, as for a plain `if`.

A static error in an `elif` condition or branch is therefore reported at that
condition or branch (`t.bot:6:6: unbound name "missing"`), not at the original
`if`.

## Backend impact

None.

* interpreter / Tcl compiler: they receive the same HIR (and Core IR) as the
  nested spelling. There is no `elif` evaluator.
* native: `native/` is unchanged. The NIR of an `elif` program is
  **byte-identical** to the NIR of the nested program, specialized and generic
  (compared as text; the NIR carries no source locations). The Tcl compiler's
  generated code is likewise the same, since its input HIR is the same.

## Formatting

The repository has no surface-source formatter. The surface AST printer
(`surface::formatAst`, used by `main.tcl -ast` and the parser tests) prints an
`elif` chain as `if` / `elif` / `else`. The semantic printer (`hir::format`,
`main.tcl -hir`) intentionally prints the normalized nested form.

## Tests

* `tests/surface-lexer.test`: `elif` is a keyword and not a prefix match.
* `tests/surface-parser.test`: AST shape of a single `elif`, multiple, no
  `else`, with `else`, value position, nested chains and ownership (inner
  `elif`/`else`, outer `elif`/`else`, `elif` branch containing an `if`, chain
  inside `else`), a 200-clause chain, spans and ids, the AST markers, 20
  diagnostics (no `if`, after `else`, duplicate `else`, missing condition /
  colon / suite, keyword misuse, indentation) and error recovery.
* `tests/surface-lowering.test`: lowering rules; HIR, `hir::format`, core IR
  and diagnostics equal to the nested spelling for eight program shapes;
  clause origins; node ids; error locations.
* `tests/elif.test` (45 tests, run on interp and compile, and on the native
  backends inside the tests): branch selection; multiple clauses; no `else`;
  a 100-clause chain; expression position; evaluation order and
  once-only (an in-language log, see below); ownership; scope; `return`,
  `fail`, propagation, unhandled errors, `continue`, `break`; Int, String,
  List, Struct, unit, mixed and error-capable branch values; static error
  locations; the reserved word; equal analyses (types, specialization, range,
  escape, cardinality, AOT readiness) and equal NIR for four program shapes;
  standalone executables; a fuzz smoke test.

Every behavioral program is run on interp, compile, native generic and native
specialized, for both the `elif` and the nested spelling, and the outcomes
(value, error, and the evaluation log) are required to be identical across all
eight runs. The standalone-executable test builds both spellings and compares
the executables' printed value with the in-process value.

Evaluation order is observed with a one-slot `MutableArray` read as a decimal
number: each probe appends its digit, so the number records which conditions and
bodies ran and in what order, on every backend (the `test-log` natives of
`tests/helpers.tcl` can be neither named from source nor run natively).

## Fuzzing

`audit/elif/tools/fuzz.tcl` generates one random tree per seed and prints it
twice, once with `elif` and once explicitly nested, then compares them (and the
backends with each other) on interp, compile, native generic and native
specialized. Random: chain length 1-6 with or without `else`; conditions
(Boolean parameters, comparisons, `not`/`and`/`or`, constants, the loop
counter, evaluation probes); branch bodies (literals, arithmetic, effect
probes, nested chains in statement/bound/returned position, `return`, `fail`
with a handler, `continue`, `break`); nesting to three levels; plain and loop
contexts.

    tclsh9.0 audit/elif/tools/fuzz.tcl -n 500 -seed 1000

RESULTS_PLACEHOLDER

A mutation check (a parser that drops one clause's `else`) was caught by 19 of
30 programs and several tests, so the harness does detect real differences.
`tests/elif.test` runs a 12-program smoke of it.

## Known limitations

* A chain's length is bounded only by the recursion depth of the later
  passes, which see nested `if`s. At Tcl's default recursion limit that is a
  few hundred clauses (300 clauses work; 400 hit `too many nested
  evaluations` in id assignment); an equivalent chain written as nested `if`s
  hits it sooner (the parser recurses through the nested suites). Raising
  `interp recursionlimit` moves the limit up, then the HIR passes become the
  bottleneck (a 1000-clause chain exhausted memory). These are properties of
  deeply nested `if`s, not of `elif`, and are unchanged here.
* A syntax error in the header of any clause drops the whole `if` chain under
  `-recover`, and the clauses after it are reported as stray `elif`/`else`
  (the same cascade a malformed `if` header already produced).
* `elif` is reserved: a program using it as a name stops parsing. The corpus
  and examples contain no such use.
* Not done, by design: no flattening/redundancy warnings, no branch layout or
  jump-threading, no new truthiness, typing or analysis rules, no corpus
  refactor.

## Answers

ANSWERS_PLACEHOLDER
