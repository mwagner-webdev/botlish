# R2.a.2: ordinary trailing-`?` identifiers

## Outcome

**Achieved, and simpler than the milestone spec anticipated.**

- A terminal `?` is now ordinary Botlish identifier spelling. `foo?`,
  `Emailish?`, `snake_case?`, `web::emailish?(x)` all lex as one `IDENT`
  token whose semantic text and source span include the `?`. Embedded or
  repeated `?` (`foo?bar`, `foo??`, `foo???`) and a bare `?` not attached to
  any name (`?foo`, `x ? y`) are still rejected, each with a clear
  diagnostic, never silently split into surprising adjacent tokens.
- The milestone spec's central architectural concern — a legacy uppercase
  `NAME?` **parser** production for "callable-type" syntax that this
  change would have to coexist with — **does not exist**. It was audited
  directly (see "Legacy callable-type syntax census" below) and traced to
  a Tcl-side native-registry naming convention plus an HIR-literal test
  notation, neither of which ever passes through `surface/lexer.tcl` or
  `surface/parser.tcl`. There was nothing to preserve, adapt, or
  compatibility-shim at the parser level. `surface/parser.tcl` is
  unchanged by this milestone.
- `web::is_emailish` (`lib/web.bot`) is renamed to `web::emailish?`, and
  `lib/web.tcl`'s `-module-fn` bridge target follows it. The root predicate
  binding (`emailish?`) and the module implementation binding
  (`web::emailish?`) remain distinct bindings that merely share a
  basename now; the `-module-fn` bridge is what connects them, not name
  equality, and R2.a.1's bridge-reachability fix keeps working across the
  rename unmodified.
- Full regression: **2481/2481 passed**, 85 test files, no skips. GC
  stress under `BOTLISH_NATIVE_GC_STRESS=1` was not run locally for this
  milestone (by request) — it runs automatically in CI's `gc-stress` job
  on every push to `main` (`.github/workflows/tests.yml`), and this
  change touches nothing about stack walking, roots, or allocation, only
  identifier spelling and one string constant.
- The regenerated scalar assembly audit corpus (`audit/native-scalar-asm/`)
  differs from before this milestone **only** in the function-9 debug
  label text (`web::is_emailish<generic>` → `web::emailish?<generic>`),
  in six lines across `refined-checks.asm`/`.summary.txt`. No instruction
  bytes, register counts, or relocation targets changed.
- R2.a remains **unfrozen**. R2.a.3 (counted-loop syntax and the
  remaining recursive loop-shaped source normalization) is next.

## Old lexer behavior

Before this milestone, `surface/lexer.tcl`'s identifier-scanning branch
(the `{[A-Za-z_]}` case) scanned `[A-Za-z_][A-Za-z0-9_]*` as an `IDENT` (or
keyword) token, then unconditionally checked the very next source
character:

```tcl
set text [string range $source $i $j-1]
set kind [expr {$text in $keywords ? $text : "IDENT"}]
lappend tokens [Token $kind $text $text [Span $file $i $j $line $lineStart]]
set i $j
if {[string index $source $i] eq "?"} {
    Report diagnostics $file $i $line $lineStart 1 "\"?\" is reserved and cannot be part of a name"
    incr i
}
```

