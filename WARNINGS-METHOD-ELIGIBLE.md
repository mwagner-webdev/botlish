# Compiler warnings: `METHOD-ELIGIBLE` and `nomethod fn`

## Outcome

Botlish's second compiler warning, **`METHOD-ELIGIBLE`**, is one pass plus one
registry line on the warning framework milestone 1 built
(`hir/warnings.tcl`, WARNINGS-SAME-RETURN.md), together with the two small
language additions it needs: the declaration `nomethod fn`, and a record in HIR
of how each call was *written*.

```
fn any_hit(xs):
    return any(xs, hit?)
```
```
f.bot:2:12: warning: call to `any` is eligible for method syntax (METHOD-ELIGIBLE)
```

The warning detects a call written in ordinary functional form that is
*proven* eligible for method syntax: the sugared spelling parses, is
unambiguous, and resolves to the identical callee. The same program spelled
`xs.any(hit?)` is silent; a chain `find(map(xs, norm), ok?)` is two warnings,
one per written call; `length(s)` never warns (one parameter), so the warning
never suggests `s.length()`. The message states eligibility and stops: no
rewritten expression, no fixit, no claim that the functional form is wrong, and
the warning is one-directional (a call written with sugar is never told it
could be functional).

For functions whose author knows receiver syntax reads badly (the motivating
case is a future `math::atan2(y, x)`, never to be suggested as `y.atan2(x)`),
`nomethod fn atan2(y, x):` withdraws method syntax at the declaration. It is
not a suppression: a method-style call that would resolve to a `nomethod`
function is a resolution *error*.

The corpus is frozen and was not touched; nothing existing is marked
`nomethod`.

### Why a preference-shaped warning still belongs

Milestone 1's principle is: *warnings report semantic facts the compiler can
prove; a warning that cannot cite a compiler proof does not belong in a
default-on, non-suppressible system.* `METHOD-ELIGIBLE` is the first warning
whose subject is a preference (receiver syntax) rather than a property of the
program's meaning, and it qualifies, for four reasons -- not because "style
warnings are fine now":

* the **fact** is compiler-proven: the sugared spelling parses and resolves to
  the identical callee. The prover is the parser's receiver rule and the
  resolver's own candidate gathering (`hir::resolve::MethodCandidates`), not a
  new theorem prover, and the claim is checked mechanically (the round-trip law
  below, at unit, fuzzer and corpus level);
* the **preference** it serves is the language's own declared idiom (METHOD-
  SUGAR.md: receiver syntax is Botlish's preferred call form), not a
  per-warning fashion;
* the **function's author** has first-class control: `nomethod fn` withdraws
  eligibility at the declaration, as part of the interface. That is
  declaration-level metadata, in the function author's voice, not call-site
  suppression: the language still has no lint-ignore, pragma or per-call
  opt-out;
* **uncertainty means silence** everywhere else: every case in which the
  compiler cannot prove the sugared form identical is silent (listed below).

`README.md` section 23 carries the same statement, compressed.

## The eligibility theorem

> A call is reported exactly when it is a **reachable, written functional call**
> to a **declared named function** of **at least two ordinary parameters**, not
> `nomethod`, whose first argument is **a receiver the grammar accepts as
> written**, and the **resolver's candidate gathering** for the sugared
> spelling finds **exactly that function**, with **no struct field** that could
> compete with it.

Two rules, as the compiler evaluates them (`hir::warnings::MethodEligible`):

1. **Method sugar must be syntactically allowed and unambiguous.**
   * *Written functional.* The call carries the frontend's provenance
     `written function`. Method sugar, list literals and operators are not
     candidates, and a synthesized call is never eligible (below).
   * *Receiver form.* The receiver is the call's first argument, never another
     argument. It must be a postfix or primary expression as written (table
     below).
   * *Declared named callee.* The callee reference resolves directly to a `fn`
     declaration (this file's, a module's, or a nested one) or to a root native
     (a builtin). A call through a *function value* -- a parameter, an alias
     (`g = f`), a call result, a projection -- is never eligible, because the
     sugared form's resolution could not be proven identical.
   * *Not `nomethod`.*
   * *Same callee.* `hir::resolve::MethodCandidates` -- the code real method
     calls use, applied to the call's own scope, namespace and arity -- returns
     exactly one candidate and it is the callee. Anything else (a second
     visible function of the name, whether lexical or a member of a directly
     imported namespace; a different function; none) means the real call would
     be decided by receiver types, be ambiguous, or mean something else:
     silence.
   * *No competing field.* `x.f(y)` is rejected when the receiver's static
     struct type has a field `f` that could be callable (the existing
     `AMBIGUOUS-METHOD-CALL`). The suggestion is silent unless no struct of the
     program has a field of that name, or the receiver's static type is known
     and cannot be such a struct. A receiver of unknown type (an untyped
     parameter) can be given such a struct by a semantic instance, so with a
     field of that name anywhere in the program it is silent.
2. **The callee declares at least two ordinary parameters.** Flags
   (FLAGS.md) are a separate parameter category and do not count; a variadic
   native (`list`) has no fixed count and is never a candidate. Rationale: the
   warning targets calls where method syntax moves a trailing argument behind
   the dot. A one-parameter call has no trailing argument, and Botlish's
   preferred spelling for such calls is the functional one. The boundary is
   pinned: exactly 1 parameter is silent; 2 and 3 warn.

