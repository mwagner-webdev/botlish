# SHARED-PACKAGE-DEPENDENCIES-MILESTONE-1

## One canonical dependency instance across independently authored Botlish packages

Independently authored packages that depend on the same ordinary package now
share one instance of it. An application has one resolved dependency graph:
every package in it appears once, at the one version every lock of it names,
installed once at `.bot_modules/NAME` and used by every package that depends
on it -- the application among them. A file beside the packages,
`.bot_modules/.graph`, tells the compiler which package uses which; a
package of the graph has one module identity, its name, wherever it is
imported from, so its types, errors, traits and contexts are one and its
native archive is one link declaration. Locks that disagree are a
deterministic `DEPENDENCY-CONFLICT` naming every lock and the path to the
package that holds it: no lock is moved, relaxed or overridden, and no
second instance is made.

The motivating case works end to end: two libraries, written independently,
each declaring and locking `event_loop_linux` 0.3.0, run their tasks under
the one Linux driver and `Native` capability the application installs once,
against epoll -- from the repository's tests and from a clean-room consumer
holding only the single-file compiler and published `.botpkg` artifacts.

> A package declares what it depends on and locks what its author built and
> tested against. The application resolves one coherent collection of
> package instances. A dependency shared by several packages has one
> identity, one selected version, and one consistent meaning throughout the
> resolved program. If those constraints cannot be satisfied together,
> resolution fails rather than silently changing an author's dependency
> contract.

Contents:

* [1. Result](#1-result)
* [2. Architecture census](#2-architecture-census)
* [3. Canonical package identity](#3-canonical-package-identity)
* [4. Resolution semantics](#4-resolution-semantics)
* [5. Installation and the resolved graph](#5-installation-and-the-resolved-graph)
* [6. Compiler and module resolution](#6-compiler-and-module-resolution)
* [7. Shared contexts: the event-loop workload](#7-shared-contexts-the-event-loop-workload)
* [8. Native dependencies and link planning](#8-native-dependencies-and-link-planning)
* [9. Diagnostics](#9-diagnostics)
* [10. Reproducibility, immutability and publication](#10-reproducibility-immutability-and-publication)
* [11. The clean-room consumer](#11-the-clean-room-consumer)
* [12. Testing and evidence](#12-testing-and-evidence)
* [13. Performance](#13-performance)
* [14. Documentation and principles](#14-documentation-and-principles)
* [15. Compatibility and migration](#15-compatibility-and-migration)
* [16. Limitations](#16-limitations)
* [17. Consequences for HTTP-SHIPPING-CENSUS.md D1](#17-consequences-for-http-shipping-censusmd-d1)
* [18. The architectural question](#18-the-architectural-question)
* [Repository changes](#repository-changes)

Evidence labels: *observed* (a command run for this report, its output
quoted or summarized), *inspected* (read in the code, not run), *projected*
(an inference from the observed and the inspected).

## 1. Result

What works (observed; section 12 has the commands):

| | |
|---|---|
| shared instance | two independently authored packages locking the same release of a dependency get one instance; the compiler binds both imports, and the application's, to one module (`pm-shared-one-instance`, `bm-graph-one-instance`) |
| shared types | a `geometry::Point` one package makes is the `geometry::Point` the other reads; an enum case and a declared error cross the packages the same way, on interp, compile, cranelift-generic and cranelift |
| shared contexts | a context struct of a shared package, required by two packages, is one type: the application installs it once (`bm-graph-shared-context`, `pw-shared-driver`) |
| the driver workload | `beats` and `probes` (examples/event-loop/shared) run against epoll under the one `event_loop_linux::Linux` and `Native` the application installs; their own botlish.json locks unchanged |
| conflicts | disagreeing locks -- two packages', or the application's and a package's -- are `DEPENDENCY-CONFLICT`, with every lock and its dependency path; the project is unchanged; the report is the same whatever the order of declarations, repositories or traversal (`pm-two-versions-conflict`, `pm-conflict-deterministic`, the fuzzer) |
| artifact identity | two different files claiming one release are a `CONFLICT`, also when one is the application's archive source and a package locks that release (`pm-shared-artifact-identity`) |
| visibility | sharing is no ambient visibility: a package imports exactly the packages it declares, the application exactly its own (`pm-shared-visibility`, `bm-graph-visibility`) |
| native | one archive declaration for a shared provider, no `LINK-CONFLICT`; a package's own archive calling the shared provider's C API links beside it (`bm-graph-shared-link-declaration`, `pw-shared-native-bridge`) |
| inspection | `botlish package graph` shows the resolved graph -- every package once, its version, who uses and who locks it, a path -- without writing anything |
| publication | `.botpkg` artifacts, their format and authors' locks unchanged; the single-file compiler installs and builds the shared graph with no checkout, Tcl, Rust or network (section 11) |

What changed, in one sentence each:

* **The package manager** resolves the application's whole graph by
  unification of exact locks (`pm/graph.tcl`), installs it flat, one
  directory per package, and writes `.bot_modules/.graph` in the same
  transaction as the packages and its installation record (schema 3).
* **The compiler** reads that file when it exists (`surface/modules.tcl`'s
  "Package graphs"): a graph package's instance is its name from every
  scope, and a scope sees exactly the packages the graph says it uses.
  Without the file, nothing changes: hand-made nested trees keep
  BOT-MODULES-MILESTONE-1.md's instance-by-place identities.

No peer dependencies, no override mechanism, no version range, no search
and no change to context-trait arity (B4) were introduced.

## 2. Architecture census

Done before any change, by reading the sources and by running a reproducer.

### 2.1 What existed

| subject | behavior before this milestone | kind |
|---|---|---|
| direct dependencies | the application's botlish.json requests and locks each (BOTLISH-JSON.md, section 6); `install` refuses an unlocked one | deliberate |
| transitive dependencies | each package locks its own direct dependencies (distributed locking); the installer copied each into the depending package's own `.bot_modules`, recursively (`pm::install::ArtifactNode`) | deliberate |
| package-local `.bot_modules` | the compiler's downward-only scopes: a package sees its own `.bot_modules`, never its consumer's or a sibling's (`surface::modules::Locate`) | deliberate |
| locks | exact `MAJOR.MINOR.PATCH`, within the request; every artifact locks every direct dependency; locks name a version, not an artifact digest | deliberate |
| version selection | `add`/`update` choose the newest version a request accepts from the repositories' file names; `install` never chooses | deliberate |
| repeated dependencies | a dependency reached through two paths was installed twice, once per path (PM-1's "Two versions on separate branches"); identical copies were never deduplicated | deliberate (PACKAGE-ECOSYSTEM-ROADMAP.md: "do not force global version unification") |
| module identity | an instance is its place in the tree: `physics/geometry::Point` and `rendering/geometry::Point` are distinct (BOT-MODULES-MILESTONE-1.md, section C) | deliberate |
| types, traits, contexts | keyed by module identity: two instances' contexts are two types | consequence |
| context installation | only the entry program installs contexts, and it cannot spell a nested instance (`lib_a/drv::Native` is no spelling) | deliberate |
| native archives | `extern c library "X" static at PATH` resolves PATH from the declaring file's scope; two instances' declarations of one library are two archives: `LINK-CONFLICT` (hir/foreign.tcl's merge rule) | deliberate |
| native closure | PM-2's plan treats identical bundled bytes from two instances as one library, different ones as a conflict | deliberate |
| caches, compiled programs | keyed by source text, front-end fingerprint, target and root; package directories and files are probed dependencies | deliberate |
| publication | immutable, deterministic `.botpkg`; locks validated at pack and at installation; provenance beside the artifact | deliberate |

### 2.2 The reproducer: the failure of HTTP-SHIPPING-CENSUS.md 6.2, confirmed

Two packages `lib_a` and `lib_b`, each `import event_loop_linux` and
locking `event_loop_linux` 0.3.0, packed with `package pack`, added to an
application that installs the driver's contexts (observed, with the
package manager at `13dd290`, main before this milestone):

```
app/.bot_modules/event_loop_linux/event_loop_linux.bot
app/.bot_modules/lib_a/.bot_modules/event_loop_linux/event_loop_linux.bot
app/.bot_modules/lib_a/lib_a.bot
app/.bot_modules/lib_b/.bot_modules/event_loop_linux/event_loop_linux.bot
app/.bot_modules/lib_b/lib_b.bot
```

Three instances, and the program does not compile:

```
error: .../lib_a/.bot_modules/event_loop_linux/event_loop_linux.bot:45:47: library
"event_loop_linux" is declared with two static archives, "native/libevent_loop_linux.a"
here and "native/libevent_loop_linux.a" at .../event_loop_linux/event_loop_linux.bot:45:47:
a library is one archive, and neither declaration is chosen over the other
(CORE SEMANTIC LINK-CONFLICT)
```

With a pure-Botlish driver `drv` (an opaque context struct `Native`), the
second half of 6.2 -- the context types -- shows:

```
error: app/main.bot:6:1: lib_a/drv::Native is required by this call but is not installed here
    lib_a::ping
        directly requires lib_a/drv::Native (CORE SEMANTIC MISSING-CONTEXT)
error: app/main.bot:6:17: lib_b/drv::Native is required by this call but is not installed here
```

while the application had installed `drv::Native`, its own instance's. Both
points of section 6.2 (3) are confirmed; point 4's workaround (the library
re-exporting the driver) was not tried, since it is what the milestone
removes the need for.

### 2.3 Defects, constraints and changes

Observed defects (fixed here): none of the package manager's or compiler's
own rules were wrong; the obstruction was the model. One test-harness
defect was found on the way (section 12.4): `audit/bot-modules/tools/
mutate.tcl` never copied `packages/`, which `tests/bot-modules.test` has
read since PM-1, so every mutant there was "killed" by a crash of the test
file. The constraints kept: distributed exact locks, immutable artifacts, the
compiler reading no metadata, downward-only visibility, context
installation by the entry program only. The change: one instance per
package in an application's graph (sections 3-6), replacing PM-1's nested
copies -- a deliberate compatibility change (section 15).

## 3. Canonical package identity

Throughout one resolved application:

| what | identifies | where |
|---|---|---|
| the package's logical identity | its name (`event_loop_linux`), a namespace segment | botlish.json `name`, the directory's name, the compiler's root namespace |
| its selected version | the one version every lock of it names | the resolution (pm/graph.tcl), the installation record (`state.json`), `package graph` |
| its artifact identity | the SHA-256 of the one `.botpkg` file of that release | the record (`sha256`), the repositories, an archive source's `sha256` |
| its canonical instance | the name, in the graph | `.bot_modules/.graph`; the compiler's `Instance` |

The invariant: **every path to the same resolved dependency reaches the same
canonical module, type, context and native-library identities.** The graph
has one version of each package, so the package's name is unique in it,
and the compiler takes the name as the instance and the module identity
(`geometry::Point`, never `physics/geometry::Point`). This is a *resolved
graph identity*, not a path identity: it depends on no path that reaches the
package, no import order and no directory -- the graph file names
packages, and the identity is the name it names.

Consequences, checked:

* **HIR and registries** hold one module per namespace of a shared package,
  one struct, enum, error, trait and context declaration
  (`bm-graph-one-instance`: the HIR's modules hold one `geometry`).
* **Identity is the spelling** for every scope of the graph, so the loader's
  rewrite of qualified references (`RewriteQualified`) never runs for a
  graph: an application whose packages use nothing compiles to the same HIR
  with and without its graph (`bm-graph-same-hir-as-direct`, byte for byte
  through HIR interchange).
* **Diagnostics** name a shared package's declarations as the application
  spells them (`geometry::Point`), not by an unspellable instance path.
* **Caching**: the graph file is read through the source seam, so it is a
  front-end cache dependency and a compiler-service source: editing it
  misses and makes a revision stale (`bm-graph-cache-and-service`). It
  holds no version, so a compiled program depends on the versions only
  through the files installed -- which are dependencies already.
* **Serialization**: HIR interchange needs nothing new: identities are
  ordinary namespaces (`bm-graph-interchange`: a `.hirx` runs in another
  process with the sources gone).
* **Link plans**: an `extern c library ... static at PATH` declared by a
  shared package resolves from its one directory: one declaration, one
  archive (`bm-graph-shared-link-declaration`).

Unrelated global names stay apart: a graph package claims its namespace in
the application (MODULE-COLLISION for an application file of that name,
`bm-graph-collision`), a package installed by hand keeps its own scope and
identity (`bm-graph-manual-package`), and nothing outside a graph changes.

## 4. Resolution semantics

### 4.1 Authoritative locks

A lock is the exact release a package's author built and tested it with
(BOTLISH-JSON.md, section 6). It stays binding: the resolver never moves,
relaxes, overrides or discards one -- the application's or an author's --
and never treats a request range as permission to choose another version
than a lock names. Since every artifact locks every direct dependency to an
exact version, resolution is **unification, not search**: each package has
at most one admissible version, the one its locks name.

### 4.2 The algorithm (`pm/graph.tcl`)

1. **Demands.** The application demands each direct dependency at its lock
   (or, editable, at the directory's version). Every demanded release is
   acquired -- from the application's archive source when it supplies that
   release, else the repositories; or, when installed exactly so, from the
   installation record without reading an artifact -- and demands each of
   its own dependencies at its own lock. Every demanded release is explored,
   breadth first in name order, *whether or not it is in conflict*, so the
   set of demands, and so the report, does not depend on visiting order.
2. **Selection.** A package is selected at the one version all its demands
   name. Two versions are a `DEPENDENCY-CONFLICT` reporting every conflicting
   package, each demand with its lock and the dependency path that reaches
   the package holding it, sorted by version and then by who demands. An
   editable demand with any other demand is a conflict (an editable
   directory is no release and satisfies no lock).
3. **Acquisition errors** (an unavailable release, an invalid artifact)
   are reported when no conflict is, the first in name order.
4. **Artifacts.** A release the application supplies from an archive source
   and some package also locks must be the repositories' file of that
   release when a repository holds one: different bytes are a `CONFLICT`.
5. **Cycles.** A package that reaches itself through the selected releases'
   dependencies is a `CYCLE`, whatever the versions.

### 4.3 The cases of the milestone's table (observed)

| application | package A | package B | result | test |
|---|---|---|---|---|
| no constraint | locks X 1.2 | locks X 1.2 | one X 1.2 | `pm-shared-one-instance` (geometry 1.0.3) |
| no constraint | locks X 1.2 | locks X 1.3 | `DEPENDENCY-CONFLICT` | `pm-two-versions-conflict` |
| requires and locks X 1.2 | locks X 1.2 | locks X 1.2 | one X 1.2 | `pm-shared-application-lock`, `pw-shared-driver` |
| requires X 1.3 | locks X 1.2 | locks X 1.2 | `DEPENDENCY-CONFLICT` naming the application's request | `pm-shared-application-lock` (1.1 against 1.0.3), `pm-shared-add-and-update-held` (`add -request 2`) |
| no constraint | a range without a lock | -- | not expressible: an artifact locks every dependency (BOTLISH-JSON.md, section 8) | `pm-artifact-identity-checked` |
| no constraint | locks X 1.2, artifact A | locks X 1.2, artifact B | `CONFLICT` | `pm-shared-artifact-identity`, `pm-two-artifacts-one-version` |

The row with unlocked ranges is the existing package format's limit: a
package artifact cannot omit a lock, and the application's own unlocked
dependency is resolved by `add`/`update` (4.4) before installation.

### 4.4 Choosing versions (`add`, `update`)

The only places a version is chosen are the application's own direct
dependencies, and only within their requests:

* `add NAME` of a package the graph already holds (some package locks it)
  takes the version they lock, not the newest, and says so; a `-request` it
  does not satisfy is a `DEPENDENCY-CONFLICT`. Otherwise the newest version
  the request accepts.
* `update` moves each named dependency to the newest version its request
  accepts, then *holds* each that some package of the graph locks at that
  version, and says why ("held at 1.0.3: physics 1.0.0 locks it, and the
  graph shares one instance"); a held lock moves once nothing locks it
  (`pm-shared-add-and-update-held`).
* No other version is ever tried: updating a library whose new release
  locks a different version of a shared package is reported as the conflict
  it is, and the user chooses (`update NAME`, `add -request`). This is
  deliberately not a solver (section 16).

### 4.5 Repeated packages, recursion, removal

A package reached through any number of paths is one node (a diamond is one
instance of each package however many paths reach it: `pm-shared-diamond`);
its path in messages is the first breadth-first path in name order.
`remove` resolves the remaining graph: packages nothing uses any more are
removed, a shared one stays while anything uses it, and the command notes
which dependency keeps a removed name installed. A package that depends on
itself through others is a `CYCLE`; a package needing another version of
itself further down, which PM-1 installed as a second instance, is a
`DEPENDENCY-CONFLICT` (`pm-dependency-cycle`).

## 5. Installation and the resolved graph

### 5.1 Layout

```
app/
    botlish.json                     the application's requests and locks
    main.bot
    .bot_modules/
        .botlish/state.json          the installation record, schema 3
        .graph                       the package graph (the compiler reads it)
        beats/                       beats 1.0.0 (its artifact's files)
        event_loop_linux/            event_loop_linux 0.3.0: one instance
        probes/                      probes 1.0.0
        .targets/linux-x86_64/       a target view: the same packages, flat,
            .graph                   its own copy of the graph,
            .lib/                    and the bundled libraries
```

No package has a `.bot_modules` of its own. The logical graph and the
physical layout are separate: the graph file says which package uses which,
the directories hold files; a view is a second physical copy of the same
logical instances, never a second identity.

### 5.2 The graph file

```
botlish package graph 1
application beats event_loop_linux probes
package beats event_loop_linux
package event_loop_linux
package probes event_loop_linux
```

One line per scope: the application's, then each package's in name order,
each listing the packages it uses in name order. Names only: no version,
lock, source or digest (the compiler never reads one). One graph has one
text, so equal graphs compile and cache alike. The compiler checks every
rule (`surface::modules::ReadGraph`, section 9).

### 5.3 The record, the transaction, the views

* **The record** (`pm/state.tcl`) is schema 3: `application` (the direct
  dependencies) and one flat node per package with the versions it `uses`
  (its own locks). The graph file is a function of the record
  (`pm::graph::OfState`), so `verify` checks it, and an edited one is
  derived again by the next operation, with a note.
* **The transaction** (`pm/install.tcl`) stages every new package, then in
  one journaled commit renames packages in and out and writes the graph file,
  the record and botlish.json; a failure, or a process killed at any step
  (`graph-written` included), leaves the previous installation and graph
  exactly (`pm-fault-graph`). A graph file the manager did not make is
  never replaced (`MANUAL`, `pm-graph-file-owned`).
* **Views** (`pm/view.tcl`) project every package of the graph once into
  `.targets/T`, with the graph file beside them; the view's digest covers
  the application's dependencies, so a change of the graph derives every
  view again (`pn-shared-in-views`).

### 5.4 Inspection: `package graph`

`botlish package graph [-project DIR] [-repository DIR]...` resolves as
`install` would and prints the graph without writing anything:

```
the dependency graph of /home/dev/app: 3 packages, one instance of each
application uses: beats, event_loop_linux, probes
beats 1.0.0 (sha256 804bb3efb378): used by the application; installed
  locked by: the application (request "1.0")
  uses: event_loop_linux 0.3.0
  path: the project -> beats 1.0.0
event_loop_linux 0.3.0 (sha256 3746cece124b): used by the application, beats, probes; installed
  locked by: the application (request "0.3"), beats 1.0.0, probes 1.0.0
  shared: one instance, event_loop_linux, for the application, beats, probes
  path: the project -> event_loop_linux 0.3.0
probes 1.0.0 (sha256 03197da6e134): used by the application; installed
  ...
```

(the clean room's transcript, section 11). A conflict prints the conflict
report and exits 1. The commands' own reports say who shares a package
(`event_loop_linux 0.3.0: unchanged, used by the application, beats,
probes`).

## 6. Compiler and module resolution

`surface/modules.tcl` (the header's "Package graphs"). When the
application's packages directory holds `.graph`:

* `ApplicationTree` probes and reads it through the source seam
  (`surface::source::text`), so it is a dependency of the front-end cache
  and of a service revision;
* a **scope of the graph** -- the application, or a package the graph names
  -- sees a graph package exactly when the graph says the scope uses it
  (`Installed`), at `PACKAGES/NAME` from every scope (`PackageDir`);
* a graph package's **instance is its name** from every scope (`Instance`),
  so its identity is its namespace (`Identity`);
* a graph package's own `.bot_modules`, a package installed by hand, and
  the application's modules are invisible to it;
* every graph package **claims its root namespace** in the application,
  used or not (MODULE-COLLISION);
* a malformed graph is **PACKAGE-GRAPH** at each import the application's
  packages decide (a new loader diagnostic kind, classified with the
  header diagnostics in `tests/static-compile.test`'s census, documented
  as `error.package-graph`).

Identity was verified through the stages the milestone lists (observed in
`tests/bot-modules.test`'s `bm-graph-*` and the workloads): imported
functions and values; structs (`geometry::Point`), enums (`geometry::Side`
compared in another package) and declared errors (`geometry::Bad` raised by
`rendering`, handled by the application); context declarations and their
installation (`drv::Native`, `event_loop_linux::Native`); public APIs
exposing a shared package's types (`physics::make -> geometry::Point`
taken by `rendering::read`); native declarations (one link entry). The
fuzzer (section 12.3) generates, for every accepted graph, a struct per
package and functions passing it between packages through their own
imports, so every generated graph checks one nominal type per shared
package. Generic applications and trait implementations are keyed by the
same module identity as every declaration (BOT-MODULES-MILESTONE-1.md,
section C), so they follow (inspected; no dedicated test). Privacy is the
module's (`private` is per module identity), unchanged. Nothing in the
compiler names the event-loop package.

## 7. Shared contexts: the event-loop workload

`examples/event-loop/shared/` holds two packages, written independently, and
an application:

* `beats` (`beats.bot`) -- a heartbeat task: a periodic timer of the loop,
  each beat stamped with the driver's monotonic clock through `Native`
  (`event_loop_linux::now_us`, a C call of the adapter);
* `probes` (`probes.bot`) -- opens endpoints of the driver through `Native`
  (`event_loop_linux::endpoint`, C calls), checks them empty, sleeps on a
  timer, wakes the loop, closes them;
* each `botlish.json` requests `event_loop_linux` "0.3" and locks 0.3.0;
* `app/main.bot` installs `std::event_loop::create(64)`,
  `event_loop_linux::create()` and `event_loop_linux::native()` -- once --
  and adopts one task of each library.

Observed (`pw-shared-driver`, cranelift, epoll):

```
["t=0: probes: opened 2 endpoints", "t=1: beats: beat 1", "t=2: beats: beat 2",
 "t=3: probes: the timer woke the probe", "t=3: probes: every endpoint was empty, and closed",
 "t=5: beats: beat 3", "t=5: beats: the driver's clock never went back"]
```

The seven proofs the milestone asks for:

| | proof | evidence |
|---|---|---|
| 1 | both libraries compile against one driver identity | the graph `package beats event_loop_linux` / `package probes event_loop_linux`; one module `event_loop_linux` in the HIR |
| 2 | both operate under the application's installed contexts | the run above; `bm-graph-shared-context` (all four backends) |
| 3 | no package-private driver is selected | no package directory has a `.bot_modules` (clean room's check); one link entry, based at `VIEW/event_loop_linux` |
| 4 | context authority unchanged | only `main.bot` installs; the libraries require `Native`, never install or run the driver |
| 5 | a missing installation is MISSING-CONTEXT | `pw-shared-driver-negatives`: without `with context event_loop_linux::native()`, the requirement of `event_loop_linux::Native` |
| 6 | incompatible locks fail | a library `future` locking 0.4.0: `DEPENDENCY-CONFLICT`, the installation unchanged |
| 7 | another library adds no instance | `pulses` locking 0.3.0: `event_loop_linux 0.3.0: unchanged, used by the application, beats, probes, pulses` |

The workload compiles under `-warnings error`
(`pw-shared-driver-warning-clean`). B4 (a context-trait implementation takes
one context) was not touched: the workload shows ordinary dependency sharing
suffices for a library to reach the application's driver.

## 8. Native dependencies and link planning

| case | result | evidence |
|---|---|---|
| two packages over one identical native provider | one instance, one `static at` declaration based at its directory, one archive in the link | `pw-shared-driver` (links: `{event_loop_linux VIEW/event_loop_linux}`), `bm-graph-shared-link-declaration` |
| one native library reached through several paths | one node of the graph, so one declaration | `pm-shared-diamond` (pure), the workload's three users |
| incompatible versions of the provider | `DEPENDENCY-CONFLICT` before anything is written or linked | `pw-shared-driver-negatives`, the clean room |
| equal versions, different artifacts | `CONFLICT` | `pm-shared-artifact-identity` |
| two distinct libraries with one link name | PM-2's native plan, unchanged: two instances bundling different libraries of one name are refused | `tests/package-native.test` (unchanged tests; their mutants re-run, section 12.4) |
| a package's own archive using the shared provider | links beside it: ticker's C thread posts through `botlish_event_post` of the driver's archive | `pw-shared-native-bridge` (native plan: each library once; five ticks handled) |
| the provider used by the application directly too | the application is one more user of the one instance | every workload |

The graph is coherent before anything links: no conflict is left for the
linker, no order of archives decides one, no duplicate symbol is
suppressed. The link plan's merge rule (hir/foreign.tcl) and PM-2's native
closure are unchanged; with one instance per package, the duplicate
declarations that made `LINK-CONFLICT` for a shared provider no longer
arise.

## 9. Diagnostics

A version conflict (observed in the clean room):

```
error: cannot select one version of event_loop_linux for the application's dependency graph: 0.3.0 and 0.4.0 are demanded:
  the application's botlish.json locks event_loop_linux 0.3.0 (request "0.3")
  beats 1.0.0 locks event_loop_linux 0.3.0 (the project -> beats 1.0.0)
  probes 1.0.0 locks event_loop_linux 0.3.0 (the project -> probes 1.0.0)
  future 1.0.0 locks event_loop_linux 0.4.0 (the project -> future 1.0.0)
A package of the application's dependency graph has one instance, at one version, used by
every package that depends on it; a lock is the release its package was built and tested
with, and is never changed, relaxed or overridden to make the graph agree, and no second
instance is made. Choose versions whose locks agree (update, add -request), or ask the
packages' authors for releases that lock the same version (PM DEPENDENCY-CONFLICT)
```

It names the package, every demand -- which lock, held by which release,
reached by which path -- and why there is no selection. Every conflicting
package of the graph is reported, not only the first found, and the text is
the same whatever the order (`pm-conflict-deterministic`; the fuzzer
compares the message byte for byte under reversed declarations and
repositories). An editable dependency says it satisfies no lock; an archive
source and a repository file of one release, `two different artifacts claim
...`; a cycle, its path.

The compiler's, for a hand-edited or damaged graph (`bm-graph-malformed`
covers every rule):

```
the package graph APP/.bot_modules/.graph is malformed (line 2: the packages a scope uses
are listed in ascending order, once each): the application's packages are not known;
reinstall them (`install`), or repair the file (SURFACE MODULE PACKAGE-GRAPH)
```

and for an import of a package another package installed:

```
unknown namespace "geometry": package snoop (of the application's package graph) does not
depend on the package "geometry", which the package graph APP/.bot_modules/.graph installs
for physics (package snoop uses none): a scope of the graph imports only the packages it
depends on, never another package's dependencies (SURFACE MODULE UNKNOWN-NAMESPACE)
```

Malformed metadata, unavailable releases, conflicting repositories, cycles
and invalid names keep their controlled PM errors (PM-1's tests, unchanged).
Compilerpedia: `error.package-graph` (new), `rule.package-modules` ("Package
graphs"), `cli.packages` ("One graph", `package graph`); `tools/compilerpedia.tcl
check` passes.

## 10. Reproducibility, immutability and publication

* **Artifacts**: the `.botpkg` format, the descriptor schemas and packing
  are unchanged; authors keep ordinary dependencies and locks, and nothing
  about a package says it may be shared. The repository's recorded releases
  are reproduced byte for byte (observed: `tools/package-repository.tcl`
  rebuilt `event_loop_linux` 0.3.0 as the recorded `3746cece...`).
* **Locks survive** publication and installation: the installed packages'
  own botlish.json still lock what their authors locked (`pw-shared-driver`
  reads them from the view).
* **Resolution modifies no artifact**; repeated resolution of equal inputs
  gives equal results: the fuzzer resolves every universe twice -- botlish.json
  written in another key order, the two repositories in the other order --
  and requires the same result, its message byte for byte; installing in
  either order of `add` gives the same tree (`pm-conflict-deterministic`).
* **Repository order** cannot change a selection: there was never a
  precedence, and the catalog now keeps its repositories sorted, so not
  even a message depends on the command line's order.
* **Altered artifacts** are still detected: `verify` and its tests
  unchanged in substance (`pm-verify-*`), now over flat packages and the
  graph file.
* **The single-file compiler** installs and consumes the graph (section 11).
* **Caches**: graph identity needs no cache key: the graph file is a
  dependency read through the seam, and the identities it makes are package
  names. A cached HIR of a program cannot be reused under another graph:
  any change of the graph's text misses (`bm-graph-cache-and-service`).

## 11. The clean-room consumer

`audit/shared-dependencies/cleanroom/`: `repository.sh OUT` builds the
published artifacts on the author's side (the driver's release by its
recipe, `beats` and `probes` packed from the example, and, for the negative
case, a driver 0.4.0 and a library `future` locking it); `cleanroom.sh
image` builds an Ubuntu 24.04 image holding gcc and libc6-dev only (the
system linker's C driver); `cleanroom.sh run COMPILER REPOSITORY OUT` copies
in the single-file compiler, the artifacts and `app/main.bot` -- no volume,
no bind mount, `--network none` -- and `inside.sh` runs as an ordinary user.

Observed (`audit/shared-dependencies/results/cleanroom/`: transcript,
checks, the artifacts' and compiler's SHA-256):

```
tclsh: none; cargo: none; rustc: none
...
added beats (request "1.0", lock 1.0.0)
added probes (request "1.0", lock 1.0.0)
note: event_loop_linux 0.3.0 is the version beats 1.0.0, probes 1.0.0 lock: the application shares that instance
added event_loop_linux (request "0.3", lock 0.3.0)
...
executable: main
["t=0: probes: opened 2 endpoints", "t=1: beats: beat 1", ..., "t=5: beats: the driver's clock never went back"]
```

All 12 checks passed: the three adds, one driver instance in the graph, no
nested `.bot_modules`, `package graph` showing the driver shared, a clean
`verify`, a native executable (`-warnings error -emit-native-executable`,
linked by the system linker), both libraries' tasks run, and `add future`
refused as `DEPENDENCY-CONFLICT` naming future's lock with the installation
unchanged.

## 12. Testing and evidence

### 12.1 Tests (observed, Linux x86-64, Tcl 9.0.1, this container)

| file | result | new or changed |
|---|---|---|
| tests/package-manager.test | 86 passed | 13 new (`pm-shared-*`, `pm-two-versions-conflict`, `pm-conflict-deterministic`, `pm-package-graph`, `pm-graph-file-owned`, `pm-nested-installation-migrated`, `pm-fault-graph`); 9 updated to the graph |
| tests/package-native.test | 38 passed, 1 skipped (constraint) | `pn-shared-in-views` replaces `pn-two-versions-in-views`; file counts and record schema updated |
| tests/bot-modules.test | 68 passed, 1 skipped (sdl3Run) | 12 new (`bm-graph-*`) |
| tests/package-workloads.test | the 4 `pw-shared-*` tests passed (constraints met here); `pw-sdlkit-installs-its-binding` updated (sdl3Package: not run here) | 4 new |
| tests/package-authoring.test | 29 passed, 1 skipped | -- |
| tests/static-compile.test | 83 passed | PACKAGE-GRAPH classified |
| compiler-service, hir-cache, hir-interchange, lsp, main-cli, imports, application-modules, compilation-isolation, surface-modules, std-namespace, native-link-plan, diagnostic-recovery, golden-duplicates | all passed | -- |
| tools/compilerpedia.tcl check | 1219 topics, 742 examples, 0 problems | 3 topics |
| tools/mutant-catalogs.tcl | 85 catalogs, 3005 mutants, 0 problems | 16 new mutants, 6 retargeted |

FULL-SUITE-PLACEHOLDER

### 12.2 Reference resolver

`audit/shared-dependencies/tools/oracle.py` resolves a universe from the
rules of section 4.2, written apart from pm/graph.tcl (`python3 -I oracle.py
selftest`: seven cases, among them a conflicting branch whose own conflicts
count and a conflict outranking an unavailable release).

### 12.3 Model-based fuzzing

`audit/shared-dependencies/tools/fuzz.tcl -seed N -cases M` draws universes
of 2-6 packages with 1-3 releases each and random locks (some to releases no
repository holds), writes real artifacts split between two repositories,
and checks: the package manager's verdict equals the oracle's (kind,
conflicting packages, selected versions); resolution is independent of
declaration and repository order, message byte for byte; an accepted graph
installs one directory per package with the oracle's graph text; and every
few accepted graphs compile and run on interp and compile with a struct of
each shared package passed between packages, the value the oracle's
selection predicts. Observed:

```
oracle selftest: ok
seed 1: 500 cases: 218 accepted (86 with a package two scopes share), 151 conflicts, 19 unavailable, 112 cycles; 43 compiled and run; 0 disagreement(s)
seed 2: 500 cases: 220 accepted (89 with a package two scopes share), 164 conflicts, 19 unavailable, 97 cycles; 44 compiled and run; 0 disagreement(s)
seed 3: 500 cases: 228 accepted (99 with a package two scopes share), 132 conflicts, 16 unavailable, 124 cycles; 45 compiled and run; 0 disagreement(s)
seed 17: 500 cases: 214 accepted (83 with a package two scopes share), 149 conflicts, 23 unavailable, 114 cycles; 42 compiled and run; 0 disagreement(s)
seed 41: 500 cases: 225 accepted (82 with a package two scopes share), 143 conflicts, 16 unavailable, 116 cycles; 45 compiled and run; 0 disagreement(s)
```

2,500 universes, every outcome kind represented, no disagreement. (Each
case also checks the reversed declaration and repository order; "compiled"
cases ran on interp and compile, about one in five accepted graphs.)

It finds planted defects (observed, each against a private copy): selecting
a version silently on conflict (disagreements from case 1), relaxing a lock
to the newest release (case 1), and giving a graph package a per-path
identity (compile failures from case 6).

### 12.4 Mutation testing

New mutants, each a deliberate defect the milestone forbids:

* package manager (audit/package-manager/tools/mutants.txt): conflicts
  unchecked (a version selected silently), a lock relaxed to the newest
  release, an editable directory satisfying a lock, an artifact conflict
  unchecked, `add` ignoring the held version, `update` ignoring holds, the
  graph file never written, the graph not rolled back, a hand-made graph
  replaced, orphaned packages kept;
* compiler (audit/bot-modules/tools/mutants.txt): a graph package's
  identity by path (two identities of one package), a scope seeing every
  graph package, an unused graph package claiming nothing, an unsorted
  graph accepted, a graph package reading its own `.bot_modules`, a
  malformed graph ignored.

MUTANTS-PLACEHOLDER

### 12.5 Cross-backend

Every compile-level property runs on the backends it concerns:
`bm-graph-one-instance` and `bm-graph-shared-context` on interp, compile,
cranelift-generic and cranelift; `pm-shared-one-instance` on interp, compile
and cranelift; the workloads natively (they call C); the fuzzer on interp and
compile.

### 12.6 Not executed

macOS, Windows and Linux AArch64 were not run (section 16). CI workflows for
this branch are reported in the final status of the change, not here.

## 13. Performance

PERF-PLACEHOLDER

## 14. Documentation and principles

* LANGUAGE-DESIGN-PRINCIPLES.md, section 2, "One dependency graph, binding
  locks": the rule, the terms (package declaration, ordinary dependency
  edge, locked requirement, canonical resolved instance, physical paths,
  module and type identity, context installation authority), why no peer
  dependency and no override, where it is enforced.
* BOTLISH-JSON.md, section 6: the graph's lock semantics (normative).
* BOT-MODULES-MILESTONE-1.md, "Package graphs" (the compiler's rule);
  IMPORTS.md, "Installed packages"; PACKAGE-MANAGER-MILESTONE-1.md and
  PACKAGE-ECOSYSTEM-ROADMAP.md: the superseded nested-instance decisions
  marked as such; HTTP-SHIPPING-CENSUS.md, 6.2 and D1 (section 17).
* Compilerpedia: `error.package-graph`, `rule.package-modules`,
  `cli.packages`; the package manager's usage text.
* AGENTS.md: the package graph rules in "Package-scoped modules", the
  graph rules and what to run in "The package manager".

Why no peer-dependency concept is needed: a peer dependency exists to let a
library say "my consumer provides this" because the package model would
otherwise give the library a private copy. Here no package has a private
copy -- the application's graph has one instance of each package -- so an
ordinary dependency already is the shared one, and the library keeps
locking the release it was tested with. Why the application gets no
override: the author's lock is the author's contract; letting the
application rewrite it would make a library run against a release its
author never built it with, silently. A graph that cannot agree is refused,
and the user chooses other releases.

## 15. Compatibility and migration

Intentional changes:

* **Two packages locking different versions of one dependency** was two
  instances (PM-1's `pm-two-versions-two-branches`); it is now a
  `DEPENDENCY-CONFLICT`. A package needing another version of itself
  further down likewise (`pm-dependency-cycle`).
* **Layout**: packages are installed flat; a nested installation of an
  earlier package manager (record schema 1 or 2) still compiles as it is
  (the compiler reads no record, and without a graph file the tree rules
  apply), `verify` reports it as the nested layout, and the next `install`,
  `add`, `update` or `remove` installs it again as one graph, with a note
  (`pm-nested-installation-migrated`). Doing so needs the artifacts (a
  repository), as any reinstallation does.
* **Record**: every operation writes schema 3; schemas 1 and 2 are read.
* **Editable dependencies**: an editable package's own dependencies join the
  application's graph from its botlish.json's locks (formerly they were
  whatever the editable directory's own `.bot_modules` held); an editable
  dependency a package also locks is a conflict.
* **Visibility in the application**: a package of the graph claims its
  namespace in the application even when only another package uses it, so
  an application file of that namespace is MODULE-COLLISION where it is
  imported (before, a package's nested dependency was invisible to the
  application, which could have a module of the same name).
* **`update`** may hold a dependency below the newest its request accepts,
  saying why; it never moved a lock past its request and still never does.
* **Report lines** of `add`/`install`/`update` are flat, one per package,
  with the scopes that share it.

Nothing changes for an application without packages, for hand-assembled
`.bot_modules` trees without a graph file (`tests/bot-modules.test`'s 56
earlier tests unchanged), or for package authors.

## 16. Limitations

* **Platforms not run**: macOS, Windows and Linux AArch64 were not executed
  in this container. The change is portable Tcl (the graph file is text read
  through the seam; renames as before), and the macOS and Windows workflows
  run `tests/bot-modules.test` and the package tests on every push; the
  AArch64 workflow is dispatched for the branch.
* **No search**: `update` of several dependencies takes each one's newest
  version and then holds shared ones; it never tries older releases of a
  library to find a combination whose locks agree. A conflict is reported
  and the user chooses. Making that automatic is solving, which strict locks
  make unnecessary for installation and which this milestone deliberately
  does not add.
* **Editable dependencies cannot stand in for a locked release**: developing
  a library that another installed package locks needs that package
  repacked, or the library tested in its own project. An override would be
  the language-design decision section 14 declines.
* **`pack` does not check a package's own transitive graph**: a library whose
  locks are incoherent with its dependencies' (it locks X 1.0, its
  dependency locks X 2.0) packs, and every application using it gets the
  conflict at installation. Checking it at packing would need the
  dependencies' artifacts on the author's side.
* **Hand-made nested trees and graphs coexist**: a directory the graph does
  not name keeps the old nested scope, so a hand-installed package can still
  carry private instances of its own dependencies.
* **Generic and trait identity** follow module identity by construction
  (section 6) but have no dedicated shared-package test.

## 17. Consequences for HTTP-SHIPPING-CENSUS.md D1

D1 asked how a library reaches the application's driver. Option (a),
"peer/shared dependencies in the package model and the language", is
decided and built -- as shared dependencies, without a peer declaration. An
HTTP package declares and locks `event_loop_linux` like any dependency;
any other library doing the same shares the instance; the application
installs `Linux` and `Native` once; the driver's archive links once. Option
(b) (lifting B4) and option (c) (a `std` driver) are no longer prerequisites
of a reusable HTTP library, and the census's point-4 workaround (the HTTP
package re-exporting the driver) is unnecessary. The BoringSSL provider of
6.2's last paragraph and 6.4 is the same shape: a provider package locked
at one release by the HTTP package and any other user is one instance; two
pins remain a conflict, as D4 wants. Work item 1 of the census's plan is
done; items 2-12 are unchanged.

## 18. The architectural question

**Can Botlish now treat an independently authored package as a reusable
component of a larger program, rather than as the root of its own isolated
dependency universe?**

Yes, for every package whose locks agree with the rest of the program's,
and with a clear, deterministic refusal for the ones that do not:

* the two-library event-loop workload shows two independently written
  libraries composing over one driver, sharing its types, its contexts and
  its native archive, with the application installing the driver once
  (section 7), from the repository and from a clean room with only the
  single-file compiler and published artifacts (section 11);
* the negative lock tests show the composition is never bought by changing
  an author's contract: a disagreeing lock, an application lock against a
  package's, an editable stand-in, a second artifact of one release, all
  refused with every lock named (sections 4, 9);
* the native-linking evidence shows one provider instance means one archive,
  and a package's own native code links against the shared provider
  (section 8);
* the fuzzer and its independent resolver show the rule holds beyond the
  examples, on thousands of generated graphs, independently of order.

A Botlish application now has one coherent dependency graph, while every
package author retains the dependency contracts they chose.

## Repository changes

Package manager:

* `pm/graph.tcl` (new) -- demands, selection by unification, conflict
  reports, artifact agreement, cycles, the graph text, paths for messages.
* `pm/install.tcl` -- the graph plan; flat staging; the graph file in the
  journaled commit and rollback; every changed package listed in one
  MODIFIED refusal; flat reports with sharing.
* `pm/state.tcl` -- record schema 3 (`application`, `uses`), schemas 1 and 2
  read as the nested layout.
* `pm/view.tcl` -- views of the flat graph with their graph file; paths from
  the graph for messages.
* `pm/commands.tcl` -- `add`'s held version, `update`'s holds, `remove`'s
  note, `package graph`, graph-aware `verify`, the usage text.
* `pm/catalog.tcl` -- repositories kept sorted.
* `pm/pm.tcl` -- loads graph.tcl; the header.

Compiler:

* `surface/modules.tcl` -- package graphs: `ReadGraph`, `InGraph`,
  `GraphPackage`, `GraphUses`, `GraphUsers`; `ApplicationTree`,
  `PackageDir`, `Installed`, `Instance`, `Locate`, `NoSuchNamespace`,
  `ScopeText` graph-aware; PACKAGE-GRAPH.

Tests, audits, workloads, benchmarks:

* `tests/package-manager.test`, `tests/package-native.test`,
  `tests/bot-modules.test`, `tests/package-workloads.test`,
  `tests/static-compile.test` (census); `audit/golden/migration/` census rows
  and `tests/golden/manifest.tsv` regenerated (five workload tests of PM-3
  that had no census row got one).
* `examples/event-loop/shared/` -- `beats`, `probes`, `app/main.bot`.
* `audit/shared-dependencies/` -- `tools/fuzz.tcl`, `tools/oracle.py`,
  `cleanroom/` (Dockerfile, `cleanroom.sh`, `inside.sh`, `repository.sh`),
  `results/cleanroom/`.
* `audit/package-manager/tools/mutants.txt` (10 new, 6 retargeted),
  `audit/bot-modules/tools/mutants.txt` (6 new),
  `audit/bot-modules/tools/mutate.tcl` (copies `packages/`).
* `bench/shared-dependencies.tcl`.

Documentation: this report, `docs/INDEX.md`, LANGUAGE-DESIGN-PRINCIPLES.md,
BOTLISH-JSON.md, BOT-MODULES-MILESTONE-1.md, IMPORTS.md,
PACKAGE-MANAGER-MILESTONE-1.md, PACKAGE-ECOSYSTEM-ROADMAP.md,
HTTP-SHIPPING-CENSUS.md, AGENTS.md, Compilerpedia (`error.package-graph`,
`rule.package-modules`, `cli.packages`).
