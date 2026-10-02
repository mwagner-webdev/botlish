# Struct destructuring

```
{user, expires} = result
{user: current_user, expires: expiry} = result
{user: {name, id}, expires} = result
```

Struct destructuring binds fields by name. It creates ordinary value bindings;
it does not create references into the source struct. Fields may be omitted or
renamed.

Lists are intentionally not destructured positionally. APIs returning
heterogeneous values should prefer struct values with named fields.

The guiding principle: destructuring is not pattern matching. It is one struct
value, selected fields read by name, those field values bound. It does not
expose positions, it does not expose storage locations, and it does not
manufacture the remainder.

| intent | the language's answer |
|---|---|
| a sequence of values | `List` |
| a heterogeneous structured result | a struct value with named fields |
| consume selected fields of one | struct destructuring |

## Syntax

```
destructure       = pattern "=" valueOrHandled          -- a statement
pattern           = "{" field { "," field } [ "," ] "}"
field             = IDENT                               -- {a}        = {a: a}
                  | IDENT ":" IDENT                     -- {a: b}     field a, bound as b
                  | IDENT ":" pattern                   -- {a: {b}}   nested
```

* **The left name is the field, the right name is the binding.** In
  `{original: renamed} = value` the field read is `original` and the binding
  made is `renamed`. This mirrors `field-name: binding-name` and is the
  opposite of nothing else in the language: a struct literal's `name: value`
  also has the field on the left.
* The source (the right of `=`) is whatever the right of an ordinary binding
  may be: an expression, a call, a method call, an `if`/`loop` value, a handled
  call (`{a, b} = f(): on Oops: ...`).
* A pattern is recognized only at the **start of a statement**, followed by
  `=`: `parser::PatternAhead` scans the bracketed group and looks at the token
  after it. A braced statement not followed by `=` is still an anonymous struct
  value, and every other use of `{` and `[` (struct and List literals, `==`,
  arguments, ...) parses exactly as before. Nothing reinterprets a List literal
  globally.
* **Trailing comma:** accepted, as in a struct literal (`{a, b,} = v`).
  Patterns may span lines, as struct literals may.
* **Empty `{} = v` is rejected** ("must select at least one field"): it would
  bind nothing and is a disguised expression statement.
* Field names are ordinary identifiers, exactly as in struct literals and
  declarations (keywords are rejected with the same message). Nothing was
  widened or narrowed for destructuring.

### Deliberately absent (each is a syntax error with its own message, never a
silently different construct)

| written | result |
|---|---|
| `[a, b] = v`, `{p: [a, b]} = v` | `LIST-DESTRUCTURING` (below) |
| `{a, ...rest} = v` | "rest/spread binding is not supported ... produces no remaining-fields value" |
| `{a = 1} = v`, `{a: default 1}` | "a struct destructuring has no default values" / ordinary pattern error |
| `{a, _} = v` | `_` is an ordinary identifier: it requests a field named `_` (`UNKNOWN-FIELD`); there is no wildcard |
| `{ref a}`, `{&a}`, `{mut a}` | pattern errors (`&` is not even a token); no reference mode exists |
| `{obj.a} = v`, `{a: obj.x} = v` | pattern errors; the right side names a new binding, never existing storage |
| `Struct(a, b) = v`, `(a, b) = v` | "only a name can be bound" / syntax error: no positional struct destructuring |

## The semantic theorem

> `{field: local, ...} = value` is valid exactly where
> `tmp = value; local = tmp.field; ...` would be, and means exactly that.

* `value` is evaluated **once**, into a hygienic temporary, before any field is
  read.
* Each requested field is then an ordinary static projection `tmp.field`
  (STRUCTS.md), bound under its local name with an ordinary binding, **in
  written order**. The written order of the pattern is the read order; it is
  documented here and nothing stronger is promised, because with immutable
  structs reads are unobservable. No user code can run between reads (a
  projection is direct value access).
* Field selection is **by name**. Declaration/storage order, and the order of
  the pattern, are irrelevant: `{a, b}` and `{b, a}` select the same fields.
* **Partial destructuring is the normal model.** The requirement is
  *requested fields ⊆ fields of the source struct*. There is no closed/open
  distinction, so adding a field to a returned struct never breaks a consumer
  that does not name it. Omitted fields are not bound anywhere and nothing is
  built from them.