`?` was never a Tcl-level character class this branch cared about (it
wasn't in `variable operators` at `surface/lexer.tcl:61` either), so any
identifier immediately followed by `?` produced two things: the plain
identifier token (`emailish`, not `emailish?`) and a **separate,
always-fired** diagnostic that skipped the `?` as a single erroring
character — regardless of case, regardless of what came after. This was
purely character-driven: lexing happens before any parsing, resolution, or
context exists, so there was no way for a "type position" to get a
different token stream even in principle.

## Existing reason `?` was reserved

There wasn't a load-bearing one. `tests/surface-lexer.test`'s
`lex-reserved-question-mark` test and this file's own header comment
documented the restriction as a blanket rule ("`?` after a name
skipped"), with no comment anywhere in `surface/lexer.tcl` or
`surface/parser.tcl` claiming it was reserved *for* something. The
belief that it was reserved for the callable-type syntax traces to
`R2A-IDIOMATIC-EMAILISH-SOURCE.md`'s own prior-milestone commentary
("`?` reserved for the uppercase NAME? callable-type-predicate type-
position syntax elsewhere in the grammar"), which — verified directly
against the parser's source rather than repeated — turns out to be
speculation, not a grammar fact. R2.a itself (`R2A-IDIOMATIC-EMAILISH-
SOURCE.md` item 34) says as much implicitly: it notes `web::emailish?`
"has nothing to resolve to" only because the lexer rejected `?`, not
because any type-position grammar needed the character.

## Legacy callable-type syntax census

Audited directly (grep + read, not inference) across `surface/lexer.tcl`,
`surface/parser.tcl`, `hir/types.tcl`, `hir/sourcetypes.tcl`,
`core/type.tcl`, `tests/*.test`, and every `*.md` doc:

- `surface/parser.tcl`'s only type-position grammar is `TypeExpr`
  (`surface/parser.tcl:471-482`): `IDENT ["[" TypeExpr "]"]`
  (MINIMAL-APPLIED-LIST-TYPES.md). It expects an `IDENT` then optionally
  `[`. There is no branch anywhere in `surface/parser.tcl`'s full
  production list (`Program`, `Domain`, `ExactDomain`, `TypeDecl`,
  `Function`, `TypeExpr`, …) that ever looks at a `?` token, because the
  lexer never emitted one attached to a name to look at.
- The actual `NAME?` convention is `core::type::definePredicate`
  (`core/type.tcl:383-395`): `if {$predicateName eq ""} { set
  predicateName $name? }` — a **Tcl string default** (`$name` concatenated
  with the literal character `?`), registering the type's membership
  predicate under that Tcl dict key via `core::native::register`. This is
  a plain Tcl proc call with a Tcl string argument; it is never lexed
  Botlish source, has no interaction with `surface/lexer.tcl`, and is
  completely unaffected by this milestone (still the same `$name?`
  default, still works identically before and after).
- `lib/web.tcl:53/64`'s `core::type::definePredicate Emailish emailish? ""
  {web emailish?}` and `core::native::alias Emailish? emailish?` are the
  same mechanism: Tcl proc calls with Tcl string/list arguments, not
  surface syntax.
- Every test exercising `Emailish?`/`UriQueryValue?` in "callable-type"-
  looking form (`tests/emailish-predicate.test`,
  `tests/native-validator-predicate.test`,
  `tests/native-refinement-propagation.test`, and others) constructs
  Tcl-list HIR literals (`{call {ref Emailish?} {ref s}}`) fed straight to
  `hir::build`/`native::buildProgramHir`, or Tcl string args to test
  helpers — an internal s-expression notation that bypasses
  `surface::lex`/`surface::parse` entirely. `grep -rn "Emailish?"
  --include=*.bot .` finds **zero** occurrences in real Botlish source
  (only a comment in `bench/uri-steady.bot`).
- Conclusion: there is no grammar production, no token shape, and no
  parser branch to preserve. Sections 5–8, 33–36, and 59 of the milestone
  spec (compatibility architecture, before/after token shape, localized
  deletability) are all **moot**: there is nothing there to adapt, and
  nothing for the later callable-type-removal refactor to delete except
  the Tcl-side `$name?` default and `core::native::alias` calls, which
  were never in scope for this milestone regardless.

This also answers the stop-and-report condition (spec item 64): no
ambiguity was found, so no shim, and nothing was stopped.

## Chosen lexical rule

`surface/lexer.tcl`'s identifier branch now scans the ordinary body, then
optionally one terminal `?`, then rejects (as one diagnostic, not a split
token) anything that would extend the name further:

```tcl
{[A-Za-z_]} {
    set j $i
    while {$j < $n && [regexp {[A-Za-z0-9_]} [string index $source $j]]} {
        incr j
    }
    set end $j
    if {[string index $source $j] eq "?"} {
        set end [expr {$j + 1}]
    }
    set text [string range $source $i $end-1]
    set kind [expr {$text in $keywords ? $text : "IDENT"}]
    lappend tokens [Token $kind $text $text [Span $file $i $end $line $lineStart]]
    set i $end
    if {$end > $j} {
        set extraStart $i
        set k $i
        while {$k < $n && ([string index $source $k] eq "?"
                || [regexp {[A-Za-z0-9_]} [string index $source $k]])} {
            incr k
        }
        if {$k > $extraStart} {
            Report diagnostics $file $extraStart $line $lineStart [expr {$k - $extraStart}] \
                "\"$text\" already ends in \"?\": an identifier can end in at most one \"?\", with nothing directly after it"
            set i $k
        }
    }
}
```

This produces exactly one `IDENT`/keyword token whose `value`/`text` is
the full spelling including `?`, and whose span covers it — never
`IDENT("foo")` followed by a separately-lexed `QUESTION`. `regexp
{[A-Za-z0-9_]}` never distinguishes case, so nothing here treats
`Emailish?` differently from `emailish?` or `EMAILISH?`; case sensitivity
downstream (the one explicit `Emailish? -> emailish?` alias) is entirely
`core::native::alias`'s doing, untouched by this change.

Bad-continuation recovery follows this file's own established pattern for
`INT` (`12ab`'s invalid suffix: one diagnostic covering the whole bad run,
the char run consumed and not re-lexed as further tokens) rather than the
old bare-`?` pattern (skip one character, resume lexing normally): `?`
being terminal means nothing may legally continue after it, so the entire
extra run (`bar` in `foo?bar`, the second/third `?` in `foo??`/`foo???`)
is swallowed into one diagnostic and one token, never emitted as
additional adjacent tokens a parser could get confused by.

## Parser: unchanged

`surface/parser.tcl` has no diff in this milestone. `TypeExpr` still reads
`IDENT ["[" TypeExpr "]"]`; nothing needed to learn about `?` because
nothing in the grammar ever depended on the old rejection (see census
above).

## Name-resolution / qualified-name behavior

Unaffected by construction: `hir/resolve.tcl`, `surface/modules.tcl`, and
`core/native.tcl` all key their dicts by exact string equality (`dict
get`/`dict exists`, `$name in [dict keys ...]`) — never `string match` or
any glob-style lookup. A trailing `?` is just one more character in an
otherwise-ordinary Tcl string key, so:

- `surface/modules.tcl`'s per-module `functionNames` list stores
  `dict get $statement name` verbatim — `emailish?` end to end, no
  stripping.
- `core::native::canonicalName`/`core::native::names`
  (`core/native.tcl:316-355`) are exact-key dict operations; `Emailish?`
  resolving to `emailish?` is `dict exists $aliases $name`, not pattern
  matching.
- `native/native.tcl`'s `ExpandNativeBodiesIn` (the `-module-fn`/
  `-native-body` substitution pass) checks `$calleeName in
  [core::native::names]` against the **unqualified** native registry only.
  A qualified reference like `web::emailish?` is never a member of that
  set (module-qualified names live in a separate, per-module dict), so
  giving the module implementation the same basename as the root
  predicate creates no resolution recursion: qualification, not spelling,
  is what keeps the two lookups apart. This was already true when the
  module function was named `is_emailish` (a different basename); it
  remains true now that the basenames coincide, for the same structural
  reason (Section 65/item 16's "basename recursion hazard" — audited,
  not found).
- One focused Tcl-glob-hazard control: `tests/surface-lexer.test`'s
  `lex-question-mark-no-glob-collision` tokenizes `"foo? fooa foob"` and
  asserts three distinct `IDENT` tokens — `?` is a glob metacharacter in
  Tcl (`string match`/`glob`), but nothing in the identifier/module-lookup
  path uses glob matching (`switch -glob` at `surface/lexer.tcl:142`
  only ever glob-matches a single literal character against fixed
  one-character patterns like `" "`/`"#"`/`{[0-9]}`, never a whole
  identifier), so no fix was needed — this pins that fact rather than
  reporting a defect.

## `web::emailish?` rename

`lib/web.bot`: `fn is_emailish(v):` → `fn emailish?(v):`, with the header
comment updated to explain the rename and point at this report instead of
claiming the old lexer restriction as the reason for the old name.
`local_extra_chars` stays at true module scope, untouched (R2.a.1's own
fix), and `scan_while`/predicate-passing/`domain_loop`'s recursive shape
are all unchanged (R2.a.3's job, not this one).

`lib/web.tcl`:

```diff
-core::type::definePredicate Emailish emailish? "" {web is_emailish}
+core::type::definePredicate Emailish emailish? "" {web emailish?}
 ...
-core::native::alias Emailish? emailish?
+core::native::alias Emailish? emailish?   # unchanged
```

## Bridge target rename / root vs. module identity

The `-module-fn` bridge's target changed from `{web is_emailish}` to
`{web emailish?}`; nothing about *how* the bridge resolves changed
(`native/native.tcl`'s `ExpandNativeBodiesIn`/`ModuleNativeBridge`, R2.a.1
territory, is untouched). Confirmed still distinct and correctly wired:

- `core::native::metadata emailish?`'s `moduleFn` is `{web emailish?}`
  (`tests/native-validator-predicate.test`).
- The root `emailish?`/`Emailish?` alias pair still resolves to one
  `BindingId`/`SymbolId`/registry entry (`tests/emailish-predicate.test`'s
  `emailish-predicate-alias-*` tests, unmodified, still passing).
- The compiled NIR/machine code still shows exactly one function body for
  the module implementation (`func 9 "web::emailish?"`, `nir-regs=27`,
  identical instruction count to before) and exactly one real dynamic call
  site into it, with the redundant cross-spelling re-check folded away
  statically — same as before the rename, only the label text differs.

## HIR before/after

Neither `hir/types.tcl` nor `hir/resolve.tcl` changed. The hand-written
HIR fixtures `examples/hir/06-refined-strings.hir`/`.ir` reference only the
root predicate (`emailish?`/`Emailish?`), never the module implementation
name, so they are untouched — HIR dumps never showed `web::is_emailish` in
the first place; that spelling only ever appeared in native/NIR debug text
(see below), which is now `web::emailish?`.

## NIR before/after

`native::nir`'s function-listing text: `func 9 "web::is_emailish"` →
`func 9 "web::emailish?"`. This is `f.name` (`native/src/codegen/clif.rs`),
a plain Rust `String` carried only in a debug `HashMap<u32, String>` for
listing/display (`format!("{name} ({})", f.name)`,
`format!("; function {} \"{}\": botlish_fn_{}\n", f.id, f.name, f.id)`) —
**never** used as a Cranelift/linker symbol. The actual `declare_function`
calls always use the numeric `botlish_fn_{id}`/`botlish_entry_{id}` forms
(`native/src/codegen/mod.rs:178,191`), so `?` never reaches anything
Cranelift or the system linker treats as a symbol-name character class.
No Rust changes were needed or made; see "Rust tests" below.

## Allocation / instance / code-size invariance

`tests/native-block-escape.test`'s pinned counts (module-init-only
`local_extra_chars` List/ImmutableSet, 800 `is_local_char` closures, 9,200
`char_at` Strings) are unchanged — they're literal assertions in the same
test file, still passing verbatim. The regenerated
`audit/native-scalar-asm/bench/refined-checks.{asm,summary.txt}` diff is
six lines, every one a `web::is_emailish` → `web::emailish?` text
substitution in a comment/disassembly label or relocation annotation; no
instruction byte, `nir-regs` count, or `raw regs`/`managed-capable regs`
value changed. `README.md`'s only diff is the recorded git-commit
provenance line (expected: the script embeds current `HEAD`).

## Alias / refinement controls

All of R2/R2.a.1's alias and refinement invariants
(`tests/emailish-predicate.test`) still pass unmodified in substance (only
the module-name string constants inside a few of them were updated to
match the rename): both spellings resolve to the identical
`BindingId`/`SymbolId`; `Emailish?` is `core::native::isAlias`, not a
second registry entry; refinement folds across spellings; the redundant
re-check is HIR-`known`, not dynamic; no anonymous callee-position
instance exists.

## R2.a.1 bridge regression

`tests/module-fn-bridge-reachability.test`'s full focused suite (root
call, nested caller, capturing caller, returned closure, transitive
module dependencies, the `uriEscape` reproducer, `emailish?`/`Emailish?`
user-block calls, refinement + redundant second check) passes with the
only textual difference being `web::is_emailish` → `web::emailish?` in
the NIR-shape assertions. `uriEscape`/`web::uri_escape_text` is untouched
(different function, out of scope for this milestone).

## Residual module-fn limitation

Unchanged and not investigated further, per spec item 39: a module
function that calls a bridged native whose module target is defined later
in the same module still fails loudly (`{NATIVE BUG} native lowering:
binding ... is not reachable from ...`), not silently. This milestone
did not touch `native/native.tcl`'s bridge-provenance logic at all.

## Focused syntax tests

`tests/surface-lexer.test` gained ten new tests (`lex-trailing-question-
identifiers`, `-call`, `-declaration`, `-adjacency`,
`lex-question-mark-still-bare-elsewhere`, `-terminal-only`,
`-distinct-names`, `-no-glob-collision`, `-span`) and two existing tests
were adapted to the new semantics (`lex-reserved-question-mark` replaced;
`lex-recover-characters`'s input changed from `c? = 1`, now valid, to
`c?d = 1`, still an error). Covered: bare identifiers, qualified calls
(`web::foo?(x)`), function declarations, parameters, adjacency to `:`, `,`,
`)`, `==` without swallowing them, rejection of `?foo`/`foo?bar`/
`foo??`/`foo???`, `foo`≠`foo?` distinctness, the Tcl-glob-collision check,
and full source-span coverage including the `?`. All 41 tests in this file
pass; the full suite's 2481/2481 includes them.

There is no lossless/error-tolerant editor-facing parser or separate
LSP token grammar in this repository (checked: no `lossless`, `LSP`, or
`error-tolerant` hits anywhere under `surface/`) — the one lexer/parser
pair audited above is the only entry point, so there is nothing separate
to keep consistent.

There is no formatter, source re-printer, or token round-trip/parse-print-
parse facility in this repository either (checked: no such tool exists
under `surface/` or elsewhere) — spec item 49 is answered "not
applicable" rather than silently skipped.

## Full regression

```
LANG=C.utf8 LC_ALL=C.utf8 tclsh9.0 tests/all.tcl
...
Tests ended at Sun Sep 27 15:21:05 UTC 2026
all.tcl:	Total	2481	Passed	2481	Skipped	0	Failed	0
Sourced 85 Test Files.
```

## GC stress

Not run locally for this milestone, at the user's direction: it runs
automatically in CI (`gc-stress` job, `.github/workflows/tests.yml`) on
every push to `main`, and this change alters no stack-walking, root-
tracking, or allocation-site code — only identifier spelling in the lexer
and one string constant (`is_emailish` → `emailish?`) threaded through a
module-function name. The prior GC-stress baseline on `main`
(R2.a.1's own report) already exercises this exact closure-bridge path
under stress; nothing here changes its shape.

## R2.a source status

Still **unfrozen**. `domain_loop`/`scan_while`'s self-tail recursion and
the recursive loop-shaped source throughout `lib/web.bot` are unchanged,
as required (spec item 20) — R2.a.3 introduces counted-loop syntax and
performs that normalization.

## Rust tests

**No Rust production code changed.** Confirmed by direct read of
`native/src/codegen/clif.rs`/`mod.rs`: function debug names are stored in
an ordinary `HashMap<u32, String>` used only for text listings, and every
`declare_function` call uses the numeric `botlish_fn_{id}`/
`botlish_entry_{id}` symbol forms — never the Botlish-level name. No
identifier-mangling code exists to special-case `?` (or any other
character), so none needed changing. `cargo build --release
--manifest-path native/Cargo.toml` was run (to produce the audit corpus
and exercise the native backend in the full regression) but produced no
diff; no `cargo test` run was needed since no Rust source changed.

## Required-question answers (spec items 58–63)

1. Before: `IDENT` (no `?`) plus an immediate `"?" is reserved..."`
   diagnostic that skipped the `?`. 2. `surface/lexer.tcl`'s identifier
   branch (see "Old lexer behavior"). 3. One `IDENT` token, text/value
   `"foo?"`. 4. Yes, `?` is in the token's span. 5. No — only exactly at
   the end. 6. No — a second `?` is rejected. 7. No — case has no lexical
   effect, confirmed by `regexp {[A-Za-z0-9_]}` never distinguishing
   case and by the identical treatment of `Foo?`/`foo?`/`FOO?` in tests.
2. The old uppercase `NAME?` "syntax" is `core::type::definePredicate`'s
   Tcl-side `$name?` registry-key default (plus the `core::native::alias`
   `Emailish?` compatibility alias) — not surface grammar. 9. No grammar
   production owns it (see census). 10/11. No tokens before or after: it
   never touched the lexer/parser. 12. Trivially: nothing there needed to
   change. 13. Yes — it's Tcl code (`core/type.tcl`, `lib/web.tcl`)
   entirely outside the lexer/parser, deletable independently of ordinary
   `foo?` identifiers whenever the later callable-type-removal refactor
   happens. 14. No.
3. Yes (`fn emailish?(v):` in `lib/web.bot`). 16. Yes
   (`web::emailish?(v)`, exercised throughout `tests/emailish-
   predicate.test`, `tests/module-fn-bridge-reachability.test`). 17. Yes
   (exact-string dict keys throughout). 18. Yes (HIR never showed the
   module name to begin with; unaffected). 19. Yes (numeric symbol names
   only; see "NIR before/after"). 20. Yes — the one found (`?` as a Tcl
   glob metacharacter) was audited and confirmed not to interact with any
   real lookup path; a focused control test pins this.
4. Yes, unless a new architectural blocker was found — none was. 22. Yes.
   23. Yes. 24. Yes. 25. Yes (`{web emailish?}`). 26. Yes (unchanged
   `core::type::PredicateImpl`/validator mechanism).
5. Allocation counts: unchanged (pinned test assertions still pass
   verbatim). 28. Machine bytes: unchanged except six comment/label-text
   lines in the regenerated audit corpus. 29. Instance count: unchanged
   (`emailish-predicate-no-second-instance`,
   `-check-scanner-instance-count` still pass). 30. Function count:
   unchanged. 31. Call-form counts: unchanged
   (`emailish-predicate-redundant-check-nir-shape`,
   `module-fn-bridge-emailish-refinement-in-user-block` still pass). 32.
   Capture/OpenInstances: unchanged (`check<generic>` capturing
   `web::emailish?`'s closure is the same shape as before, just renamed).
   33. M9 entry facts: unchanged (same `check<generic>`/no-Int-fact
   situation R2.a.1 already recorded, untouched by this milestone).

## Next step: R2.a.3

Counted-loop syntax, and normalizing the remaining recursive loop-shaped
source (`domain_loop`, `scan_while`'s self-tail recursion) to use it. R2.a
stays unfrozen until that lands.