**The rule lives in the warning, not in the language.** Rule 2 is a property of
this pass. The grammar and the resolver are unchanged: `s.length()` (one-
parameter sugar) remains legal wherever it was, and the warning merely stays
silent for it. Do not "simplify" the sugar to ≥2-parameter functions.

Everything is read from the final, generic source HIR, once per source unit; it
never visits a semantic instance, so a function specialized ten ways is one
warning with source locations. Calls HIR marks structurally unreachable (dead
branches, code after a `return`) are skipped; an interprocedurally dead but
structurally reachable call still warns (the conservative direction, accepted
as in milestone 1). Calls inside loops, handlers, closures and nested functions
are ordinary calls reported at their own locations; a recursive call and a tail
call are ordinary calls (the pass walks syntax, so there is nothing to
terminate).

### The receiver-form table

The accepted forms come from the parser (`surface/parser.tcl`):
`postfix = primary { "(" args ")" | "." IDENT [ "(" args ")" ] }`,
`unary = "-" unary | postfix`, `primary = literal | name | qualified name |
list | struct | "(" expr ")"`. The receiver of `x.f(y)` is therefore a
*postfix*, which binds tighter than every operator.

| receiver as written | eligible? | grammar rule |
|---|---|---|
| plain name `x`, `true`, `false`, `unit` | yes | primary |
| qualified name `m::value` | yes | primary (`IDENT { "::" IDENT }`) |
| field chain `a.b.c` | yes | postfix `"." IDENT` |
| call result `g(x)`, `f(x)(y)` | yes | postfix `"(" args ")"` |
| method-call result `x.g()` | yes | postfix `"." IDENT "(" args ")"` |
| parenthesized call/name/literal `(g(x))` | yes | the parser drops the parentheses: the same node as `g(x)` |
| `Int` literal `5` | yes | primary; Botlish has no float literal, so `5.f(x)` cannot re-lex |
| `String` literal `"s"`, `UnicodeChar` literal `'c'` | yes | primary |
| list literal `[1, 2]` | yes | primary |
| anonymous struct `{a: 1}`, named struct `P {a: 1}` | yes | primary |
| negative literal `-1`, unary minus `-x` | **no** | `-` is an operator: `-1.f(y)` is `-(1.f(y))`, a different program |
| binary operator `x + 1`, comparison `x == 1` | **no** | an operator expression: `a + b.f(y)` is `a + (b.f(y))` |
| `not x`, `x and y`, `x or y`, `x != y` | **no** | conditions the frontend synthesizes, not postfix expressions |
| parenthesized operator `(x + 1)` | **no** | HIR records no parentheses: the node is the same as `x + 1`, and a receiver that needs parentheses *added* is not eligible |

**Parenthesization policy (decision).** A receiver is eligible only when, *as
written*, it is already a valid receiver; one that would need parentheses added
(`(-1).f(y)`, `(x + 1).f(y)`) is not, however valid the parenthesized spelling
is (a test pins that `(-1).two(x)` is the same program, so the silence is
conservatism, not invalidity, and another that `-1.two(x)` is *not* the same
program). Because the parser keeps no trace of parentheses, `(x + 1)` is
indistinguishable from `x + 1`: both are silent, whereas a parenthesized
postfix `(g(x))` *is* the postfix `g(x)` and is eligible. The receiver form is
recorded in the warning's `data` (`receiverForm`: `name`, `qualified-name`,
`field`, `call`, `method-call`, `literal`, `list`, `struct`).

**Lexical traps.** The classic trap -- `1.f` reading as a float -- does not
exist: the lexer has no float token, `5.f(x)` is `INT "." IDENT`, and the form
is exercised by a literal sugared round-trip program. Every other eligible row
is likewise exercised by a literal sugared program that parses, resolves to the
same callee and compiles to the same program.

### Callees, shadowing, ambiguity and imports

* **Qualified callees.** `mod::f(x, y)` is eligible exactly when the *same*
  resolver lookup that decides `x.f(y)` -- the file's directly imported
  namespaces' members named `f`, plus ordinary lexical lookup -- finds the same
  function as the only candidate. Imports are exact and not transitive; the
  module's own functions are found lexically from inside the module (a
  module's bare call to a sibling is eligible, while `list::at(...)` inside
  module `list` is silent: the module does not import itself, so `xs.at(i)` is
  not visible there). An intrinsic (`str::concat`, `list::append`) is a
  candidate when its namespace is imported, which any qualified reference
  already requires.
* **Shadowing / ambiguity (item 19).** The language *can* resolve `x.f(y)` to
  something other than the free function `f`: another function of the name
  visible lexically or through an imported namespace (decided by receiver
  types, or `AMBIGUOUS-METHOD-CALL`), and a struct field of that name. Those
  cases are silent (pinned, including a proof that the sugared spelling really
  is rejected there). An alias of the same function (`append = list::append`
  beside `import list`) is the same candidate (`CandidateIdentity` follows
  aliases) and does not silence. A binding established *after* the call is
  invisible to it, as to the real resolver.
* **Hygiene.** HIR renames bindings after resolution: module bindings to their
  qualified spelling (`list::find`) and shadowing bindings to `name#N`. The
  resolver's lookup works on the names as written, so the pass hands it a
  *view* of the HIR (`ResolutionView`) in which only the module sections' name
  tables are restored to their written spelling. The resolver code is not
  changed and not duplicated.
* **Function values.** Never eligible (above): `g = two; g(x, 1)`, a parameter
  `f(x, 1)`, a parameter that shadows a function name, a call result called
  directly.

