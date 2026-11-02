# The .botpkg format, version 1

The normative specification of a Botlish package artifact
(PACKAGE-MANAGER-MILESTONE-1.md). The implementation is `pm/archive.tcl`:
`pm::archive::bytes` writes the format, `pm::archive::read` and
`fromBytes` enforce it; `tests/package-manager.test`'s `pm-archive-*` tests
check every rule below against archives built byte by byte to break one rule
each, and Python's `zipfile` reads what the writer makes
(`pm-archive-standard-zip`).

Contents:

* [1. What an artifact is](#1-what-an-artifact-is)
* [2. Identity and the verification boundary](#2-identity-and-the-verification-boundary)
* [3. The container: a restricted ZIP profile](#3-the-container-a-restricted-zip-profile)
* [4. Entries and paths](#4-entries-and-paths)
* [5. Compression](#5-compression)
* [6. Limits](#6-limits)
* [7. Reading](#7-reading)
* [8. Writing, and what packing normalizes](#8-writing-and-what-packing-normalizes)
* [9. Contents of a package](#9-contents-of-a-package)
* [10. Installation](#10-installation)
* [11. Evolution](#11-evolution)

## 1. What an artifact is

A `.botpkg` file is one immutable release of one package: its source files
and anything else it ships, with its `botlish.json` (BOTLISH-JSON.md,
context *artifact*) at the root. The archive's root *is* the package's root:
there is no enclosing `NAME-VERSION/` directory.

```
sdlkit-0.1.0.botpkg
    botlish.json          {"schema": 1, "name": "sdlkit", "version": "0.1.0", ...}
    README.md
    sdlkit.bot            the module sdlkit
    sdlkit/video.bot      the module sdlkit::video (when it has one)
```

A pure-Botlish package and a native-backed one have the same format: a
generated binding (`sdl3/*.bot`), a C source, a static archive
(`native/libraven_bridge.a`), a shared library or a header are ordinary
files of the archive, which the format transports and never interprets. A
target-aware package (BOTLISH-JSON.md section 12) holds every target it
supports in its one archive -- its targets' files under the directories its
`botlish.json` names, `targets/linux-x86_64/...` -- so one release, one
name and version and one digest, is every target's: there are never
several archives claiming one release for different targets.

## 2. Identity and the verification boundary

An artifact's identity is

* its **name and version**, read from its `botlish.json` (never from its
  file name), and
* its **digest**: the SHA-256 of the complete archive file's bytes, as
  64 lowercase hexadecimal digits.

The digest is never stored inside the archive (it could not cover itself).
Everything that vouches for an artifact refers to it from outside, by
(name, version, digest): a project's archive source (`"sha256"`,
BOTLISH-JSON.md section 7), the installation record (`state.json`), and,
later, detached signatures and TUF targets metadata (PM-4), provenance
records (PM-5) and transparency log entries (PM-6). A signature is made over
the digest of the archive as it is, so the format needs no field for it.

In a local repository, an artifact's file is named `NAME-VERSION.botpkg`
after its own identity; a reader compares the two and refuses a file whose
contents claim another identity. The file name is a locator, not an
identity: two files may never claim one release with different bytes
(PACKAGE-MANAGER-MILESTONE-1.md, "Local package sources").

PM-1 authenticates nothing about *who* made an artifact: a digest checks
that bytes are the bytes someone recorded, and no artifact carries a
publisher's signature yet.

## 3. The container: a restricted ZIP profile

A `.botpkg` is a ZIP file (PKWARE's APPNOTE.TXT) that any ZIP tool reads,
restricted to one canonical layout. Every multi-byte field is
little-endian, as ZIP's.

**Layout.** The file is exactly, in order:

1. for each entry, in increasing byte order of its name: its local file
   header (30 bytes + name) immediately followed by its data;
2. the central directory: one 46-byte header + name per entry, in the same
   order;
3. the 22-byte end of central directory record, ending the file.

There is no byte before the first local header, between an entry's data and
the next header, between the last entry and the central directory, or after
the end record. The end record's two disk numbers are 0, its two entry
counts are equal (at least 1, below 65535), its central directory offset and
size add up to the end record's own offset, and its comment length is 0. No
ZIP64 record exists.

**Each entry's fields** (central header; the local header repeats every
shared field with the same value):

| field | value |
|---|---|
| version made by | `0x0314` (Unix, 2.0) |
| version needed to extract | `20` |
| general purpose flags | `0x0800` (UTF-8 names; nothing else: no encryption, no data descriptor) |
| compression method | `0` (stored) or `8` (deflate) |
| last modification time, date | `0x0000`, `0x0021` (1980-01-01 00:00:00) |
| CRC-32 | of the uncompressed bytes |
| compressed size, uncompressed size | the data's; equal when stored |
| file name length | the name's bytes |
| extra field length, file comment length | `0` |
| disk number start, internal attributes | `0` |
| external attributes | `0x81A40000`: a regular file, mode 0644 |
| relative offset of local header | where the previous entry ended (0 for the first) |

A field with any other value makes the archive invalid. In particular a
symbolic link (`0xA...` in the high nibble), a directory entry, a file with
an executable or special bit, an encrypted entry, a data descriptor, an
extra field (including the Unix extra fields that carry owners and times),
a comment, a time stamp, another compression method, a multi-disk or ZIP64
field are each refused.

## 4. Entries and paths

Every entry is a regular file. Directories have no entries: a directory is
implied by the paths below it, and an empty directory cannot be
represented. At least one entry exists, and one is named `botlish.json`.

An entry's name is its path from the package root: components separated by
`/`, each matching

    [A-Za-z0-9_][A-Za-z0-9_.+-]*

and, beyond that,

* no empty component (no leading, doubled or trailing `/`), and so no
  absolute path;
* no component `.` or `..`, and no component starting with `.` (no hidden
  file: never `.bot_modules`, `.git`, `.botlish`);
* no component ending with `.` (Windows drops it), none that is a Windows
  device name (`con`, `prn`, `aux`, `nul`, `com0`-`com9`, `lpt0`-`lpt9`,
  in any letter case, with any extension);
* no backslash, drive letter, colon, space or non-ASCII character (the
  character set excludes them, and with them every Unicode normalization
  question);
* at most 255 bytes per component, 1024 bytes per path, 32 components.

Across the archive:

* names are in strictly increasing byte order, so no name repeats;
* no two names are equal ignoring ASCII letter case (one file on a
  case-insensitive file system);
* no name is also a directory of another name, ignoring case (`a` and
  `a/b`, `X` and `x/c`).

## 5. Compression

An entry is stored (method 0) or deflated (method 8: a raw deflate stream,
RFC 1951). A deflated entry has at least one byte of data, and an entry
whose uncompressed size is over 64 KiB declares at most 256 times its
compressed size: a larger declared expansion is refused before anything is
decompressed. Decompression is streamed and stops as soon as the output
passes the declared size (within one 64 KiB step), so no entry ever
expands in memory beyond its declaration; the output must then equal the
declared size and CRC-32 exactly.

## 6. Limits

| limit | value |
|---|---|
| archive file | 256 MiB |
| entries | 10,000 |
| one entry, uncompressed | 64 MiB |
| all entries, uncompressed | 256 MiB |
| declared expansion of an entry over 64 KiB | 256 x its compressed size |
| a path | 1024 bytes, 32 components |
| a path component | 255 bytes |

A reader enforces these; it may enforce lower ones (the tests do), never
higher ones. A writer never produces an archive over them.

## 7. Reading

A reader validates the whole archive before any of its files is exposed:

1. the file's size against the archive limit; the end record (the last 22
   bytes) and its fields;
2. every central directory entry, in order: its fixed fields, its name
   (UTF-8, the path rules), its order after the previous name, its sizes and
   declared expansion against the limits, its local header at exactly the
   expected offset and equal to it, its data inside the region before the
   central directory;
3. the whole name set: case-folded collisions and file/directory conflicts;
   `botlish.json` present;
4. every entry's data: decompressed (streamed, capped), its size and CRC-32
   checked;
5. the `botlish.json`, against BOTLISH-JSON.md's artifact rules.

The reader returns bytes; it never writes a file, and never interprets any
entry but `botlish.json`. An installer writes those bytes only below a
staging directory it created, at paths the rules above have made safe, and
moves the result into place only when every artifact of the operation has
been read this way (PACKAGE-MANAGER-MILESTONE-1.md, "Transactions").

Not detected: bytes after the end of a deflate stream inside an entry's
declared compressed data (zlib stops at the stream's end). They cannot
change any extracted byte, which the size and CRC-32 checks pin.

## 8. Writing, and what packing normalizes

The writer (`pm::archive::bytes`) is deterministic: the same files give the
same archive bytes. It sorts the entries by name and writes every field the
profile fixes; it deflates a file at zlib's level 9 when that is smaller
and within the expansion rule, and stores it otherwise. Byte-identical
output across *implementations* additionally needs the same deflate
encoder: two zlib versions may encode a file differently, which yields a
different (equally valid) artifact with a different digest. The files'
bytes, and so the installed package, are the same either way.

`package pack DIR` makes an artifact from a package directory:

* **included**: every regular file below DIR, with its exact bytes (no line
  ending conversion, no encoding conversion);
* **excluded** silently: every entry whose name starts with `.` at any
  depth (`.git`, `.hg`, `.svn`, `.bot_modules`, `.botlish`, editors' files,
  `.DS_Store`) and every `*.botpkg` file (earlier artifacts);
* **refused**, with every offending path listed: a symbolic link, a device,
  a socket or a named pipe (an artifact holds regular files only), a name
  outside the path rules, two names colliding ignoring case;
* **rewritten**: `botlish.json` is replaced by its canonical form
  (BOTLISH-JSON.md section 9) without `sources`, after validation in the
  *pack* context;
* **never recorded**: modification times, permissions, owners, groups, the
  directory's location or any other host path, the packing machine, the
  time of packing; empty directories.

There is no include or ignore list: a file that should not ship must not be
in the package directory (or must be hidden).

## 9. Contents of a package

The package's Botlish source follows the compiler's module layout
(BOT-MODULES-MILESTONE-1.md): the package `NAME`'s modules are `NAME.bot`
and `NAME/...`. A package need not have a `NAME.bot` (one that provides only
`NAME::a` has `NAME/a.bot`); `package pack` notes a package with no module of
its namespace at all. A `.bot` file outside that tree is no module of
anything, as in any installed package.

Every other file is opaque to the format: documentation, licenses, C
sources, headers, static archives, shared libraries, generated binding
metadata. The format attaches no meaning to any path but `botlish.json`: no
install script, hook, entry point or build step exists, and an executable
bit cannot be represented. A schema 2 `botlish.json` gives some files a
meaning *for the package manager* -- a target's directory, a bundled
library's file -- which it checks when it reads the artifact (the target
layout, at every acquisition) and when it derives a target view (each
bundled native file inspected as its declaration says:
PACKAGE-MANAGER-MILESTONE-2.md); the archive stays the same restricted ZIP
of regular files. Native libraries need no executable bit and get none: a
deployment places them with mode 0644, which the loaders of every target
accept. A macOS framework bundle, whose structure relies on symbolic links,
is not representable and not needed by any package yet (a dylib or a static
archive is); PM-3 decides a declarative reconstruction if one is.

## 10. Installation

An installed package is the archive's files written below
`.bot_modules/NAME/` with the host's default permissions for new files
(never executable), and its dependencies below its own
`.bot_modules/` (PACKAGE-MANAGER-MILESTONE-1.md). The installation record
keeps, for every file, its size and CRC-32 (from the validated archive), and
for the artifact its digest.

## 11. Evolution

Version 1 is identified by the profile itself (version needed 20, made by
`0x0314`, flags `0x0800`) together with the `botlish.json` schema it holds.
A later version will change a field a version-1 reader checks -- the
version needed to extract, or the descriptor's schema -- so that a
version-1 reader refuses it rather than half-reading it. Target-specific
contents (PM-2) needed no change to the format: they are a declared layout
in `botlish.json` schema 2, which a PM-1 reader refuses as an unsupported
schema rather than installing a target-aware package as if its target
directories were ordinary files. Signatures and registry metadata (PM-4)
stay outside the archive, over its digest -- the digest of the one archive
that holds every target.

The limits (section 6) were checked against the real multi-target packages
(PACKAGE-MANAGER-MILESTONE-2.md, "Performance"): the SDL3 release with two
targets' bindings, thunk archives and a bundled libSDL3 is 1.5 MiB packed
and 4.3 MiB unpacked, Raven's 1.6 MiB and 3.8 MiB, far inside 256 MiB per
archive and 64 MiB per file; they are unchanged.
