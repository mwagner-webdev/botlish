# The smallest cross-file module system: `uriEscape` as a real module function

De-nativizing `refined-checks.ir`'s executable core moved `uriEscape`'s
algorithm out of `-native-body` (a copied-per-call-site core IR literal,
NATIVE-URI-ESCAPE.md) and identified the real gap it stood in for: Botlish
had no ordinary way for one source file to define something another file
could use. This milestone adds the smallest such mechanism and uses it for
its acceptance target: `web::uri_escape_text` (`lib/web.bot`) is now an
ordinary cross-file Botlish function, compiled once, and `uriEscape`'s
native (Cranelift) execution calls it directly instead of pasting its body
into every call site.

## 1. Files changed

New:

- `surface/modules.tcl` -- the module loader: namespace &lt;-&gt; file
  mapping, dependency discovery/loading, cycle detection, diagnostics.
- `lib/web.bot` -- `namespace web`, `uri_escape_text` (the migrated
  algorithm).
- `lib/mathish.bot` -- `namespace mathish`, `inc` -- the minimal
  demonstration module (spec's own suggested example).
- `examples/surface/14-modules.bot` -- `mathish::inc`, called twice.
- `tests/surface-modules.test` -- 21 tests: parity, structural (one
  definition/direct calls), namespace identity, transitive dependencies,
  shadowing immunity, all diagnostics, cycles, `uriEscape`'s bridge.

Changed:

- `surface/lexer.tcl` -- `namespace` keyword, `::` operator.
- `surface/ast.tcl`, `surface/parser.tcl` -- `namespace NAME` declaration,
  `mod::name` qualified-name syntax.
- `surface/lower.tcl` -- lowers `mod::name` to a `ref` carrying a
  `qualified {mod name}` field; factors `surface::lower::Finish` (shared
  by `surface::lowerToHir` and `surface::modules::compileProgramFile`).
- `surface/surface.tcl` -- loads `modules.tcl`; `readProgramFile` now goes
  through it.
- `hir/resolve.tcl` -- `hir::resolve::program` takes a `modules` parameter
  (one extra "program"-kind scope per namespace, `ProgramSection`);
  `ResolveQualifiedRef` (a qualified reference's own resolution path, not
  `Lookup`).
- `hir/hygiene.tcl` -- `qualifyModules`: renames every module-section
  binding (and all its refs, bare or qualified) to its qualified spelling,
  so lowered core IR -- name/lexical-scope based, like the rest of this
  engine -- agrees with what HIR resolved. `Rename`/`RenameTo` factored to
  share the renaming mechanics with `qualifyModules`.
- `hir/hir.tcl` -- `hir::buildSyntax` gains `-modules` and
  `-module-native-targets`; `ResolveModuleNativeTargets`.
- `hir/types.tcl` -- `BindingType`'s root-binding case consults
  `moduleNativeTargets` before falling back to the native's own type.
- `compiler/compiler.tcl` -- `GenerateUnit` pushes every module section's
  scope (Tcl compiler backend parity).
- `core/native.tcl` -- `-module-fn {NAMESPACE NAME}` registry field.
- `native/native.tcl` -- the module-native bridge (`ModuleNativeBridge`,
  `ExpandNativeBodies`'s traversal now also collects `moduleNativeCalls`);
  `buildProgramHir` prepends the modules it needs.
- `lib/web.tcl` -- `uriEscape` registration: `-native-body` (the 34-line
  literal) replaced by `-module-fn {web uri_escape_text}`.
- `native/generate-scalar-audit.tcl` -- doc comment only (still calls
  `native::buildProgramHir` unchanged).
- `tests/surface-parser.test`, `tests/native-refinement-propagation.test`
  -- two pre-existing tests updated for intentional behavior changes (§8).

## 2. Module syntax

```
namespace web

fn uri_escape_text(s):
    ...
```

`namespace NAME`, if present, must be the file's first statement
(`surface/parser.tcl`'s `NamespaceDecl`; a `namespace` line anywhere else
is a syntax error). A file without one is an ordinary/entry program,
exactly as before this milestone -- every existing `examples/surface/*.bot`
file is unaffected. Reference syntax is `mod::name`, a primary expression
(`IDENT "::" IDENT`; only one level -- `a::b::c` is a syntax error, no
syntax resolves it as nested namespaces or anything else).

No import statement of any kind exists. §5 of the milestone asked whether
the existing structure could discover dependencies from qualified
references without one; it can, cleanly: `surface/modules.tcl`'s
`QualifiedRefs` walks a file's AST for every `mod::name` it contains, and
that is the complete, exact set of namespaces the file depends on. Adding
`import` syntax on top would only let it disagree with what the code
actually references.

## 3. Namespace &lt;-&gt; file mapping

`ModulePath`: namespace `NAME` maps to exactly one path,
`$::core::libraryDir/NAME.bot` (the same directory the existing Tcl
library convention, `lib/NAME.tcl`, already uses -- `core/core.tcl`).
There is no search path, so "two files define namespace `NAME`" cannot
arise -- `NAME` names one candidate file, period. That file must itself
declare `namespace NAME`; a missing file, a missing declaration, or a
declaration naming a different namespace are each a distinct, clear
diagnostic (`Error` in `surface/modules.tcl`; `{SURFACE MODULE KIND}`
error codes):

- `UNKNOWN-NAMESPACE` -- no such file.
- `NAMESPACE-MISMATCH` -- the file exists but declares no namespace, or a
  different one.
- `UNKNOWN-SYMBOL` -- the namespace loaded fine but has no such
  definition (distinct from `UNKNOWN-NAMESPACE` -- spec §31/45).
- `INVALID-TOPLEVEL` -- a module's top level has something other than a
  function definition.
- `CYCLE` -- a module dependency cycle, with the chain shown
  (`a -> b -> a`).

## 4. Dependency discovery and loading

Implicit, from `mod::name` references alone (§2 above). `LoadNamespace`
loads a namespace at most once per program (memoized in `state loaded`);
`CollectAndLoad` recurses into a namespace's own qualified references
before appending its section, so the result is dependencies-first, and
deterministic (driven only by the referencing files' own fixed AST
structure -- never filesystem enumeration order, hash order, or an ambient
current directory).

## 5. Cycle rule

Rejected, always, with the full chain shown (§26 of the milestone; no
mutual-recursion-across-modules SCC handling). `LoadNamespace` tracks a
"stack" of namespaces currently being loaded; asking for one already on it
is the cycle. Ordinary same-module recursion, including mutual recursion,
is unaffected -- it was never a *module* dependency at all (verified by
`surface-modules-same-module-recursion-is-not-a-cycle`, next to
`surface-modules-cycle`, in `tests/surface-modules.test`).

## 6. Symbol identity: HIR/resolver changes

This is the part that took two real iterations to get right, and is worth
walking through, because the wrong shape looks plausible until it is
actually run.

**Attempt 1 (rejected): flat qualified names.** Bind every module
function directly at the shared program scope, spelled `"mod::name"`.
Simple, and lowers correctly (`hir::lower`'s core IR is just
name-based) -- but a module's own *internal* code, written as ordinary
same-module calls (`odd(n - 1)`, not `parity::odd(n - 1)`), can no longer
resolve its own siblings: only the qualified spelling exists in scope.
Reproducing this everywhere the module was written would mean rewriting
the module author's own source -- unnatural, and not what "same-module
recursion remains normal" (spec §27) asks for.

**Attempt 2 (rejected): a private wrapper block.** Wrap each module's
statements in an immediately-invoked, capture-free closure
(`(call (block () STATEMENTS...))`), so its own body scope is genuinely
private (ordinary same-file resolution inside it, no cross-module
collision), and record that scope as the namespace's own; a qualified
reference resolves directly against it. This is semantically clean at the
HIR level -- and unusable, because `hir::lower`'s core IR, and so the
interpreter and the Tcl compiler alike, are lexical-scope-based at *run
time*: a binding made inside one block invocation is only reachable from
code that was itself created (as a closure) during that same invocation,
never from a sibling top-level statement that runs after the call
returns. Blocks only ever let a *value* escape their own invocation
(through capture, or their own return value), never a binding by name.
`tests/surface-modules.test`, run against this attempt, failed every
cross-file call with `unbound name "mathish::inc"` on interp -- the
wrapper's own `inc` binding was correctly resolved by HIR, and just as
correctly unreachable at run time.

**What actually works: one scope per namespace, same invocation tag.**
`hir::resolve::program` takes a `modules` list (one
`{namespace nodes origin}` per namespace the program needs); each gets its
own **"program"-kind** scope -- `ProgramSection` -- a sibling of the
referencing code's own top scope, both children of the same root.
"Program"-kind, not "block"-kind, is the entire trick: its `invocation`
tag is `""`, the same tag every top-level scope carries (`hir::resolve`'s
"same invocation" rule, which decides whether a reference needs deferred/
captured resolution, compares this tag, not scope ancestry) -- so at run
time every module's bindings are ordinary top-level bindings in the very
same interpreter frame as everything else, exactly like the referencing
program's own. Two different namespaces can still freely declare the same
plain name (`a::parse`, `b::parse`) with zero collision, because they are
genuinely different `ScopeId`s; same-module code (including mutual
recursion) resolves its own siblings by ordinary lexical lookup, exactly
as it would in a single file, because that is exactly what it is doing.

A qualified reference (`ResolveQualifiedRef`) does **not** use
`hir::resolve::Lookup`'s ordinary lexical walk at all: it reaches
directly into `hir modules`' entry for its namespace (populated as each
section resolves, always before the code that references it, since
sections are ordered dependencies-first) and looks up the plain name
there -- immune, by construction, to any local binding named like the
namespace or the symbol (spec §13). Every reference reaching it was
already validated to name a namespace that was loaded and a symbol it
actually has, by `surface::modules::CollectAndLoad`, before this HIR was
ever built; failure here is an internal invariant violation
(`core::malformed`), not a user diagnostic.

**Making two spellings agree for one binding.** Both a bare, same-module
reference (`odd`) and an external qualified one (`parity::odd`) can now
resolve, correctly, to the *same* `BindingId` -- but `hir::lower` prints
whatever the expression's own `name` field says, and those two
occurrences were written with two different spellings. `hir::hygiene::
qualifyModules` (run right after ordinary resolution, alongside the
existing root-reference rename pass) renames every binding a module
section declares -- and every `ref`/`bind` of it, wherever spelled -- to
its one qualified name, exactly the mechanism `Rename` already uses to
keep a hygiene-shadowed root reference faithful through lowering, minus
the `#N` collision search (a qualified spelling can never collide: no
ordinary identifier can spell `::`). This is a **post-resolution,
`BindingId`-driven** rename -- never raw pre-resolution text
substitution -- so it is immune to the exact flaw spec §14 calls out for
the old `-native-body`/`ExpandNativeBodies` (which matched bare `ref`
text before any scope was known, and so could not tell a genuine native
reference from a same-named local shadow). `RenameTo` gained a
`recordSpelling` flag: `Rename`'s hygiene-#N renames keep `spelling`
(diagnostics should show what the programmer wrote, e.g. for a plain
local that happened to shadow a root name), but `qualifyModules`'
renames do not -- the qualified spelling *is* the meaningful identity
here (spec §66), so it is what diagnostics and native symbol names should
show, and now do (`func 1 "mathish::inc"`, not `func 1 "inc"`).

The Tcl compiler backend (`compiler/compiler.tcl`) needed one matching
change: `GenerateUnit` seeds its own scope-tracking `ctx` with only
`hir::top`'s scope (every other scope it ever sees is reached by
recursing into a `block`/`if`/`loop` expression node, which always
triggers its own scope-opening code) -- but a module section's scope has
no owning expression at all, so it is pushed explicitly, up front, under
the very same `base` Tcl frame as `hir::top`'s own scope (mirroring the
interpreter: they are the same run-time frame).