## Provenance: how each call was written

*Question: which calls were written `f(x, y)`, and which are sugar, operators or
list literals?* The frontend lowers `x.f(y)` to the ordinary call `f(x, y)`, and
operators, list literals and `!=` to ordinary calls of root natives. After
`hir::resolve` the existing `method` field marks only the resolved sugar calls
(for the field/function ambiguity check) and the three synthesized families are
indistinguishable from written calls but for the shape of their callee --
deriving "written" from that (origin or callee sniffing) is exactly the trap
milestone 1's boolean-`if` caveat warned about.

**Representation (a real marker).** `surface::lower` states how it built each
call: `hir::syntax::withWritten CALL FORM`, `written FORM` with FORM one of

| form | source |
|---|---|
| `function` | `f(a, b)` |
| `method` | `a.f(b)` (also `method 1`) |
| `list` | `[a, b]` |
| `operator` | `a + b`, `a == b`, `-a`, and the `==` inside `a != b` |

`hir::resolve` copies it to the HIR call node as `written {form F ns NS}`, NS
being the namespace of the code the call is in (the namespace whose imports the
method spelling would consult). It is recorded unconditionally -- in every
warning mode, so HIR is identical under `-warnings off` and `default` (pinned)
-- and a call from core IR carries none. It is a plain field: `hir::format`,
`hir::lower`, native lowering, every analysis and every backend ignore it
(NIR, CLIF and `native::report` of the functional and the sugared spelling are
identical; pinned), and a test pins that none of those outputs mention a
warning or the marker.

**Robustness.** Only the AST kinds `call`, `methodcall`, `list`, `binary` and
`unary` produce call syntax in `surface/lower.tcl`, and each says what it is;
the marker survives the module loader (`RemapFile` copies nodes), the
method-candidate rebuilds (the call is rebuilt from the same syntax node) and
semantic-instance cloning (the pass never reads instances). A call without the
marker is never eligible (default silence), so a future frontend construct that
forgets to mark its calls cannot produce a false warning.

## `nomethod fn`

* **Syntax.** `nomethod fn atan2(y, x):` -- a contextual modifier word, like
  `opaque struct`: a modifier only when the words before `fn` are all modifier
  words, so `nomethod` stays an ordinary name elsewhere. Accepted wherever `fn`
  is (top level, modules, nested functions; there are no `fn` expressions). A
  repeated modifier, and `nomethod` before `struct`/`type`/`error`, are syntax
  errors naming the function declaration. The surface AST prints
  `nomethod fn f (a b)`.
* **Semantics.** A `nomethod` function is called functionally exactly like any
  other: type, completion, specialization, code and behavior are identical
  (pinned: NIR, core IR, `native::report`, specialization analysis and the run
  value). The flag affects only call-form legality and warning eligibility.
* **Method sugar to it is a resolution error.** `x.f(y)` where the sugared
  spelling resolves to a `nomethod` function is `NOMETHOD-CALL`:

  ```
  t.bot:3:3: `atan2` is declared nomethod and cannot be called with method syntax; call it as atan2(receiver, ...)
  ```

  *Mechanism:* a `nomethod` function is **not a method candidate**.
  `hir::resolve::MethodCandidates` leaves it out before the arity rule and
  reports what it left out; the call is rejected only when every visible
  function of that name is `nomethod`. So `x.f(y)` resolves to something else
  (another visible `f`) without error, exactly when shadowing would make it so;
  the error triggers only when the sugar would otherwise have resolved to the
  `nomethod` function. An alias (`g = atan2`) is the same function. A struct
  field of the same name is called as `(s.f)(...)`, as the ambiguity message
  already advises.
* **Strictness class.** The error is a *resolution* diagnostic, the class of an
  unbound name: under `-strict 1` it is raised before type inference runs
  (`{CORE SEMANTIC NOMETHOD-CALL}`, in every warning mode including `off`);
  under `-strict 0` it stays in the HIR's diagnostics and the call stays the
  call of a field value (never a call of the function), so the program fails
  at run time as well. A program with an error diagnostic is never warned
  about.
* **Visibility.** The flag lives on the function's binding (read by
  `MethodCandidates` for lexical and imported candidates alike, after alias
  resolution), and on the `block` expression (printed by `hir::format` as
  `nomethod`, read back by `hir::parse`). A `nomethod` function imported from a
  module behaves identically; the module loader's `RemapFile` carries the field.
* **Builtins.** `core::native::register -nomethod 0|1` (default 0, validated),
  `core::native::metadata NAME` carries `nomethod`. The resolver reads it for
  natives exactly as for source functions (a test registers a probe native,
  skips it as a candidate, calls it functionally without a warning, and
  unregisters it). **No shipped function is marked** (a test pins it): marking
  belongs to the future warning-driven refactor, because it could break frozen
  code that uses a function's sugar.
* **Not a suppression pragma.** `nomethod` is a declaration-level property of
  the *function* (like a calling-convention marker), decided by its author. It
  changes what call forms are *legal*; the warning's silence on such a function
  is a consequence of that semantic fact, not an instruction to the compiler
  about a particular call. That is why the strong semantics (an error) were
  chosen over a warning-only flag: a flag that kept sugar legal but silenced
  the warning would be suppression in disguise, which milestone 1 ruled out. The
  language still has no call-site suppression, annotation or lint-ignore.

## Architecture

