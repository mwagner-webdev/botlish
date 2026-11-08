# Native unused-context import correctness, milestone 1

Importing a declaration makes it available for name resolution and type
checking; it does not run it. A module may declare a context and a
resource whose `cleanup fn` requires that context, and a program may import
the module for something else. Such a program now runs on every backend
without installing the context. On the native backends it used to fail at
lowering with `NATIVE BUG: context load ... which the program does not
install`.

The fix is to the dependency edge, not the symptom. The native backend
compiled every cleanup function as a root of the program. It now compiles
a cleanup where it compiles code that may release that cleanup's resource.
That is the rule the context analysis already used to charge the cleanup's
contexts. Every real release keeps its cleanup and its contexts. A context
a release really needs is still a compile-time MISSING-CONTEXT.

Throughout, *code inspection* means something read from the source,
*executed* something a run in this container showed.

## Contents

1. Result
2. Minimal reproducer
3. Original failure
4. Root cause
5. Correct rule
6. Implementation
7. Real cleanup preservation
8. Backend parity
9. HIR, cache and isolation
10. Regression tests
11. Mutation testing
12. TUI workload
13. Remaining limitations
14. Merging main: threads and the C backend

## 1. Result

| program | before (interp, compile) | before (cranelift, cranelift-generic) | after (all four) |
|---|---|---|---|
| imports a module whose cleanup requires an uninstalled context | value | `NATIVE BUG` at lowering | value |
| imports `std::event_loop` or `std::actor` without installing a `Loop` | value | `NATIVE BUG` at lowering | value |
| really releases such a resource with the context installed | value | value | value (unchanged) |
| really releases one without the context | MISSING-CONTEXT (compile time) | MISSING-CONTEXT (compile time) | unchanged |

*Executed.* The second row is the standard library's own instance of the
defect, found during this milestone. `std::event_loop`'s `Owner` is a
resource. Its cleanup `release` requires the `Loop`. So a program that
imported `std::event_loop`, or `std::actor`, which imports it, without
installing a `Loop` failed natively:

```
== main.bot (cranelift)
   error: native lowering: context load e2625 of context "std::event_loop::Loop", which the program does not install (NATIVE BUG)
```

There is also a code-size effect. A program that installs the `Loop` but
never releases an `Owner` (`examples/event-loop/05-revoke.bot`) no longer
compiles `std::event_loop::release`: 122 NIR functions instead of 123.

## 2. Minimal reproducer

`session.bot`, a module:

```botlish
opaque context struct Terminal:
    fd: int
opaque resource struct Session:
    id: int
cleanup fn leave(s: Session, context t: Terminal):
    {id} = s
    t.fd
```

`app.bot`, beside it:

```botlish
import session

1
```

Commands (from the repository root, Tcl 9.0.1, the native backend built):

```sh
export LANG=C.utf8 LC_ALL=C.utf8
tclsh9.0 main.tcl -backend interp DIR/app.bot             # value: 1
tclsh9.0 main.tcl -backend compile DIR/app.bot            # value: 1
tclsh9.0 main.tcl -backend cranelift DIR/app.bot          # NATIVE BUG before, value: 1 after
tclsh9.0 main.tcl -backend cranelift-generic DIR/app.bot  # NATIVE BUG before, value: 1 after
```

Minimization (*executed*, before the fix, each variant importing the module
and evaluating `1`):

| variant of session.bot | interp, compile | cranelift, cranelift-generic |
|---|---|---|
| (a) the module above | value 1 | NATIVE BUG |
| (b) the cleanup without a context parameter | value 1 | value 1 |
| (c) no resource; an ordinary unused `fn leave(id: int, context t: Terminal)` | value 1 | value 1 |
| (d) as (a), the cleanup never reading `t` | value 1 | NATIVE BUG |

So the failure needs a cleanup function and a context requirement of that
cleanup. An ordinary unused function that requires a context was already
handled correctly (c): it is not compiled. Reading the context is not
needed (d), because a context parameter is loaded at the function's entry.

The committed form of the reproducer is `tests/unused-context/terminal.bot`
with `import_only.bot` (section 10). It is the same shape with a log in
the context, a second resource and a portable function.

## 3. Original failure

*Executed*, on the minimal reproducer (a):