## 7. `uriEscape`'s bridge: the native-only wiring

`uriEscape` stays registered exactly as before (`-impl core::web::uriEscape`,
`-result-type {refined str {UriQueryValue}}`) -- interp and the Tcl
compiler still call the Tcl implementation, evidence and all, unchanged
on every backend but native. What changed is `-native-body` (34 lines of
literal core IR) is gone, replaced by one line:

```
-module-fn {web uri_escape_text}
```

`native/native.tcl`'s `ExpandNativeBodies` traversal (unchanged in shape,
since it already visited every call node checking registry metadata)
additionally records, for every call of a native whose registry carries
`-module-fn`, its IR path and native name (`moduleNativeCalls`).
`ModuleNativeBridge` turns that into the set of namespaces actually
needed (today, just `web`) and loads them
(`surface::modules::LoadNamespaces` -- the *same* general loader ordinary
`.bot` programs use, just given namespace names directly instead of
discovering them from source syntax); `buildProgramHir` prepends their
sections and passes `-module-native-targets {uriEscape web
uri_escape_text}`.

That option (`hir::ResolveModuleNativeTargets`, `hir/hir.tcl`) resolves,
right after resolve/hygiene, into `moduleNativeTargets`: native name -&gt;
`{BlockExprId Arity}`. `hir::types::BindingType`'s root-binding case
consults it: a reference to a native whose name is a key there is typed
as `{block E arity any}` -- the ordinary module function's own type --
*instead of* `{native Y}`. This is deliberately **not** a one-shot edit
of the call's own `target` field (an earlier draft tried exactly that,
and specialization's own per-instance re-inference, which re-runs
`hir::types::Call` on scratch copies of the region, silently recomputed
`target` back to `{native Y}` on the very next pass -- discovered by the
same differential testing this milestone's tooling already does). Baking
the redirection into `BindingType` itself means every re-inference,
original or scratch, sees the same answer, consistently -- and it is
scoped by the native's own resolved root `BindingId` (`core::value::
nativeName`), never by name text, so it cannot mistake a locally shadowed
name for the native either.

The call's own **result type** still comes from the native's declared
`-result-type`, via the pre-existing `-native-result-overrides`
mechanism (unchanged, still populated the same way `-native-body` used
to populate it) -- so `str[UriQueryValue]` survives untouched, exactly as
`NATIVE-URI-ESCAPE.md`'s milestone already established, just through a
call whose *target* is now an ordinary compiled function rather than an
inlined body.

## 8. Two pre-existing tests updated

- `tests/surface-parser.test`'s `parse-error-double-colon`: `"a::b"` used
  to be (by construction, since `::` did not lex as one token) a syntax
  error; it is now valid `qualname` syntax. Replaced with `"a::b::c"`
  (still, and by design, a syntax error -- only one `::` level is
  supported).
- `tests/native-refinement-propagation.test`'s `...-without-override-
  loses-it`: this "control" case used to demonstrate that, without
  `hir::ApplyNativeResultOverrides`, `-native-body`'s substituted call
  fell back to the *body's own* inferred type. `uriEscape` no longer has
  a `-native-body` to substitute, so the old body (which called
  `native::ExpandNativeBodies` + `hir::build` directly) no longer
  exercises that path at all. Rewritten to the genuinely analogous
  control for the new mechanism: `web::uri_escape_text`, referenced
  directly (no native, no override), types as plain `any` -- confirming
  the opaque type is never forged by the module mechanism itself, only
  ever supplied by the native's own registered contract.

## 9. `-native-body` status

Still used -- by `Emailish?`'s predicate (`lib/web.tcl`,
`core::type::definePredicate`'s third argument) and by
`tests/helpers.tcl`'s `NonEmpty?` fixture. Neither this milestone's
`uriEscape` migration nor anything else here touches `ExpandNativeBodies`'
substitution logic (only its *traversal*, which now also records
`moduleNativeCalls` alongside its existing `nativeResultOverrides` -- the
substitution behavior itself is unchanged and still exercised by every
`Emailish?`/`UriQueryValue?` test). `-native-body` is not generalized,
not removed, and not otherwise touched; ordinary module definitions now
supersede it for reusable library *code* (any new cross-file helper
should be an ordinary module function, not a `-native-body`), but it
remains the transitional bridge for a native whose implementation itself
needs to run as a *type predicate* with no separate module home of its
own.

## 10. Representative cross-file call

Source (`examples/surface/14-modules.bot`, referencing `lib/mathish.bot`):

```
namespace mathish            fn inc(x):
                                  x + 1