**One pass, one registry line.** `hir/warnings.tcl`'s registry gained

```tcl
variable passes {
    SAME-RETURN-VALUE hir::warnings::SameReturnValue
    METHOD-ELIGIBLE   hir::warnings::MethodEligible
}
```

and the pass (`MethodEligible` and a handful of helpers) is appended to the
file. **Framework untouched:** policy modes, `run`/`collect`/`of`, record shape,
sorting, rendering, error promotion, the stats counter, `BOTLISH_WARNINGS`
and the CLI option are byte-for-byte what milestone 1 shipped; the diff of
`hir/warnings.tcl` above the `SAME-RETURN-VALUE` section is the one registry
line. The pass reads, and adds no analysis to, what compilation already
computed: the resolver's callee identities and candidate gathering, parameter
declarations, the parser's receiver rule (as HIR node kinds), HIR's structural
`reachable` flags, the struct registry's field facts, and sugar provenance.
Under `off` it does not run at all (counter and execution trace pin it).

**What else changed, and why each is small:**

| file | change |
|---|---|
| `surface/parser.tcl`, `surface/ast.tcl` | the contextual function modifier `nomethod` (no lexer change: it is not a keyword); `function` nodes carry `nomethod`/`nomethodSpan`; the AST printer shows it |
| `hir/syntax.tcl`, `surface/lower.tcl` | `withWritten` (provenance) and `withNoMethod`; every call the frontend builds says how it was written |
| `hir/resolve.tcl` | `written` copied to the HIR call (with the namespace); `nomethod` recorded on the function's binding and block; `MethodCandidates` leaves `nomethod` functions out (and can report them), and the call case raises `NOMETHOD-CALL`. The lookup itself is unchanged and not duplicated |
| `hir/structs.tcl` | `FieldCompetes`, the tail of `AmbiguousMethodCall` factored out unchanged so the warning asks the existing ambiguity rule about the sugared spelling |
| `hir/format.tcl`, `hir/read.tcl` | `nomethod` printed on a `block` line and read back |
| `core/native.tcl` | `-nomethod` registry flag, `nomethod` metadata |
| `hir/hir.tcl` (and the headers of the files above) | documentation of the above |

No change was made to `native/` (Rust or Tcl), `core/` evaluation, the Tcl
compiler, specialization, ranges, escape analysis or any backend: native
lowering, NIR and CLIF cannot see the marker or the flag (pinned).

**Timing.** Discovery is in `surface::lower::Finish`, after `hir::buildSyntax`/
`hir::check` and strict diagnostics, before any backend, exactly as in
milestone 1. A program with error diagnostics is never warned about; a
sugar-on-`nomethod` error is a resolution error raised even earlier, so such a
program is silent by construction. `error` mode raises the first warning
across both codes in sort order, before `hir::lower`, `native::prepareHir`,
`native::evalHir` or `core::compiler::evalHir` (traces: 0 calls; a
`main.tcl -backend cranelift -warnings error` run prints no value).

**Record, ordering, granularity.** Same dict as milestone 1,
`{code message primary secondary data}`. `primary` is the call's own origin
(`hir::originLocation` vocabulary; inside module code, the module's file).
`secondary` is **empty**, a deliberate deviation from `SAME-RETURN-VALUE`'s
multi-exit shape: the fact has a single location, so no `note:` line is
rendered. `data`: `function` (`{block ExprId}` or `{native NAME}`, the call
`target` representation), `functionName` (the callee as written), `call`,
`receiver` (ExprIds), `paramCount`, and `receiverForm`; no rendered source
text. Ordering is the inherited `Sort` (primary origin, code, message), so a
program with both warnings interleaves deterministically (pinned, both
orders). Each eligible written call is **its own warning**: no grouping, no
pairing, no per-function aggregation, and two identical eligible calls are two
warnings. This differs from `SAME-RETURN-VALUE` by design: there the fact
spans sites, here it is local to one call. Message and rendering:

```
FILE:LINE:COL: warning: call to `any` is eligible for method syntax (METHOD-ELIGIBLE)
```

Under `error`: `core::semanticError METHOD-ELIGIBLE "LOCATION: MESSAGE"`,
`{CORE SEMANTIC METHOD-ELIGIBLE}`, printed `(CORE SEMANTIC METHOD-ELIGIBLE)`.

**Policy.** Unchanged and re-pinned with this warning: three modes, one option
(`-warnings`), no `-Wfoo`/`-Wno-foo`/`-Wall`/levels (`-Wno-method-eligible` is
`unknown option`, in process and through `main.tcl`), unknown modes rejected,
`BOTLISH_WARNINGS` read fresh per compilation with an explicit option winning,
interleaved compilations under different modes do not interact. Adding this
warning gave the environment variable and the command line nothing.

## Corpus findings

Observational only; the corpus is frozen and was **not** edited, no call was
rewritten and no function marked `nomethod`.
`audit/method-eligible/tools/corpus.tcl` compiles every program of
`examples/stdlib` (9), `examples/surface` (14; `09` and `10` are the deliberate
rejections), `bench/*.bot` (8) and `lib/*.bot` (8) with warnings on and writes
`audit/method-eligible/corpus-audit.txt`.

* 35 of 39 programs compile standalone. The four that do not: the two
  deliberate rejections, and `lib/list.bot` and `lib/mutable_array.bot`, which
  use their own namespace's intrinsics without importing it (a state of the
  repository that predates this milestone: they are loaded as modules by the
  programs that import them, and their findings are reported through those).
