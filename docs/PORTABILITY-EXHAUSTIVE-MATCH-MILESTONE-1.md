# PORTABILITY-EXHAUSTIVE-MATCH-MILESTONE-1

## Exhaustive case selection and typed payload binding for Botlish enums

> A match selects exactly one alternative of a statically known closed enum.
> The compiler proves that every possible case is accounted for, makes the
> selected case's declared payload available through ordinary bindings, and
> preserves the language's existing value, error, and ownership rules. No
> user program needs to know how the enum is represented.

```botlish
enum Node:
    Const {value: int},
    Param,
    Add {left: int, right: int},
    If {condition: int, yes: int, no: int},
    Call {function: int},

fn evaluate(node: Node) -> int:
    match node:
        case Node::Const {value}:
            value
        case Node::Param:
            0
        case Node::Add {left, right}:
            left + right
        case Node::If {condition, yes, no}:
            if condition != 0:
                yes
            else:
                no
        case Node::Call {function}:
            function
```

This report is the completion record of the milestone. Its claims are
marked by kind: **(inspection)** -- read from the implementation;
**(observed)** -- an execution in this work's container (a 4-core Linux
x86-64 container, Tcl 9.0.1, rustc 1.97.0, the release native build);
**(CI)** -- a GitHub Actions run, named; **(projection)** -- an estimate or
a design consequence not measured.

## Contents

1. The starting point and the gaps
2. Syntax, and the alternatives rejected
3. The exhaustiveness rule
4. A match is an expression: typing and completions
5. Case facts and arm scopes
6. Payload bindings and their types
7. Ownership: affine scrutinees, partial bindings, cleanup
8. The HIR representation and its validation
9. Tcl and native lowering (and the C backend)
10. Generic helpers and semantic-instance rollback
11. Static decisions
12. Diagnostics
13. The independent model and the fuzzer
14. Mutation testing
15. Regression and CI
16. The mid-end kernel with payload-bearing nodes
17. Performance and allocations
18. Remaining limitations and later work
19. Files
20. What to run when changing this

## 1. The starting point and the gaps

**(inspection)** PORTABILITY-PAYLOAD-ENUMS-MILESTONE-1.md left an enum
whose values could be constructed, passed, stored, compared and hashed, and
whose payload could not be read back: "Reading a payload (case selection,
payload binding, projection): the next milestone's `match`. Nothing here
offers a substitute." What it provided, and this milestone uses:

* the closed case set and each case's payload fields with resolved types
  (`hir::enums::cases`, `fields`, `payloadType`, `hasPayload`);
* case identity carried by every value on every backend: the Tcl value
  `{enum ID CASE PAYLOAD}` (a payload-free case `{enum ID CASE}`), natively
  an immediate word for a payload-free case and an `EnumCaseObj` for a
  payload-bearing one, both read by `enum_case_parts`;
* a payload that is an ordinary anonymous struct value, so a selected
  case's fields can be bound by the existing struct destructuring
  (STRUCT-DESTRUCTURING.md);
* exact-case facts (`hir::enums::caseFact`);
* affinity derived from the payloads, and drop descriptors that release an
  affine enum by its case.

The gaps were the construct itself (syntax, a representation every
analysis and backend understands), a static exhaustiveness check, a way to
select a case that is not `==` (an affine or non-Equatable enum has no
equality), payload extraction that cannot read another case's payload, and
ownership rules for consuming an affine scrutinee. One existing analysis
also needed a precision fix (section 7): the ownership analysis did not
know that an `if true:` block always runs.

## 2. Syntax, and the alternatives rejected

**(inspection)** The brief's syntax, unchanged (surface/parser.tcl's
`Match`, `MatchCaseName`, `MatchArmError`):

```
match        = "match" expression ":" NEWLINE INDENT arm { arm } DEDENT
arm          = "case" caseName [ IDENT | pattern ] ":" suite
caseName     = [ "::" ] IDENT "::" IDENT { "::" IDENT }
```

