# botlish.json, schemas 1 to 4

The normative specification of `botlish.json`, the package manager's
metadata file (PACKAGE-MANAGER-MILESTONE-1.md; schema 2's targets and native
dependencies: PACKAGE-MANAGER-MILESTONE-2.md; schema 3's run-time
dependencies, licenses and notices: PACKAGE-MANAGER-MILESTONE-3.md; schema
4's tools: EXTERNAL-COMPILER-TOOLS-AND-TARGET-PACKAGES-MILESTONE-1.md and
BOTLISH-TOOLS.md). The implementation is
`pm/descriptor.tcl` (the rules), `pm/targets.tcl` (schema 2's `targets`),
`pm/json.tcl` (the encoding) and `pm/version.tcl` (versions and requests);
`tests/package-manager.test`'s `pm-json-*`, `pm-version-*` and
`pm-descriptor-*` tests, `tests/package-native.test`'s `pn-schema2-*`
and `pn-target-*` tests and `tests/package-authoring.test`'s `pa-schema*`
tests check every rule below.

The compiler never reads this file. A program compiles from the
`.bot_modules` trees beside it (BOT-MODULES-MILESTONE-1.md) whether or not a
`botlish.json` exists, and whatever it holds.

Contents:

* [1. Where it is, and who reads it](#1-where-it-is-and-who-reads-it)
* [2. Encoding](#2-encoding)
* [3. The object](#3-the-object)
* [4. Names](#4-names)
* [5. Versions and requests](#5-versions-and-requests)
* [6. Dependencies and locks](#6-dependencies-and-locks)
* [7. Sources](#7-sources)
* [8. Contexts](#8-contexts)
* [9. The canonical form](#9-the-canonical-form)
* [10. Examples](#10-examples)
* [11. Evolution](#11-evolution)
* [12. Schema 2: targets and native dependencies](#12-schema-2-targets-and-native-dependencies)
* [13. Schema 3: run-time dependencies, licenses and notices](#13-schema-3-run-time-dependencies-licenses-and-notices)
* [14. Schema 4: tools](#14-schema-4-tools)

## 1. Where it is, and who reads it

A *project* is a directory with a `botlish.json`: an application (the
directory of its entry file, the compiler's application root) or a package
under development. A *package artifact* (a `.botpkg`, BOTPKG-FORMAT.md)
holds a `botlish.json` at its root. The same schema serves both, under the
rules of its *context* (section 8).

Only the package manager reads and writes it. It rewrites a project's
`botlish.json` only when a command changes the project's dependencies
(`add`, `update`, `remove`), always in the canonical form (section 9).

## 2. Encoding

A `botlish.json` is one JSON value (RFC 8259) in UTF-8, read strictly:

* the bytes must be valid UTF-8 (no overlong forms, no encoded surrogates);
  a leading byte order mark is an error;
* an object may not repeat a key, at any depth: readers that kept the first
  or the last value would disagree about what the file says;
* a string escape may not name half of a surrogate pair alone; a control
  character in a string must be escaped (JSON's own rule);
* at most 1 MiB of text and 32 levels of nesting.

A violation is an error naming the character offset. No other leniency
exists: no comments, no trailing commas, no single quotes.

## 3. The object

The value is an object whose keys are drawn from exactly these:

| key | type | meaning |
|---|---|---|
| `schema` | number | required: `1` or `2` |
| `name` | string | the package's name (section 4) |
| `version` | string | the package's exact release (section 5) |
| `dependencies` | object | direct dependency name -> request (section 6) |
| `lock` | object | direct dependency name -> exact version (section 6) |
| `sources` | object | direct dependency name -> where it comes from (section 7) |
| `targets` | object | schema 2 only: the targets a package supports, each with its target-specific files and native dependencies (section 12) |
| `origins` | object | schema 2 only, projects: native library name -> `"system"` or `"bundled"`, the consumer's choice where a package offers both (section 12) |
| `tools` | object | schema 4 only: the programs the package carries for a developer to run explicitly (section 14) |

Any other key is an error, never ignored: a key a later schema adds must not
be half-understood by this one, and there is no `scripts`, `main`, `exports`,
`type`, `engines`, `files`, `repository` or similar key. `schema` must be
the JSON number `1` or `2` (not `"1"`, not `1.0`); a file whose `schema` is
another number is refused as an unsupported schema ("a newer one needs a
newer Botlish"), and one without `schema` is refused. A schema 1 file using
`targets` or `origins` is refused saying that they are schema 2's: a
schema 1 reader (PM-1's) refuses them as unknown keys, so a file meant for
schema 2 is never half-read by it. Everything else is the same in both
schemas; a schema 1 file is read and written exactly as before.

`dependencies`, `lock` and `sources` may be absent; absent and empty mean the
same.

## 4. Names

A package's name is its *root namespace*: the first segment of every module
it provides (`sdlkit`, `sdlkit::video`), and the name of its directory in a
`.bot_modules` (BOT-MODULES-MILESTONE-1.md). A name is

    [a-z][a-z0-9_]{0,63}

-- a lowercase letter, then lowercase letters, digits and underscores, at
most 64 characters -- and is none of:

* `std`, the standard library's root, which no package may claim
  (`surface::modules`' standard root);
* a keyword of Botlish's lexer (`fn`, `if`, `type`, `yield`, ...: the
  lexer's own list, `surface::lexer::keywords`, read at run time), which no
  import can name.

The compiler accepts any identifier as a package directory; the package
manager accepts fewer, so that a name means one directory on every file
system: two names that differ only in letter case would be one directory on
macOS's and Windows' default file systems. The same rule holds for every
dependency name in `dependencies`, `lock` and `sources`.

## 5. Versions and requests

    version := N "." N "." N
    request := N | N "." N | N "." N "." N
    N       := "0" | [1-9][0-9]{0,8}

An exact version is three numbers (MAJOR.MINOR.PATCH), each below 10^9 and
without a leading zero (`1.02.3` is an error, not `1.2.3`). A request is one,
two or three such numbers, and its *precision* is how many:

| request | accepts |
|---|---|
| `1` | every `1.x.y` |
| `1.2` | every `1.2.x` |
| `1.2.3` | exactly `1.2.3` |

A request accepts exactly the versions whose leading components equal its
components; nothing else is assumed about what a version change means.
There are no operators (`^`, `~`, `>=`, `<`, `*`, `x`, `||`), no ranges, no
prerelease (`1.2.3-rc.1`) and no build metadata (`1.2.3+linux`): each is an
error that says which of these it is. Versions compare numerically,
component by component (`1.10.0` is above `1.9.7`).

## 6. Dependencies and locks

`dependencies` names the package's *direct* dependencies and the versions it
accepts of each. `lock` names, for direct dependencies, the exact version
selected. A transitive dependency appears in neither: each package's own
`botlish.json` names and locks its own direct dependencies (distributed
locking).

An application has one dependency graph
(SHARED-PACKAGE-DEPENDENCIES-MILESTONE-1.md): every package that appears in
it, directly or through other packages, appears once, at one version, and
every package that depends on it -- the application among them -- uses that
one instance. The package manager installs each at the application's
`.bot_modules/NAME` and writes `.bot_modules/.graph`, which tells the
compiler which package uses which. A lock is binding wherever it is written:

* every lock of a package in the graph -- the application's and every
  package author's -- names the same exact version, or the graph is a
  `DEPENDENCY-CONFLICT` that names every lock and the dependency path to the
  package that holds it;
* no lock is ever moved, relaxed or overridden to make the graph agree --
  not by the application, not by the package manager -- and no second
  instance of a package is made as a fallback;
* a request (one, two or three numbers) is satisfied by the version the
  graph selects only when it accepts it; `add` and `update` choose, within
  a request, the version the graph's locks already hold when a package of
  the graph locks one (`update` says the dependency is held, and why);
* an editable dependency (section 7) is no release and satisfies no
  package's lock;
* a release is one artifact: two different files claiming one name and
  version are a `CONFLICT`, also when one is the application's archive
  source and a package of the graph locks that release;
* a package that depends on itself through its dependencies is a `CYCLE`.

There are no peer dependencies: a library declares and locks what it uses
like any dependency, and it is shared because the graph has one instance of
it, not because it is declared differently.

In every context:

* a `lock` entry names a dependency (one not in `dependencies` is an error);
* a lock satisfies its request (`"3.2"` locked to `3.3.0` is an error);
* an editable dependency (section 7) has no lock;
* a package does not depend on its own name.

A project being written may lack locks (section 8); a package artifact
locks every direct dependency. The package manager never changes a request:
`add` writes one (MAJOR.MINOR of the version it installs, unless `-request`
gives another), `update` moves locks within it, and a request is changed
only by editing the file or `add -replace`.

## 7. Sources

`sources` says, for a direct dependency of a project, where the package
manager acquires it when not from a repository (PACKAGE-MANAGER-MILESTONE-1.md,
"Local package sources"). Each value is exactly one of:

    {"archive": PATH, "sha256": DIGEST}   an immutable local artifact
    {"directory": PATH}                   an editable local package

* `PATH` is relative to the project's directory (the directory of this
  `botlish.json`), whatever the working directory: "/"-separated, no empty
  or "." segment, ".." allowed (a sibling checkout), never absolute, never
  with a drive letter or a backslash.
* `DIGEST` is the archive's SHA-256, 64 lowercase hexadecimal digits: the
  project's own integrity assertion about that file, checked at every
  installation. It says the file is the one the project was set up with,
  not who published it.
* A directory dependency is *editable*: the package manager links it into
  `.bot_modules`, never copies it, and it has no lock (its contents are
  whatever the directory holds). Its directory must hold a `botlish.json`
  with its name and version, the version accepted by the request.

A dependency without a source is acquired from the repositories the command
line names. `sources` is a project's configuration: it never enters an
artifact (section 8).

## 8. Contexts

| rule | project | pack | artifact |
|---|---|---|---|
| `name` | optional | required | required |
| `version` | optional (needs `name`) | required | required |
| every dependency locked | no (while authoring) | yes | yes |
| an editable dependency | allowed | refused (it has no lock) | impossible |
| `sources` | allowed | allowed (never packed) | refused |
| `targets` (schema 2) | allowed | allowed (packed, its layout and native files checked) | allowed (checked again at every installation) |
| `origins` (schema 2) | allowed | allowed (never packed) | refused |

* **project**: the `botlish.json` of a directory a command manages (an
  application, or a package under development). `install` installs exact
  releases only, so it refuses a dependency without a lock (`update NAME`
  resolves one); `add` and `update` write locks. An editable dependency's
  own `botlish.json` is read as a project's, and its dependencies, which
  join the application's graph, must be locked there.
* **pack**: a package directory being packed (`package pack`). Packing
  requires a name, an exact version, and an exact, compatible lock for every
  direct dependency.
* **artifact**: the `botlish.json` inside a `.botpkg`, validated again at
  every installation, whatever made the artifact: a registry having accepted
  it is never taken as evidence that it is valid.

## 9. The canonical form

The package manager writes a `botlish.json` in one form:

* keys in the order `schema`, `name`, `version`, `dependencies`, `lock`,
  `sources`, `targets`, `tools`, `origins`; in `tools`, the tools sorted by
  name, each tool's keys in the order `protocol`, `summary`, `programs`
  (its hosts sorted), `inputs`, `environment` (empty ones left out); an absent `name` or `version`, an empty
  `lock`, empty `sources`, `targets` and `origins` are left out, and
  `dependencies` is always written (`{}` when there is none); `schema` is
  the file's own (a schema 1 file stays schema 1);
* in `targets`, the targets sorted by name, each target's keys in the order
  `files`, `libraries`, `frameworks`, `headers` (absent or empty ones left
  out), each library's keys in the order `name`, `origin`, `linkage`,
  `file`, `import`, `identity`, `needs`, `version`, `pkg-config`,
  `symbols` (empty ones left out, but a bundled shared library's `needs`
  always written), libraries, frameworks and headers in the order written;
* the entries of `dependencies`, `lock` and `sources` sorted by name;
* two spaces of indentation per level, `": "` after a key, one entry per
  line, `{}` and `[]` for empty containers, one trailing newline;
* strings escaped as JSON requires (`\"`, `\\`, `\n`, `\r`, `\t`, `\b`,
  `\f`, `\u00XX` for other control characters and DEL), other characters as
  themselves in UTF-8.

The `botlish.json` of an artifact is the canonical form of the packed
directory's descriptor without `sources`; reading the canonical form gives
the same descriptor, and writing it again gives the same bytes.

## 10. Examples

An application during development (no name, one lock missing):

```json
{
  "schema": 1,
  "dependencies": {
    "sdlkit": "0.1",
    "web": "0.4"
  },
  "lock": {
    "sdlkit": "0.1.0"
  }
}
```

A package (as packed: name, version, every dependency locked):

```json
{
  "schema": 1,
  "name": "sdlkit",
  "version": "0.1.0",
  "dependencies": {
    "sdl3": "0.1"
  },
  "lock": {
    "sdl3": "0.1.0"
  }
}
```

An application with a vendored artifact and an editable checkout:

```json
{
  "schema": 1,
  "name": "game",
  "dependencies": {
    "physics": "2.1",
    "sdlkit": "0.1"
  },
  "lock": {
    "sdlkit": "0.1.0"
  },
  "sources": {
    "physics": {
      "directory": "../physics"
    },
    "sdlkit": {
      "archive": "vendor/sdlkit-0.1.0.botpkg",
      "sha256": "1cbf1eb6c765e8a210a53d38715dfc689cf96313d295f568b5416e96ed9687dc"
    }
  }
}
```

Refused, with the reason given:

| text | why |
|---|---|
| `{"name": "x"}` | no `schema` |
| `{"schema": 2}` | unsupported schema 2 |
| `{"schema": 1, "scripts": {}}` | unknown key `scripts` |
| `{"schema": 1, "name": "std"}` | `std` is reserved |
| `{"schema": 1, "name": "My-Pkg"}` | not a package name |
| `{"schema": 1, "dependencies": {"a": "^1.2"}}` | an operator |
| `{"schema": 1, "dependencies": {"a": "1.2"}, "lock": {"a": "1.3.0"}}` | the lock is outside the request |
| `{"schema": 1, "dependencies": {"a": "1"}, "lock": {"a": "1.0.0", "b": "1.0.0"}}` | `b` is no dependency |
| `{"schema": 1, "a": 1, "a": 2}` | a repeated key |

## 11. Evolution

A later schema is a new `schema` number. A schema reserves no key for the
next: a key added later is refused by this reader, never silently ignored,
so a file meant for a later schema is never half-read. Native dependency
metadata is schema 2 (section 12), run-time dependencies and licenses
schema 3 (section 13); publication and signature records (PM-4) and
provenance (PM-3's records, BOTPKG-PROVENANCE.md; PM-5's anchors) belong to
later schemas or to records outside the artifact, never to optional keys of
these; signatures in particular are
made over an artifact's digest (BOTPKG-FORMAT.md, "Identity"), never stored
in the `botlish.json` they would sign -- and since a schema 2 artifact's
`botlish.json` (its targets and native declarations with it) is inside the
archive the digest covers, a signature over the digest authenticates every
target variant and every native declaration at once.

## 12. Schema 2: targets and native dependencies

`"schema": 2` adds two keys. A package without `targets` is
*target-independent* -- every file is the same for every target -- whatever
its schema: a pure-Botlish package needs schema 1 and nothing else.

### `targets`

    "targets": {
      TARGET: {
        "files": DIR,                       optional
        "libraries": [LIBRARY, ...],        optional
        "frameworks": [NAME, ...],          optional, Apple targets only
        "headers": [DIR, ...]               optional
      }, ...
    }

A package with `targets` is *target-aware*: it supports exactly the targets
it names, and none other -- a consumer preparing another is refused
(`UNSUPPORTED`), never given the common files alone.

* **TARGET** is a compilation target's name, exactly as the compiler's
  `-target` takes it (core/cabi.tcl's table: `linux-x86_64`,
  `linux-aarch64`, `macos-x86_64`, `macos-aarch64`, `windows-x86_64`,
  `windows-x86_64-gnu`, `windows-aarch64`): an operating system, an
  architecture and, where the C toolchain's ABI family differs, that family
  too (`windows-x86_64` is MSVC's, `windows-x86_64-gnu` MinGW-w64's; the
  Linux targets are the GNU C library's, and a library built against musl
  is refused for them). There is no second naming convention.
* **files** is a directory of the artifact (an archive path,
  BOTPKG-FORMAT.md section 4) whose files are, for that target, at the
  package root: `targets/linux-x86_64/sdl3/video.bot` is the module
  `sdl3::video` when compiling for `linux-x86_64`. Every artifact file
  under no target's directory is *common*: the same file for every target.
  For each target, its *view* is the common files and its directory's files
  so mapped; the files of another target's directory are not in it. Rules:
  a target directory holds at least one file; two targets' directories are
  equal or not nested; in a target's view no two files have one path (a
  target file never replaces a common one), none collides ignoring case or
  as a file and a directory, and no target file is `botlish.json`.
  Several targets may name one directory.
* **headers** are directories of the target's view holding public C
  headers, for consumers' own C code (`botlish native plan -include`).
* **frameworks** are Apple frameworks the package links (system-provided);
  only a macOS target has them.

A **LIBRARY** is an object:

| key | | meaning |
|---|---|---|
| `name` | required | the native library's name as `extern c library "NAME"` writes it (letters, digits, `_ + . -`, not starting with `-`) |
| `origin` | required | `bundled` (a file of the package) or `system` (the target's own installation) |
| `linkage` | required | `static` or `shared` |
| `file` | bundled | the library's file, a path in the target's view |
| `import` | bundled shared, Windows | the DLL's import library (what the linker links), a path in the view |
| `identity` | bundled shared: required; system: optional | the loader identity: an ELF soname, a Mach-O install name, a DLL's file name |
| `needs` | bundled shared: required (`[]` for none) | the library's loader dependencies, exactly the binary's (ELF DT_NEEDED, Mach-O LC_LOAD_DYLIB, PE imports) |
| `version` | system, optional | a request (section 5's grammar) the system's version must satisfy |
| `pkg-config` | system, optional | the pkg-config module recording it (default: the name in lowercase) |
| `symbols` | optional | exported C symbols the library must define |

A library has at most one entry per origin in a target: two entries of one
name, one bundled and one system, are alternatives the consumer chooses
between (`origins`; bundled by default). A bundled library's facts are
checked against its file when the package is packed and whenever a target
view is derived (PACKAGE-MANAGER-MILESTONE-2.md, "Native verification"); a
system library's on its own target's host only.

### `origins`

A project's choices, `"origins": {"SDL3": "system"}`: for every package
offering both a bundled and a system `SDL3`, the system one. A project
configuration like `sources`: never packed, refused in an artifact.

### Example

```json
{
  "schema": 2,
  "name": "raven",
  "version": "0.2.0",
  "dependencies": {},
  "targets": {
    "linux-aarch64": {
      "files": "targets/linux-aarch64",
      "libraries": [
        {
          "name": "raven_bridge",
          "origin": "bundled",
          "linkage": "static",
          "file": "native/libraven_bridge.a"
        },
        {
          "name": "raven",
          "origin": "bundled",
          "linkage": "shared",
          "file": "native/libraven.so.0",
          "identity": "libraven.so.0",
          "needs": [
            "libm.so.6",
            "libc.so.6",
            "ld-linux-aarch64.so.1"
          ]
        }
      ]
    },
    "linux-x86_64": {
      "files": "targets/linux-x86_64",
      "libraries": [ ... the same for x86-64 ... ]
    }
  }
}
```

The package's common `raven.bot` declares `extern c library "raven_bridge"
static at "native/libraven_bridge.a"`; each target's directory holds that
archive, built for the target, at `native/libraven_bridge.a` of its view,
and the target's generated binding at `raven/`. One artifact,
`raven-0.2.0.botpkg`, is the release for both targets.

Refused, with the reason given (each a line of the error):

| text (in `targets`) | why |
|---|---|
| `{"linux-sparc": {}}` | not a compilation target |
| `{"linux-x86_64": {"files": "../up"}}` | not an archive path |
| `{"linux-x86_64": {"scripts": "x"}}` | unknown key |
| a bundled library without `file` | a bundled library names its file |
| a bundled shared library without `identity` or `needs` | both are stated |
| a bundled Windows DLL without `import` | the linker links its import library |
| a system library with `file` | a system library is the target's own |
| `"frameworks"` for a Linux target | only Apple targets have frameworks |
| two `system` entries of one name | at most one per origin |
| `{}` | a target-independent package leaves `targets` out |

## 13. Schema 3: run-time dependencies, licenses and notices

`"schema": 3` is schema 2 with three keys more, and nothing else: a target's
`runtime`, and a library's `license` and `notices`. A schema 2 file using
one of them is refused, saying it is a schema 3 key; a reader of schemas 1
and 2 (PM-2's) refuses schema 3 as an unsupported schema, so a file that
declares run-time dependencies is never half-read as one without them. A
file is read and written in its own schema; the package manager's author
commands (PACKAGE-MANAGER-MILESTONE-3.md) raise a package's schema only to
what its contents need -- native metadata 2, a run-time dependency, a
license or a notice 3 -- and never lower one.

### `runtime`

    "runtime": [RUNTIME, ...]          in a target, optional

A *run-time dependency* is something a package's native code uses at run
time that no loader dependency names: a library its code opens by name
(`dlopen`, `LoadLibrary`), or a *facility* that is no file at all (a
graphics driver the Vulkan loader finds, a display server). The loader's
dependencies are `needs` (section 12), exactly the binary's; a run-time
dependency is never one of them, never part of the link, never part of the
native closure an installation verifies, and its absence never makes a
package uninstallable.

| key | | meaning |
|---|---|---|
| `name` | required | its name (as a library name: letters, digits, `_ + . -`), unique in the target |
| `kind` | required | `library` (opened by name) or `facility` (no file) |
| `identity` | library: required; facility: absent | the name it is opened by: an ELF soname, a Mach-O install name, a DLL name |
| `loaded-by` | optional | the library of this target that opens it |
| `requirement` | required | `always` (whenever the package's native code runs), `capability` (only for one capability: a program that does not use it runs without it) or `optional` (used when present, never required) |
| `capability` | `capability`: required; else absent | the capability's name: lowercase letters, digits and `-` |
| `purpose` | required | what needs it, in one line of at most 300 characters |

Rules: a `loaded-by` names a library of the same target; an `identity` is
no library's identity and no bundled library's need in the target (a
library the loader loads is declared as a library, `origin` system or
bundled). Nothing checks that a library is opened at run time: `native
audit` reports whether the identity's string occurs in the `loaded-by`
library's bytes (consistent with an open by name, never a proof) and, on the
target's own host, whether the system has a candidate (by its metadata, as
for a system library); `native plan` lists run-time dependencies apart from
the link, with that host's candidate. A facility cannot be verified from
any file.

### `license` and `notices`

| key | | meaning |
|---|---|---|
| `license` | bundled, optional | the library's license, an SPDX license expression: identifiers (`MIT`, `Apache-2.0`, `LicenseRef-NAME`), `AND`, `OR`, `WITH` and parentheses, at most 256 characters |
| `notices` | bundled, optional; needs `license` | files of the target's view (archive paths) that the license requires to travel with the library: its license text, NOTICE files, third-party notices |

Both are the author's statement about what a consumer redistributes when
it deploys the library (`native deploy`); nothing checks the statement
against the library, and a system library has neither (it is the target's
own). A notice must be a file of the target's view (checked with the rest
of the layout, section 12). `native audit` notes a bundled library with no
license.

### Example

The linux-x86_64 target of `raven` 0.3.2 (packages/raven, its release made
by tools/package-repository.tcl), shortened:

```json
"linux-x86_64": {
  "files": "targets/linux-x86_64",
  "libraries": [
    {"name": "raven_bridge", "origin": "bundled", "linkage": "static",
     "file": "native/libraven_bridge.a"},
    {"name": "raven", "origin": "bundled", "linkage": "shared",
     "file": "native/libraven.so.0", "identity": "libraven.so.0",
     "needs": ["libm.so.6", "libX11.so.6", "libc.so.6", "ld-linux-x86-64.so.2"],
     "symbols": ["Rinit_ex", "Rvulkan_get_instance"],
     "license": "Apache-2.0 AND OFL-1.1 AND (MIT OR Unlicense)",
     "notices": ["licenses/raven/LICENSE", "licenses/raven/NOTICE", "licenses/raven/THIRD_PARTY.md", "..."]},
    {"name": "X11", "origin": "system", "linkage": "shared",
     "identity": "libX11.so.6", "symbols": ["XOpenDisplay"]}
  ],
  "runtime": [
    {"name": "vulkan", "kind": "library", "identity": "libvulkan.so.1",
     "loaded-by": "raven", "requirement": "capability", "capability": "desktop",
     "purpose": "the Vulkan loader, opened by Raven's renderer when a program starts raven::desktop(); a headless program never opens it"},
    {"name": "vulkan-driver", "kind": "facility", "loaded-by": "raven",
     "requirement": "capability", "capability": "desktop",
     "purpose": "a Vulkan driver (a GPU's, or Mesa's lavapipe) the loader finds, able to present to an X11 window: no file a package can name"},
    {"name": "x11-xcb", "kind": "library", "identity": "libX11-xcb.so.1",
     "loaded-by": "raven", "requirement": "optional",
     "purpose": "opened by the renderer only for a Vulkan driver that presents through XCB alone"}
  ]
}
```

libX11 is a loader dependency (the bundled libraven's `DT_NEEDED`):
declared a system library, verified at installation. The Vulkan loader is
not: Raven opens it only when a program starts its renderer, so a headless
installation needs no Vulkan at all, and `native plan` says what desktop
rendering needs.

Refused, with the reason given:

| text | why |
|---|---|
| `"runtime"` in a schema 2 file | a schema 3 key |
| a library run-time dependency without `identity` | the name it is opened by is stated |
| a facility with `identity` | a facility is no file |
| `"requirement": "sometimes"` | always, capability or optional |
| a capability requirement without `capability` | the capability is named |
| `"loaded-by"` naming no library of the target | it names the library that opens it |
| an `identity` that is a declared library's or a bundled library's need | the loader loads it: it is a library |
| `"license": "MIT AND"` | not a license expression |
| `license` or `notices` on a system library | a system library is the target's own |
| `notices` without `license` | the license the notices belong to |

## 14. Schema 4: tools

`"schema": 4` is schema 3 with one key more, `tools`, and nothing else. A
schema 1, 2 or 3 file using it is refused, saying it is a schema 4 key; a
reader of schemas 1 to 3 (PM-3's) refuses schema 4 as an unsupported
schema, so a file that declares tools is never half-read as one without
them. The author's commands raise a package's schema to 4 only when it
declares a tool.

    "tools": {
      TOOL: {
        "protocol": N,                    required
        "summary": TEXT,                  required
        "programs": {HOST: PATH, ...},    required, at least one
        "inputs": [KIND, ...],            optional
        "environment": [VARIABLE, ...]    optional
      }, ...
    }

| key | | meaning |
|---|---|---|
| TOOL | | the tool's name: a lowercase letter, then lowercase letters, digits and `-`, at most 64 characters |
| `protocol` | required | the tool protocol it speaks (BOTLISH-TOOLS.md): a positive integer; any is accepted here, a tool command runs only a protocol it speaks |
| `summary` | required | one line, 1 to 300 characters |
| `programs` | required | each host the tool runs on (a compilation target's name) -> the archive path of its program, a native executable of that host: checked against the file when the package is packed and whenever its artifact is acquired, never run by either |
| `inputs` | optional | the artifact kinds it requires (`native-library`) |
| `environment` | optional | environment variables it reads, by name (reported, never their values) |

A tool runs only when `botlish tool` names it (BOTLISH-TOOLS.md, sections 3
to 5): installing the package, importing its modules or compiling a program
that uses them runs nothing, and an installed program is never executable.
`tools` is an artifact's like `targets`: packed, validated again at every
installation. A tool program is a declared native file of the package, so
the native audit of a target-aware package does not report it.

Refused, with the reason given:

| text (in `tools`) | why |
|---|---|
| `"tools"` in a schema 3 file | a schema 4 key |
| `{}` | a package without tools leaves `tools` out |
| `{"Bad": ...}` | not a tool name |
| a tool without `protocol`, `summary` or `programs` | each is stated |
| `"protocol": 0` | a positive integer |
| `"programs": {}` | at least one host |
| `"programs": {"linux-sparc": ...}` | not a host |
| `"programs": {"linux-x86_64": "../tool"}` | not an archive path |
| `"script": ...` (any other key) | unknown key: no script, hook or install step exists |
| an `environment` name given twice | each once |

At packing and acquisition: a program that is no file of the package, or
not a native executable of its host (a script, a library, another
architecture's), refuses the package.

### Example

```json
{
  "schema": 4,
  "name": "abi_tools",
  "version": "0.1.0",
  "dependencies": {},
  "tools": {
    "emit-caller": {
      "protocol": 1,
      "summary": "generates a C command-line caller of a Botlish native library from its manifest",
      "programs": {
        "linux-x86_64": "tools/linux-x86_64/emit-caller"
      },
      "inputs": [
        "native-library"
      ]
    }
  }
}
```
