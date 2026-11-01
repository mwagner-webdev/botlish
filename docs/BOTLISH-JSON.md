# botlish.json, schema 1

The normative specification of `botlish.json`, the package manager's
metadata file (PACKAGE-MANAGER-MILESTONE-1.md). The implementation is
`pm/descriptor.tcl` (the rules), `pm/json.tcl` (the encoding) and
`pm/version.tcl` (versions and requests); `tests/package-manager.test`'s
`pm-json-*`, `pm-version-*` and `pm-descriptor-*` tests check every rule
below.

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
| `schema` | number | required: `1` |
| `name` | string | the package's name (section 4) |
| `version` | string | the package's exact release (section 5) |
| `dependencies` | object | direct dependency name -> request (section 6) |
| `lock` | object | direct dependency name -> exact version (section 6) |
| `sources` | object | direct dependency name -> where it comes from (section 7) |

Any other key is an error, never ignored: a key a later schema adds must not
be half-understood by this one, and there is no `scripts`, `main`, `exports`,
`type`, `engines`, `files`, `repository` or similar key. `schema` must be
the JSON number `1` (not `"1"`, not `1.0`); a file whose `schema` is another
number is refused as an unsupported schema ("a newer one needs a newer
Botlish"), and one without `schema` is refused.

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
locking), and the package manager installs it in that package's own
`.bot_modules`.

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

* **project**: the `botlish.json` of a directory a command manages (an
  application, or a package under development). `install` installs exact
  releases only, so it refuses a dependency without a lock (`update NAME`
  resolves one); `add` and `update` write locks.
* **pack**: a package directory being packed (`package pack`). Packing
  requires a name, an exact version, and an exact, compatible lock for every
  direct dependency.
* **artifact**: the `botlish.json` inside a `.botpkg`, validated again at
  every installation, whatever made the artifact: a registry having accepted
  it is never taken as evidence that it is valid.

## 9. The canonical form

The package manager writes a `botlish.json` in one form:

* keys in the order `schema`, `name`, `version`, `dependencies`, `lock`,
  `sources`; an absent `name` or `version`, an empty `lock` and empty
  `sources` are left out, and `dependencies` is always written (`{}` when
  there is none);
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

A later schema is a new `schema` number. This schema reserves no key for
it: a key added later is refused by this reader, never silently ignored, so
a file meant for a later schema is never half-read. Native dependency
metadata (PM-2), publication and signature records (PM-4) and provenance
(PM-5) belong to later schemas or to records outside the artifact, never to
optional keys of this one; signatures in particular are made over an
artifact's digest (BOTPKG-FORMAT.md, "Identity"), never stored in the
`botlish.json` they would sign.