* **Phase.** The front end accepted the program: `hir::check` reported
  nothing. The failure was in native lowering, before any machine code was
  generated. `-emit-nir` failed the same way. The interpreter and the Tcl
  compiler ran it, because they register cleanups lazily
  (`affine#register_cleanup`) and never call this one.
* **Diagnostic.** `native lowering: context load e3 of context
  "session::Terminal", which the program does not install (NATIVE BUG)`,
  raised by `native::lower::UninstalledContext`.
* **HIR** (`main.tcl -hir`). The cleanup block is analyzed like any
  function. It is `e2 block ... cleanup contexts (session::Terminal)
  requires (session::Terminal)`. Its first statement is `t`'s binding to
  `call native(context#load) "session::Terminal"`. Nothing else refers to
  it.
* **Contexts** (`main.tcl -contexts`). `session::leave` requires
  `session::Terminal` directly. The program installs nothing (`contexts
  installs {}`), and no top-level obligation names the Terminal. The
  context analysis correctly found that the program needs no Terminal.
* **Native.** `ContextSlots` gives a slot only to an installed context, so
  `session::Terminal` had none. Lowering still compiled `session::leave`
  and reached its context load with no slot to read.

## 4. Root cause

*Code inspection*, confirmed by the mutants of section 11.

`native::lower::Program` passed every cleanup block of the program to
specialization as an export:

```tcl
-exports [concat [lmap export ...] \
    [CleanupBlocks $hirProgram] \
    [lmap callback ...]]
```

`hir::specialize::ProgramValues` makes each export a *value of the program
region*. The export's generic instance is therefore always used, and open
(no caller facts). `CleanupTable` then installed a function value of every
cleanup at program start. That was the false dependency edge: *declared ⇒
compiled*. Every declared cleanup was compiled, with its context loads,
whether or not anything could release its resource.

The context analysis has the opposite edge, and it is the correct one.
`hir::contexts::Requirements` charges a cleanup's contexts only along
*release edges* (`ReleaseEdges`). An edge goes from each region holding
a value whose drop runs the cleanup to that cleanup. A region whose value
is its function's result is exempt (`Returned`). Context verification
checks the top level's requirements over call and release edges. So it
proves contexts installed exactly for the cleanups reachable that way.
Native lowering compiled a strictly larger set, and nothing guaranteed the
extra cleanups' contexts a slot.

The section 11 notes of LEXICAL-RESOURCE-CLEANUP-EXPLORATION-MILESTONE-1.md
give the reason for the root. The runtime calls a cleanup with any value
its declared type admits, so its generic instance must be open, as an
export's is. That reason holds. It requires the instance to be *open
where it is used*. It does not require it to be *used whether or not
anything releases*.

Things that were not the cause (each *executed*):

* The cleanup function itself: (b) compiles and runs it fine without a
  context.
* The context-load lowering: `UninstalledContext` is a correct backstop.
  Verified code has no uninstalled loads.
* Import or package resolution: the same failure occurs with a plain
  application module, a transitive import and a package module.
* The interpreter and Tcl compiler: they never call an unreleased cleanup.

## 5. Correct rule

A context requirement becomes a runtime dependency only along an operation
that can actually need it:

* **Call edges.** Unchanged. A function is compiled when compiled code
  calls it or makes its value. A function that requires a context cannot
  become a value (CONTEXT-FUNCTION-VALUE). Exports and callbacks may
  require no context (EXPORT-ENVIRONMENT, CALLBACK-ENVIRONMENT), release
  edges included.
* **Release edges.** New for native lowering. A cleanup is compiled exactly
  when a compiled region's release edges name it. Those are the context
  analysis's edges (`ReleaseEdges`): any reachable expression of a type
  whose drop runs the cleanup, except a function's returned value, and any
  parameter of such a type. The region holding such a value *materializes*
  the cleanup's value. That is literally what its lowering does:
  `fnvalue` before `cleanupcall`, or a table entry a runtime walk calls.
  So the cleanup's generic instance is used and open, as before, but only
  when a compiled region may release.
