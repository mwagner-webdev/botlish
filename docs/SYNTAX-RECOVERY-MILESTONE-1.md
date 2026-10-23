# SYNTAX-RECOVERY-MILESTONE-1.md

Syntax-error-tolerant semantic analysis: a program with syntax errors is
analyzed past them, and invalid syntax invalidates only the knowledge that
depends on it.

> The desired outcome is a compiler that can reason about the valid parts of
> an incomplete program, not a compiler that quietly accepts incomplete
> programs.

Before this milestone a syntax error anywhere in a program -- the entry or
any module it imports -- left the compiler service a revision with no HIR:
`main.tcl -check` reported the syntax errors and nothing else, and the
language server answered every query from the last analysis of a version
that parsed, marked stale, or not at all. Now the front end turns each
malformed statement into a *hole* -- source with no value, no type and no
meaning, which binds, declares or installs only what its first tokens
establish -- builds one HIR of the whole program, and lets the existing
analyses run on it, with the uncertainty carried by the semantic dependency
model DIAGNOSTIC-RECOVERY.md introduced. A run, a build, every backend and
the front-end cache still refuse a program with syntax errors.

The work starts from `main` as merged at `85753d95` (the LSP milestone,
LSP-MILESTONE-1.md, and the compiler service, COMPILER-SERVICE-MILESTONE-1.md).
No syntax, grammar, HIR expression kind, Core IR form, NIR instruction,
protocol feature, daemon or incremental mechanism was added. The HIR gained a
marked `ref` (the hole), three side tables (`syntaxRecovery`,
`syntaxDependent`, `holeBlocks`) and one diagnostic kind recorded but never
reported (SYNTAX-HOLE); the service gained a revision field (`semantics`);
the HIR's interchange format is unchanged, the service's export format is
version 2 (it carries `semantics`).

## Contents