* **365 distinct findings** (locations), in **95 distinct (callee,
  receiver-form) patterns** over 81 callees. Milestone 1 reported 4: every
  functional call to a function of two or more parameters is a finding, and
  that volume is information for the deferred refactor, not a defect.
* Receiver forms: name 315, call result 24, literal 17, qualified name 4,
  field 4, list literal 1. Parameter counts: 2 parameters 160, 3 parameters
  154, 4: 27, 5: 17, 6: 5, 7: 2. Natives (intrinsics and root natives) account
  for 140 findings in 30 patterns, source functions for 225 in 65.

**Classification** (per distinct pattern, with totals; the category is derived
mechanically from HIR: a struct-literal second argument, or a callee that calls
its own second parameter or is passed a function, or neither):

| category | findings | patterns | examples |
|---|---|---|---|
| subject-first helper the refactor would convert | 358 | 89 | `peek(text, i)`, `scan_quoted(text, i, acc)`, `ht_get(table, key)`, `mutable_array::set(a, i, v)`, `list::at(xs, i)`, `list::append(xs, v)`, `str::substring(s, a, b)`, `replace(text, old, new)` |
| predicate / mapper call | 7 | 6 | `list::any?(xs, p)`, `list::all?(xs, p)`, `list::find(xs, p)`, `list::none?(xs, p)`, `scan_while(text, p)` |
| "config object" second argument | 0 | 0 | none in the corpus |
| one-parameter callees (excluded by rule 2) | 0 | -- | 74 distinct callees at 246 written call sites, e.g. `str::length`, `list::length`, `char_at`, `ht_size`, `clean_ai_text`: listed in the audit for completeness |
| false positives (round-trip failures) | **0** | **0** | -- |

**`nomethod` candidates** (callees whose receiver reading would mislead;
recorded for the future refactor, **not applied**): `mutable_array::copy` (4
findings: the receiver would be the *destination* of a five-parameter copy,
`dst.copy(at, src, from, n)` reads as copying `dst`) and `bit_and`, `bit_or`,
`bit_xor` (9 findings: symmetric operands, neither is the subject). This is a
human judgement; the tool only counts how often each curated callee is a
finding.

**Round-trip law on every distinct finding pattern: 95 of 95 hold.** For each
(callee, receiver-form) the call is respelled with method sugar in a scratch
copy (the call may be in an entry program or a library module; the rewrite is
mechanical, from the parser's own spans: it moves one argument's text behind a
dot), and the respelled program must compile, lose exactly that one warning,
and have the same HIR text, core IR and NIR (specialized and generic) as the
original (compiled right before it: the declared-error and struct registries
are process-global). Then, for each of the 23 programs with findings, *every*
eligible call is respelled (last first, so a call is respelled before the
calls its receiver contains), recompiling after each step: **0 warnings left
and the original's NIR in all 23**, 443 steps in all. Any failure would be a
warning-design bug; there were none after the receiver rule and the
hygiene-aware lookup described above (the first audit run exposed that
hygiene's qualified module spellings hid every module function from the
lookup -- silence, never a false warning -- which `ResolutionView` fixed).

Library findings print for every program that loads the library (see Known
limitations): `lib/web.bot`'s 20 findings, `lib/byte.bot`'s 11 and
`lib/mutable_array.bot`'s 1 appear whenever a program loads those modules.

## Tests

* **`tests/method-eligible.test` (145 tests)**, every compile passing its
  policy explicitly. Eligibility: a 2-parameter call warns, the same program
  with sugar is silent, both spellings in one program warn once; 3 and 4
  parameters warn, 1 never (user function, module function, intrinsic, a
  function with one ordinary parameter and a flag), the 1/2/3/4 boundary in one
  test, the language's one-parameter sugar still legal; a variadic native never;
  flags; chains (two warnings, source order; the fully sugared chain silent and
  identical), no grouping, source order, record shape, the data fields,
  rendering, neutral message, no rewrite anywhere. Receiver forms: every
  eligible row of the table with a literal sugared round-trip program (name,
  field chain, call result, method-call result, parenthesized call, `Int`,
  `String`, `UnicodeChar`, `true`/`unit`, list, anonymous and named struct,
  qualified name), and the ineligible rows (negative literal and the proof that
  `-1.f(x)` is another program, `(-1).f(x)` valid but not suggested, unary
  minus, binary, parenthesized binary, comparison, `not`/`and`/`or`/`!=`).
  Callees: qualified, imported module function (located in the importing file
  and, for a sibling call inside a loop, in the module file), intrinsics,
  function values (alias, parameter, shadowing parameter, call result), a
  nested function. Ambiguity: two candidates (local + import, two imports),
  the proof the sugar is really ambiguous there, an alias that is one candidate,
  a later binding that does not silence, a field named like the function
  (untyped receiver silent, the proof that the sugared spelling is rejected,
  known receivers warn, unrelated field names do not matter). Reachability:
  dead branch, code after `return`, loops, an interprocedurally dead function.
  Closures, recursion (self-call eligible, operator receiver silent), tail
  calls, handled calls, top level. Synthesized operators, list literals and
  unary minus. `nomethod`: parse, the pinned error and message, error before
  type inference, error in every warning mode, the `-strict 0` class, no
  warning for a `nomethod` function and the same function without the modifier
  warns, nested declaration, module import, alias, another function wins, the
  field-call spelling `(s.f)(...)`, NIR/core IR/behavior/specialization/
  `native::report` identity with the plain function, `hir::format`/`hir::parse`
  round trip, contextual word, stray and duplicate modifier, AST printer, AST
  and lowered-syntax fields, the registry flag (default off, none shipped,
  declarable, skipped by sugar, validated). Provenance: forms recorded under
  `off` and `default`, the namespace, HIR identical across modes, NIR
  identical across modes and between spellings (NIR, generic NIR, CLIF,
  `native::report`), no warning text or marker in any machine-readable output
  or `hir::format`. Policy: interleaving with `SAME-RETURN-VALUE` (both
  orders), default/off/error, default-is-default, `BOTLISH_WARNINGS`, unknown
  mode, no `-Wfoo`, no new modes, promoted identity, the stats counter and an
  execution trace on the pass (0 under `off`, 1 under `default`), a program with
  errors never warned about, per-compilation interleaving, `of` equals
  `collect`, `error` stopping before every lowering entry point (traces),
  all four backends in process, both spellings running identically, and
  through `main.tcl`: the three modes, `-Wno-method-eligible` rejected, unknown
  mode rejected, stdout/stderr separation, `-warnings error` on `cranelift`
  prints no value, identical warning text on all four backends over the whole
  `examples/stdlib` corpus; and a 60-seed fuzz run.