* **The cleanup table.** Entry K is cleanup K's value when the program
  compiles that cleanup. Otherwise it is `unit`. The indices are the HIR's
  (drop descriptors name `rK.`) and do not move. The runtime refuses a
  `unit` entry as a bug ("no cleanup function K in this run's cleanup
  table"). A correct compiler never reaches one.

What stays the same:

* **Static validity.** An unused cleanup is still checked. It is resolved,
  type-checked and RESOURCE-DECLARATION-checked, and its `requiredContexts`
  is still computed. Importing still checks declarations. Only what native
  lowering *compiles for a run* follows use.
* **Requirements of real releases.** Every region the context analysis
  charges keeps its edge, so a real release still requires its cleanup's
  contexts (MISSING-CONTEXT otherwise).

This gives the soundness argument (*code inspection*). Native lowering
compiles a region only if it is reachable from the program, an export or a
callback, over call edges, materialized values and now release edges. Over
the same edges the context analysis has proven every context the program
requires installed. Exports, callbacks and function values require no
context, transitively. So every context load in compiled code has a slot,
and `UninstalledContext` stays unreachable for verified programs.

## 6. Implementation

| file | change |
|---|---|
| `hir/contexts.tcl` | `hir::contexts::releasedCleanups HIR`: region (block, or `program`) → the cleanup blocks of its release edges. It runs the same `Walk` and `ReleaseEdges` the requirement analysis uses, so there is one rule. It activates its HIR (compilation isolation) and returns `{}` for a program without a cleanup. |
| `hir/specialize.tcl` | A new option, `-releases`. `ReleaseValues REGION VALUES` adds a region's released cleanups to the Block values its reachable code materializes, in both the specialized (`Analyze`) and `-specialize 0` (`SemanticInstances`) paths. `ProgramValues` (exports) is unchanged. |
| `native/lower.tcl` | Cleanups are no longer `-exports`. `-releases [hir::contexts::releasedCleanups ...]` is passed instead. `LiveCleanups` (computed once per lowering, after specialization, into `liveCleanups`) is the set of cleanups some used instance materializes. `LiveCleanup` resolves a release's cleanup K and throws NATIVE BUG for one no release edge reached; this is a backstop, never a compile on demand. `CleanupTable` writes `unit` for an entry the program does not compile, and nothing when it compiles none. |
| `native/src/runtime/affine.rs` | `cleanup()` refuses a `unit` table entry as `RtError::Bug`, like a missing one. |
| `native/src/codegen/mod.rs` | A Rust test of that refusal (below). |

No HIR form, HIR text, interchange format, cache key, NIR instruction or
Core IR changed. The Tcl backends are unchanged.

## 7. Real cleanup preservation

*Executed* (`tests/unused-context.test`). Each of the following runs its
cleanup with the installed contexts. The four backends agree on every
value.

`uses.bot` installs the Terminal and the Clock. Its log is
`[11, 10, 20, 21, 30, 31, 40, 41, 51, 50, 60, 1070, 71, 1]`:

| case | log entries |
|---|---|
| a helper's Session, released at the helper's end after its note | 11 10 |
| the explicit release, at once | 20 21 |
| a propagated failure: the release on the error edge, then the caller's handler | 30 31 |
| a moved-in Session, released at the callee's end | 40 41 |
| made by one function and released by its new owner | 51 50 |
| a generic (untyped) function, natively an Int instance | 60 |
| an Alarm whose cleanup requires two contexts, one of another module, released before the Session acquired before it | 1070 71 |
| the Clock's one tick | 1 |

* **Counters** (`uc-uses-counters`). Natively, 7 compiled releases ran
  their cleanups (`native::allocationReport`: `cleanups 7 abandoned 0`).
  The interpreter's probe saw 7. Release 20 is the program's own call.
* **The table and runtime walks** (`uc-tags`, `uc-tags-table`).
  `tags.bot` releases only Tags: a cleared vector (`mvcleardroprun`), a
  dying struct (`affinedroprun`) and a direct release. Its log is
  `[-1, -2, 3, 5, -4, -6]`. Its NIR cleanup table is `{unit fn}`: Session's
  cleanup (entry 0) is not compiled, Tag's (entry 1) is called four times.
  The interpreter's releases name only cleanup 1.
* **The top level's own release** (`uc-toplevel`). A discarded Job runs
  spool's cleanup.
* **The package structure** (`uc-package-session`). Installing the
  package's Terminal and running a session gives `[6, 5]`.
* **GC stress** (`uc-gc-stress`, and a separate
  `BOTLISH_NATIVE_GC_STRESS=1` run of `tests/resources.test` and
  `tests/unused-context.test`): all values the same.
* **The existing resource tests** (`tests/resources.test`, 40 tests, on all
  four backends, also under GC stress) pass unchanged. Their programs
  install a Log the cleanups use.

What compiles, before → after (*executed*, NIR of `uses.bot`): before,
`terminal::leave`, `terminal::untag` and `clock::disarm` with a table of
three function values. After, `leave` and `disarm`, and the table
`{fn fn unit}`. `untag`'s Tag is never released in that program.

## 8. Backend parity

*Executed*, Linux x86-64, this container:

| program | interp | compile | cranelift-generic | cranelift |
|---|---|---|---|---|
| import_only.bot | 81 | 81 | 81 | 81 |
| transitive.bot | 82 | 82 | 82 | 82 |
| several.bot | 223 | 223 | 223 | 223 |
| unreachable.bot | 2 | 2 | 2 | 2 |
| `import std::event_loop` / `import std::actor` | 2 / 3 | 2 / 3 | 2 / 3 | 2 / 3 |
| uses.bot | the log above | same | same | same |
| tags.bot | `[-1, -2, 3, 5, -4, -6]` | same | same | same |
| toplevel.bot | 1 | 1 | 1 | 1 |
| package, portable / session | 76 / `[6, 5]` | same | same | same |
| missing.bot, branch.bot | MISSING-CONTEXT at compile time, before any backend |

Both native backends go through the one shared lowering
(`native::lower::program`). `cranelift-generic` is `-specialize 0`, which
takes `SemanticInstances`, and that path gets the same `ReleaseValues`. The
NIR tests check both (`uc-nir-import-only`). Standalone executables
(`uc-executable`) link and run the reproducer, and run `tags.bot`'s
cleanups through the table.

Not executed: Linux AArch64, macOS AArch64 and Windows x86-64. The change
is in host-independent Tcl and a host-independent runtime check. CI's
workflows for those hosts run on the branch push.

## 9. HIR, cache and isolation

*Code inspection, with the tests named.*

* **HIR interchange.** Unaffected. `releasedCleanups` is computed at
  lowering from what HIR already holds: the `resources` cleanup table,
  `reachable` flags, types, blocks and parameters. Those are the facts the
  context analysis reads, and interchange carries them. `uc-interchange`
  round-trips three programs and runs them natively to the same values.
* **The front-end cache.** Unaffected. The key covers the front end, and
  the change is in what the backend compiles from the HIR. `uc-cache` runs
  two programs from a miss and then a hit.
* **Compilation isolation.** `releasedCleanups` calls `hir::activate` (it
  reads the struct registry through `ResourcesOf`). `liveCleanups` is
  recomputed at every lowering. `uc-isolation` compiles three applications
  in one process: one that really releases, one that only imports, and one
  with a table hole. It runs them natively in the order A B A C B C A on
  both native backends, and each gives its own value. The
  `live-cleanups-stale` mutant (a set kept across compilations) is killed
  there.
* **Package identities.** Cleanups are keyed by block and struct identity,
  never by spelling. `uc-package-*` exercises a package instance's modules.
* **Context selection and layout.** Unchanged. Slots are still given to
  installed contexts only (`ContextSlots`). A program that compiles no
  cleanup gets no extra slot.
* **Per-VM state.** The cleanup table is still the Vm's (`Vm::cleanups`),
  installed by the program function on each run. A `unit` entry is an
  immediate, which the collector's root walk ignores like any non-pointer.

## 10. Regression tests

New: `tests/unused-context.test` (27 tests) with the application root
`tests/unused-context/`:

* **Modules.** `terminal.bot` holds a context, two resources whose cleanups
  require it, a context-requiring function, an unused function that holds
  a Session, and a portable function. `clock.bot` holds a cleanup that
  requires its own Clock and terminal's Terminal. `spool.bot` holds a third
  context. `relay.bot` holds a transitive import.
* **Programs.** `import_only`, `transitive`, `several`, `unreachable`,
  `uses`, `tags`, `toplevel`, `missing` and `branch`.
* **The matrix.** Unused declarations (a context, a context-requiring
  function, a cleanup requiring one context and one requiring two, a
  transitive import, a package module, several modules) and the standard
  library's instance. Actual use (section 7). A missing context: a helper's
  requirement charged to its call, a branch that may run, and a top-level
  release (MISSING-CONTEXT located at "the release of this value").
  Reachability: imported and never called, called directly, called
  transitively, generic, specialized, through a drop, and in a branch the
  compiler proves never runs. Through a typed callable (`uc-typed-callable`):
  a function that releases a resource with a context-free cleanup, reached
  only as a value, runs its cleanup once. With a cleanup that requires the
  Terminal, the function requires the Terminal, and cannot become a value
  at all (CONTEXT-FUNCTION-VALUE: not supported, by the existing rule).
  Static validity: an unused cleanup with an ill-typed body is TYPE, and
  one that may yield is RESOURCE-DECLARATION. NIR evidence, isolation,
  interchange, the cache, GC stress and executables.

| command | outcome |
|---|---|
| `tclsh9.0 tests/unused-context.test` | 27 passed |
| the same against the tree before the fix | 15 failed, 12 passed. Every test of the absent false dependency fails. `uc-declarations-still-checked` also fails, because it calls the new `releasedCleanups`. The preservation tests pass on both trees. |
| `BOTLISH_NATIVE_GC_STRESS=1 tclsh9.0 tests/resources.test`, `... tests/unused-context.test` | 40 passed, 27 passed |
| `tclsh9.0 tests/resources.test` (all four backends) | 40 passed |
| `cargo test --release --manifest-path native/Cargo.toml --bin botlish-native cleanup_root_tests` | 2 passed; the new one fails with the runtime's `unit` check removed |
| `tclsh9.0 tests/local.tcl` over the related test files (section 10.1) | see 10.1 |
| `tclsh9.0 tools/mutant-catalogs.tcl` | 89 catalogs, 3137 mutants, 0 problems |
| `audit/golden/migration/merge.tcl -check 1` | 0 problems (27 new manifest rows, not ported: KEEP-MULTI-PROGRAM, KEEP-INTERNAL, KEEP-RUNTIME-ONLY) |

### 10.1 Related suites

`tclsh9.0 tests/local.tcl -jobs 3` over `resources`, `unused-context`,
`contexts`, `context-affine`, `context-traits`, `affine`, `coroutines`,
`event-loop`, `actor`, `c-callbacks`, `native-library`, `hir-interchange`,
`hir-cache`, `compilation-isolation`, `bot-modules`, `imports`,
`compiler-service`, `restricted-injection` and `direct-hir-native`. Each
ran on the interpreter and the Tcl compiler pass, with golden duplicates
skipped. It also ran the 12 golden suites that replace those duplicates,
on all four backends, through the front-end cache. *Executed*, all
passed:

| file or suite | interp pass | compile pass |
|---|---|---|
| unused-context.test (25 tests at the time; all 27 later, separately) | 25 | 25 |
| resources.test | 40 | 40 |
| contexts.test | 61 (12 golden duplicates) | 61 |
| context-affine.test | 28 | 28 |
| context-traits.test | 53 (8) | 53 |
| affine.test | 28 (20) | 28 |
| coroutines.test | 37 (44) | 37 |
| event-loop.test | 109 | 109 |
| actor.test | 67 | 67 |
| c-callbacks.test | 36 | 36 |
| native-library.test | 28 | 28 |
| hir-interchange.test | 11 | 11 |
| hir-cache.test | 19 | 19 |
| compilation-isolation.test | 19 | 19 |
| bot-modules.test | 68 (1 skipped) | 68 |
| imports.test | 61 (43) | 61 |
| compiler-service.test | 56 | 56 |
| restricted-injection.test | 45 | 45 |
| direct-hir-native.test | 27 (10) | 27 |

The golden suites passed on interp, compile, cranelift-generic and
cranelift: coroutines (62), contexts (88), affinity (67), ownership (38),
diagnostics (27), imports (59), imports-abi-child (17), compiled-values
(118), imports-unimported (16), imports-library-modules (12),
imports-abi-family (6) and modules (31): 541 golden tests on each
backend, 0 failed. The run took 1660 s of wall time with 3 jobs.

Also executed: `tclsh9.0 tools/compilerpedia.tcl check` (1222 topics, 753
examples, 0 problems).

## 11. Mutation testing

`audit/unused-context-import/tools/mutate.tcl` applies each mutant of its
`mutants.txt` to a private copy of the tree and runs
`tests/unused-context.test`. A mutant counts as killed only by a test its
`!!` line names. *Executed*: 10 of 10 killed, on the branch and again on
the tree merged with `main` (section 14); the whole catalog runs in about
three quarters of a minute.

| mutant | the break | killed by |
|---|---|---|
| `cleanups-rooted` | restores the original false dependency: every cleanup is a program root | uc-import-only, uc-transitive, uc-several, uc-stdlib-imports, uc-nir-import-only, uc-nir-several, uc-package-portable |
| `table-names-dead-cleanups` | the cleanup table names every declared cleanup | uc-tags, uc-tags-table, uc-nir-uses, uc-uses |
| `releases-of-every-region` | every region's releases are charged to the program, compiled or not | the seven of `cleanups-rooted` |
| `releases-ignored` | omits the genuine cleanup dependency: no release makes a cleanup live | uc-uses, uc-tags, uc-toplevel, uc-package-session, uc-uses-counters, uc-tags-table |
| `releases-program-only` | the dependency is not propagated through a helper: only the top level's releases count | uc-uses, uc-tags, uc-package-session, uc-uses-counters, uc-tags-table |
| `releases-first-only` | a region releasing two resources keeps only the first's cleanup | uc-uses, uc-uses-counters, uc-nir-uses |
| `releases-top-level-dropped` | the top level's own releases are dropped | uc-toplevel |
| `cleanup-table-compacted` | the table loses its placeholders, so entry K names another cleanup | uc-tags, uc-tags-table, uc-nir-uses, uc-gc-stress, uc-isolation, uc-executable |
| `live-cleanups-stale` | stale metadata across compilations: the live set is decided once per process | uc-isolation and nine others |
| `cleanups-rooted-load-suppressed` | the workaround the brief rules out, and `main`'s own before the merge (section 14): every cleanup a root again, an uninstalled context's load raising at run time instead of failing lowering. Every program runs, so only the tests of what is compiled catch it | uc-nir-import-only, uc-nir-several, uc-stdlib-imports, uc-tags-table, uc-nir-uses |

One existing mutant applied to the text this milestone changed:
`audit/c-callbacks/tools/mutants.txt`'s `root-not-specialized` (a callback
not rooted). Its text was updated and it is still a mutant of the same
rule. Its harness (`-only root-not-specialized`) killed it, by
`cb-interchange` and `cb-tcl-backends`.