[mathish::inc(41), mathish::inc(1)]
```

Resolved HIR (`-hir -origins`; trimmed):

```
e1 bind b1 mathish::inc : block(e2)/1 -> int @file f2 node inc() ...
    e2 block s4 (b2 x) captures () : block(e2)/1 -> int @file f2 ...
        e3 call native(+) : int @file f2 ...
e7 call native(list) : list @file f1 node list ...
    e9  call block(e2) : int @file f1 node list/item1 ...
        e10 ref b1 mathish::inc : block(e2)/1 -> int @file f1 ...
    e12 call block(e2) : int @file f1 node list/item2 ...
        e13 ref b1 mathish::inc : block(e2)/1 -> int @file f1 ...
```

`e1` (the definition) is attributed to `f2` = `lib/mathish.bot`; both call
sites (`e9`/`e12`) and their callee references (`e10`/`e13`) are
attributed to `f1` = the referencing file -- `hir::sourceFile $hir f2`
resolves to the real path. Both references resolve to the identical
`block(e2)` target: one compiled definition, two call sites.

NIR (`-emit-nir`, `native::nir`):

```
func 0 "<program>" ...
    %2 = call 1 %0 @e9
    %5 = call 1 %3 @e12
    ...
func 1 "mathish::inc" params=1 ... @e2
    ...