* **`tests/warnings.test` (81 tests)**, milestone 1's file. See "Deviations
  from the brief": four of its tests and its fuzz tool were adapted, for the
  two reasons listed there.
* No other test file was edited. `nomethod`'s small surface and resolution
  tests live in `tests/method-eligible.test` rather than in the parser and
  lowering test files, so those are unchanged.

## Fuzzing

`audit/method-eligible/tools/fuzz.tcl SEEDS FIRST` (`audit/method-eligible/
fuzz-result.txt`). Each seed generates one to three functions from
construction-known pieces: declared functions with 1, 2 and 3 parameters, one
`nomethod` function, the 2-parameter intrinsic `str::concat`; calls written
functionally with plain-identifier receivers and with the other eligible
postfix/primary forms (literal, list, field, call result, method-call result);
chains; calls in a loop and in a nested function; calls already written with
sugar; one-parameter calls; `nomethod` calls; dead-branch calls
(`if 1 == 2`); calls through function values (an alias and a parameter);
receivers of the ineligible forms (`n + 1`, `-n`, `n == 1`, `not b`, `b and b`,
`n != 1`, `(n + 1)`, ...); about a third of the programs contain only silent
calls. No shadowing is generated (the unit tests own it). The oracle is
independent of the compiler: it knows from construction which calls are
eligible and predicts the exact line and column of each warning.