Because this milestone changes which cleanups native lowering compiles,
the lexical-cleanup harness was also run on the mutants closest to that
code (`audit/lexical-cleanup/tools/mutate.tcl -only no-release-edges,
everything-returned,cleanup-index-zero,no-cleanup-descriptor,
tcl-cleanup-not-called,native-cleanup-not-called`). `no-cleanup-descriptor`
and the other five are killed too: 6 of 6, each by the resources and
event-loop ownership tests (for example `no-release-edges` by 27 failures,
`native-cleanup-not-called` by 20, `cleanup-index-zero` by the resources
tests). `native-cleanup-not-called` edits `native/src/runtime/affine.rs`,
so the harness rebuilt a private native backend for it.
`tools/mutant-catalogs.tcl` confirms that every mutant of every catalog
still applies.

## 12. TUI workload

The clean-room TUI library and its `repros/native-bug-cleanup-context/`
are not in this repository or this environment. No file, directory, branch
or commit names them. The complete TUI workload was **not rerun**.

What was run instead is the structure that originally failed, rebuilt
independently (`uc-package-portable`, `uc-package-session`):

* a package `tui` installed in the application's `.bot_modules`;
* a session module `tui::session` declaring the Terminal context and the
  cleanup-owning Session (the same text as `terminal.bot`);