* The source struct is only read; it is preserved.
* The statement has no value of its own beyond ordinary bindings: where a
  statement's value is observable (the last statement of a body) it is the
  value of the last binding the explicit spelling would make, i.e. the last
  field value read. It is not the source, a List of the bound values, or a
  narrowed struct.

### Named and anonymous structs

Identical. Destructuring never asks whether the source type has a name; it asks
the ordinary projection question (struct-like type with that field). A named
struct is destructured by its declared fields, an anonymous one by the fields it
was constructed with, through the same `hir::structs::ProjectionProblem`.

### Bindings, not references

`{count} = value` creates an ordinary value binding `count`. It is not a
reference to, borrow of, alias of, view of or proxy for `value.count`. This is a
hard invariant, and the design needs no change for mutable structs, which do not
exist yet:

* If a future language allowed `mutable_value.count = 10`, then
  `{count} = mutable_value` followed by that assignment leaves `count`
  unchanged, and rebinding `count` never writes `mutable_value.count`:
  destructuring reads field **values**, not storage locations. The lowering
  already says so: `count = tmp.count` is a read of a value into a new binding.
* If a field's value is itself a mutable value (a `MutableArray` field, which
  can be tested today), the binding denotes that same value under that type's
  ordinary semantics: `{items} = h` then `mutable_array_set(items, ...)` is seen
  through `h.items`. What it must not denote is the slot `h.items`: re-pointing
  the slot later must not retarget `items`.
* There is no reference, `ref`, `&` or `mut` binding mode; destructuring adds no
  lvalue mechanism and no assignment-through-pattern. A destructured name is a
  *new* binding at its source position; `{a: existing} = v` is the ordinary
  `DUPLICATE` binding error, not a mutation of `existing`.

## Lists are intentionally not destructurable

`[a, b] = value` is rejected with the dedicated diagnostic **`LIST-DESTRUCTURING`**:

```
LIST-DESTRUCTURING: positional List destructuring is not supported; use a struct
value with named fields instead (a List is for a sequence of values; have the
function return a struct, e.g. `result = get_result()` then
`{value, error} = result`)
```

* This is a **language policy**, not an unfinished feature: do not "complete"
  destructuring by adding List patterns, and do not leave an undocumented parser
  path that happens to accept them (there is none: the only path that sees `[`
  in binding position is the diagnostic).
* The message names the design direction (a struct with named fields) rather than
  saying "unsupported", and does not disparage Lists: they remain the right type
  for homogeneous/sequence data, and `list_get(xs, i)` / `xs.list_get(i)` and all
  List APIs are untouched.
* Recognition is syntactic and positional: a bracketed group followed by `=` at
  the start of a statement, and, nested, `field: [` inside a pattern. It carries
  the stable code in the syntax diagnostic's `code` entry and at the start of its
  message. Repository convention for *semantic* diagnostics is the kind in the
  error code (`{CORE SEMANTIC KIND}`); a syntax error has no kind slot
  (`{SURFACE SYNTAX DIAGNOSTIC}`), so the stable name is the diagnostic's `code`,
  and `-recover 1` parsing reports it like any syntax error and continues.
* `{a} = some_list` is **not** this error: it requested a named field, so it
  gets the ordinary `NOT-A-STRUCT` projection error.
* No Tuple/Pair/product type is introduced; struct values remain the named
  product.

### No rest value, and narrowing is a separate operation

`{a, ...rest}` is rejected. A rest binding would construct a new struct holding
all fields but the selected ones: a distinct structural transformation with its
own materialization, representation, field-set, ownership, type and cost
semantics. If Botlish later wants "a struct containing only fields X, Y, Z" it
must be designed as its own operation; destructuring is not reserved as an
implicit way to do it.

## Normalization: where destructuring disappears

The surface AST keeps a `destructure` node (printing, spans, ids, diagnostics),
exactly as `elif` and method-call sugar are kept. It disappears in
**`surface::lower`** (`Sequence`, `Destructure`, `Projections`): a destructure
statement lowers to ordinary syntax nodes spliced into the enclosing sequence:

```
{a, b: c} = e          tmp = e
                       a = tmp.a
                       c = tmp.b
```

i.e. one `bind` of a hygienic temporary to the source, then one `bind` of an
ordinary `project` of a `ref` of the temporary per field. A nested field is
`tmp2 = tmp.field` and recursion on `tmp2`.