1. [Result](#1-result)
2. [Existing recovery architecture](#2-existing-recovery-architecture)
3. [Recovery representation](#3-recovery-representation)
4. [Semantic soundness](#4-semantic-soundness)
5. [Module recovery](#5-module-recovery)
6. [Diagnostics](#6-diagnostics)
7. [Strict compilation](#7-strict-compilation)
8. [Compiler service and LSP](#8-compiler-service-and-lsp)
9. [Tests](#9-tests)
10. [Performance](#10-performance)
11. [Limitations](#11-limitations)
12. [Deviations](#12-deviations)
13. [Next milestone](#13-next-milestone)
14. [Files and usage](#14-files-and-usage)

## 1. Result

### A program with three syntax errors

```text
shapes.bot                                main.bot
 1  fn area(w: int, h: int) -> int:        1  import shapes
 2      w * h                              2
 3                                         3  fn report(n: int) -> int:
 4  fn perimeter(w: int, h: int) -> int:   4      total = shapes::area(n, 2)
 5      2 * (w +                           5      half = total *
 6                                         6      total + shapes::square(n)
 7  fn square(s: int) -> int:              7
 8      area(s, s)                         8  fn scale(n):
                                           9      k = n *
                                          10      k
                                          11
                                          12  a = report(3)
                                          13  p = shapes::perimeter(1, 2)
                                          14  c = scale(2)
                                          15  q = nosuch + 1
```

A run stops at the entry's syntax errors, as it always did:

```text
$ tclsh9.0 main.tcl main.bot
== main.bot (interp)
   error: main.bot:5:19: expected an expression, found end of line (SURFACE SYNTAX)
   help: tclsh9.0 main.tcl -help error.surface-syntax
   error: main.bot:9:12: expected an expression, found end of line (SURFACE SYNTAX)
```

`-check` reports the same syntax errors, first and unchanged, then the
module's, then the one semantic error the malformed lines cannot affect:

```text
$ tclsh9.0 main.tcl -check main.bot
== main.bot (check)
   error: main.bot:5:19: expected an expression, found end of line (SURFACE SYNTAX)
   help: tclsh9.0 main.tcl -help error.surface-syntax
   error: main.bot:9:12: expected an expression, found end of line (SURFACE SYNTAX)
   error: shapes.bot:5:9: "(" is never closed (SURFACE SYNTAX)
   error: main.bot:15:5: unbound name "nosuch" (CORE SEMANTIC UNBOUND)
   help: tclsh9.0 main.tcl -help error.unbound
```

What the compiler service (`service::at`) knows, position by position:

| position | fact | why |
|---|---|---|
| `total` (4:5, 6:5) | `total: int`, defined at 4:5 | written before the malformed line, used after it: an expression hole binds nothing else |
| `shapes::area` (4:21) | `fn shapes::area(w: int, h: int) -> int`, defined at shapes.bot:1:4 | a well-formed member of a module with a syntax error |
| `half` (5:5) | a binding, defined at 5:5; *its value is not known: it depends on malformed source* | `half = ...` certainly binds `half`; what to is malformed |
| `shapes::square` (6:21) | `fn shapes::square(s: int) -> int` | declared after the module's malformed function |
| `report` (3:4) | `fn report(n: int) -> int` | its declared signature, though its body holds a malformed line |
| `scale` (8:4) | a binding; *its signature is not known: its body holds malformed source and the signature does not declare every type* | an undeclared parameter type and result would be inferred from a body nobody finished |
| `a` (12:1) | `a: int` | the declared result of `report` |
| `p` (13:1) | `p: int` | the declared result of the malformed `shapes::perimeter` |
| `shapes::perimeter` (13:14) | `fn shapes::perimeter(w: int, h: int) -> int` | its header is well formed |
| `c` (14:1) | *its value is not known* | `scale`'s result would be inferred from its incomplete body |
| the malformed text (shapes.bot 5:5) | *malformed source: no meaning is known for it (its syntax error says why)* | a hole |

### Under each soundness rule, a fact withheld

| program | recovered analysis | why not more |
|---|---|---|
| `fn index() -> int:` / `    k = 1` / `    k +`; `x = std::list::at([10, 20, 30], index())` | no KNOWN-ERROR | completed as `k + 6` the index is out of bounds, as `k + 0` it is not: the visible `k = 1` proves nothing |
| `fn f() -> int errors Boom:` / `    k = 1 +` / `    k` | no proof that `f` fails or never completes | the hole is neither divergence nor a value |
| `with context Clock {ticks: ` / `x = now()` | no MISSING-CONTEXT | the malformed line may have installed it |
| `x = foo(` / `y = x + 1` / `z = 1 + nosuch` | UNBOUND for `nosuch`; nothing for `y` | `x` is bound, its value poison; `z` is independent |
| a module whose malformed top-level line may be the implementation a trait needs | no TRAIT-NOT-SATISFIED | conformance reads the module's own declarations |
| `static compile:` in a program with syntax errors | no decision: the block is a hole | a decision reads the whole program's analysis |

Each row is a test (section 9).

### An editing session in Neovim

`tests/lsp-neovim.test` drives Neovim 0.11.4's own LSP client, unmodified,
configured by `editors/neovim/botlish.lua`, headless, through the real
server and worker over real pipes. On the LSP milestone's two-module program
(`shapes.bot` declares `area`; `main.bot` imports it and `std::list`):

| Step | What Neovim shows |
|---|---|
| line 6 of `main.bot` becomes `a + ` (unsaved) | `SURFACE SYNTAX` on line 6 |
| hover on `shapes::area` (line 4) | `fn shapes::area(w: int, h: int) -> int`, **fresh** (before: the same text marked *stale*) |
| hover on `b` (line 5) | `b: int`, fresh |
| hover on `a` inside the malformed line 6 | `a: int` *stale: analyzed before the latest changes to main.bot* -- the current analysis knows nothing there, the last complete one answers in text it saw |
| line 6 fixed | no error; hover fresh |
| `shapes.bot` opened (second buffer); line 2 becomes `    w *` | `1:7: expected an expression, found end of line` in `shapes.bot`; no error in `main.bot` |
| hover on `shapes::area` and on `b` in `main.bot` | the signature and `b: int`, fresh |
| `shapes.bot` repaired | its diagnostic goes; hover fresh |
| the files on disk | never written |

`tests/lsp.test`'s `lsp-lang-recovery-session` runs the milestone's editing
sequence (section 11 of its brief) against the real server with both
schedulers, and `lsp-lang-recovery-declarations` the malformed declarations
(section 8).

## 2. Existing recovery architecture

What was already there, and reused:

* **The lexer** (`surface/lexer.tcl`) recovers locally: it skips a
  character outside the language, ends an unterminated string at its line's
  end, closes a bracket left open at the end of the input or before a line
  that starts like a new statement (a zero-width *synthetic* closer), and
  reports a tab in indentation or an inconsistent dedent and goes on with a
  guess about the line's block.
* **The parser** (`surface/parser.tcl`) always parses with recovery
  (`surface::parseTokens -recover 1`): a statement it cannot read becomes an
  `error` node and parsing resumes after its line and the block indented
  under it; `surface::parser::Independent` keeps one diagnostic per
  malformed construct (DIAGNOSTIC-RECOVERY.md, section 5). Without
  `-recover`, `surface::parse` raises those diagnostics.
* **Diagnostic recovery** (DIAGNOSTIC-RECOVERY.md, `hir/recovery.tcl`):
  poison in inference (an invalid value typed so that nothing restates its
  error), the source front end checking a program whose resolution failed,
  and *taint* -- the check diagnostics of a top-level unit that refers to a
  unit with a resolution diagnostic are dependent and not reported.
* **The compiler service** (`service/service.tcl`): immutable revisions
  with an outcome (`ok`, `semantic`, `syntax`, `loader`, `failure`), their
  diagnostics as data and position queries; `service::export`/`import`
  moving a revision between processes with its HIR in interchange text.
* **The language server** (`lsp/`): a revision is *fresh* when every source
  it read is still what the editor and the disk hold; where the latest
  revision has no fact, the last revision with a HIR answers where the text
  is unchanged (`Mapping`), marked stale.

The barriers that kept a HIR from being built:

1. `surface::readProgramFile` parsed the entry strictly: its first syntax
   error ended the compilation. The service caught it and made a `syntax`
   revision with no HIR.
2. The loader (`surface::modules::ParseModule`) parsed every module
   strictly: a syntax error in any imported module did the same, for every
   importer.
3. The recovering parse's tree could not be analyzed as it stood. An `error`
   node has no lowering, and the lexer's guesses are text nobody wrote:
   `x = f(` reaches the parser as `x = f()`, a call of `f` with no
   arguments, and analyzing it would report and prove things about a
   program that does not exist.
4. Everything downstream assumed a HIR comes from a program that parsed: a
   backend would run one, the cache would keep one, a static block would be
   decided on one.

## 3. Recovery representation

### Where the text is damaged

`surface::parse` records, for a text with syntax errors only, a `damage`
record (`surface::parser::Damage`): every position where the text stopped
being what the parser read as written --

* each construct the parser failed on: its region, the start of its
  diagnostic, and whether it is part of the file header (an import, the
  `direct module` marker);
* each lexical problem (a skipped character, a string ended at its line's
  end), a bracket never closed (the end of its opener: the opener was
  written), every synthetic closer;
* each layout problem (a tab in indentation, an inconsistent dedent).

The lexer now also lists which of its diagnostics are layout ones and which
are unclosed brackets (`indentation`, `unclosed`). The record carries the
parse's tokens so that recovery does not lex the text a second time; the
recovered tree drops them.

### Holes

`surface::recover::apply` (`surface/recover.tcl`) replaces each *malformed*
statement -- the innermost statement holding a damaged position; for layout
damage, every top-level statement from the last one written at column 1
before it to the next one after it -- with a `hole` node. Damage between
statements (a line the parser skipped) is a hole of its own. A malformed
import makes the file header damaged: the damaged import is dropped and what
the file may name is not known.

A hole keeps what its *valid prefix* establishes: the real tokens before its
first damaged position (never a synthetic closer, never a token after the
damage). Every completion of a prefix the parser accepted is a statement of
the form the prefix decided:

| prefix | the hole |
|---|---|
| `NAME = ...` | binds NAME (to a value nobody knows) and nothing else |
| `fn NAME ...`, `nomethod fn NAME ...` | binds NAME |
| `return`, `break`, `continue`, `fail`, `yield`, `if`, `elif`, `else`, `loop`, an expression (`f(`, `x.`, `a +`, a literal) | binds nothing visible after it |
| `struct`, `type`, `error`, `enum`, `layout`, `trait`, `union`, `refined`, `opaque`, `context` + a name, at the top level | may declare a type-level name of its file |
| `extern c fn ...` at the top level | may declare an extern its whole file sees |
| `with context ...` at the top level | may install a context |
| `{` (a destructuring), `coroutine {`, `fn (` | may bind any name (*binding hole*) |
| too short to decide (empty, one word), or a region that swallowed the next statement | may bind, declare, install anything |

`surface::lower::Hole` lowers a hole to HIR: a named one to `bind NAME
<value hole>`, and otherwise (or besides, when it may bind more) a statement
hole. In HIR a hole is a `ref` named `syntax#hole` with a `hole {binds B
installs I}` field (`hir::syntax::holeNode`), so every walk, printer and the
interchange format handle it without a new expression kind. A module's
qualified reference or construction the loader could not resolve because of
a malformed module (section 5) is lowered as a hole too, and a
`static compile:` block of a program with syntax errors is replaced by a
hole (its decision would read an analysis of what nobody wrote).

### How a hole differs

| | a valid expression | `never` (divergence) | an ordinary semantic error | a hole |
|---|---|---|---|---|
| has a value | yes | no: control does not reach past it | yes, of an invalid type (poison) | **unknown**: neither a value nor divergence |
| what follows it | reachable | unreachable | reachable, checked | reachable, checked |
| its type | inferred | `never` | poison | poison, never divergence (`hir::types::Halts` is false) |
| range, completion facts | computed | none: nothing completes | from its type | **unknown**: any value, any completion |
| its diagnostic | -- | -- | reported | SYNTAX-HOLE, recorded and **never reported**: its syntax error is the report |
| runs | yes | yes | in a lenient HIR, as a run-time error | **never**: the HIR is refused |

The SYNTAX-HOLE diagnostic exists so that the dependency model sees the
hole: like a resolution failure, it taints its unit.

## 4. Semantic soundness

Recovery may lose precision; it never manufactures a guarantee. Each rule
below is a test of `tests/syntax-recovery.test` and a mutant of
`audit/syntax-recovery/tools/mutants.txt` (section 9) that breaks it.

**Bindings.** A hole binds only what its prefix states (above). A *binding
hole* may bind any name in its scope: a reference that a binding hole in a
scope between it and its binding's own scope may capture is
`syntaxDependent` (`hir::resolve::AfterBindingHole`) -- no binding, no
definition, no references, no diagnostic; inference types it and then
poisons it. A binding of the hole's own scope is not uncertain: rebinding it
there would be a DUPLICATE. An unresolved name after a binding hole is not
reported unbound. Navigation never falls back to a name's spelling.
(Mutants `no-binding-holes`, `own-scope-shadowable`,
`dependent-binding-guessed`, `references-include-dependent`,
`definition-by-spelling`, `prefix-past-damage`, `swallowed-lines-ignored`.)

**Types.** A hole is poison: whatever consumes it is typed and poisoned
(`hir::types::Dependent`), so no check restates a missing premise, and no
unknown syntax satisfies a constraint. A function whose body holds a hole
(`holeBlocks`) keeps its declared contract and nothing its body would
infer: an undeclared result is poison, not the type of the rest of the body
(`missing-result-inferred`); a call of it is typed by its declaration, never
by a semantic instance of the incomplete body (`instance-of-incomplete-body`);
its untyped parameters get no inferred contract (`hir/signatures.tcl`), and
the service shows its signature only when it declares every type
(`signature-unmarked`). A hole is not `unit` (`hole-is-unit`), and a
malformed declaration's name is not bound to a value (`declaration-is-valid`).

**Range and exact values.** A hole's range is unknown (`hir/range.tcl`): a
missing expression proves no value and no bound -- in the table of section
1, no KNOWN-ERROR at an index the visible part of a body would put out of
bounds (`range-hole-never`).

**Known errors and error effects.** The completion analysis gives a hole an
unknown completion: it may complete normally with any value, so no call of
an incomplete body is proven to fail or never to complete
(`hole-is-never`, `completion-hole-never`). What a call may raise is its
callee's declared `errors` clause, which every function that raises must
have: an incomplete body cannot narrow its callers' obligations.
`sr-analysis-claims-nothing` checks the HIR's own diagnostics, not only the
reported ones, for a KNOWN-ERROR.

**Static decisions.** A `static compile:` block is never decided in a
program with syntax errors: it becomes a hole (`static-decided`).

**Context installation, conformance, authority.** A top-level hole that may
install a context taints every top-level unit after it (MISSING-CONTEXT is
not reported: `installs-ignored`); while a module's malformed top-level
line may declare a function -- perhaps the missing implementation -- no
TRAIT-NOT-SATISFIED, MISSING-CONTEXT or AMBIGUOUS-CONTEXT-IMPLEMENTATION is
reported (`conformance-ignored`), and a malformed value binding, which
cannot be one, withholds nothing (`sr-trait-conformance`).
Recovery grants nothing: a recovered HIR never runs, so no authority it
might be thought to establish is ever exercised, and the direct-module
analysis's module-level findings, like every check diagnostic without an
expression, are not reported for a program with an unresolved part (a hole
is one).

## 5. Module recovery

In recovery mode (`-recover-syntax 1`) the loader parses every module with
recovery (`ParseModule`), collects its syntax diagnostics (the entry's
first, then each module's in load order) and applies
`surface::recover::apply` to it. A module keeps every well-formed top-level
declaration, so its importers keep their bindings, types and definitions
(section 1: `shapes::area`, `shapes::square`, `shapes::perimeter`'s declared
signature). What a malformed top-level statement may contribute is recorded
per file (`surface::modules::Recovered`) and decides what is dependent:

| the module's malformed top-level line may | then |
|---|---|
| bind any value name (`values`) | a qualified reference to a member the module does not visibly declare is not UNKNOWN-SYMBOL (`DependentReference`): it is lowered as a hole (`members-known`) |
| declare a type-level name (`types`) | an unknown type, struct, error or layout name in that module or an importer is dependent (`Recovered`'s `typeFiles`), and an `import type` of it is not reported (`types-known`) |
| bind any value name, so define a function | a method-style call in a file importing it may apply that function: dependent (`methodFiles`, `methods-known`) |
| declare a function (it may bind any name, or it is a malformed `fn NAME` header) | it may be the implementation a trait or context trait needs: conformance diagnostics are not reported (section 4, `openFiles`); a malformed value binding (`x = (1`) cannot be one, and they are |
| (a malformed header) | every unit of the file is tainted, and every reference error in it dependent: what it imports is not known (`header-known`) |

A module whose malformed top-level line may bind any value name is *open*:
what it declares cannot be listed. One whose malformed lines bind only the
names their prefixes state is not: a reference to a member it does not
declare is still UNKNOWN-SYMBOL (section 6). A syntax error two imports away (`main -> mid -> low`) taints what
depends on its malformed function and nothing else: `mid::twice` keeps its
type in `main`, `mid::usebad` (which calls `low::bad`) does not
(`sr-transitive-module`, the experiments' case E). Loader errors (a module
that does not exist) still end the build, with the syntax errors found so
far reported first: there is no HIR to recover then (`semantics none`).

## 6. Diagnostics

**Syntax diagnostics** are the parser's, exactly: the same messages,
positions and order a strict parse reports, the entry's first, then each
module's in the order the loader parses them; a compilation without
recovery raises the first of them as it always did
(`sr-diagnostics-syntax-unchanged`).

**Semantic diagnostics** follow every syntax error. A diagnostic is
*independent* when no hole is among its premises: it is reported, and is the
one a compilation of the repaired program reports. A *dependent* one is
suppressed by the semantic dependency model, never by comparing messages or
positions:

* within inference, poison (a hole, and everything that consumes it);
* `syntaxDependent` references (a binding hole may capture them) and the
  dependent resolution diagnostics `hir::recovery::Recovered` removes;
* unit taint (DIAGNOSTIC-RECOVERY.md): a unit holding a hole, a dependent
  reference or a reference to a tainted unit's binding reports no check
  diagnostic; every unit of a file with a malformed header; every top-level
  unit after a hole that may have installed a context.

| program (after its syntax error) | reported | not reported, and why |
|---|---|---|
| `x = foo(` / `y = x + 1` / `z = 1 + nosuch` | `UNBOUND nosuch` at 3:9 | nothing about `y`: `x` is poison |
| `fn f(n: int) -> int:` / `    n +` / `x = f("s")` / `y = nosuch` | `UNBOUND nosuch` | the call of `f`: its unit refers to a unit with a hole (section 11) |
| `{p, q} = (` / `r = p` / `s = nosuch` (a binding hole at the top level) | nothing for `nosuch` | `p` and `nosuch` may both be bound by the destructuring |
| `import util` where util.bot's first line is `$$` / `y = util::missing()` / `z = util::ok()` / `w = nosuch` | `UNBOUND nosuch`; `z: int` is known | `util::missing`: a line of no known form may declare it |
| the same with util.bot's malformed line `fn helper(` | `UNKNOWN-SYMBOL util::missing` (*it defines: helper, ok*) | -- : the malformed line declares `helper` and nothing else, so the error is independent (a loader error: the analysis stops there, section 11) |

**The fidelity oracles** (`tests/syntax-recovery.test`):

* *independent-source* (`sr-diagnostics-independent-and-dependent`): each
  reported semantic diagnostic, with its code, message and position, is one
  the program with its malformed lines repaired reports;
* *dependency* (`sr-experiments-oracle`, `audit/syntax-recovery/experiments/`):
  each experiment comes with two repairs, line-preserving completions of the
  malformed lines that disagree; a fact the repairs disagree on must be
  unavailable in the malformed program, a fact expected known must be known
  and equal to both repairs' (section 9);
* *appended hole* (`sr-appended-hole-changes-nothing-before`): a malformed
  statement appended to a valid program changes no fact before it;
* *strict-compiler* (`sr-strict-unchanged`, `sr-valid-programs-unchanged`):
  a strict compilation of a program with syntax errors raises exactly its
  syntax errors, and every program without one -- the examples, a
  multi-module application, golden suites -- compiles to the same HIR,
  diagnostics and warnings with recovery requested and without.

Diagnostics are deterministic: the same sources give the same diagnostics in
the same order whatever was analyzed before (`sr-diagnostics-deterministic`).

## 7. Strict compilation

Nothing that runs or builds a program asks for recovery: only
`surface::readProgramFile -recover-syntax 1` makes a recovered HIR, and only
the compiler service passes it.

* A strict compilation (`-strict 1`, every run, build and inspecting option
  of main.tcl, `tests/golden/run.tcl`) raises the syntax errors exactly as
  before. Asked to recover as well, it raises the syntax errors first, then
  the independent semantic ones -- never the HIR (`sr-strict-unchanged`,
  mutant `strict-recovered-accepted`).
* Every backend entry point refuses a recovered HIR before compiling
  anything: `hir::recovery::runnable` throws `HIR SYNTAX-RECOVERED` (Tcl
  interpreter, the Tcl compiler, both native backends, AOT executables, and
  a recovered HIR read back from interchange text: `sr-backends-refuse`,
  mutant `backend-accepts`).
* `main.tcl` rejects a program with syntax errors on every backend with its
  syntax errors alone and runs nothing (`sr-main-never-runs`).
* The front-end cache never stores a compilation with syntax errors; fixed,
  the program is compiled and kept (`sr-cache-never-stores`,
  `cache-keeps-recovered`).

`main.tcl -check` reports more than a run of the same file, and the
difference is deliberate: a run reports the entry's syntax errors (the
strict parse fails before any module is loaded); `-check` reports those,
then every module's, then the independent semantic errors
(`cli-check-recovers-past-syntax`, which also checks that the semantic part
equals what `-check` reports for the repaired program; the `cli.options`,
`cli.output` and `error.surface-syntax` Compilerpedia topics say so). For a
program without syntax errors `-check` and a run still print the same lines
(`cli-check-matches-run-*`).

## 8. Compiler service and LSP

### Revisions

`service::analyze` compiles with `-recover-syntax 1`. A revision now has two
separate descriptions:

| field | values | meaning |
|---|---|---|
| `outcome` | `ok`, `semantic`, `syntax`, `loader`, `failure` | the program's result, as before: **`syntax` whenever there is a syntax error**, never `ok` (mutant `syntax-revision-ok`) |
| `semantics` | `full`, `partial`, `none` | how much the revision analyzed: a whole program, the program around its syntax errors, nothing |

A partial revision's errors are its syntax errors, then the reported
semantic ones; its warnings are none (an error hides warnings, as before).
It is immutable like any revision, and every query activates its HIR first:
partial and full revisions of programs with conflicting declarations,
analyzed in any order, each answer from their own declarations
(`sr-service-isolation`, mutant `partial-not-activated`).

### Queries

`service::at` answers in a partial revision exactly as in a full one, and
names why a fact is unavailable:

| position | unavailable facts and reason |
|---|---|
| malformed text | every one: *malformed source: no meaning is known for it (its syntax error says why)* |
| a `syntaxDependent` name | binding, definition, references: *a malformed statement before it, in a scope it sees, may bind this name: which binding it denotes is not known*; its type: *its value is not known* |
| a value that depends on a hole | type and hover: *its value is not known: it depends on malformed source or on a construct a diagnostic rejects* |
| an undeclared parameter of a function whose body holds a hole | type: *its contract is not known: it declares no type, and its function's body, which would require one, holds malformed source* |
| a function whose body holds a hole and that does not declare every type | type and hover: *its signature is not known: ...* |

References never list a dependent name; a recovered binding's definition is
its name, not its whole malformed statement (`name-is-statement`,
`identity-of-keyword`).

### Export and import

`service::export` writes a partial revision with its HIR (holes, side tables
and all, in the unchanged HIR interchange format), its syntax and semantic
diagnostics and its `semantics`; `service::import` restores it, and the
imported revision answers every query and reports every diagnostic as the
original (`sr-service-export-import`, mutants `export-omits-syntax`,
`import-loses-markers`). The export format is version 2, and the
compiler-service tests that read its header read it from an export.

### The language server

The server's choice of revision is the only change in `lsp/`
(`lsp/server.tcl`):

* every fresh revision is published as before -- its diagnostics are now the
  syntax errors and the independent semantic ones;
* the *fallback* revision is the latest one with `semantics full`, no longer
  the latest one with any HIR (`lsp-partial-is-good`);
* a query is answered from the latest revision first; only where it has no
  fact of the kind asked (hover, definition, references) does the fallback
  answer, through `Mapping`, marked stale, or the server waits or answers
  nothing as before (`lsp-prefers-stale`).

So current recovered facts are reported as current, and the stale fallback
remains where recovery cannot establish semantics: in the malformed
expression itself, and in what depends on it. The worker transports partial
revisions like any other (export and import above); both schedulers answer
the editing session identically (`lsp-lang-recovery-schedulers-agree`). No
capability, request, notification or option was added.

## 9. Tests

### 9.1 What runs

| File | Tests | What |
|---|---:|---|
| `tests/syntax-recovery.test` | 33 | below |
| `tests/lsp.test` | 3 new (70) | `lsp-lang-recovery-session` (the brief's eleven steps, real server and worker, real pipes), `-schedulers-agree`, `-declarations` (an unfinished function header, an incomplete parameter annotation, a malformed declaration between two valid ones, syntax errors in two files); `lsp-lang-session`'s syntax-error step now expects a fresh hover |
| `tests/lsp-neovim.test` | 1 (extended) | the session of section 1: Neovim's own client through a syntax error in the entry and one in an imported module |
| `tests/compiler-service.test` | 3 changed (54) | `cs-overlay-module-syntax` (a module's syntax error: a partial revision), `cs-syntax-error-queries`, `cs-export-import-outcomes`; the export-header tests read the version from an export |
| `tests/main-cli.test` | 1 new (62) | `cli-check-recovers-past-syntax` (section 7) |
| `tests/static-compile.test` | -- | the census classifies SYNTAX-HOLE and SYNTAX-RECOVERED (never a block's rejection: a program with a syntax error has no static decision) |

`tests/syntax-recovery.test`, by the brief's matrix (section 12):

| Area | Tests |
|---|---|
| Parser recovery | `sr-holes-statement-forms`, `-lexical`, `-layout`, `-header`, `-declarations`, `-damage-past-statement`; `sr-no-damage-no-recovery`; the fuzzer (below) |
| Declaration recovery | `sr-module-recovery`, `sr-declared-contract`, the experiments' cases C and D |
| Incomplete declarations | `sr-declared-contract` (an undeclared result, an untyped parameter, `-> any`), the experiments' case C |
| Function bodies | `sr-function-body-facts`, the experiments' case A |
| Module recovery | `sr-module-recovery`, `sr-header-damage`, `sr-type-declaration-damage`, `sr-method-candidates` |
| Transitive imports | `sr-transitive-module`, the experiments' case E |
| Type inference | `sr-hole-is-poison-not-divergence`, `sr-declared-contract` |
| Range and exact-value analysis | `sr-no-proof-from-incomplete-body` |
| Known errors, error effects | `sr-no-proof-from-incomplete-body`, `sr-analysis-claims-nothing` |
| Static decisions | `sr-no-proof-from-incomplete-body` (the static block), the experiments' case F |
| Affinity and capabilities | `sr-context-installation`, `sr-trait-conformance`, `sr-backends-refuse` |
| Diagnostics | `sr-diagnostics-syntax-unchanged`, `-independent-and-dependent`, `-deterministic`, `sr-experiments-oracle` |
| Strict compilation | `sr-strict-unchanged`, `sr-valid-programs-unchanged`, `sr-backends-refuse`, `sr-main-never-runs`, `sr-cache-never-stores` |
| Source identity | `sr-service-hole-facts` (a recovered binding's definition), `sr-appended-hole-changes-nothing-before`, the LSP declarations test |
| Revision isolation | `sr-service-isolation` |
| HIR interchange | `sr-service-export-import`, `sr-backends-refuse` (a recovered HIR read back from interchange text) |
| CLI | `cli-check-recovers-past-syntax`, `sr-main-never-runs` |
| LSP | `lsp-lang-recovery-*`, `lsp-neovim-session` |
| Performance | `bench/syntax-recovery.tcl`, `bench/lsp.tcl -malformed 1` (section 10) |

Programs with several independent syntax errors in one source and across
modules: `sr-diagnostics-syntax-unchanged` (three files),
`sr-diagnostics-independent-and-dependent`, the experiments, the fuzzer's
`several` damage, `cli-check-recovers-past-syntax`, the LSP declarations
test.

### 9.2 Experiments

`audit/syntax-recovery/experiments/` holds the nine programs of the brief's
cases A-F (`a-expression`, `a-undeclared`, `b-toplevel`, `c-declaration`,
`d-module`, `e-transitive`, `f-errors`, `f-proofs`, `f-static`), each with
`probes` (a position and what the malformed program's analysis must say
there: `known`, `binding` -- a binding whose value is not known -- or
`unavailable`) and two repairs. `tools/experiments.tcl` prints, for the
program and each repair, the outcome, diagnostics and the fact at every
probe; `results/experiments-before.txt` is the compiler at `85753d95`
(every probe: *no semantic analysis: the revision's outcome is syntax (no
HIR)*), `results/experiments-after.txt` this milestone's. `sr-experiments-oracle`
checks every probe: of the 38, the 27 expected known are known and equal to
both repairs' facts, the 4 expected `binding` have their binding and no
type, and the 7 expected unavailable have no type (each where the two
repairs disagree, or where a decision would read the malformed body). Before
the milestone, none of the 38 had a fact.

### 9.3 Fuzzing

`audit/syntax-recovery/tools/fuzz.tcl` damages real programs -- the
examples, the 2048 and Icy Tower modules, golden suites -- the way editing
does (cut off, a line cut short, characters deleted, a bracket, operator,
keyword, quote, tab or line break inserted, two or three lines cut short),
analyzes each damaged text as an unsaved buffer, and checks that the
analysis never fails internally, that its syntax diagnostics are exactly a
strict parse's, that it built a partial HIR unless a loader error stopped
it, that no reported semantic diagnostic lies in malformed text, that no
backend accepts the HIR, that queries at random positions answer, and that
export and import keep it. @@FUZZ-RESULTS@@

The fuzzer was written after the Neovim session found the one internal
failure recovery had: a statement the parser failed on whose diagnostic
points past its own span -- `a + ` with a blank before the end of the line --
was located by no statement and stayed an `error` node, which lowering
cannot lower; the service caught the error and fell back to a revision with
no HIR. It is fixed (a failed construct is located by its region's start),
an `error` node can no longer reach lowering (it becomes a hole that may
bind anything), and `sr-holes-damage-past-statement` pins it.

### 9.4 Mutation testing

`audit/syntax-recovery/tools/mutate.tcl` applies each mutant of
`audit/syntax-recovery/tools/mutants.txt` to a private copy of the tree and
runs the test file that states its rule (`tests/syntax-recovery.test`, or
`tests/lsp.test` for the server's choice of revision). The brief's candidate
mutants, and the rule each is:

| the brief's candidate | mutants |
|---|---|
| any syntax diagnostic prevents HIR construction | `no-recovery` |
| a malformed module discards every module's facts | `module-error-erases` |
| an invalid expression becomes `unit` | `hole-is-unit` |
| an invalid expression becomes `never` | `hole-is-never` |
| a missing return expression becomes a successful return | `missing-result-inferred` |
| a malformed body proves its declared result range | `missing-result-inferred`, `completion-hole-never` (and two equivalent mutants, below) |
| a failed expression proves a function cannot throw | `completion-hole-never` |
| unknown static input selects one branch | `static-decided` |
| a dependent error is reported | `dependent-units-reported`, `hole-diagnostic-reported`, `installs-ignored`, `conformance-ignored`, `types-known`, `members-known`, `header-known`, `methods-known`, `no-binding-holes` |
| an independent error is suppressed | `independent-suppressed`, `own-scope-shadowable` |
| an invalid declaration becomes a valid exported binding | `declaration-is-valid` |
| a recovered declaration gets another's source identity | `identity-of-keyword`, `name-is-statement` |
| the service reports a syntax-error revision as `ok` | `syntax-revision-ok` |
| a backend accepts a recovered HIR | `backend-accepts`, `strict-recovered-accepted`, `cache-keeps-recovered` |
| worker export omits syntax diagnostics | `export-omits-syntax` |
| worker import loses recovery markers | `import-loses-markers` |
| the LSP prefers stale facts | `lsp-prefers-stale`, `lsp-partial-is-good` |
| definition navigation uses textual spelling | `definition-by-spelling`, `dependent-binding-guessed`, `references-include-dependent` |
| a recovered HIR leaks into another revision | `partial-not-activated` |
| (the damage and the prefix) | `lexical-damage-ignored`, `prefix-past-damage`, `swallowed-lines-ignored`, `signature-unmarked` |

@@MUTATION-RESULTS@@

The existing harnesses were rerun against the changed code:
@@OTHER-MUTANTS@@

### 9.5 Regressions and CI

@@REGRESSIONS@@

## 10. Performance

@@PERFORMANCE@@

## 11. Limitations

* **Taint is per top-level unit, so some independent diagnostics are
  suppressed.** A unit that refers to a binding declared by a unit holding a
  hole reports no check diagnostic: `x = f("s")` against `f(n: int)` whose
  body holds a malformed line is not reported, though the declared parameter
  type makes it independent of the body. This is DIAGNOSTIC-RECOVERY.md's
  dependency model, reused unchanged; a finer one (a call depends on its
  callee's declaration, not its body) would report it. It never reports a
  dependent diagnostic.
* **Check diagnostics without an expression** (STALE-DIRECT-MODULE at a
  marker, other module-level findings) are not reported for a program with
  any unresolved part, which a program with a hole always is.
* **The trait plan's build is not run** on a recovered program, as on any
  program with a diagnostic (`hir::BuildFull`): its diagnostics are withheld
  and trait-polymorphic calls are answered from the analysis before
  monomorphization.
* **A hole's own text has no facts.** In `total = shapes::area(n, ` neither
  `shapes::area` nor `n` is analyzed: everything from the statement's start
  is the hole, and only its bound name survives. The language server falls
  back to the last complete revision there (stale) when the text maps.
* **Coarse regions.** A tab or an inconsistent dedent makes every top-level
  statement from the last column-1 statement before it to the next one after
  it a hole; a malformed function header makes the whole function a hole
  (its name survives, its parameters and body do not); a hole whose form the
  prefix does not decide makes later references in its scope dependent.
* **Open modules.** A module with a top-level hole that may bind any value
  name is open: a qualified reference to any member it does not visibly
  declare is dependent, so a misspelled member of such a module is not reported until
  its syntax error is fixed. A malformed declaration that may declare a type
  makes every unknown type name in its file and its importers dependent.
* **Conformance.** While any file has a malformed top-level statement that
  may declare a function, TRAIT-NOT-SATISFIED, MISSING-CONTEXT and
  AMBIGUOUS-CONTEXT-IMPLEMENTATION are not reported anywhere in the program
  (the diagnostic is not traced to the owner module and requirement it is
  about).
* **Static blocks** of a program with syntax errors are not decided, so
  their CompilerError values and the code under them are unknown.
* **Loader errors and declaration errors** still end the analysis, as they
  end any compilation: a missing module, or an error a declaration raises
  while it is registered (an unknown type in a struct's field), leaves no HIR
  to recover. With syntax errors the revision then reports only those (the
  declaration error may be theirs: a type a malformed declaration would have
  declared) and has `semantics none`; the fuzzer counts these cases
  (section 9.3). A compiler failure there is recorded as the revision's
  `failure`, never hidden behind the syntax errors.

None of these establishes a fact: each withholds one.

## 12. Deviations

Changes to the brief's plan, each with its evidence:

1. **Independence is per top-level unit.** The brief asks that independent
   diagnostics survive. This milestone reuses DIAGNOSTIC-RECOVERY.md's
   dependency model, whose unit of dependency is a top-level declaration or
   statement, so a diagnostic in a unit that merely *calls* a function with
   a malformed body is suppressed even when the function's declaration alone
   decides it (section 11, `sr-diagnostics-independent-and-dependent`).
   Refining the unit to "a call depends on its callee's declaration, not its
   body" is a change to the existing model for every program with an error,
   not only to recovery; the brief rules out a wholesale redesign, and no
   dependent diagnostic is ever reported either way.
2. **`-check` reports module syntax errors a run does not.** A run parses
   the entry strictly and stops; `-check` reports every file's syntax errors
   and then the independent semantic ones. The brief allows `-check` to
   report more if it is documented and tested: section 7,
   `cli-check-recovers-past-syntax`, the `cli.options`, `cli.output` and
   `error.surface-syntax` topics. For a program that parses, `-check` and a
   run still agree (`cli-check-matches-run-*`).
3. **Static blocks are not decided at all** in a program with syntax errors,
   rather than decided where independent of the holes. A decision is a
   whole-program build of the block's body in place (STATIC-COMPILE.md);
   deciding which blocks are independent of a hole would take builds per
   block, which the brief asks to avoid, and the block's outcome would still
   read the analysis of the rest of the program. A hole loses the block's
   facts; it cannot select a branch.
4. **The trait plan's build is not run** on a recovered program (section
   11): `hir::BuildFull` runs it only on a program without diagnostics, and
   a hole is one, exactly as a program with any semantic error is
   treated. The alternative -- the plan's second build for every incomplete
   version -- would add a whole-program build to each analysis of a program
   using traits or context traits (the 2048 demo's two builds against one,
   section 10) for diagnostics a program with any other error does not get
   either.
5. **Loader errors still stop the analysis.** A missing module, or a member
   a module provably does not declare (`fn helper(` declares `helper` and
   nothing else), is a loader error that ends the build as it did; only
   references a malformed line may satisfy are dependent. Making the loader
   recover from its own errors is a separate change (DIAGNOSTIC-RECOVERY.md
   already reports all of them at once).
6. **The experiments' probes gained a third expectation**, `binding`: the
   brief's facts are known or unavailable, but `t = s *` establishes `t`'s
   binding (its definition, its references) and not its value. The oracle
   checks both halves.
7. **The parse was not cheap enough at first.** Recovery initially lexed
   the text a second time to read the prefixes' tokens, which doubled the
   cost of parsing a damaged file (about 80 ms of 2048's engine). The damage
   record now carries the parse's own tokens (section 10).
8. **The language server's fallback is narrower.** The LSP milestone's
   fallback was the latest revision with any HIR; it is now the latest
   revision with complete semantics, so that a partial revision never
   shadows a complete one where it knows nothing (`lsp-partial-is-good`).

## 13. Next milestone

@@NEXT@@

## 14. Files and usage

### Production

| File | Change |
|---|---|
| `surface/recover.tcl` | new: the damage to holes (`surface::recover::apply`) |
| `surface/parser.tcl` | the damage record (`surface::parser::Damage`); header failures marked |
| `surface/lexer.tcl` | the layout and unclosed-bracket diagnostics listed |
| `surface/lower.tcl` | holes lowered; dependent qualified references and constructions as holes; strict-with-recovery raises syntax errors first |
| `surface/modules.tcl` | `-recover-syntax`: recovering module parse, per-file recovery facts, dependent references, `import type` of an open module, syntax entries before loader errors, `Recovery`; the cache skips recovered HIRs |
| `hir/syntax.tcl` | `hir::syntax::holeNode` |
| `hir/resolve.tcl` | `ResolveHole`, `AfterBindingHole`; dependent references and method calls |
| `hir/types.tcl` | holes poison, `Dependent`, hole functions' undeclared results, no semantic instances |
| `hir/range.tcl`, `hir/completions.tcl` | holes and dependent references unknown |
| `hir/signatures.tcl` | no inferred contracts in hole functions |
| `hir/recovery.tcl` | `Recovered`, taint of dependent units, files and installs, SYNTAX-HOLE and conformance kinds not reported, `runnable` refuses a recovered HIR |
| `hir/hir.tcl` | `-syntax-recovery` |
| `hir/static.tcl` | an undecided block becomes a hole |
| `service/service.tcl` | recovering analysis, `semantics`, export format 2, unavailable reasons, references without dependent names |
| `lsp/server.tcl` | the fallback is the latest full revision; the latest answers first |
| `compilerpedia/topics/` | `error.syntax-hole`, `error.hir-syntax-recovered`; `error.surface-syntax`, `cli.options`, `cli.output`, `cli.lsp` updated |

### Tests, harnesses, measurements

`tests/syntax-recovery.test`, `tests/lsp.test`, `tests/lsp-neovim.test`
and `tests/lsp-neovim.lua`, `tests/compiler-service.test`,
`tests/main-cli.test`, `tests/static-compile.test`;
`audit/syntax-recovery/` (experiments, `tools/experiments.tcl`,
`tools/fuzz.tcl`, `tools/mutate.tcl` and `tools/mutants.txt`, `results/`);
`bench/syntax-recovery.tcl`, `bench/lsp.tcl -malformed 1`; census rows in
`audit/golden/migration/census/` (the new tests are KEEP-INTERNAL,
KEEP-NOT-EXPRESSIBLE -- a golden suite cannot hold a syntax error -- or
KEEP-MULTI-PROGRAM) and the regenerated manifest.

### Commands

```sh
# What the analysis knows past syntax errors
tclsh9.0 main.tcl -check FILE.bot

# The tests
tclsh9.0 tests/syntax-recovery.test
BOTLISH_NVIM=/path/to/nvim tclsh9.0 tests/lsp-neovim.test
tclsh9.0 audit/syntax-recovery/tools/experiments.tcl
tclsh9.0 audit/syntax-recovery/tools/fuzz.tcl -seed 17
tclsh9.0 audit/syntax-recovery/tools/mutate.tcl

# The measurements
tclsh9.0 bench/syntax-recovery.tcl ?-root BASELINE-CHECKOUT?
tclsh9.0 bench/lsp.tcl -malformed 1
```