* a portable module `tui::app` that imports `tui::session`. This is the
  dependency the TUI library removed to work around the defect;
* a program that uses only the portable function. It runs on all four
  backends without a Terminal;
* a second program that installs the Terminal and enters and leaves a
  session. Its cleanup runs with the Terminal on every backend.

So the workaround of keeping `tui::app` independent of `tui::session` is no
longer needed for correctness. Whether to keep it for architectural reasons
is the library's decision. Its public API was not touched.

## 13. Remaining limitations

* **Release edges are per region as written.** A region's release edges
  come from its semantic reachability, not from what a specialized
  instance proves reachable. A specialized instance that can never release
  may therefore still compile its region's cleanup. That is harmless: the
  context analysis charged the same region, so the contexts have slots.
  Only code size is affected, and no case was found. This was a deliberate
  choice. The native rule is exactly the verified one, never finer than
  what the context analysis proved.
* **Cost.** `releasedCleanups` is one walk of the HIR per lowering of a
  program that declares a cleanup (none otherwise). Measured: 0.6 ms for
  the reproducer, 1 ms for `tests/resources/collections.bot`, and 57 ms for
  `examples/event-loop/05-revoke.bot` (7,205 expressions), whose whole
  native lowering takes about 3.5 s. A whole-lowering comparison against
  the tree before the fix (3.35 s vs 3.53 s for 05-revoke, 44 vs 46 ms for
  collections.bot) was taken while other test processes shared the
  machine, so it is not precise enough to state more than "within a few
  percent".