* **Payload forms**: none (`case E::C:`), the whole payload
  (`case E::C p:`), or struct destructuring's pattern (`case E::C {a, b: c,
  d: {x}}:`) -- exactly the three forms an `on` handler gives an error's
  payload (ERROR-PAYLOADS.md), so no second binding language exists.
* **Contextual words.** `match` is recognized only where a statement or a
  statement's value starts (`AtMatch`): directly followed by a name, a
  literal, `not`, `true`, `false`, `unit` or a rooted `::` -- an adjacency
  no expression allows -- or, after `(`, `[`, `{` or `-` (which an ordinary
  name `match` may be followed by: a call, an imprint, a construction, a
  subtraction), only when its logical line ends with `:` and the indented
  block after it starts with the word `case`. `case` is a word only as an
  arm's first token. `match = 1`, `match(x)`, `x.match`, a field named
  `match`, and stdlib/test.bot's `case(name, check)` keep their meanings
  (`em-contextual-words`). Both words are in `surface::parser::words`
  (recorded in the token IR, highlighted by the generated Vim and TextMate
  grammars); `_` joined `refusedWords` (compared only to refuse
  `case _:`).
* **Positions.** Like an `if`: a statement, or the value of `=`, `return`
  or a destructuring (`em-match-in-value-positions`); not inside an
  expression (`acc + match ...` is a syntax error, as `acc + if ...` is).
  Arms are suites (a body starts on a new line).
* **Qualified case names** use the existing qualification: `Node::Add`,
  `geo::Shape::Dot` after `import geo`, `Shape::Dot` after `import type
  geo::Shape`. The case name is a `qualname` AST node, a child of the
  match node, so the loader's one walk (surface/modules.tcl's `Walk`)
  checks it and rewrites a package's namespace to its identity as it does
  every qualified reference. A rooted qualifier is a namespace path, as for
  every value reference (`::Node::Param` is the loader's UNKNOWN-NAMESPACE).

Rejected, each with a parser message naming what exists instead
(`em-syntax-errors`): a wildcard (`case _:`) and a default (`else:`), a
bare case name, a literal, a guard (`if`, `where`), several cases in one
arm (`,`, `|`), a positional payload (`case E::C(a)`). Rejected as
alternatives to the syntax itself:

* **`on` for arms**: `on` is error handling; a match is not one.
* **A wildcard arm**: the milestone's central guarantee is that adding a
  case makes every match that does not handle it a compile-time error.
* **A general pattern framework** (nested enum patterns, literals, guards):
  out of scope by the brief; nested matches compose instead.

## 3. The exhaustiveness rule

**(inspection)** hir/match.tcl's `Check`, after typing, for every match:

1. The scrutinee's static type is read in the program's own typing walk
   (never a semantic instance's), refinements removed. If it is poison or
   `never` (an earlier diagnostic, or unreachable code), no type rule is
   stated; the arms are still held to one enum and to naming its cases once.
2. A type that is not `{enum E}` -- `any` (an untyped parameter's value), a
   non-enum, a join of two enums (which is `any`) -- is a **TYPE** error at
   the scrutinee: a match never tests a type at run time
   (`em-coverage-diagnostics`).
3. An arm whose case belongs to another enum is a **TYPE** error naming both
   enums: identity is nominal, never the spelling (two enums may both have a
   case `Idle`).
4. A case named by two arms is **MATCH-DUPLICATE-CASE** at the later arm,
   naming the earlier one's location as a related location.
5. Every case of `EnumCases(E)` -- the declared, closed set the registry
   keeps -- not named by an arm is **MATCH-NOT-EXHAUSTIVE** at the match,
   listing the missing cases in E's declaration order.
6. An arm whose case name resolution could not resolve (MATCH-NOT-A-CASE,
   UNKNOWN-ENUM-CASE, reported at resolution) suppresses rule 5: the
   missing case would only restate that mistake (`Idel` for `Idle`).

Coverage is the declared case set, whatever the analyses know of the value:
a constant scrutinee still needs every arm (`em-exact-case-still-exhaustive`).
An enum of one case needs one arm. Arm order is irrelevant to every rule.

## 4. A match is an expression: typing and completions

**(inspection, observed)** A match evaluates its scrutinee once, binds it,
selects the arm of its case, binds that arm's payload, runs the arm and is
the arm's value. Since the arms are an `if` chain (section 8), the match's
type is the join of the normally completing arms' types by the existing
`lub` (`hir::types::If`), a match whose every arm leaves has no normal
completion (`em-never`), and nonlocal completions -- `return`, a declared
failure with its payload, `break`, `continue` -- propagate exactly as from
an `if` branch (`em-completions`). A failure of the scrutinee propagates
before any arm runs (the scrutinee is the first statement of the block). No
arm is tested after another observably (`em-scrutinee-once` logs every
evaluation: the scrutinee once, the selected arm only), and no implicit
failure exists for an unmatched value: a match is proven exhaustive, and the
chain's end (`enum#unmatched`) is a placeholder for code that cannot run
(section 8).

## 5. Case facts and arm scopes

**(inspection)** An arm's selection is the condition of its own `if`, so
its bindings live in that `if`'s then-branch scope: visible only inside the
arm (an arm's name used after the match is UNBOUND), never colliding with
another arm's (`em-binding-types` binds `value` as an Int in one arm and a
String in another). The case an arm established is a fact of its own
position, not a type: inside the arm, the payload is the arm's binding,
typed as the case's declared payload (section 6); the scrutinee keeps its
enum type. `hir::enums::caseFact` is not consulted by the checks (rule 5
above) and no selection is folded statically yet (section 18).

## 6. Payload bindings and their types

**(inspection)** An arm's payload is bound to `enum#payload(match#N, "ID",
"CASE")`, whose result type is the case's declared payload type --
`hir::enums::payloadType`, the canonical anonymous struct of its fields --
or `unit` for a payload-free case (`hir::types::ShapeResult`'s
`enum-payload`). The pattern forms then project from it by the ordinary
destructuring rules, so field selection by name, renaming, nested patterns,
partial selection, UNKNOWN-FIELD and DUPLICATE are struct destructuring's
own. A binding has exactly its field's declared type: an Int, a String, a
struct, a callable with its contract (`em-non-equatable-payloads` calls a
payload's `Fn{args: [int], return: int}`), a MutableVector (bound as the
arm's own logical copy, `em-unrestricted-reuse`, `em-payload-vector-whole`),
an affine value. A payload-free case binds nothing: a name or a pattern is
ENUM-PAYLOAD-UNEXPECTED, reported at the binding. An unknown payload field
is UNKNOWN-FIELD worded for the case ("the payload of case R::Number has no
field "count" (its fields: value)"), never as an anonymous struct.

The callable-contract analysis (hir/callables.tcl's `ArgContexts`) keeps
the scrutinee's contracts through both selections (`enum-test`,
`enum-payload` shapes): the test reads only identity, the payload leaves at
its declared type.

## 7. Ownership: affine scrutinees, partial bindings, cleanup

**(inspection)** Ownership is the existing discipline (AFFINE-VALUES.md)
applied to an ordinary chain:

* `match#N = SCRUTINEE` moves an affine scrutinee into the match: the
  source binding is moved (a later use is USE-AFTER-MOVE,
  `em-affine-match-consumes`). An unrestricted one is copied logically,
  and stays usable (`em-unrestricted-reuse`).
* `enum#is` *observes* the scrutinee (ownership role `observe`): the next
  arm's selection reads it again.
* `enum#payload` *moves* it (role `move`), and **every arm takes the
  payload** -- an arm that binds nothing binds it to a hygienic
  `match#N#K` -- so an affine scrutinee is moved on every path. That is
  what makes a resource's scoped release well defined: a payload-free arm
  of an enum whose other case holds a resource moves the scrutinee too,
  never AFFINE-PATH-RELEASE-UNSUPPORTED (`em-resource-payload`).
* A destructured payload is a destructuring temporary (`destructure#N`):
  the bound affine fields move out of it, the unbound ones are released
  when it dies, by the payload's descriptor -- for a resource, at the end of
  the arm (its sequence), after the arm's own code; a whole-payload binding
  owns everything and releases it after its last use's statement; an
  ignored payload is released at once (`em-affine-releases`, which reads
  the Tcl runtime's live coroutines and the native release counters).
* Early exits release what the arm owns, exactly once (`em-affine-early-
  exits`: a declared failure, a `return`, a failing scrutinee); a payload
  held across a yield inside an arm survives the suspension
  (`em-coroutine-suspension`).

**The one change to the analysis.** The match's block is `if true:` (the
idiom of inject blocks and accepted static blocks). The ownership analysis
used to join both branches of every `if`, so a binding moved inside the
block was only "maybe moved" after it (AFFINE-NOT-DEFINITELY-LIVE instead
of USE-AFTER-MOVE, and a path release placed in the dead `else`).
hir/affine.tcl's `Flow` now treats the branch a constant condition never
takes -- a reference to the root `true` or `false`, the constants a front
end writes, never a value an analysis decided (`ConstantCondition`) -- as
reaching no join. This is a precision improvement for inject blocks too; it
makes no program unsound (the untaken branch never runs) and only turns a
"maybe moved" into "moved" after an `if true:`, or "live" after an `if
false:` whose branch moved it. **(observed)** tests/affine.test (48),
tests/coroutines.test (81), tests/payload-enums.test (41) and
tests/enums.test (66) pass with it.

## 8. The HIR representation and its validation

**(inspection)** A match is no node kind. surface/lower.tcl's `Match`
writes, and hir/resolve.tcl's `MatchSyntax` resolves:

```
if ^true:                                   carries `match 1`
    match#N = SUBJECT                        once
    if ^enum#is(match#N, "ID", "C1"):        arm 1's selection
        P1 = ^enum#payload(match#N, "ID", "C1")
        ...the pattern's projections...
        BODY1...
    else:
        if ^enum#is(match#N, "ID", "C2"):
            ...
        else:
            ^enum#unmatched()
```

The three selections are internal root natives (core/enums.tcl; no source
spells a `#` name): `enum#is` (a Bool; result shape `enum-test`, role
`observe`), `enum#payload` (shape `enum-payload`, role `move`) and
`enum#unmatched` (shape `never`). Every arm is tested -- the last too -- so
a payload is always taken under its own test, and the chain ends in a
placeholder that a proven-exhaustive match never reaches (it raises
UNMATCHED; natively a runtime error, in C a status). The written case names
travel on the selections' `matchCase` field until resolution resolves them
(`hir::enums::lookup` from the code's namespace, the visibility of a case
expression's qualifier); the two String constants then hold the enum's
declaration identity and the case.

Why this and not a node kind: every analysis and backend (completions,
types, ranges, ownership, logical copies, contexts, coroutines, the four
backends, the C backend) already understands `if`, `bind`, calls and
projections; a new node would have been a case in some forty walkers, each
a chance to approximate. What none of them can see -- that the arms cover
the enum -- is one check over a recognized shape (hir/match.tcl).

**Validation.** `hir::match::chain` recognizes the shape exactly: the
`if true` block with `match`, the scrutinee's binding, each level's
`enum#is(ref match#N, ID, CASE)` whose then-branch starts with the binding
of `enum#payload(ref match#N, ID, CASE)` of the same case, ending in
`enum#unmatched()`. In every compilation (`hir::match::verify`, in
`hir::CheckOnce`) a malformed chain or an `enum#payload` call that is no
arm's payload is MATCH-INVALID, an internal diagnostic. Every reader of HIR
it did not build checks again (`hir::match::validate`: the shape, one
declared enum per match, each of its cases named exactly once, every
payload under its own selection) -- HIR text (hir/read.tcl: HIR PARSE) and
interchange (`hir::interchange::decode`: HIR INTERCHANGE MATCH; the
front-end cache treats a refused entry as a miss) -- so text never claims
exhaustiveness (`em-hir-roundtrip`, `em-interchange-forged`). HIR text
prints a match's block as `if match`. And `enum#payload` checks the
identity at run time on every backend (`em-tcl-selection-identity`, the
Rust test `enum_selection_reads_identity_never_payload`): a program run
despite a rejected match (a lenient build) fails there, never reading
another case's payload.

## 9. Tcl and native lowering (and the C backend)

**(inspection)** The Tcl interpreter and the Tcl compiler call the
selections like any native: `enum#is` compares the value's ID and case
names (core/enums.tcl's `isImpl`, never `core::value::equal`),
`enum#payload` returns the fourth component or unit.

Native lowering (native/lower.tcl's `EnumSelection`):

* a selection on a value whose every possible value is an immediate word
  (`ImmediateEnum`: an enum with no payload-bearing case) is the inline
  word comparison `op enumeq VALUE WORD` against the case's word -- no
  helper, no allocation;
* any other is `op enumis VALUE E C` (runtime::ops's `rt_enum_is`: an
  immediate word's or an EnumCaseObj's (enum, case) against E and C);
* a payload-free case's payload is the unit constant, with no operation; a
  payload-bearing case's is `op enumpayload VALUE E C` (`rt_enum_payload`:
  one field read after the identity check; it allocates nothing, so no
  collection can run while the payload is in hand);
* `enum#unmatched` is `op enumunmatched` (an UNMATCHED runtime error).

E and C are the program's enum and case numbers, representation only, read
from the call's constants (`em-native-shape` checks which operations appear).
The C backend (C-COMPILE-FREESTANDING-MILESTONE-1.md) compiles payload-free
matches -- its enum subset -- as comparisons with the enumeration
constants, the unmatched end as a status (`em-c-backend`; the C compiles
warning-free under `-Wconversion`); a payload enum remains C UNSUPPORTED
where it is typed, as before. No C layout, transfer encoding or export ABI
for payload enums was added.

## 10. Generic helpers and semantic-instance rollback

**(inspection, observed)** A match is checked once, in the generic walk.
An untyped parameter used as a scrutinee is `any` there and is rejected
(TYPE): a match never becomes a dynamic type test, and its contract is never
inferred from its arms. Generic helpers called inside arms are instantiated
per argument type as anywhere else (`em-generic-instances`: a helper
returning its argument in a List, called with an Int and a String from
arms of matches over two enums). SEMANTIC-INSTANCE-SCALABILITY-MILESTONE-1's
walks type the program's HIR in place and undo what they wrote; a match
writes no HIR field while it is typed (`MatchSyntax` writes the constants at
resolution; the selections' types are pure functions of them and the
registry), so there is nothing to undo. **(observed)**
tests/exhaustive-match.test passes under `BOTLISH_SEMANTIC_ROLLBACK_AUDIT=1`
(23 of 23 when run; `em-rollback-audit` enables the audit for nested
matches calling a generic helper with values of two enums), and
tests/semantic-instances.test passes (96).

## 11. Static decisions

**(inspection)** The match check reads the types of expressions of its own
region (the scrutinee's) and the enum registry (top-level declarations,
which no static block holds). hir/staticdeps.tcl's region graph already
makes a site's diagnostics depend on everything its region mentions --
its bindings, call targets, their summaries -- so no new edge or channel
was needed. **(observed)** `em-scheduler-parity` decides an accepted block
and blocks rejected for a missing case, a duplicate and an untyped
scrutinee identically under the batched scheduler and the sequential
reference; the golden suite puts every test in a `static compile:` block.
The CI comparison over every golden suite is in section 15.

## 12. Diagnostics

**(inspection)** Three new kinds, each with a `std::compiler::DiagnosticCode`
case (`MatchNotExhaustive`, `MatchDuplicateCase`, `MatchNotACase`), a row
of `hir::static::codes` and a Compilerpedia topic with a rejected example;
one internal kind (MATCH-INVALID, classified internal in
tests/static-compile.test's census); one run-time kind (UNMATCHED, with its
topic); one interchange refusal (HIR INTERCHANGE MATCH, with its topic).
Existing kinds where they describe the failure:

| condition | diagnostic |
|---|---|
| missing cases | MATCH-NOT-EXHAUSTIVE at the match, missing cases in declaration order |
| a case named twice | MATCH-DUPLICATE-CASE at the later arm, the earlier one related |
| unknown case | UNKNOWN-ENUM-CASE at the arm, with suggestions |
| a qualifier that is no enum type | MATCH-NOT-A-CASE at the arm |
| a case of another enum | TYPE at the arm, naming both enums |
| a non-enum or untyped scrutinee | TYPE at the scrutinee |
| a missing arm body, a wildcard, a guard, ... | located syntax errors |
| a payload bound for a payload-free case | ENUM-PAYLOAD-UNEXPECTED at the binding |
| unknown payload field, duplicate binding, bad nested pattern | UNKNOWN-FIELD (worded for the case), DUPLICATE, the destructuring's |
| an arm's binding used outside it | UNBOUND |
| an affine scrutinee used after the match | USE-AFTER-MOVE ("moved here: j matched by a match") |

Syntax recovery (`-check`, the language server) treats a malformed match
like any statement: the innermost statement holding the damage becomes a
hole (surface/recover.tcl walks the arms' suites).
`capability.match` -- which said "There is no switch or match statement" --
is rewritten as the documentation of the construct (its ID kept), and
`concept.enums` no longer says a payload cannot be read back.

## 13. The independent model and the fuzzer

**(inspection)** audit/exhaustive-match/tools/fuzz.tcl draws programs: one
to three enums (case names overlapping across enums; payload-free and
payload-bearing cases; Int, String and Bool fields), one to three functions
each matching a parameter of one enum with arms in a random order, each
arm's payload received in a random form (none, whole, destructured fully
or partly, renamed), its body an Int computed from what it bound, a
`return`, a declared failure with a payload, or a nested match over a
second parameter of another enum whose arms also read the outer arm's
bindings. Each function is called on random values. The model is the
tool's own -- a value is `{ENUM CASE {FIELD VALUE ...}}`, selected by
(enum, case) and evaluated from the arm's bindings, never through the
compiler -- and every backend must agree with it. With probability
`-faults` percent a program carries one mistake and the model predicts the
rejection's code instead: a missing arm, a duplicate, another enum's case,
an untyped scrutinee, a non-enum scrutinee, an unknown case, a payload
bound for a payload-free case, an unknown payload field.

**(observed)** 200 programs with seed 2: 150 accepted and agreeing on the
four backends, 50 rejected as predicted; 200 with seed 3: 136 and 64; 100
with seed 4 under `-gc-stress 1`: 63 and 37; 40 with seed 1: 26 and 14.
0 disagreements.

## 14. Mutation testing

**(observed)** audit/exhaustive-match/tools/mutate.tcl applies each of the
26 mutants of mutants.txt to a private copy (rebuilding a private native
backend for the two Rust mutants) and runs tests/exhaustive-match.test,
the fuzzer (40 programs, seed 11) and, for a native mutant, `cargo test
--lib enum`. MUTATION-RESULTS

The catalog's header lists what is deliberately not mutated, with the
reason: a binding escaping its arm and an arm left out of the join or
losing its completion (ordinary `if` and scope rules, mutated by their own
harnesses), an unrooted native payload (nothing allocates while it is
held), rollback residue (a match writes no field while typed).
`tools/mutant-catalogs.tcl`: 109 catalogs, 3,741 mutants, 0 problems --
every existing mutant still applies after this milestone's edits.

## 15. Regression and CI

REGRESSION-RESULTS

## 16. The mid-end kernel with payload-bearing nodes

**(inspection)** audit/mid-end-port/kernel/ranges-enums.bot is
ranges-structs.bot with one change: the node. Where ranges-structs.bot has

```botlish
enum Kind:
    Const, Param, Add, If, Call,

struct Node:
    kind: Kind
    a: int
    b: int
    c: int
```

and an evaluator testing `kind ==` each case and reading `a`, `b`, `c` by
convention, ranges-enums.bot has

```botlish
enum Node:
    Const {value: int},
    Param,
    Add {left: int, right: int},
    If {condition: int, yes: int, no: int},
    Call {function: int},
```

and an evaluator that matches `nodes.at(i)` and binds only the selected
case's fields. The generator (the same LCG, seed 42, the same recursion and
the same pushes), the side tables, the rounds, the widening after round 6
and the checksum are unchanged; the other five versions are untouched.
audit/mid-end-port/tools/kernel.tcl gained the version and checks that all
six compute one value.

**(observed)** 1,500 functions, depth 8, best of 5:

KERNEL-TABLE

The payload-enum version computes the committed reference -- 455,468
nodes, 6 rounds, checksum 275164515 -- and so do the five others; at 40
functions and depth 6 it agrees with the struct version on all four
backends ([3275, 8, 955339119]). The payload-enum version is not slower:
its construction costs two allocations per payload-bearing node (the
payload struct and the EnumCaseObj, as the payload milestone measured)
where the struct version's node is one struct, but the evaluator reads one
selection and the bound fields instead of a Kind comparison chain and
three generic fields, and `Param` is an immediate word.

## 17. Performance and allocations

**(observed)** bench/exhaustive-match.tcl, natively (Cranelift, JIT
compile excluded), N = 200,000 operations per program, best of 5; time per
operation over the baseline that makes the same value and keeps it, the
whole program per operation in parentheses:

MATCH-BENCH-TABLE

Every match program allocates exactly what its baseline does (the
allocation table): a selection, a payload read and a binding allocate
nothing, and a match over a payload-free enum, or a payload-free case's
value, involves no EnumCaseObj. A payload-free match is the inline word
comparison; a payload match is two runtime helper calls on the selected
arm's path (one `rt_enum_is` per arm tested before it, one `rt_enum_payload`)
-- the chain is as long as the arms (`em-many-cases`: 120 arms, 120
selections), so selecting the last of 32 cases costs 32 tests. Compilation
is linear in the arms (one `if` per arm).

## 18. Remaining limitations and later work

* **Positions.** A match is a statement or a binding's, return's or
  destructuring's value, not an operand inside an expression (as for `if`).
* **No patterns beyond one case per arm**: no wildcard, default, guard,
  alternative, literal, range, positional or nested enum pattern, by the
  brief; nested matches compose.
* **Untyped scrutinees are rejected**, never inferred: a generic helper
  that matches needs its parameter annotated.
* **Selection is a chain.** Natively a payload match calls `rt_enum_is`
  per arm tested and `rt_enum_payload` once; a jump on the case number (or
  inline tests of the word and the object's two numbers) would make a long
  match constant-time and avoid the calls. (projection: the kernel's
  evaluator would gain little -- its time is dominated by allocation, as the
  mid-end audit's callgrind profile shows for the struct version.)
* **No static selection.** A scrutinee known to be one case
  (`hir::enums::caseFact`) still runs its chain; folding it (and typing the
  other arms unreachable) is the brief's optional optimization, not done:
  coverage must not depend on it, and the gain is one test.
* **Payload representation** is the payload milestone's: two allocations
  per payload-bearing value, the payload materialized as a struct. An
  EnumCaseObj with inline fields, or scalar replacement of a value that
  does not escape, would remove the payload struct; neither is needed for
  correctness.
* **Not changed, by the brief**: payload enums stay refused by the C
  backend, C exports, the value transfer (not Sendable) and a context
  struct's native layout; no generic enums.

## 19. Files

* Surface: surface/parser.tcl (`AtMatch`, `Match`, `MatchCaseName`,
  `MatchArmError`; the words `match`, `case`; `_` refused),
  surface/ast.tcl (the `match` node's ids, children, mapping, text),
  surface/lower.tcl (`Match`, `MatchCall`), surface/recover.tcl.
* HIR: hir/match.tcl (new), hir/hir.tcl (`hir::match::verify` in
  `CheckOnce`), hir/resolve.tcl (`MatchSyntax`, `MatchSelection`, the
  `matchCase` problems), hir/types.tcl (`enum-test`, `enum-payload`),
  hir/callables.tcl, hir/affine.tcl (`ConstantCondition`, `IsMatchTemp`),
  hir/structs.tcl (the payload's UNKNOWN-FIELD wording), hir/format.tcl and
  hir/read.tcl (`if match`, the reader's validation), hir/interchange.tcl,
  hir/static.tcl (three codes).
* Core: core/enums.tcl (`enum#is`, `enum#payload`, `enum#unmatched`),
  core/native.tcl (the shapes); stdlib/compiler.bot, stdlib/test.bot (the
  codes).
* Native: native/lower.tcl (`EnumSelection`), native/src/nir.rs,
  native/src/codegen/clif.rs, native/src/runtime/ops.rs (`rt_enum_is`,
  `rt_enum_payload`, `rt_enum_unmatched`, a unit test).
* C backend: ccompile/ccompile.tcl.
* Tests: tests/exhaustive-match.test (new), tests/golden/exhaustive-match.bot
  (new), tests/static-compile.test, tests/golden-framework.test,
  tests/stdlib-namespaces.test, tests/golden/manifest.tsv,
  audit/golden/migration/{census,fragments}/exhaustive-match.tsv,
  audit/golden/migration/tcl-names.txt.
* Audit and benchmark: audit/exhaustive-match/tools/{fuzz.tcl,mutate.tcl,
  mutants.txt} (new), audit/mid-end-port/kernel/ranges-enums.bot (new),
  audit/mid-end-port/tools/kernel.tcl, audit/mid-end-port/README.md,
  audit/depth-safe-nesting/census.tsv, bench/exhaustive-match.tcl (new).
* Editors: tools/editor-grammars.tcl, the generated grammars and the
  fixture.
* Docs: this file, ENUMS.md, README.md, INDEX.md, AGENTS.md, the root
  README; Compilerpedia (`capability.match`, `concept.enums`,
  `error.match-not-exhaustive`, `error.match-duplicate-case`,
  `error.match-not-a-case`, `error.match-invalid`, `error.unmatched`,
  `error.hir-interchange-match`).

## 20. What to run when changing this

`tests/exhaustive-match.test` (also with
`BOTLISH_SEMANTIC_ROLLBACK_AUDIT=1`), `tclsh9.0 tests/local.tcl
tests/golden/exhaustive-match.bot`, `tests/payload-enums.test`,
`tests/enums.test`, `audit/exhaustive-match/tools/fuzz.tcl` (several
seeds, once with `-gc-stress 1`), `audit/exhaustive-match/tools/mutate.tcl`
(every mutant must still apply and be killed), `cargo test --release
--manifest-path native/Cargo.toml --lib enum`; for a change to
hir/affine.tcl the affine and coroutine harnesses (AGENTS.md); for a
diagnostic `tools/compilerpedia.tcl check`, tests/static-compile.test and
tests/golden-framework.test; for the parser's words
tests/syntax-highlighting.test and `tools/editor-grammars.tcl check`.
`audit/mid-end-port/tools/kernel.tcl` and `bench/exhaustive-match.tcl`
regenerate sections 16 and 17.