Each program is compiled under all three modes: `default` must give the
predicted sites (a missed one fails; an extra one is printed as `EXTRA` and
counted, and fails the test run's summary check), `off` must compile
silently, run no pass (stats counter and an execution trace) and yield the
same HIR as `default` without its side table, `error` must reject with
`{CORE SEMANTIC METHOD-ELIGIBLE}` iff a warning is predicted. For every
predicted site the generated source is rewritten to the sugared spelling,
recompiled, and must have one warning fewer, the same HIR text, core IR and
NIR (specialized and generic), and the same interpreter value.

**2000 seeds (1387 with warnings, 613 without): 0 failures, 0 missed
constructed sites, 0 extra warnings, 9795 of 9795 round trips hold.** The test
suite runs 60.

**The checks can fail.** `audit/method-eligible/tools/mutate.tcl` breaks the
pass (or the `nomethod` resolution) one line at a time in a scratch copy and
runs the fuzzer, then the unit tests for what the fuzzer does not generate
(`audit/method-eligible/mutation-result.txt`, 40 seeds each): operator
receivers accepted (killed by fuzz: 14 extra warnings), the receiver rule
disabled (18), reachability ignored (58), method-sugar calls accepted as
candidates (27 failures, 189 extras), `nomethod` ignored (24), the candidate
check skipped (24); and killed by the unit tests: the 2-parameter rule weakened
to 1 (1 failing test) and the field-competition check skipped (2 failing
tests). **8 of 8 mutants killed.**

## The round-trip law: results

> For every call the pass calls eligible: (1) the sugared spelling parses,
> (2) it resolves to the same callee, (3) it compiles to identical NIR.

A warning whose call fails it is a false positive by definition -- this
warning's analogue of milestone 1's "unknown equality does not warn". Verified
at three levels, all with zero failures:

| level | what | result |
|---|---|---|
| unit table | every eligible receiver form, plus qualified/imported/intrinsic/nested/recursive/handled/flagged callees, each with a literal sugared program (HIR text, core IR, NIR specialized and generic compared) | all hold |
| fuzzer | every predicted site of 2000 generated programs | 9795 of 9795 |
| corpus | every distinct (callee, receiver-form) pattern; then every eligible call of each program respelled | 95 of 95; 23 of 23 programs (443 respelled calls) |

"Resolves to the same callee" is the identity of the printed HIR: the HIR text
prints each call's target (`call native(+)`, `call block(e2)`), so equal text
means every call, in the whole program, has the target it had.

## Known limitations

* **Library findings are shown.** A finding inside `lib/*.bot` appears for any
  program that loads that module (the pass sees all code in the HIR; there is
  no "system header" notion; the corpus is frozen). With this warning the
  volume is higher: `lib/web.bot` 20, `lib/byte.bot` 11, `lib/mutable_array.bot`
  1. Programs that import them print those warnings, and `-warnings error`
  rejects them. Documented, not fixed (the repetition-for-loaders limitation of
  milestone 1, at higher volume).
* **Conservative silences** (a missed warning, never a wrong one): a callee
  whose binding hygiene renamed (`name#N`: one that shadows a root name, or a
  later same-named binding of its scope) is looked up under the spelling
  written and may find nothing; a receiver written `(a + b)` is not told apart from `a + b`
  (parentheses are not recorded); an untyped receiver is silent when any
  struct of the program has a field of the function's name; a variadic native
  is never a candidate; the lookup is over the HIR as compilation left it, so a
  later binding that hygiene renamed is invisible to it (correct: it is
  invisible to the call).
* **Interprocedural unreachability** is not required: a structurally
  reachable call in a function nobody calls still warns.
* The import table the candidate gathering reads (`hir::imports`) is, like the
  struct registry, the *current compilation's*: `hir::warnings::collect` over
  an old HIR after another compilation was made may see the wrong imports.
  Warnings are discovered inside the compilation, where it is right.
* Only the first warning is raised under `error` (as in milestone 1), and
  `NOMETHOD-CALL` reports the first offending call (a resolution diagnostic).
* A `nomethod` function is also skipped when only reached through an alias;
  the alias cannot be used to obtain method syntax (intended).
* The message names a module function's qualified spelling even when the call
  wrote the bare sibling name inside the module (hygiene's canonical spelling).

## Deviations from the brief

* **`tests/warnings.test`: four tests and one tool adapted, not two named
  exceptions.** Item 63 allows updating a pin on the whole-dict shape of the
  stats or the registry size, and the stats expectation of
  `warn-off-runs-no-warning-pass` was updated for exactly that reason (it now
  lists `METHOD-ELIGIBLE` beside `SAME-RETURN-VALUE`). A second cause the brief
  did not foresee follows from its own item 72: three milestone-1 tests
  (`warn-separate-mutable-construction`, `warn-same-mutable-binding`,
  `warn-alias-of-mutable-binding`) compile programs that `import
  mutable_array`, whose module carries a real `METHOD-ELIGIBLE` finding
  (`lib/mutable_array.bot:75:40`, `list::at(xs, i)`), and the milestone-1 fuzzer
  `audit/same-return-value/tools/fuzz.tcl` (run by `warn-fuzz-smoke`) imports it
  in every program. They asserted the *complete* warning set. They now assert
  the complete `SAME-RETURN-VALUE` set (helpers `sameReturnShown` and
  `sameReturnCodes` filter by code); the fuzzer compares the library's own
  warnings with a baseline (the warnings of a program that only imports it),
  keeps them out of its groups, and under `error` expects the code of the
  sort-first warning of either kind. No `SAME-RETURN-VALUE` pin was weakened,
  but "no other warning appears" for those four programs is now pinned by the
  baseline rather than by emptiness. Nothing else in the file changed.
* **`lib/list.bot` and `lib/mutable_array.bot` do not compile standalone** (the
  corpus audit lists them), unlike milestone 1's report (36 of 38 compiled): a
  change of the repository before this milestone, not caused by it.
* **The fuzzer's `EXTRA` policy.** The brief says `default` must produce exactly
  the predicted warnings *and* that extras are reported rather than failing.
  The tool follows milestone 1 (a missed prediction fails; an extra is printed
  and counted), and the summary line carries `extra warnings N`, which the
  unit-test smoke run pins at 0.
* **Branch.** `AGENTS.md` says to push finished work to `main`; this session was
  assigned a development branch and told not to push elsewhere without
  permission, so the work is pushed to that branch and not to `main`.

## Future warning candidates

`METHOD-ELIGIBLE` moves from candidate to implemented. Still future, only for
warnings that state a provable fact in this framework:

* `SAME-FAILURE`: the same declared failure from several exits (one registry
  line and a pass);
* a condition that repeats an already established proof;
* manual iteration whose cardinality duplicates another domain (lockstep
  candidates).

Not planned: further style rules, "a sentinel should be an error", automatic
rewriting or fixits (the mechanical rewrite used by the audits stays in
`audit/`), call-site suppression, a warning-only `nomethod`.

The deferred corpus refactor is the consumer of this warning: it can convert the
findings with the audit's patterns, and mark the `nomethod` candidates above
(`mutable_array::copy`, `bit_and`, `bit_or`, `bit_xor`) in the same change.

## Full regression

@@REGRESSION@@

## Required questions

**Warning framework**

1. *Enabled by default?* Yes (`default`; `BOTLISH_WARNINGS` only sets the default
   of a compilation given no option).
2. *All warnings disableable globally?* Yes: `-warnings off`.
3. *All warnings promotable globally?* Yes: `-warnings error`.
4. *Per-warning `-Wfoo`/`-Wno-foo`?* No (`-Wno-method-eligible` is an unknown
   option, pinned in process and through `main.tcl`).
5. *Warning groups (`-Wall`/`-Wextra`)?* No.
6. *Codes stable?* Yes (`METHOD-ELIGIBLE`).
7. *Policy per compilation, not global state?* Yes: an option of every compile
   entry point; interleaved compilations under different modes do not interact
   (pinned). The only global is the pass-run counter tests use.
8. *Does `off` skip the pass?* Yes: stats counter (no `METHOD-ELIGIBLE` entry
   under `off`, one after a `default` compile) and an execution trace on the
   pass proc (0 calls under `off`, 1 under `default`).
9. *Does `error` preserve the code?* Yes: `{CORE SEMANTIC METHOD-ELIGIBLE}`.
10. *Backend-independent?* Yes: the same HIR gives the same warning set on
    `interp`, `compile`, `cranelift` and `cranelift-generic`, in process and
    through `main.tcl` (identical warning text over all of `examples/stdlib`).

**`METHOD-ELIGIBLE`**

11. *Meaning?* A reachable, written functional call to a declared named function
    of at least 2 parameters, not `nomethod`, whose sugared spelling provably
    parses and resolves to the same callee.
12. *Source-text matching?* No: grammar and resolution facts. The receiver-form
    check is grammar validity (HIR node kinds plus the frontend's provenance),
    not text equality; the audit's rewrite is a tool, not the compiler.
13. *Reuses existing machinery?* Yes: the resolver's `MethodCandidates` and
    `CandidateIdentity`, the declarations' parameter lists, the parser's
    receiver rule, HIR reachability, the ambiguity rule of `hir/structs.tcl`
    (`FieldCompetes`), and the warning framework.
14. *Warns when the sugared resolution cannot be proven identical?* No.
15. *One-parameter callees (`length(str)`)?* Never.
16. *Calls already written with sugar?* Never.
17. *One-directional?* Yes: it never suggests the functional form.
18. *`nomethod` respected?* Yes: such a function is never a candidate and never
    reported.
19. *Is `nomethod` a suppression pragma?* No: a declaration-level interface fact;
    method syntax to such a function is a resolution *error*.
20. *Unreachable calls ignored?* Yes (HIR's structural reachability).
21. *One diagnostic per call site, no grouping?* Yes.
22. *Prescribes or auto-rewrites?* No: no rewritten expression, no fixit.
23. *Receiver-needing-parentheses policy?* Not eligible: a receiver is eligible
    only when, as written, it is already a postfix/primary expression;
    operator expressions (parenthesized or not: HIR records no parentheses) are
    silent. Pinned, including that `(-1).f(x)` is valid and identical.
24. *Shadowed/ambiguous name silences the warning?* Yes: any second visible
    function of the name, and any struct field of that name that could compete.
25. *Qualified callees?* `mod::f(x, y)` is eligible exactly when the resolver's
    own gathering for `x.f(y)` (imports are exact and not transitive, plus
    lexical lookup) finds that function as the only candidate.
26. *Function-value callees?* Never eligible.

**Architecture**

27. *Stage?* `surface::lower::Finish`, after `hir::buildSyntax`/`hir::check`
    and strict diagnostics, before any backend; unchanged from milestone 1.
28. *Which analyses supply the proof?* The resolver (callee identity, candidate
    gathering, shadowing, aliases, nomethod filtering), parameter declarations,
    the parser's receiver rule, HIR reachability, the struct ambiguity rule, and
    sugar provenance.
29. *How is provenance represented, and is it mode-independent?* A `written
    {form F ns NS}` field on the HIR call, from `written FORM` on the syntax
    node `surface::lower` builds (function, method, list, operator); recorded
    unconditionally (HIR identical under `off` and `default`, pinned).
30. *Does provenance reach NIR/codegen?* No: NIR, generic NIR, CLIF,
    `native::report`, `hir::format` and `hir::lower` never show it (pinned, and
    pinned identical between the functional and the sugared spelling).
31. *Record shape and secondary locations?* `{code message primary secondary
    data}`; `secondary` empty (a single location), so no `note:` line.
32. *Deterministic ordering, including interleaving?* `hir::warnings::Sort`
    (primary origin, code, message); pinned with both orders of a program
    carrying both warnings.
33. *Duplicates across instances?* None: the generic source HIR is read once;
    instances are never walked (365 distinct locations were 365 warnings).
34. *Did framework code change beyond the registry line?* No.
35. *Do the warning, the marker or the flag affect HIR/NIR/optimization/
    runtime?* No (pinned across modes and spellings; nothing under `native/`
    changed).
36. *Does `error` reject before backend lowering?* Yes (traces on `hir::lower`,
    `native::prepareHir`, `native::evalHir`, `core::compiler::evalHir`: 0
    calls; a native-backend CLI run prints no value).
37. *Structurally collectable?* Yes: `hir::warnings::of` / `collect`.
38. *At which levels is the round-trip law verified?* The unit table, the
    fuzzer (9795 sites) and every distinct corpus finding (95 patterns, and
    every call of 23 programs): zero failures.

**Verification**

39. *Corpus findings: how many, which categories?* 365 distinct findings in 95
    patterns over 81 callees: 358 subject-first helper, 7 predicate/mapper, 0
    config object; 74 one-parameter callees (246 call sites) excluded; `nomethod`
    candidates `mutable_array::copy`, `bit_and`, `bit_or`, `bit_xor`.
40. *False positives (round-trip failures)?* Zero.
41. *Warning-mode tests pass?* @@Q41@@
42. *Fuzzer results?* 2000 seeds, 1387 with warnings and 613 without: 0
    failures, 0 missed constructed sites, 0 extra warnings, 9795 of 9795
    round trips; 8 of 8 mutants killed.
43. *Backend parity?* Identical sets on all four backends, in process and
    through `main.tcl` over `examples/stdlib` (pinned).
44. *Full regression?* @@Q44@@