* **Other hosts.** Only Linux x86-64 was executed here (section 8).

## 14. Merging main: threads and the C backend

While this milestone was on its branch, `main` gained 50 commits, two of
which touch this code (*code inspection* of the merge).

* **Threads** (BOTLISH-OWNED-THREADS-AND-CROSS-THREAD-ACTORS-MILESTONE-1.md)
  hit the same defect independently. Every thread program imports
  `std::event_loop`. That milestone kept cleanups as roots and added
  `native::lower::InCleanup`: inside a cleanup, a load of an uninstalled
  context lowered to a run-time `raise MISSING-CONTEXT` instead of the
  NATIVE BUG. That is the suppression this milestone's brief rules out.
  The cleanup was still compiled, with a load of a context that no slot
  holds. The merge keeps this milestone's rule and removes `InCleanup`, so
  `UninstalledContext` is the backstop for every function again. The
  threads report's paragraph now says it was superseded. The mutant
  `cleanups-rooted-load-suppressed` reconstructs that workaround, and the
  NIR tests kill it (section 11).
* **Thread entries are roots** (`-exports` holds each thread entry and
  its transfer owners' functions). The rule stays sound with them.
  `hir::contexts::verify` checks each thread entry as it checks the top
  level: in evaluation order, its own installations, and its calls *and
  its release edges* as obligations (`byRelease`). So a cleanup that a
  thread entry's code releases has its contexts proven installed in that
  entry. The context area is the program's, so the slot exists.
* **The C backend** (`ccompile/`, C-COMPILE-FREESTANDING-MILESTONE-1.md)
  never had the defect. It calls `hir::specialize::analyze` with no roots
  besides the program and refuses an affine struct only where compiled
  code uses one, so an imported, unused resource compiles nothing there.
  Nothing changed in it.
* **Conflicts.** `native/lower.tcl`'s `-exports` (thread roots beside this
  milestone's `-releases`) and `InCleanup` (removed);
  `audit/c-callbacks/tools/mutants.txt`'s `root-not-specialized` (`main`
  had rewritten it for the thread roots: it now deletes the callback line
  of the merged `-exports` and is still a mutant of the same rule);
  `audit/golden/migration/tcl-names.txt` (both sides' new names). The
  regenerated golden manifest equals the automatic merge's.

*Executed* on the merged tree, after rebuilding the native backend:

| check | outcome |
|---|---|
| `tests/unused-context.test` | 27 passed |
| `tests/threads.test` (`main`'s, the workaround removed) | 21 passed |
| `audit/unused-context-import/tools/mutate.tcl` | 10 of 10 killed |
| `cargo test ... --bin botlish-native cleanup_root_tests` | 2 passed |
| `tools/mutant-catalogs.tcl` | 91 catalogs, 3187 mutants, 0 problems |
| `tools/compilerpedia.tcl check` | 1290 topics, 758 examples, 0 problems |
| `audit/golden/migration/merge.tcl -check 1` | 0 problems |
| `tests/local.tcl` over the related files of section 10.1, plus `sendability.test` | PENDING at this commit |

CI on the branch before the merge (`fa3598a`), every workflow green:
`tests` and `tests (linux arm64)` (both dispatched in full), `tests (macos
arm64)`, `tests (windows x86-64)`, `icy-tower (macos arm64)` and `icy-tower
(windows x86-64)`. CI on the merged commit: PENDING.

