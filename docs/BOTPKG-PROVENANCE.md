# Provenance records and evidence, format 1

The normative specification of a release's provenance record --
`NAME-VERSION.provenance.json`, written beside `NAME-VERSION.botpkg` by
`botlish package pack -evidence FILE` -- and of the evidence file an author
gives it (PACKAGE-MANAGER-MILESTONE-3.md, "Provenance"). The implementation
is `pm/release.tcl`; `tests/package-authoring.test`'s `pa-provenance-*`
tests check the rules below.

A record is **evidence, not authentication**. It is unsigned and made by
whoever packed the artifact. Its computed facts were computed from the
artifact's bytes when it was made. Its assertions are the author's own
statements, checked only where its `checks` say so. It does not show who
made the artifact, that the sources are the upstream's, or that the build
environment can be trusted. PM-4 authenticates the artifact's bytes (and
may sign a record's); PM-5 checks source identities against earlier
authenticated anchors. Neither is part of this format.

Contents:

* [1. Where it is](#1-where-it-is)
* [2. The evidence file](#2-the-evidence-file)
* [3. The record](#3-the-record)
* [4. Checks](#4-checks)
* [5. Canonical form and reading](#5-canonical-form-and-reading)
* [6. What a record establishes](#6-what-a-record-establishes)
* [7. Evolution](#7-evolution)

## 1. Where it is

A record is a file of its own, beside the artifact, never inside it: it
names the artifact by the SHA-256 of the artifact's exact bytes
(BOTPKG-FORMAT.md, "Identity"), which no file inside the artifact can hold.
It is written in the same transaction step as the artifact (`package pack`
makes it, and runs its checks, before writing anything). A record already
at its path is replaced only when it records the same artifact (the same
SHA-256), or with `-force`; a record of another artifact under the
release's name is `EXISTS`, as a different artifact is.

The compiler never reads a record; neither does installation. `botlish
package inspect FILE.botpkg -provenance RECORD` and `botlish package
compare A B -provenance RA -provenance RB` read them.

## 2. The evidence file

The author's statements about how a release was made: a strict JSON object
(the same reader as `botlish.json`: UTF-8, no repeated keys), every key
known, every value of its type. Unknown keys are refused, never ignored.

    {
      "evidence": 1,                                       required
      "package": {"name": N, "version": V},                optional: must be the artifact's
      "sources": [SOURCE, ...],
      "builds": [BUILD, ...],
      "generators": [GENERATOR, ...],
      "notes": [TEXT, ...]
    }

SOURCE (an input of the build: upstream source code, headers):

| key | | |
|---|---|---|
| `name` | required | unique among the sources |
| `role` | | free text (`upstream`, `vendored`, ...) |
| `repository` | | where it comes from (a URL) |
| `git` | | `{"object-format": "sha1"\|"sha256", "commit": ID, "tree": ID, "tag": NAME, "tag-object": ID}`; object-format required |
| `sha256` | | the SHA-256 of the source material used (an archive) |
| `directory` | local | the source files as built, on the author's machine: read for checks, never recorded |
| `archive` | local | the source archive used: read for checks, never recorded |
| `submodules` | | `[{"path": P, "commit": ID}, ...]`: the gitlinks of the tree |
| `patches` | | `[{"name": N, "sha256": D, "file": LOCAL, "description": T}, ...]` |
| `notes` | | free text |

BUILD (how native files of the artifact were made):

| key | | |
|---|---|---|
| `name` | required | |
| `outputs` | required | artifact paths (a directory: a prefix ending in `/`) the build made |
| `targets` | | compilation targets, each one the package supports |
| `sources` | | names of the evidence's sources |
| `configuration` | | free text |
| `toolchain` | | an object of strings: compiler and tool identities |
| `flags` | | the material flags, as strings |
| `environment` | | an object of strings: environment variables that affect outputs |
| `image` | | the build environment's identity (a container image's specification or digest) |
| `sysroot` | | free text |
| `inputs` | | `[{"name": N, "sha256": D, "source": URL}, ...]`: binary inputs (packages, SDKs) |
| `steps` | | free text, one step each |
| `notes` | | free text |

GENERATOR (files a generator wrote): `name` (required), `version`,
`inputs` (strings), `outputs` (required: artifact paths or prefixes),
`command` (strings), `notes`.

Local paths (`directory`, `archive`, a patch's `file`) are relative to the
evidence file's directory unless absolute. They exist so the package
manager can check what the author states (section 4) and are never written
into a record.

**Publication rules.** A record is published, so evidence that would put a
machine's private facts into one is refused (`EVIDENCE`): any string
(outside the local paths) holding a path of the machine that built it --
under `/home/`, `/root`, `/tmp/`, `/Users/`, `/var/folders/`,
`/private/var/`, `C:\Users\`, or the current user's home; a URL's path is
not such a path -- or something shaped like a credential (a private key, a
GitHub, GitLab, Slack or AWS token); an environment variable whose name
names a credential (token, secret, password, credential, private key, API
key, auth, cookie, session). An author writes paths relative to named roots
(`$SOURCE`, `$BUILD`, `$CACHE`).

## 3. The record

A JSON object with exactly these keys, in this order:

| key | kind | |
|---|---|---|
| `provenance` | | `1` |
| `subject` | computed | `{name, version, artifact, sha256, size, format, schema, targets}`: the artifact's name and version (its `botlish.json`'s), its file name, the SHA-256 and size of its bytes, its archive format (1) and descriptor schema, the targets it supports (`["*"]` for a target-independent package) |
| `producer` | computed | `{tool, sources-sha256}`: the package manager that made the record, identified by a SHA-256 over its own source files (a fact about the tool, not the release: two records of one artifact made by different package manager sources differ here alone) |
| `contents` | computed | `[{path, size, sha256}, ...]` by path: every file of the artifact |
| `native` | computed | per target (by name), per bundled library (as declared): `{target, library, linkage, path, sha256, description}`, for a shared library `identity` and `needs`, for a 64-bit ELF file `build-id` (NT_GNU_BUILD_ID), `compilers` (the `.comment` strings), `runtime-search-path` (RUNPATH and RPATH entries) and `glibc` (the highest GLIBC_ version required), for an archive `members` (`{name, size, sha256}` each) and the `compilers` its ELF members record |
| `sources` | asserted | the evidence's sources, local paths left out |
| `builds` | asserted | the evidence's builds |
| `generators` | asserted | the evidence's generators |
| `checks` | checked | `[{subject, fact, value, result, method}, ...]` (section 4) |
| `notes` | asserted | the evidence's notes |
| `trust` | | the fixed statement of section 6's first paragraph |

Within an asserted item the keys are in the grammar's order (section 2), an
object of strings by key.

## 4. Checks

A check is a statement the package manager tested itself, without running
anything, when it made the record. `result` is one of:

* `confirmed` -- an assertion, and what the package manager computed from
  the files given equals it;
* `computed` -- no assertion; the package manager computed the value from
  the files given (it is evidence of what was given, not of where it came
  from);
* `not checked` -- an assertion the package manager has no way to check
  (a Git tree in the SHA-256 object format).

A check that would *contradict* an assertion is never recorded: the pack
fails (`PROVENANCE`) and writes nothing.

| subject | fact | how |
|---|---|---|
| `source NAME` | `files` (computed) | the SHA-256 of the list of the source directory's files -- one line `MODE SIZE SHA256 PATH`, by path, `.git` left out -- a Botlish identity of exactly the bytes given |
| `source NAME` | `git-tree` (confirmed) | the Git tree object identity computed from the source directory's files equals the asserted `git.tree`: blobs and trees exactly as `git add` of a clean checkout makes them (SHA-1; mode 100644 or 100755, 120000 for a link, 40000 for a directory, empty directories omitted, the asserted submodules as 160000 gitlinks), `.gitattributes`' text conversions applied in Git's "clean" direction (`text`, `eol=`, `text=auto`: CRLF to LF; `binary`, `-text`: none). A file is 100755 when its owner-execute permission is set, where the host's files have one (Unix); on a host without (Windows) every file is 100644, so a tree with an executable file is never confirmed there. The bytes are the files' as they are on disk: no Git configuration is read, so a checkout whose line endings the host's Git converted (`core.autocrlf`) differs. No Git program is run and no repository read: a modified or incomplete checkout, untracked files, or a conversion this check does not model (filters, `ident`, LFS) make it differ, and the pack fails |
| `source NAME` | `sha256` | the SHA-256 of the source archive given: confirmed against the asserted `sha256`, else computed |
| `source NAME` | `patch P` | the SHA-256 of the patch file given: confirmed against its asserted `sha256`, else computed |
| `build NAME` | `output PATH` (confirmed) | the artifact holds the file (or, for a prefix, the files) the build names; the value is its SHA-256 (or the SHA-256 of the list of their digests and paths). That the build made them stays the author's statement |
| `generator NAME` | `output PATH` (confirmed) | the same, for a generator |

A commit, a tag, a tag object, a repository URL, a toolchain, flags, an
image and an input's digest are assertions: the package manager records
them and checks none (it reads no Git history and runs no tool; PM-5 checks
source history).

## 5. Canonical form and reading

A record is written in the canonical JSON form of `botlish.json`
(BOTLISH-JSON.md section 9: two-space indentation, one trailing newline),
with its keys in section 3's order and its arrays in the order section 3
states. It holds no time, no path of the machine that made it and nothing
that depends on the order a directory lists its files, so the same
artifact, evidence and package manager give the same bytes.

A reader (`pm::release::readRecord`) refuses a file that is not exactly
that: other keys or another order, another format number, a subject whose
`sha256` is no SHA-256, or bytes that are not the canonical form of what it
holds. A record *describes* an artifact (`package inspect -provenance`)
when its subject's SHA-256, name and version are the artifact's and its
`contents` list exactly the artifact's files with their digests; anything
else is reported as a mismatch (`PROVENANCE`).

## 6. What a record establishes

That the producer, when it made the record, computed these facts from this
artifact's bytes, read these statements from an evidence file, and checked
those of them its checks list. Not: that the producer is who it claims to
be, that the record was not edited since (it is unsigned), that the stated
repository holds the stated commit, that the commit descends from an
earlier release, that the stated toolchain made the native files, or that
anything in the sources is harmless.

What later milestones add on top of the same bytes: PM-4 signs the
artifact's SHA-256 (the subject) and may sign the record's bytes as an
attestation; PM-5 compares a record's source identities (repository,
commit, tree, tag object) with the previously authenticated release's
anchors; PM-6's independent builders publish their own records of the same
subject, and a comparison (`package compare`) of their artifacts.

## 7. Evolution

A later format is a new `provenance` number; this reader refuses it. A key
is never added to format 1.