* The temporary is named `destructure#N` (`N` the pattern's start offset in its
  file): it contains `#`, which source can never spell, so it cannot collide
  with or capture a user name, and no user-visible binding denotes it. It is not
  a source binding; the existing hygiene pass handles it like any `NAME#N`
  rename. It does appear where HIR bindings are listed (`hir::format`, and
  `main.tcl -backend compile`'s program-level type listing); that is the
  compiled form, not a source name.
* **HIR has no destructuring abstraction.** The HIR a destructure produces is
  node-for-node the explicit spelling's (`tests/struct-destructuring.test`
  compares the formatted HIR, modulo the temporary's name). The resolver, struct
  analysis, typing, specialization, range, escape, construction, cardinality,
  AOT and callable analyses never see anything but `bind`, `project`, `ref`.
* **The interpreter, the Tcl compiler and `native/` are unchanged**: no
  destructuring evaluator, no runtime helper, no NIR operation. Core IR and NIR
  are the explicit spelling's.

### Evaluate once

The source is the initializer of one `bind`; every projection reads the
resulting binding. Nothing in the lowering repeats the source expression (it is
never lowered as `source.a, source.b`). Under every backend the call count and
side-effect order are those of the hoisted explicit spelling
(`destructure-once-*` tests, probe logs).

### Syntax errors and static errors

| defect | diagnostic | where |
|---|---|---|
| `[a, b] = v`, nested `[..]` | `LIST-DESTRUCTURING` | parser, at the List pattern |
| same field twice (`{a, a}`, `{a, a: x}`) | `DUPLICATE-FIELD` (syntax) | parser, at the second selection |
| `{a: x, b: x}`, or a name already bound in the scope | ordinary `DUPLICATE` binding error | the second binding written |
| missing field | ordinary `UNKNOWN-FIELD` | the field name in the pattern |
| non-struct source (Int, String, List, function, unit, ...) | ordinary `NOT-A-STRUCT` | the field name in the pattern |
| struct type not provable | ordinary `UNPROVEN-FIELD` (or its instance error) | the field name in the pattern |
| `{}`, `...rest`, defaults, ... | syntax errors | as above |

Static errors are the *projection's own*: the explicit spelling is rejected
with the same kind and message (compared by tests and by the negative fuzzer),
and nothing becomes a run-time match. An unknown shape stays rejected exactly
as `value.field` would, and a function whose generic body cannot prove the
field is cured only by the semantic instances that already cure `x.field`.

### Source locations and ids

* Each requested field's projection has the field's entry as its origin and the
  **field name written in the pattern** as its `nameOrigin`, which is where
  `UNKNOWN-FIELD`/`NOT-A-STRUCT`/`UNPROVEN-FIELD` point
  (`{good, mising} = v` points at `mising`, also across lines).
* Each binding's origin is the **name it creates** (the rename target or the
  shorthand name), which is where `DUPLICATE` points.
* AST ids: the statement is `destructure` / `destructure#2` (like other
  statements), its source `.../value`, its fields `.../field1`, `.../field2`,
  nested fields `.../field2/field1`; lowering origins add `/name` and
  `/binding`. Temporaries do not appear in user-facing ids.
* The surface AST printer keeps destructuring as destructuring:
  `(destructure {user, expires: expiry} (name result))`, with `-spans` per field
  entry and `-ids`.

## Nesting: implemented

The task made nesting conditional on it remaining trivial. It did: the grammar is
recursive (`field = IDENT ":" pattern`), and the lowering is the same loop one
level down on a further hygienic temporary. There is no pattern AST hierarchy,
matcher, failure semantics, guard or alternative, and nothing is refutable:
nested patterns are the same irrefutable, statically checked named projections.

* `{user: {name, id}, expires} = result` is `tmp = result; tmp2 = tmp.user;
  name = tmp2.name; id = tmp2.id; expires = tmp.expires`. The field that is
  destructured further is not itself bound (`user` is unbound).
* Renaming works inside nesting, inner fields may be omitted, a missing inner
  field is `UNKNOWN-FIELD` at the inner name, a non-struct nested field is
  `NOT-A-STRUCT`, the source is evaluated once, and `{pair: [a, b]}` is the
  `LIST-DESTRUCTURING` error at the nested List pattern.
* Duplicate checks apply per pattern level for fields (the same field name in
  *different* patterns is fine), and across all levels for bindings.

## Module top level