```

x86-64 (`native::object`, `objdump -dr`):

```
  4c: call   51 <botlish_fn_0+0x51>
        4d: R_X86_64_PLT32  botlish_fn_1-0x4
  ...
  78: call   7d <botlish_fn_0+0x7d>
        79: R_X86_64_PLT32  botlish_fn_1-0x4
```

Both call sites: a direct `call` with a `R_X86_64_PLT32` relocation to
`botlish_fn_1` (`mathish::inc`'s own compiled function) -- no function
table, no registry lookup, no string lookup, no indirect call. (Object-
level symbol names are the pre-existing `botlish_fn_N` scheme for *every*
function, module or not; the readable, provenance-carrying name
`mathish::inc` is what the NIR/CLIF *text* dumps show, exactly as an
ordinary same-file function's name already was before this milestone --
modules changed nothing about that scheme, for better or worse.)

## 11. `uriEscape` before/after

Before (`NATIVE-URI-ESCAPE.md`):

```
-native-body {block {s} ...34 lines of literal core IR... }
```

registered on `uriEscape` itself; `native/native.tcl`'s
`ExpandNativeBodies` pasted a *copy* of that block into the callee
position of every call site, before `hir::build` ever ran -- "each direct
call site gets its own literal body inlined (no sharing across call
sites)" (that document's own §7, listed as a known limitation).

After:

```
-module-fn {web uri_escape_text}
```

`web::uri_escape_text` (`lib/web.bot`) is an ordinary module function,
resolved through the regular semantic resolver (§6 above), compiled once,
and referenced by its stable `BindingId`/`ExprId` -- never pasted.

Measured (a program calling `uriEscape` twice, `native::codeSize`/
`native::nir`):

| | before (documented) | after (measured) |
|---|---|---|
| body copies | 1 per call site (2, for 2 calls) | 0 |
| compiled `uri_escape_text`-equivalent instances | N/A (no shared function existed) | 1 |
| direct calls to it | N/A | 2 |
| total machine code | not measured then | 8185 B (one call: 8046 B; the ~139 B delta is the extra call-site glue only) |

`refined-checks.ir` (the acceptance target, one `uriEscape` call): still
`[400, 0]` on `cranelift`, unchanged, with `BOTLISH_NATIVE_GC_STRESS=1`
too.

## 12. Runtime allocation/lookup accounting

The later immutable-module-binding extension is documented in
MODULE-BINDINGS.md. `mathish::inc` remains envless and uses the existing
direct-call path. `web::uri_escape_text` now captures `web::hex_digits`,
so its one closure is created at program startup and its statically known
`callenv` calls carry the existing hidden environment field. There is no
runtime namespace/name lookup or dynamic dispatch; CLIF calls its compiled
function directly. The table changes from one List allocation per call to
one allocation per program execution.

## 13. Audit corpus

`audit/native-scalar-asm/bench/refined-checks.{summary,asm}.txt` (and its
`roots.txt` neighbor) are now stale: they show `uriEscape`'s old
`-native-body` shape (its helpers -- `high_nibble`, `esc_from`, etc. --
inlined, unqualified, into the one function the old expansion produced).
Regenerating them needs `native/generate-scalar-audit.tcl`, which -- like
its `NATIVE-URI-ESCAPE.md`-era predecessor -- has no per-file selection
and regenerates the *entire* corpus (every `bench/*.ir` and
`examples/stdlib/*.bot` program). Following that same milestone's own
precedent (its §11: "updated status line (targeted, not a full corpus
regeneration)"), this is left undone here rather than risking unrelated
diffs across the whole committed corpus; §10/§11 above give the same
before/after evidence (HIR, NIR, x86-64, byte counts) a regeneration would
show for this specific native, gathered directly instead.

## 14. Regression status

`tests/all.tcl` (interp + compile), `tests/surface-modules.test` (28/28),
`tests/native-uri-escape.test` (18/18, unchanged), `tests/
native-refinement-propagation.test` (14/14, one test rewritten per §8),
`refined-checks.ir` on `cranelift`/`compile` (`[400, 0]`, with and without
`BOTLISH_NATIVE_GC_STRESS=1`); `interp` on `refined-checks.ir` still hits
Tcl's own recursion limit at this `n`, a pre-existing, unrelated fact
(confirmed identical before this milestone's changes, via `git stash`).

## 15. Final answers

1. **Is namespace identity one-to-one with source-file identity?** Yes.
   `ModulePath` is a pure function name -&gt; path with no search path; a
   loaded module's own file must declare exactly that name (`NAMESPACE-
   MISMATCH` otherwise). One file can declare at most one namespace (the
   grammar only allows one `namespace` statement, and only as the first
   statement); one namespace can only ever be satisfied by one file.

2. **Can namespaces be aliased?** No. No syntax exists for it (`import
   X as Y`/`from X import y`/`using`/`open` are simply not part of the
   grammar -- `"import web as w"` and a stray `namespace` declaration are
   both ordinary syntax errors, tested). The qualified spelling is the
   only spelling a reference can ever have.

3. **How is a qualified symbol resolved?** `hir::resolve::
   ResolveQualifiedRef`, directly against the namespace's own section
   scope (`hir modules`'s table, populated as each section resolves) --
   not `hir::resolve::Lookup`'s lexical walk, so it is immune to any
   local binding sharing the namespace's or the symbol's name.

4. **Does later lowering operate on strings or stable semantic IDs?**
   Stable IDs. Resolution fixes a qualified reference's `binding`
   (`BindingId`) once; every later stage (types, specialize, native
   lowering) reads that `BindingId`/its `block` `ExprId`, never
   re-matching the "mod::name" text. `hir::hygiene::qualifyModules`
   ensures the *lowered core IR text* -- which interp and the Tcl
   compiler do still run on, being genuinely name-based engines -- agrees
   with that identity, but the identity itself is fixed before that pass
   even runs.

5. **Is an imported function compiled once or pasted at every call
   site?** Compiled once (§6/§10/§11): one `BindingId`, one `block`
   `ExprId`, one compiled function/specialization; every call site
   references it directly.

6. **Are cross-module exact calls direct in machine code?** Yes: a
   direct `call` with a `R_X86_64_PLT32` relocation to the callee's own
   function, both call sites (§10) -- no function table, no registry, no
   string lookup, no indirect call.

7. **Does specialization still operate across the boundary?** Yes,
   unmodified: a module function is an ordinary closed-call target
   (`{block E arity result}`), so `hir::types::Call`'s existing
   specialization-handler path and `native/lower.tcl`'s existing
   `envless`/direct-call machinery apply exactly as they would to a
   same-file function -- no module-specific call form was added anywhere
   in that pipeline.

8. **Did any optimization fact get lost merely because the callee moved
   files?** Not measurably, and not by construction: nothing in
   specialize/escape/range/native-lowering was changed to accommodate
   modules; a module function is simply an ordinary top-level function
   whose `BindingId` happens to live in a different (but ordinary,
   "program"-kind) scope. `uriEscape`'s own result type is deliberately
   *not* left to whatever the module function's body would infer (it
   would be a plain `str`) -- the pre-existing `-native-result-overrides`
   mechanism keeps the native's own declared `str[UriQueryValue]`, exactly
   as `-native-body` already did; nothing new was needed there.

9. **Does `uriEscape` still use `-native-body` anywhere on the native
   path?** No. Its registration carries `-module-fn {web
   uri_escape_text}` and no `-native-body` at all.

10. **What remaining uses of `-native-body` exist?** `Emailish?`'s
    predicate (`lib/web.tcl`) and a test fixture, `NonEmpty?`
    (`tests/helpers.tcl`) -- both type predicates, not migrated by this
    milestone (§9 above).

11. **Is opaque evidence handling unchanged?** Yes. `core::web::uriEscape`
    (the Tcl `-impl`) is untouched and stays authoritative for evidence on
    every backend but native; `web::uri_escape_text` is ordinary,
    unprivileged Botlish that only ever computes the escaped *text* and
    could not attach `UriQueryValue` evidence even if it tried (confirmed
    directly: referenced without the native's override, it types as plain
    `any`, never `str[UriQueryValue]` -- `tests/native-refinement-
    propagation.test`'s rewritten control case).

12. **Does `refined-checks` still return `[400, 0]`?** Yes, on `cranelift`
    and `compile`, with and without `BOTLISH_NATIVE_GC_STRESS=1`.

13. **What module limitations are intentionally left for later?**
    MODULE-BINDINGS.md adds eager immutable values, but not mutable globals,
    lazy cells, namespace aliasing/imports/re-exports, separate or
    incremental compilation, a search path/package registry/versioning, or
    cross-module mutual recursion. Module dependency cycles remain rejected.

14. **How are module values initialized safely?** Each ordinary module
    `bind` is an ordinary program root. Dependency-first module order and
    source order inside a module execute it once before the entry roots.
    `hir/modulebinding.tcl` requires a context-free initializer and a
    transitively immutable retained result; it uses resolved call targets
    and native metadata, not source spelling. See MODULE-BINDINGS.md for
    the complete rule, diagnostics, and `web::hex_digits` evidence.
