# PM-1: local package management, `botlish.json` and `.botpkg` artifacts

Botlish has a package manager. A package is defined by a `botlish.json`
(name, version, direct dependency requests, exact locks), packed into a
deterministic `.botpkg` artifact, and installed -- with its own exactly
locked dependencies, recursively, each in its own package's `.bot_modules`
-- from local artifacts by the ordinary command line: `botlish add`,
`install`, `update`, `remove`, `verify` and `package pack`. Every operation
is one transaction that a failure or an interruption leaves undone. The
compiler is unchanged: it reads the `.bot_modules` trees the package manager
builds exactly as it reads hand-assembled ones (BOT-MODULES-MILESTONE-1.md),
and never reads `botlish.json`, a version, a lock or an artifact.

This is milestone PM-1 of PACKAGE-ECOSYSTEM-ROADMAP.md. The normative format
specifications are BOTLISH-JSON.md (schema 1) and BOTPKG-FORMAT.md (format
version 1); this report summarizes them (section B) and records the
implementation, its evidence and its limits.

> The compiler compiles installed source. The package manager determines
> what gets installed, validates it, and maintains exact dependency
> resolutions. Neither knows how the other does its work.

Contents:

* [A. Result](#a-result)
* [B. Format specifications](#b-format-specifications)
* [C. Installation algorithm](#c-installation-algorithm)
* [D. Security audit](#d-security-audit)
* [E. Workload results](#e-workload-results)
* [F. Tests and performance](#f-tests-and-performance)
* [G. Remaining limitations](#g-remaining-limitations)
* [H. PM-2 preparation](#h-pm-2-preparation)
* [Repository changes](#repository-changes)

## A. Result

### What works

| operation | what it does |
|---|---|
| `package pack [DIR] [-out DIR] [-force]` | validates DIR's `botlish.json` (name, version, a compatible exact lock for every direct dependency), collects its files, writes the deterministic `NAME-VERSION.botpkg` and prints its SHA-256; refuses to overwrite a different artifact of the same release without `-force` |
| `package inspect FILE` | validates an artifact completely and shows its identity, digest, dependencies and files |
| `add NAME [-request R]` | finds the newest version (or the newest `R` accepts) in the `-repository` directories, validates the whole tree it needs, installs it and writes the request (MAJOR.MINOR by default) and the exact lock |
| `add FILE.botpkg` | the same from one archive, recorded as the dependency's source with its SHA-256 |
| `add DIR` | links an editable local package (no lock, never copied) |
| `install` | recreates exactly what `botlish.json` locks, recursively, from local artifacts; changes no lock; reuses what is already installed exactly |
| `update [NAME...]` | moves locks to the newest version their requests accept (never past the request, never changing it), then installs |
| `remove NAME...` | removes dependencies, their locks and sources, and their installed trees |
| `verify` | compares the installation with its record and, where the artifacts are available, with their bytes; reports editable dependencies as unauthenticatable |

Each package's own dependencies are installed in its own `.bot_modules`; two
packages may lock different versions of one dependency and each gets its own
instance; a package installed by hand is never touched; a changed managed
package is replaced only with `-force`; nothing is downloaded and nothing a
package holds runs.

The commands are main.tcl's (`tclsh9.0 main.tcl add ...` in a checkout) and
the single-file compiler's (`botlish add ...`), which packs `pm/` and runs a
package command without installing its native backend.

### Hosts

Executed on Linux x86-64 (Ubuntu 24.04 container, Tcl 9.0.1, rustc 1.97,
clang 18). The package manager is portable Tcl with one platform-specific
part (renames retried on Windows, editable links as Tcl's directory links,
`/proc` or `kill -0` for a lock holder's liveness), but macOS, Windows and
Linux AArch64 were **not** run for this report; section G says what that
leaves unverified.

### Which existing workflows can now use it

| workflow | before | now |
|---|---|---|
| SDL3 binding + the reusable airlock | sdlkit existed only as text inside `tests/bot-modules.test`; the binding was staged by `tools/c-bindgen.tcl stage -package 1` | `packages/sdlkit` (with `botlish.json` locking `sdl3`) and `packages/sdl3`; `botlish add sdlkit` installs both, sdl3 inside sdlkit's scope |
| Raven | `tools/raven-package.tcl install APP` copied, staged and compiled the bridge in the consumer's tree | the same staging runs once on the author's side (`tools/package-repository.tcl`), and `botlish add raven` installs the identical tree (plus its `botlish.json`) with no C compiler |
| Linux event loop | `tools/event-loop-linux.tcl install APP` copied and compiled the adapter in the consumer's tree | likewise: `botlish add event_loop_linux` |
| a pure-Botlish library | copy the files | `package pack` + `add` (the 2048 engine is the workload) |

## B. Format specifications

### `botlish.json` (BOTLISH-JSON.md)

One strict UTF-8 JSON object (no BOM, no duplicate key at any depth, at most
1 MiB and 32 levels) whose keys are exactly `schema`, `name`, `version`,
`dependencies`, `lock`, `sources`; any other key, and any `schema` but the
number `1`, is refused.

* **name**: the package's root namespace, `[a-z][a-z0-9_]{0,63}`, never
  `std`, never one of the lexer's keywords (read from `surface/lexer.tcl`).
  Lowercase only, so a name is one directory on every file system.
* **version**: `MAJOR.MINOR.PATCH`, numbers below 10^9 without leading
  zeros; no prerelease, no build metadata.
* **request** (the values of `dependencies`): one, two or three such
  numbers; `1` accepts `1.x.y`, `1.2` accepts `1.2.x`, `1.2.3` only itself.
  No operators, ranges or wildcards. Versions compare numerically.
* **lock**: exact versions of direct dependencies, each satisfying its
  request; a lock names a dependency; an editable dependency has none.
* **sources** (projects only): `{"archive": PATH, "sha256": D}` or
  `{"directory": PATH}`, PATH relative to the project's directory with `/`
  separators, never absolute.
* **contexts**: a *project* may omit name, version and locks while it is
  being written; a package being *packed* and an *artifact* have a name, a
  version and a compatible lock for every direct dependency; an artifact has
  no `sources`.

The package manager writes one canonical form (keys in schema order, maps
sorted, two-space indentation, one trailing newline).

### `.botpkg` (BOTPKG-FORMAT.md)

A ZIP file in one restricted, canonical profile: local headers and data
back to back from offset 0, sorted by name, then the central directory, then
the 22-byte end record; regular files only (external attributes
`0x81A40000`), flags `0x0800`, method 0 or 8, time stamp fixed at
1980-01-01, no extra fields, comments, encryption, data descriptors, ZIP64
or gaps; local headers equal to the central ones. Paths are "/"-separated
components of `[A-Za-z0-9_][A-Za-z0-9_.+-]*` (no hidden, empty, `.`, `..`,
trailing-dot or Windows device component; at most 32 components, 1024
bytes), unique ignoring case, never both a file and a directory. Limits:
256 MiB per archive and in total, 64 MiB per file, 10,000 entries, a
declared expansion at most 256 times the compressed size for files over
64 KiB. The archive's root is the package's root; `botlish.json` is
required there. Its identity is its name and version (from its
`botlish.json`) and the SHA-256 of the whole file, never stored in it.

### A complete example

The package directory

```
geometry/
    botlish.json      {"schema": 1, "name": "geometry", "version": "1.0.3"}
    geometry.bot      struct Point (x, y) and fn area(w: int, h: int) -> int
    .git/HEAD         (left out: hidden)
```

`botlish package pack geometry -out repo` writes
`repo/geometry-1.0.3.botpkg` (the output as it was, the directory
shortened):

```
packed geometry 1.0.3: /.../repo/geometry-1.0.3.botpkg
  sha256 b35d2b1111198e54387946eee8dd1432244e59e8e63884074eb3444e4e495f14
  2 files, 351 bytes (163 bytes unpacked)
```

whose `botlish.json` is the canonical

```json
{
  "schema": 1,
  "name": "geometry",
  "version": "1.0.3",
  "dependencies": {}
}
```

A package using it, `shapes/botlish.json`:

```json
{
  "schema": 1,
  "name": "shapes",
  "version": "2.1.4",
  "dependencies": {
    "geometry": "1.0"
  },
  "lock": {
    "geometry": "1.0.3"
  }
}
```

and an application that adds it (`botlish add shapes -repository repo`):

```json
{
  "schema": 1,
  "dependencies": {
    "shapes": "2.1"
  },
  "lock": {
    "shapes": "2.1.4"
  }
}
```

```
app/
    botlish.json  main.bot
    .bot_modules/
        .botlish/state.json                         the installation record
        shapes/botlish.json  shapes.bot
        shapes/.bot_modules/geometry/botlish.json  geometry.bot
```

The application locks only `shapes`; `shapes` locks `geometry`, and the
installer reads that from the shapes artifact.

## C. Installation algorithm

### Acquisition and selection

An artifact comes from exactly one place:

* the project's **archive source** for that dependency (a path relative to
  the project's directory, its recorded SHA-256 checked on every
  acquisition); or
* the **local repositories** the command line names (`-repository DIR`, any
  number): the file `NAME-VERSION.botpkg` of each. There is no precedence:
  identical files in two repositories are one artifact, different bytes
  claiming one release are a `CONFLICT` naming both, and nothing is ever
  chosen arbitrarily.

Nothing else is consulted: no parent directory, working directory,
environment variable, global installation or network
(`pm-no-network-in-sources` checks the sources: no socket, no http or tls
package, no command but `kill -0`). A transitive dependency always comes
from the repositories: an artifact has no sources, so a published package
never names an author's paths.

Every acquired artifact is read whole, hashed (SHA-256 over the bytes read,
never trusted from a name or a record), validated completely as a `.botpkg`
and its `botlish.json` validated in the *artifact* context; its embedded
name and version must be the ones asked for (`IDENTITY` otherwise). Exact
versions come only from locks: `add` and `update` choose the newest version
the repositories hold within a request (versions are listed from file
names, then the chosen one is validated); `install` never chooses.

### The dependency tree

*Superseded by SHARED-PACKAGE-DEPENDENCIES-MILESTONE-1.md:* an application
now has one dependency graph -- each package installed once, at
`.bot_modules/NAME`, shared by every package that depends on it, with
`.bot_modules/.graph` telling the compiler which package uses which -- and
two packages locking different versions of one dependency are a
`DEPENDENCY-CONFLICT`, never two instances. This section records PM-1's
nested layout, which an `install` of the new package manager replaces.

`Resolve` builds the whole plan before anything is written: for each direct
dependency of the project, its node, and for an artifact node its children
from its own locks, recursively. A node is

* **reused** when the installation record has that instance (at that place
  in the tree) at that version -- and, for an archive source, that digest --
  and every installed file still has the recorded size and CRC-32, its
  nested installation included: no artifact is read, which makes a repeated
  `install` cost about 20 ms (section F);
* **extracted** from its artifact otherwise.

A path that reaches a release it is already inside (`a 1.0.0 -> b 1.0.0 ->
a 1.0.0`) is a `CYCLE`, refused with the path; another version of the same
package further down is no cycle. Depth (32) and instance count (1000) are
bounded.

Two versions on separate branches:

```
app/.bot_modules/physics/                       physics 1.0.0
app/.bot_modules/physics/.bot_modules/geometry/   geometry 1.0.0  (physics locks it)
app/.bot_modules/rendering/                     rendering 1.0.0
app/.bot_modules/rendering/.bot_modules/geometry/ geometry 2.0.0  (rendering locks it)
```

The installer copies each instance; it never deduplicates by name. The
compiler gives them the identities `physics/geometry` and
`rendering/geometry`: passing physics's `geometry::Point` where rendering's
is declared is a TYPE error naming both (`pm-two-versions-two-branches`),
and the application cannot import `geometry` at all
(`pm-no-transitive-access`).

### Ownership

The package manager owns:

* the project's `botlish.json` (rewritten canonically by `add`, `update`,
  `remove`; never by `install`);
* `PROJECT/.bot_modules/.botlish/` -- `state.json` (the installation
  record), `lock`, `txn/` -- which the compiler can never name (a namespace
  segment is an identifier);
* every top-level entry `PROJECT/.bot_modules/NAME` the record names, with
  everything below it.

Any other entry of `.bot_modules` was installed by hand and is never
modified, replaced or deleted: adding a package of its name is `MANUAL`
(`pm-manual-packages-preserved`). A managed package whose files differ from
the record (an edited, missing or extra file, a file turned into a link) is
replaced or removed only with `-force`; the refusal lists the changes
(`pm-modified-packages-protected`, `pm-install-restores-only-with-force`).
`.bot_modules` and `.botlish` must be real directories, never links. A
project inside the compiler's standard library is refused
(`pm-stdlib-never-a-project`). An editable dependency is a link
(`.bot_modules/NAME -> DIR`); the manager never writes into DIR, and
removing the dependency removes the link only.

### Transactions

An operation (`add`, `install`, `update`, `remove`):

1. locks the project (`.botlish/lock`, created exclusively, holding its
   process id); a lock whose process is gone, or a `txn/` without a lock,
   is an interrupted operation, recovered first (below); a lock whose
   process runs is `BUSY`;
2. resolves and validates the whole tree (above): nothing is written yet;
3. checks ownership: nothing it would replace or remove is manual or
   changed (without `-force`);
4. stages each new or changed top-level package -- its files, and its
   dependencies under its own `.bot_modules`, recursively; a reused nested
   instance copied from the installed tree -- in `txn/new/NAME`, in
   directories it created, each file created exclusively;
5. writes `txn/journal.json` (the renames, and whether the record and
   `botlish.json` existed, copies of both kept in `txn/`), then for each
   package renames the old tree to `txn/old/NAME` and the staged one into
   place, replaces `state.json`, replaces `botlish.json`, and writes
   `txn/committed`;
6. deletes `txn/` and the lock (and `.bot_modules`/`.botlish` again if this
   operation created them and they are empty: a failed first `add` leaves
   no trace, `pm-failed-add-writes-nothing`).

Every file replacement is a new file renamed over the old one. A failure in
steps 2-4 deletes the staging; a failure in step 5 runs the rollback: the
journal's renames undone in reverse (a staged tree moved back out, an old
tree back in), the record and `botlish.json` restored from their copies.
An interrupted process (killed, power lost) leaves the journal: the next
command, before anything else, rolls it back -- or, when `committed` exists,
only deletes the leftovers (`pm-crash-recovery`: killed after each of the
journal, the first old tree moved out, the first new tree moved in, the
record, `botlish.json` and the commit marker, the project is afterwards
byte for byte the old installation, or, after the marker, the new one).

On Windows, where a rename fails while another process holds a file open,
every rename is retried for about two seconds before the operation rolls
back; where the liveness of a lock's holder cannot be determined,
`-recover` must be given to roll an interrupted operation back.

## D. Security audit

### What is checked

* **Descriptors**: strict UTF-8, no BOM, no duplicate keys, bounded size and
  depth, unknown keys refused, every version, request, name and path by its
  grammar, locks against requests, artifacts against the artifact context
  (complete compatible locks, no sources) at every installation -- never
  trusting whoever made the artifact.
* **Archives**: every field of the profile, the layout (no hidden byte
  anywhere in the file), the entry order, the path rules, case-folded and
  file/directory collisions, the size, count, total and expansion limits
  *before* any decompression, streamed decompression that stops within one
  64 KiB step past the declared size (`pm-archive-bomb`: an 8 MiB deflate
  bomb declaring 1000 bytes stops after at most 66,536), each file's exact
  size and CRC-32.
* **Paths**: no absolute path, drive, backslash, `.`, `..`, hidden
  component, Windows device name, trailing dot or non-ASCII character can
  reach the installer; extraction writes only below a staging directory the
  installer created, with files created exclusively (`O_EXCL`: never through
  a link someone planted), and moves the result into `.bot_modules` by
  rename. `pm-extraction-never-escapes` installs an artifact naming
  `../../victim/pwned.txt`: refused, nothing written, the project unchanged.
* **Entry types**: a symbolic link, a directory entry, an executable or
  special file is refused in an archive; `package pack` refuses links,
  sockets, pipes and devices in a package directory instead of following or
  skipping them. Installed files are never executable.
* **Integrity**: the SHA-256 of every acquired artifact, compared with an
  archive source's recorded digest (`INTEGRITY`), and with other copies of
  the same release (`CONFLICT`); the embedded identity against the requested
  one (`IDENTITY`).
* **Execution**: none. No hook, script, build step or binary of a package
  runs at packing, inspection, verification or installation; a
  `botlish.json` key asking for one is an unknown key
  (`pm-no-scripts`: an artifact with `install.sh`, `postinstall.tcl`, a
  Makefile and `build.rs` installs as plain, non-executable files and none
  runs).
* **Failures**: every refusal happens before the active tree is touched, or
  is rolled back (section C); errors name the package, the version, the
  dependency path and the file.

### What PM-1 authenticates, and what it does not

PM-1 checks **integrity against local records**: that an archive is the
file a project recorded (its SHA-256), that two copies of a release agree,
that installed files are the artifact's bytes (`verify -repository`), and
that the installation record matches the files (sizes and CRC-32, which
detects accidents, not forgery: `pm-verify-record-is-not-authority` forges a
file *and* the record, which only the artifact comparison detects).

PM-1 authenticates **no publisher**. No artifact carries a signature, and a
digest a project writes is that project's assertion about a file it
already had: whoever could replace a repository's artifact before it was
first added could replace its digest too. A repository is trusted as the
local file system is. `verify` says so in its output; editable directories
are reported as unauthenticatable. Authentication of publishers, freshness,
rollback and freeze protection, revocation and provenance are PM-4 to PM-6
(TUF, developer signatures, upstream anchors, transparency), and the format
reserves their place outside the artifact (BOTPKG-FORMAT.md section 2).

## E. Workload results

All on the Linux x86-64 container, from packages packed by
`tools/package-repository.tcl` (the author's side) into a fresh local
repository and installed by the commands into fresh applications
(`tests/package-workloads.test`).

| workload | source package installed | compiled | linked | ran |
|---|---|---|---|---|
| A. pure Botlish: the 2048 engine as `game2048` 1.0.0 | yes, with PATH emptied (no C compiler, linker or Rust) | yes, interp, compile, cranelift | -- (no C) | yes: the 60-move benchmark checksum equals the engine's as an application module on all three; the HIR is the same apart from the module's path (`pw-pure-botlish-*`) |
| B. nested: `sdlkit` 0.1.0 locking `sdl3` 0.1.0 (the generated linux-x86_64 binding, 62 files) | yes: sdlkit in the application's scope, sdl3 in sdlkit's; a fresh copy reinstalls the same tree; verify clean against the artifacts | yes (`-target linux-x86_64`): `sdlkit` contextualized, every `sdlkit/sdl3::*` module ordinary; the application cannot import `sdl3` (UNKNOWN-NAMESPACE) | -- | -- |
| C. two versions on separate branches | yes (`pm-two-versions-two-branches`) | yes: values on interp and compile, nominal types distinct | -- | yes |
| D. SDL3 through sdlkit | as B | yes | yes, against the package-owned libSDL3 (`-L`) | yes, headless, `cranelift` and `cranelift-generic`: `[[true, true, true, true, true, true], true]` |
| E. Raven (`raven` 0.1.0: wrapper, generated binding, prebuilt `native/libraven_bridge.a`) | yes, with PATH emptied: the identical file tree `tools/raven-package.tcl install` makes, plus `botlish.json` | yes | yes: the bridge archive from the package instance's directory (`static at`), libraven by `-L` | yes: `examples/raven/headless.bot`, `["3", "3 clicks", "false", "0"]` |
| F. event loop (`event_loop_linux` 0.1.0 with prebuilt `native/libevent_loop_linux.a`) | yes | yes | yes: the driver's archive from the package; the application builds only its own `libticker.a` (against the header the package installed) | yes: `examples/event-loop/native`, five ticks handled |

What the generic manager replaced, and what stays native work:

* **Raven** (`tools/raven-package.tcl`). Replaced: copying the wrapper,
  staging the target's generated binding as `raven/`, placing the bridge
  archive -- the consumer's whole installation, now `botlish add raven`.
  Remaining, moved to the author's side but still native build work:
  compiling `native/raven_bridge.c` against the pinned Raven headers and
  archiving it (`cc`, `ar`). Remaining outside both: building `libraven.so`
  (`tests/cffi/raven.tcl`) and deploying it (`-L`, `LD_LIBRARY_PATH`).
* **The event loop** (`tools/event-loop-linux.tcl`). Replaced: copying the
  package. Remaining author-side: compiling the adapter into
  `libevent_loop_linux.a`. Its header (`botlish_event_loop.h`) now arrives
  with the package, so a native library posting events compiles against the
  installed copy.
* **SDL3**. Replaced: `tools/c-bindgen.tcl stage -package 1` for a
  consumer, and hand-nesting the binding under an airlock package.
  Remaining: the binding is one target's per artifact; the C library
  (`tests/cffi/sdl3.tcl`), the thunk shim a program using SDL's static
  inline functions needs (`tools/c-bindgen.tcl build`; sdlkit uses none),
  and deployment.

The two helpers stay: their tests (`tests/raven.test`,
`tests/event-loop-linux.test`) and `tools/package-repository.tcl` use them
as the author-side staging they are.

## F. Tests and performance

### Commands and outcomes (executed)

Every command with `LANG=C.utf8 LC_ALL=C.utf8` and a private `-tmpdir`.

| command | result |
|---|---|
| `tclsh9.0 tests/package-manager.test` | 74 tests, 74 passed (the single-file compiler test included: the compiler packed by `single/package.tcl` with this host's tclsh as base kit) |
| `tclsh9.0 tests/package-workloads.test` | 8 tests, 8 passed (libSDL3 and libraven built here by `tests/cffi/sdl3.tcl` and `tests/cffi/raven.tcl`) |
| `tclsh9.0 audit/package-manager/tools/mutate.tcl` | 27 mutants, 27 apply, 27 killed (final code; the first run's six survivors below) |
| `tclsh9.0 audit/single-executable/tools/mutate.tcl` (with the static base kit `single/build.sh` built) | 10 mutants, 10 killed, each by a named smoke-test failure; the new `package-commands-install-native` by "a package command installed the native backend" |
| regression files (below) | all passed: `bot-modules.test` 56/56 (its SDL3 run and bundled-compiler tests included), `main-cli.test` 64/64, `imports.test` 104/104, `std-namespace.test` 36/36, `application-modules.test` 21/21, `surface-modules.test` 37/37, `numeric-looking-names.test` 5/5, `raven.test` 10 passed and 1 skipped (`ravenDesktop`: no Xvfb or Vulkan here), `event-loop-linux.test` 25/25 (its SDL3 tests included), `compilerpedia.test` 42/42, `golden-duplicates.test` 4/4 |
| `tclsh9.0 tools/compilerpedia.tcl check` | 1142 topics, 692 examples run, 0 problems |
| `tclsh9.0 audit/golden/migration/merge.tcl -names audit/golden/migration/tcl-names.txt -check 1` | exit 0 (the new tests' census rows, KEEP-INTERNAL) |
| `single/build.sh`, then `single/smoke-test.sh` and `single/ffi-smoke-test.sh` | built (14.4 MB, a static Tcl 9.0.1 base kit built from the pinned source); both smoke tests passed, the new package check included ("packages: pack, add, verify, with no native backend installed") |

`tests/package-manager.test` covers: SHA-256 against FIPS 180-4 and
`sha256sum` at every length around the padding boundaries; the JSON reader
(duplicate keys at any depth, BOM, invalid UTF-8, lone surrogates, control
characters, limits, the canonical writer); the version grammar, ordering
and matching; every descriptor rule in every context; the archive writer
(determinism, round trip of binary, empty and CRLF files, Python's
`zipfile` as an independent reader) and the reader against 43 adversarial
archives built byte by byte (and one against four lowered limits) (traversal, absolute and drive paths, links,
directory entries, executable and special files, duplicates, case and
file/directory collisions, misordering, encryption, data descriptors,
methods, extra fields, comments, time stamps, ZIP64, prefix, gap and
trailing data, local/central mismatches, CRC and size lies, truncated and
invalid deflate, a deflate bomb, every limit, non-UTF-8 names); `pack`'s
determinism across copies and working directories, inclusion rules, refusals
and immutability; `add` from repositories, archives and directories with
default and explicit requests; offline reconstruction of a fresh copy;
idempotent `install`; missing locks; unavailable artifacts; two artifacts
claiming one release; identity mismatches; artifacts with unlocked
dependencies or sources; cycles; two versions on two branches; transitive
invisibility; `update` within precision and leaving others untouched;
stale-file removal; `remove`; manual packages; modified packages with and
without `-force`; editable links; archive sources and their digests;
`verify` (clean; changed, missing and extra files, a lock the installation
does not match, an artifact that is not the one installed, a dependency not
installed, a forged record, an operation in progress); fault
injection at every step and crash recovery at every step; a busy lock; a
failed first `add` leaving nothing; escape attempts; no scripts; no network
in the sources; the compiler ignoring `botlish.json` and the record; working
directory independence; usage errors; main.tcl unchanged; the single-file
compiler.

### Fault injection (executed)

`BOTLISH_PM_FAULT=POINT` (read from the environment only) makes POINT fail;
`crash:POINT` ends the process there with status 99, cleaning up nothing.

| point | failure (in process) | crash (killed), then the next command |
|---|---|---|
| `stage` (after a package is staged) | staging removed, project byte-identical | -- |
| `extract` (after a package's files) | the same | -- |
| `journal` (after the journal) | rolled back, byte-identical | rolled back, byte-identical |
| `commit-old` (an old tree moved out) | rolled back, byte-identical | rolled back, byte-identical |
| `commit-new` (a new tree moved in) | rolled back, byte-identical | rolled back, byte-identical |
| `state-written` | rolled back, byte-identical | rolled back, byte-identical |
| `descriptor-written` | rolled back, byte-identical | rolled back, byte-identical |
| `committed` (after the commit marker) | -- | cleanup finished: the new installation, verified by running it |

### Mutation testing (executed)

`audit/package-manager/tools/mutate.tcl`: 27 mutants of `pm/` (JSON
duplicates, unknown keys, locks outside requests, sources in artifacts,
textual version matching and ordering, `..` paths, entry types, entry
order, gaps, CRC, the inflate cap, repository conflicts, identity, archive
digests, update past the request, manual and modified packages, reuse
without checking, rollback, recovery, the lock, cycles, pack's links,
hidden files and sources, verify's byte comparison), each against
`tests/package-manager.test` in a private copy. The first run killed 21 and
left 6 survivors, each a gap in the tests or the code, all closed:

* `archive-inflate-unbounded`: an uncapped inflate failed with the same
  message, so the cap was invisible; the message now says where
  decompression stopped and `pm-archive-bomb` bounds it;
* `install-reuse-ignores-changes`: no test ran `install` over a changed
  package (`pm-install-restores-only-with-force` added);
* `cycle-unchecked`: no cycle test (`pm-dependency-cycle` added);
* `pack-includes-hidden`: Tcl's `glob *` already skipped hidden files on
  Unix, so the rule was untested and platform-dependent; `pack` now lists
  every entry and the rule decides;
* `pack-keeps-sources`: the inclusion test's `sources` was empty;
* `verify-ignores-artifact-bytes`: the record check masked it
  (`pm-verify-record-is-not-authority` added).

The final run, on the code as committed: 27 mutants, 27 killed, 0
survived.

### Performance (executed)

`tclsh9.0 bench/package-manager.tcl` (medians of 5 runs; commands as child
processes, so each includes Tcl's start-up, about 6 ms):

| measurement | time |
|---|---|
| read and validate a `botlish.json` (in process) | 0.19 ms |
| SHA-256 (in process, pure Tcl) | 1.21 s per MiB (0.83 MiB/s) |
| `package pack` of the SDL3 binding package (62 files, 474 KB, 83 KB packed) | 141 ms |
| `add sdlkit` from a repository (2 instances, fresh project) | 146 ms |
| `install`, unchanged tree (no artifact read) | 21 ms |
| `verify` against the installation record | 19 ms |
| `verify` against the artifacts (`-repository`) | 139 ms |
| `install` into a fresh copy of the project (offline, from the repository) | 132 ms |

SHA-256 dominates acquisition, and it hashes compressed archives (the SDL3
binding is 83 KB packed); a warm `install` reads no artifact at all. The
compiler's own path is unchanged: main.tcl without a package command does
one list membership test before it parses its options, and its start-up
(usage, `-version`, a one-line program) measured the same before and after
within noise (5.7/5.6 ms, 115/111 ms, 142/142 ms, medians of 7).

## G. Remaining limitations

### Bugs or incomplete PM-1 requirements

* **Not run on macOS, Windows or Linux AArch64.** The Windows-specific
  behavior (rename retries, directory links for editable dependencies,
  `-recover` where a lock holder's liveness is unknown, file locking during
  a transaction) is implemented but unexecuted; the tests that need links
  or `mkfifo` are constrained to Unix. Whatever the repository's CI
  workflows report for those hosts after this change is pushed is not part
  of this report's evidence.
* **No automatic recovery of a lock whose holder is alive but hung**: the
  lock is refused as `BUSY` until the process ends.

### Intentional native packaging omissions (PM-2, PM-3)

* An artifact is one target's when it carries a generated binding or a
  native archive: `sdl3`, `raven` and `event_loop_linux` artifacts are
  linux-x86_64's, and a repository serves one target. Two targets' artifacts
  of one release would be a `CONFLICT`, correctly.
* Native files are transported, never checked: no ABI, format,
  architecture or symbol check, no deployment of shared libraries, no
  `-L`/`LD_LIBRARY_PATH` management, no static/shared choice.
* Native archives are built on the author's side by
  `tools/package-repository.tcl`'s per-package recipes, which are code, not
  metadata.

### Future registry and provenance (PM-4 to PM-6)

No remote acquisition, publication, signatures, TUF, revocation, outdated
or revoked warnings, upstream anchors or transparency. The local catalog
(`pm/catalog.tcl`'s `Find`/`Versions`) is the seam a remote backend
replaces.

### Potential format refinements

* Deflate output depends on the zlib version; byte-identical artifacts
  across implementations would need a fixed encoder or stored entries.
* A content digest (over the files, independent of compression) could
  identify a package's contents across re-packings.
* A per-dependency digest pin for repository acquisitions (today only
  archive sources record one) would make a fresh installation on another
  machine refuse a substituted artifact before PM-4.
* Explicit, path-scoped lock overrides (`app -> a -> b` pinned by the
  application) were not needed by any workload and are not implemented;
  the record keeps every instance's place, which such an override would
  name.

## H. PM-2 preparation

What the real integrations showed PM-2 needs, and nothing more:

1. **Target-selected contents in one artifact.** `sdl3`, `raven` and
   `event_loop_linux` each need a per-target subtree (the generated binding,
   the native archive) and a rule selecting it at installation by the
   *compilation* target, materialized into the installed tree the compiler
   reads today (`sdl3/*.bot` at the package root). The compiler need not
   change: the installed view is ordinary.
2. **Declared native link inputs.** The bridge and adapter archives are
   already linked by `static at "native/..."` relative to the package
   instance (NATIVE-LINK-PLAN-MILESTONE-1.md); PM-2 needs only a declaration
   of which file is which target's, and checks of its format and
   architecture before installation (the driver's `check_static_archive`
   already knows how to judge an archive).
3. **System libraries.** `SDL3` and `raven` are linked by name and found at
   run time by the environment. A declaration of the system library a
   package expects (name, minimum version where reliable, target) and a
   deployment plan for the application builder (what to put beside the
   executable, or which `-L` to pass) is the missing piece.
4. **Headers for consumers' C code.** The event loop's `botlish_event_loop.h`
   is consumed by applications' own native code; PM-2 should say where a
   package's public headers are (they are already installed: the include
   path is the gap).
5. **Thunk shims.** A binding whose users call static inline functions
   needs a prebuilt shim per target (`tools/c-bindgen.tcl build`): the same
   per-target archive mechanism as 2.

## Repository changes

* `pm/` (new): `pm.tcl` (loader, shared helpers, fault injection),
  `json.tcl`, `sha256.tcl`, `version.tcl`, `descriptor.tcl`, `archive.tcl`,
  `catalog.tcl`, `state.tcl`, `install.tcl`, `commands.tcl`.
* `main.tcl`: package commands dispatched before the compiler loads; usage
  summary and header comment.
* `single/package.tcl` packs `pm/`; `single/main.tcl` installs no native
  backend for a package command; `single/smoke-test.sh` packs, adds and
  verifies a package; `audit/single-executable/tools/mutants.txt` gains
  `package-commands-install-native`, and its harness copies `pm/` into its
  private tree (it copies what `single/package.tcl` packs: without it every
  mutant was "killed" by the packing failing, not by a smoke test -- the
  first run here did exactly that, and was discarded).
* `packages/sdlkit/` (new: the airlock, until now only text inside
  `tests/bot-modules.test`, which now reads it from there -- its four SDL3
  tests rerun and passing -- with its `botlish.json` and README), `packages/sdl3/` (new: the
  binding package's descriptor and README), `botlish.json` for
  `packages/raven` and `packages/event_loop_linux`, README sections.
* `tools/package-repository.tcl` (new): the author's side.
* Tests: `tests/package-manager.test` (74), `tests/package-workloads.test`
  (8); census rows (`audit/golden/migration/census/package-*.tsv`,
  `tcl-names.txt`, the regenerated `tests/golden/manifest.tsv`).
* Audit and benchmark: `audit/package-manager/tools/mutate.tcl` and
  `mutants.txt` (27 mutants); `bench/package-manager.tcl`.
* Documentation: this report, BOTLISH-JSON.md, BOTPKG-FORMAT.md,
  `docs/INDEX.md` (with PACKAGE-ECOSYSTEM-ROADMAP.md, which it lacked),
  IMPORTS.md and BOT-MODULES-MILESTONE-1.md's notes, `AGENTS.md` ("The
  package manager"), Compilerpedia (`cli.packages`; `cli.usage`,
  `cli.exit-status` and `rule.package-modules` point to it).