A destructure is **not allowed at module top level**
(`SURFACE MODULE INVALID-TOPLEVEL`, with a message saying so and to destructure
inside a function). This is not a destructuring restriction: a module binding
must be a context-free, provably immutable value (`hir/modulebinding.tcl`), and
no struct value or field projection is one, so even `t = {a: 1}` /
`a = t.a` is rejected there (`MODULE-CONTEXT`). A destructure could never be
accepted; the dedicated message is clearer than the `MODULE-CONTEXT` failure of
the temporary. The entry program's top level is a normal scope and works.

## Backend impact

None below `surface/lower.tcl`: `hir/`, `core/`, `compiler/` and `native/` are
unmodified (`git diff` of the milestone touches `surface/parser.tcl`,
`surface/ast.tcl`, `surface/lower.tcl`, `surface/modules.tcl` for the one
module-level message, tests, the fuzzer, README, and this report). Scalar
replacement/virtualization see ordinary field reads of a constructed struct and
apply as they do to the explicit spelling; no heuristic was added and no
performance claim is made (explicit and destructured programs have byte-identical
NIR, modulo the temporary's name, which NIR does not print).

## Tests

* `tests/struct-destructuring.test` (215 tests, table-generated cases included): AST shape and the
  field-versus-binding direction, syntax errors, the List policy (every shape
  including nested, multi-line, with `-recover`), lowering shape and origins;
  then, for named and anonymous sources, a table of destructured-versus-explicit
  programs (all fields, one, two, all-but-one, last, reordered, renaming,
  shorthand mixes, swapped names, trailing comma, multi-line) on interp,
  compile, cranelift-generic and cranelift; evaluate-once (named, anonymous,
  nested, loop body, struct-literal source); omitted fields and adding a field
  to a producer; MutableArray field values; rejection parity (missing, Int,
  String, List, Bool, unit, function, native, MutableArray, unknown shape,
  nested) and error locations; duplicates; scopes (functions, if, elif, loop,
  collecting loop, lockstep loop, nested function, loop-in-function); function
  results (named/anonymous, direct and via binding); error-capable sources
  (handled, declared, propagating, unhandled); closure capture; method sugar and
  `elif` composition; nesting; modules; same-program checks (HIR, core IR, NIR
  specialized and generic, specialization, range, escape, cardinality, AOT
  readiness and the explain reports are equal between spellings); a standalone
  executable.
* Pins in `tests/surface-parser.test` and `tests/surface-lowering.test`.

## Fuzzing

`audit/struct-destructuring/tools/fuzz.tcl` generates random struct values (2-6
fields; Int/String/List/nested struct fields; named and anonymous; shuffled
construction order), a random pattern (random subset, order, renaming, nesting)
over them, in random source forms (literal, call, bound) and contexts (body,
branch, elif, collecting loop, capturing closure, helper), and two programs:
destructuring syntax and the explicit `tmp = source; a = tmp.a; ...`. The
explicit spelling is the oracle (the feature's own theorem, not an independent
destructuring implementation); outcomes (value, error, evaluation-order log)
must be identical on every backend and between backends. One negative per
program, one defect at a time: missing field (any level), non-struct source,
non-struct nested, unproven shape, duplicate source field, duplicate
destination, List pattern (top and nested), rest binding, empty pattern. Each
must be rejected, with the explicit spelling's rejection where it has one and
the named diagnostic otherwise.

**Results.** `-n 300 -seed 1000` (all four backends: interp, compile,
cranelift-generic, cranelift): `programs 300 values 300 errors 0 negatives 300
equivalence-disagreements 0 negative-escapes 0 backend-disagreements 0`. A first
run found one seed where *both* spellings failed with `UNPROVEN-FIELD`: four
levels of nested anonymous structs exceed `aggregateDepth`, a pre-existing
limit, so the generator was capped at three levels (see Known limitations). A
bounded run (`-n 12`) is part of the test suite
(`destructure-fuzz-smoke`); longer: `tclsh9.0 audit/struct-destructuring/tools/fuzz.tcl -n 500 -seed 1000`.

## Known limitations

* Anonymous struct types nest at most three levels (`aggregateDepth`); deeper
  nesting is widened to a bare `struct` by the existing type system, and the
  explicit spelling is rejected as `UNPROVEN-FIELD` as well. Not a destructuring
  rule; the fuzzer stays within three levels.
* No destructuring at module top level (above).
* The compiler's program-level type listing in `main.tcl` shows the hygienic
  temporary.
* A struct field of a declared struct has to be spelled as a named struct type
  (there is no anonymous-struct type syntax); unrelated to destructuring.
* Destructuring has no value of its own: as the last statement of a body it
  yields the last field value read.

## Required questions

1. **What syntax was added?** `{field, field: local, field: {nested}} = value`
   as a statement (the `destructure` surface node), and the dedicated
   `LIST-DESTRUCTURING` diagnostic for `[...] = value`.
2. **What does `{a, b: c} = value` mean?** `tmp = value; a = tmp.a;
   c = tmp.b`, `tmp` a hygienic temporary.
3. **Is `value` evaluated exactly once?** Yes.
4. **Are fields selected by name?** Yes.
5. **Does physical/declaration field order matter?** No.
6. **May fields be omitted?** Yes.
7. **May fields be renamed?** Yes (`{field: local}`, field on the left).
8. **Does `{field}` mean `{field: field}`?** Yes.
9. **Must every requested field exist?** Yes (statically).
10. **Must the source contain only the requested fields?** No.
11. **Are destructured names ordinary bindings?** Yes.
12. **Are they references to source-field storage?** No.
13. **If mutable structs exist later and the field slot is changed, does an
    existing destructured binding change?** No.
14. **If a field's value is itself a mutable value, does destructuring use that
    value's ordinary semantics?** Yes (tested with `MutableArray`).
15. **Does destructuring introduce any reference/lvalue mechanism?** No.
16. **Do named struct values support destructuring?** Yes.
17. **Do anonymous struct values?** Yes.
18. **Is either kind preferred?** No.
19. **Can Lists be destructured positionally?** No.
20. **Is this merely an unimplemented future feature?** No; its absence is
    intentional.
21. **What diagnostic does `[a, b] = value` produce?** `LIST-DESTRUCTURING`
    ("positional List destructuring is not supported; use a struct value with
    named fields instead ...").
22. **Does it recommend a struct with named fields?** Yes.
23. **Does `{a} = some_list` produce `LIST-DESTRUCTURING`?** No; ordinary
    `NOT-A-STRUCT`.
24. **Are ordinary List operations affected?** No.
25. **Is a rest/spread binding supported?** No.
26. **Does destructuring construct a narrowed struct from omitted fields?** No.
27. **If narrowing is added later, is it a separate operation?** Yes.
28. **Was nested struct destructuring implemented?** Yes.
29. **Is it recursively the same named-projection semantics?** Yes.
30. **If no, why deferred?** n/a.
31. **Are nested List patterns still rejected with the dedicated error?** Yes.
32. **Where is destructuring in the surface AST?** The `destructure` node
    (`pattern`, `value`); fields carry spans and ids.
33. **At what stage is the source evaluated once?** Lowering makes it the single
    initializer of one hygienic `bind`; evaluation is that bind's.
34. **How are requested field projections represented?** Ordinary HIR `project`
    of a `ref` of the temporary, each in an ordinary `bind`.
35. **Does HIR retain a destructuring abstraction?** No.
36. **Did the interpreter gain a destructuring evaluator?** No.
37. **Did native/NIR gain a destructuring operation?** No.
38. **Are ordinary struct-field rules reused?** Yes (`ProjectionProblem` and
    friends, unchanged).
39. **Are existing construction/scalar-replacement analyses reused?** Yes.
40. **Do explicit and destructured spellings produce equivalent
    analyses/NIR?** Yes: equal HIR, core IR, NIR (specialized and generic) and
    analyses, modulo the temporary's name.
41. **Are duplicate source fields rejected?** Yes (`DUPLICATE-FIELD`).
42. **Are duplicate destination bindings rejected?** Yes (`DUPLICATE`).
43. **Are missing fields rejected statically?** Yes (`UNKNOWN-FIELD`).
44. **Are non-struct sources rejected?** Yes (`NOT-A-STRUCT`).
45. **Is the source evaluated once under every backend?** Yes.
46. **Do closures capture destructured bindings normally?** Yes.
47. **Do error-capable RHS expressions behave like ordinary bindings?** Yes.
48. **Did equivalence fuzzing find any disagreement?** No (300 programs, four backends).
49. **Did negative fuzzing find any escape?** No (300 negative programs, nine defect kinds).
50. **Did the full regression pass?** Yes: `tests/all.tcl` passes 4541/4541 on interp and 4537 passed + 4 skipped (as before) on compile, 0 failures; GC stress and native coverage were not rerun locally (nothing in `native/` changed).
