# WINDOWS-X86-64-MILESTONE-7.md

Milestone 7 of the Windows x86-64 port: paths and synchronous filesystem
I/O. It is an implementation report and an architecture decision record at
once: three path representations were compared through real filesystem
operations on Linux and Windows, the smallest coherent one was chosen, and it
is now the standard library's. The milestones before it are
WINDOWS-X86-64-MILESTONE-1.md (the driver, executables),
WINDOWS-X86-64-MILESTONE-2.md (C calls, Windows I/O through kernel32),
WINDOWS-X86-64-MILESTONE-3.md (unwind information, native-frame roots),
WINDOWS-X86-64-MILESTONE-4.md (the stack guard),
WINDOWS-X86-64-MILESTONE-5.md (coroutines) and
WINDOWS-X86-64-MILESTONE-6.md (variadic C calls). The textual path layer it
graduates is CONTEXT-TRAITS.md's, section 9 (`std::io::path::Path`,
`std::linux::path::LinuxPath`) and MACOS-AARCH64-MILESTONE-8.md's
(`std::darwin::path::DarwinPath`). The work was developed on Linux.

> A path a program writes is text; a name the operating system returns is
> the operating system's. The two are different types, one conversion is
> total and one is partial, and the type of a path decides, at compile time,
> which filesystem may operate on it.

Evidence is marked by kind throughout:

* **real Windows**: observed on a `windows-2025` runner (NTFS) through
  `.github/workflows/windows-fs-probe.yml` (the experiment) or
  `.github/workflows/windows-x86_64.yml` (the production modules), run named;
* **real Linux**: observed in this repository's Linux x86-64 development
  container (ext4), locally, and in the Linux CI;
* **macOS**: observed on a `macos-15` runner (APFS) through
  `.github/workflows/macos-arm64.yml`, run named;
* **controlled experiment**: a program or a probe run on purpose, and where;
* **compile only**: compiled for a target on a host that cannot run it (the
  Windows and macOS programs are type-checked on every host by
  `fs-windows-programs-compile` and `fs-darwin-programs-compile`), never run
  there;
* **code inspection**: what the code does, read, not run.

No Wine and no WSL were used. Commits are on the branch
`ccr-e9a35564-p23sm2`, where every CI run below ran.

## Contents

1. Result
2. The experiments
3. Windows path semantics
4. Linux and macOS path semantics
5. Two layers
6. Contexts and portable composition
7. Files: modes, completion, enumeration
8. Affine ownership
9. Errors
10. Authority
11. macOS
12. Findings
13. Tests, fuzzing, mutation testing, CI
14. Performance
15. Not here, remaining limitations, next
16. What to run when changing this

## 1. Result

The standard library has a portable synchronous filesystem and three
platform filesystems:

| module | what it is |
|---|---|
| `std::io::fs` (stdlib/io/fs.bot) | the portable layer: `FileError {reason, code}`, `Reason` (ten cases), `OpenMode`, `EntryKind`, `Entry`, `ReadSize`, and the eager trait `FilePath` |
| `std::linux::fs` (stdlib/linux/fs.bot) | Linux's native paths (bytes), `LinuxFS`, affine `File`, open/read/write/close, whole files, directories -- through raw syscalls |
| `std::windows::fs` (stdlib/windows/fs.bot) | Windows' native paths (UTF-16 code units), Win32 path syntax (`PathKind`), `WindowsFS`, affine `File` -- through kernel32's wide functions |
| `std::darwin::fs` (stdlib/darwin/fs.bot) | macOS's native paths (bytes), `DarwinFS`, affine `File` -- through libSystem |
| `std::windows::path` (stdlib/windows/path.bot) | the textual `WindowsPath`, LinuxPath's and DarwinPath's sibling |
| `std::io::bytepath` (stdlib/io/bytepath.bot) | internal: the byte-path syntax Linux and Darwin share |

Portable code is written once against `FilePath` and specialized per
witness:

```botlish
import std::abi
import std::abi::bytes
import std::io::fs
import std::io::path
import std::linux::fs
import std::linux::path
import std::str

fn save(dir: std::io::fs::FilePath, text: str) errors std::io::path::NotAPath, std::io::fs::FileError:
    file = dir.concat("save.txt")
    file.write_file(std::abi::bytes::from_list(text.encode_utf8()))

fn main() errors std::io::path::NotAPath, std::io::fs::FileError:
    home = "/tmp"
    std::linux::path::validate(home)
    home.save("hello")

with context std::linux::fs::create()
main():
    on std::io::path::NotAPath:
        unit
    on std::io::fs::FileError:
        unit
```

`save` becomes `save<std::linux::path::LinuxPath>`, whose `concat` and
`write_file` are direct calls of std::linux::path's functions
(`fs-specialized-per-witness`: no trait call, view or dispatch left). The
same `save` given a `WindowsPath` in a program compiled for Windows installs
`std::windows::fs::create()` instead. Without the installation the program
is MISSING-CONTEXT at compile time, and a Windows path never meets a Linux
filesystem: std::windows is UNSUPPORTED-PLATFORM for a Linux target
(sections 5, 6).

What a platform module adds is everything that does not behave alike:
native paths that every name a directory holds round-trips through, opened
files with explicit modes, single reads and writes with their short counts,
and listings with native names. Nothing in the compiler, the runtime or the
backends knows a path or a file: the modules are ordinary Botlish over raw
syscalls (Linux), C calls (Windows, macOS) and byte storage. Below the
library there are three byte-storage primitives, five Linux syscall
wrappers and one compiler fix:

* `std::abi::bytes::join` (one Bytes of many: a file read in chunks),
  `slice` (a range of a Bytes: the rest after a short write) and
  `decode_utf8` (strict; the declared builtin error `InvalidUtf8`, builtin
  error 12) -- core/bytestore.tcl, core/utf8text.tcl, the native helpers in
  native/src/runtime/ops.rs;
* `std::linux::openat`, `close`, `getdents64`, `mkdirat`, `unlinkat` (and
  `O_DIRECTORY`/`O_NOFOLLOW` per architecture) over the existing syscall
  transports (stdlib/linux.bot, stdlib/linux/sys.*.bot);
* a method-call decision defect fixed (hir/methods.tcl: section 12.1).

## 2. The experiments

The question was what a path is. Three designs were compared, each through
the operations that decide it -- list a directory, name each entry again,
open it -- on directories holding the names that break designs:

* **A, platform textual refinements only**: a path is a refined String
  (LinuxPath, WindowsPath); a listed name is decoded to text, strictly (A:
  a name that is not text has no path) or lossily (A': U+FFFD for what does
  not decode, which a "never fail" listing must do);
* **B, opaque native paths only**: a path is the operating system's own
  representation (bytes; UTF-16 code units), and every program converts;
* **C, both layers**: a textual path for what programs write (validated
  syntax, portable through a trait) and a native path for what the
  operating system returns (lossless), with one total conversion from text
  to native and one partial conversion back.

Each fixture file holds its own index, so a read says which file a name
reached.

### 2.1 Linux (real Linux, ext4)

`audit/filesystem/experiments/linux.tcl` (results:
audit/filesystem/results/linux-probe.txt). The fixture names: `plain.txt`,
NFC `é` and NFD `é` spellings, the bytes `FF FE 78`, `��x` (the U+FFFD
spelling a lossy decoding of `FF FE 78` produces), a newline, a symbolic
link, a dangling one, a subdirectory. Per entry: A's text, what it opened,
A''s text, what it opened, what the native name opened.

| entry | A | A opens | A' | A' opens | native opens |
|---|---|---|---|---|---|
| `é` (NFC) | é | 1 | é | 1 | 1 |
| `é` (NFD) | é | 2 | é | 2 | 2 |
| `a\nb` | a\nb | 5 | a\nb | 5 | 5 |
| `FF FE 78` | -- | (no name) | ��x | **4** | 3 |
| `��x` | ��x | 4 | ��x | 4 | 4 |

The lossy name of `FF FE 78` opened **another file**: the one whose name
really is `��x`. A strict textual listing cannot name the entry at all. Only
the native name reaches every entry. NFC and NFD are two names on ext4.

### 2.2 Windows (real Windows, NTFS)

`audit/filesystem/experiments/windows.tcl` on windows-2025, run 40775315573
of `windows-fs-probe.yml` (results: audit/filesystem/results/windows-probe.txt,
rows W1-W11). W1 made six files from raw UTF-16 -- one holding the unpaired
high surrogate D800, its U+FFFD spelling, one holding the unpaired low
surrogate DC00 -- listed them with FindFirstFileW/FindNextFileW and named
each again:

| entry units | A | A opens | A' | A' opens | native opens |
|---|---|---|---|---|---|
| `u - D800 - x` | -- | (no name) | u-�-x | **4** | 3 |
| `u - FFFD - x` | u-�-x | 4 | u-�-x | 4 | 4 |
| `v - DC00` | -- | (no name) | v-� | **not found** (2) | 5 |
| `é-nfc`, `é-nfd` | | 1, 2 | | 1, 2 | 1, 2 |

NTFS keeps a name with an unpaired surrogate; the wide functions return
exactly the units they were given. The lossy name opened another file, or
nothing (ERROR_FILE_NOT_FOUND). Only the native units reach every entry.

### 2.3 Decision

Design A is ruled out by the experiments: strict, it cannot name entries
that exist (on both systems); lossy, it opens the wrong file -- a silent
misdirection, the worst outcome a path API can have. Design B is lossless
but leaves programs nothing portable: every program would hold platform
types, and textual syntax checks (a component that is absolute, a Win32
trailing period) would have no home. **Design C** is chosen, as the
smallest design that is lossless and portable: the textual refinements stay
exactly what they were (CONTEXT-TRAITS.md, section 9), the native layer is
new, and the conversions are:

| from | to | how | total? |
|---|---|---|---|
| LinuxPath / DarwinPath | NativePath | its UTF-8 bytes (`native`) | yes (a validated path holds no U+0000) |
| WindowsPath | NativePath | its UTF-16 units (`native`) | yes |
| NativePath (bytes) | str | strict UTF-8 (`text`) | no: `std::io::path::NotText` |
| NativePath (units) | str | strict UTF-16 (`text`) | no: `NotText` for an unpaired surrogate |
| NativePath | str for people | `display`: U+FFFD, lossy, never a path | yes |

No compiler change was needed for the design itself: refinements, opaque
structs, eager traits, contexts and affinity were enough.

## 3. Windows path semantics

Rows of the real-Windows probe (run 40775315573) and what std::windows does
with each. A Windows path is Win32's syntax, not Unix's with backslashes.

| probe | observed | rule |
|---|---|---|
| W5 `GetFullPathNameW("C:x")` on a runner whose current directory is on D: | `C:\x` | `C:x` is **drive-relative** (drive C's current directory), never `C:\x`: `concat("C:", "a")` is `C:a` |
| W5 `\x` | `D:\x` | **root-relative**: the current drive's root |
| W5 `1:x` | `1:\x` | a drive designator is **any** unit and `:` |
| W5 `\\server\share\x\..\..\y`, `//server/share/x` | `\\server\share\y`, `\\server\share\x` | UNC; `/` is a separator outside `\\?\` |
| W5 `\\.\C:\a\..\b`, `//./C:/a` | `\\.\C:\b`, `\\.\C:\a` | the device namespace |
| W5 `\\?\C:\a\..\b`, `\\?\C:/a` | resolved by GetFullPathNameW | but W10/W11: `\\?\dir/plain.txt` and `\\?\...\sub\..\plain.txt` fail ERROR_INVALID_NAME (123) when opened, `\\?\...\.\plain.txt` ERROR_PATH_NOT_FOUND: **verbatim** paths reach NTFS unchanged, so `/`, `.` and `..` are no syntax there |
| W5 `\??\C:\a` | `D:\??\C:\a` | GetFullPathNameW takes `\??\` as relative; CreateFileW passes it to NT as verbatim: `kind` reads it as Verbatim |
| W2 `trail.` (Win32) | made as `trail`; `trail...` opens it too | Win32 drops trailing periods and spaces: a component ending in `.` or ` ` is refused under a Win32 path (it would name another entry) |
| W2 `\\?\...\verb.` | made as `verb.`; Win32 `verb.` is NOT FOUND (2) | a verbatim directory keeps them: a listed `verb.` is joined only to the verbatim directory it came from |
| W3 `NUL` (Win32) in a directory | the NUL device; reading gives nothing | `CON`, `COM1`, `nul.txt`, `AUX.log` made ordinary files on this Windows version (Server 2025); only NUL stayed a device; not refused (it is valid syntax), documented |
| W4 `Case.txt` then `CASE.TXT` (CREATE_NEW) | ERROR_FILE_EXISTS (80) | NTFS compares names without case: path equality is spelling, never file identity |
| W6 nested 50-unit directories | Win32 fails at 272 units (ERROR_PATH_NOT_FOUND); verbatim reaches 476 and beyond | MAX_PATH for Win32, NTFS's 32767 through `\\?\` |
| W7 share modes | a second open succeeds under READ\|WRITE\|DELETE; an exclusive opener makes it ERROR_SHARING_VIOLATION (32) | files are opened sharing READ\|WRITE\|DELETE; a conflict is `Busy` |
| W8 a directory opened as a file | ERROR_ACCESS_DENIED (5) (FILE_FLAG_BACKUP_SEMANTICS opens it) | reported as `IsADirectory` with the code 5 (section 9) |
| W9 `missing\*`, `plain.txt\*`, an empty directory | 3, 267 (ERROR_DIRECTORY), 2 entries (`.` `..`) then 18 | the enumeration's reasons |
| W9 a name with `<` | ERROR_INVALID_NAME (123) | `InvalidName` |

`std::windows::fs::kind` classifies a path as Relative, DriveRelative,
DriveAbsolute, RootRelative, Unc, Device or Verbatim
(`fs-windows-kinds`), and `join` -- one rule for text (`concat`) and native
paths -- inserts one `\` unless the base ends with a separator (`\` only
under a verbatim base) or is a bare drive designator; it refuses a
component that is not relative (`\a`, `/a`, `C:a`, `1:a`, a UNC), under a
verbatim base `/`, empty components, `.` and `..`, and elsewhere a component
ending with a period or a space (`fs-windows-concat`, 34 cases;
`fs-windows-join-one-rule`, 110 pairs through both). Nothing is normalized,
no unit decoded and no filesystem observed: a `WindowsPath` is textual
eligibility (non-empty, no U+0000), as LinuxPath is.

Every call is a wide (W) function given the units' little-endian bytes and a
two-byte NUL built for that one call; the ANSI code page is never used.

## 4. Linux and macOS path semantics

A Linux name is bytes: any byte but 0 (and `/`, which separates
components). `std::linux::fs::NativePath` holds exactly those bytes --
non-empty, no 0, nothing else assumed, nothing normalized -- so every name
round-trips (`fs-linux-native-roundtrip`: `FF FE 78`, its lossy spelling's
own file, NFC and NFD, a newline, each listed, joined and opened again,
reaches its own file). Paths are used as written: `.` and `..` components
and repeated separators reach what the kernel resolves, relative paths the
working directory (`fs-linux-paths-as-written`). Joining is concat's rule on
bytes (one `/`, an absolute name refused). Path equality is spelling:
`a` and `./a` are two paths.

macOS shares the byte syntax (std::io::bytepath, one text for both) but
APFS is not ext4: it refuses a name that is not UTF-8 and compares names
without normalization and without case (`fs-darwin-names`: EILSEQ for
`FF FE 78`, AlreadyExists for an NFD spelling of an existing NFC name and
for another case). On macOS a listed name therefore always has text; the
native layer is still the one that names entries exactly as listed.

## 5. Two layers

What each layer is, and what it is not:

* **Textual paths** (`LinuxPath`, `WindowsPath`, `DarwinPath`; refinements
  of str). What a program writes, reads from its configuration, shows to
  people. Validation is syntax only. Their `concat` is the platform's join.
  They satisfy `std::io::path::Path` (concat, text) and now
  `std::io::fs::FilePath`, whose file operations are the platform module's
  on the path's native form.
* **Native paths** (`std::PLATFORM::fs::NativePath`; opaque). What the
  operating system takes and returns. Lossless: bytes or UTF-16 units,
  exactly. Built from text (`from_text`, total for a validated path:
  `native`), from bytes (`from_bytes`: Linux, macOS), from units
  (`from_units`: Windows), and from listings. Their `text` is partial
  (`NotText`), `display` lossy and for people only.

A native path is **not** a `std::io::path::Path`: its `text` can fail, and
the trait's `text` cannot (`fs-witnesses`: TRAIT-NOT-SATISFIED, the
conformance check citing the error contract). This is deliberate: nothing
portable can take a native name and silently decode it.

The portable listing, `FilePath.entries`, returns textual names, and fails
with `NotText` for a directory holding a name without text, rather than
skip or misname an entry (`fs-linux-native-roundtrip`,
`fs-windows-native-roundtrip`). Programs that must handle every name use the
platform module's `entries`, whose names are native.

## 6. Contexts and portable composition

**The path's type selects the filesystem, statically.** `FilePath`'s
witnesses implement its operations in their own modules by calling the
platform module's functions, which require the platform's context
(`LinuxFS`, `WindowsFS`, `DarwinFS`). Context requirements are derived
(CONTEXTS.md), so the requirement flows through every caller, and through
the trait monomorphization into the clone of a portable function for that
witness:

* a program that hands portable code a LinuxPath and installs no LinuxFS is
  **MISSING-CONTEXT** at compile time, found in the monomorphized program
  (`fs-missing-context-linux`, `-windows`);
* a program compiled for Linux cannot import std::windows at all
  (**UNSUPPORTED-PLATFORM**, `fs-wrong-platform`), and vice versa;
* a Windows-shaped witness of the application's own whose operations need
  their own context is MISSING-CONTEXT under LinuxFS alone, and runs once
  its context is installed (`fs-wrong-platform`): no run-time selection, no
  fallback, no SFINAE (an installed context never changes which function a
  call means).

Selection is the trait's ordinary static witness selection
(TRAITS.md): `save<LinuxPath>` and `save<WindowsPath>` are two clones, each
with direct calls (`fs-specialized-per-witness`). No dynamic dispatch exists
anywhere in the layer.

**What portable code cannot do: hold a file.** An opened file is an affine
value of its platform's own type (`std::linux::fs::File`,
`std::windows::fs::File`, `std::darwin::fs::File`). A trait requirement
cannot return a type that differs by witness -- Botlish has no associated
types -- so `FilePath` has no `open`: the portable layer is the
whole-file and directory operations, and streaming is the platform
modules'. This is the one place the design is bounded by the language
rather than chosen; section 15 records what an associated type would add.

**Why not a context trait.** A `context trait Filesystem` (CONTEXT-TRAITS.md)
was the other candidate for portability: one context trait, one
implementation per platform, portable code requiring it. It was rejected:
a context trait selects the installed implementation, not the path's
platform, so a portable function would still take a path of *some* type --
either text (losing the native layer) or a value of a trait over paths
(this design). With FilePath the path's type is the selection, and the
context is only the authority its operations need.

## 7. Files: modes, completion, enumeration

Each platform module has the same streaming API (std::linux::fs shown):

```
open(path, mode) -> File                     OpenMode: Read | Replace | CreateNew | Append
read(file, count: ReadSize) -> Read {file, data}       one read(2): short reads are ordinary
read_all(file) -> Read {file, data}          to the end of the file
write(file, data) -> Written {file, count}   one write(2): short writes are ordinary
write_all(file, data) -> File                every byte (short writes continued)
close(file)
read_file(path), write_file(path, data), create_file(path, data)
entries(dir) -> List[Entry {name: NativePath, kind}]
create_directory(path), remove_file(path), remove_directory(path)
```

* **Open modes** are explicit and mean the same on every platform: `Read`
  (NotFound otherwise), `Replace` (create or truncate), `CreateNew`
  (AlreadyExists when the name exists, never truncating: O_EXCL,
  CREATE_NEW), `Append` (create; every write at the end: O_APPEND,
  FILE_APPEND_DATA). Every descriptor is close-on-exec (O_CLOEXEC); Windows
  handles are not inheritable.
* **End of file** is a read of no bytes; `ReadSize` is 1..2^30, so no read
  ever asks for zero bytes and an empty result is unambiguous.
* **Completion**: `read` and `write` are one call each. `read_all`,
  `write_all` and the whole-file operations repeat until the end or until
  every byte is written; a write that makes no progress fails (Other) rather
  than loop. A short write is continued from the byte after what the kernel
  reports, never restarted (`fs-linux-fault-short-write`: strace injects a
  one-byte write, and the next write carries the remaining five bytes). A
  short read is no end of file (`fs-linux-short-reads`: a FIFO whose writer
  pauses between chunks). No retry of EINTR and no durability claim (no
  fsync, no FlushFileBuffers).
* **Failure paths close**: a read or write that fails closes its File
  (close's own result ignored) and fails with the operation's error, so an
  error never leaves an owner holding a broken File; the whole-file and
  directory operations close on every path (`fs-linux-fault-read`,
  `fs-linux-fault-enumeration`: strace's log shows the close after the
  injected failure).
* **Enumeration** lists every entry but `.` and `..`, in the system's order,
  with its kind as the listing says (`d_type`, the find data's attributes
  and reparse tag): File, Directory, SymbolicLink (a link itself, dangling
  or not), Other (a FIFO), Unknown (DT_UNKNOWN). Linux reads getdents64 into
  a 4 KiB buffer read back through a fixed layout array
  (FIXED-LAYOUT-ARRAYS.md) and walks the records in Botlish; Windows uses
  FindFirstFileW/FindNextFileW with the WIN32_FIND_DATAW layout; macOS
  opendir/readdir with a native view of `struct dirent`. An entry removed
  between the listing and its use is NotFound when opened
  (`fs-linux-disappearing`).

## 8. Affine ownership

A File is opaque and affine. Botlish has no declaration that makes a
struct affine, so a File's affinity comes from a field: on Windows its
HANDLE (a `std::ffi::c::Ptr`, affine by C-ABI-TYPES.md), on Linux and
macOS a `std::io::fs::Owner` beside the descriptor -- an affine token that
owns nothing and costs one word (a null C pointer no C call receives,
declared in the portable module: the Linux syscall side names no
`std::ffi::c`, C-POINTER-BORROWING.md's separation, which the macOS CI's
`cb-namespace-separation` caught on the first version). Only the standard
library makes one (`std::io::fs::owner` is an internal member). The ten
ownership experiments,
every one a compile-time test on both platforms (`fs-ownership-*`):

| # | experiment | outcome |
|---|---|---|
| 1 | use a File after closing it | USE-AFTER-MOVE |
| 2 | bind a File to a second name, use the first | USE-AFTER-MOVE |
| 3 | give a File to a function, use it after | USE-AFTER-MOVE |
| 4 | return a File, take it back from a call, store it in a struct, destructure it | accepted: ownership moves through all of them |
| 5 | compare two Files | AFFINE-EQUALITY-UNSUPPORTED |
| 6 | capture a File in a closure | AFFINE-CAPTURE-UNSUPPORTED |
| 7 | pass a File where `any` is expected | AFFINE-ERASURE-UNSUPPORTED |
| 8 | make a File the program's result | AFFINE-ERASURE-UNSUPPORTED ("a result is shown, never owned") |
| 9 | read a File's descriptor or build one outside its module | OPAQUE-REPRESENTATION, OPAQUE-CONSTRUCTION |
| 10 | keep a File in a context and use it from a contextual function | installation moves it in; using it by value is AFFINE-CONTEXT-COPY-OUT |

And what affinity does **not** give (`fs-ownership-gaps`): a File dropped
unclosed -- by an early `return`, by a call that fails while the File is
owned, at the end of its owner -- compiles with no diagnostic and runs no
cleanup. The descriptor leaks until the process ends. Affinity is "at most
once", not "exactly once" (AFFINE-VALUES.md), and the language releases an
affine value without running code. The library therefore closes on every
path it controls, and the documentation says "close every File you open".

No RAII is claimed. What a resource feature would need, from these
experiments:

1. **Must-consume values** (or a drop action): a value whose loss is a
   compile-time error, or code that runs when it is lost. Affinity already
   tracks every release point (`hir::affine::Releases`, `ExitReleases`); it
   would have to call something there.
2. **Release on error edges**: when a call fails while a File is owned, the
   error edge already releases affine values (`ReleasingOnError`); a drop
   action would run there too.
3. **Borrowing for operations**: every operation takes the File and gives
   it back (`Read {file, data}`), because a place parameter cannot be affine
   (PLACE-PARAMETERS.md). An operation that observes its receiver without
   moving it would remove the threading.
4. **A declaration that makes a struct affine** without a dummy pointer
   field.
5. **Scoped acquisition** (a block that opens and is guaranteed to close),
   which needs 1 and 2.

## 9. Errors

* `std::io::path::NotAPath`: validation -- a String that is no path of the
  platform, a component that cannot be joined. Never a filesystem failure.
* `std::io::path::NotText`: a native name without a String.
* `std::io::fs::FileError {reason, code}`: an operation the system refused.
  `reason` is the portable `Reason` (NotFound, AlreadyExists,
  PermissionDenied, NotADirectory, IsADirectory, NotEmpty, InvalidName,
  Busy, ResourceExhausted, Other); `code` the native one, exactly: Linux's
  errno (from the syscall's negative result: no thread-local is read),
  macOS's errno (read through `__error()` right after the failed call),
  Windows' `GetLastError()`, read right after the failed call before
  anything else is called. The tests pin both for every case they make
  (`fs-linux-directory-failures`, `fs-windows-directory-failures`,
  `fs-darwin-directory-failures`).
* Where the systems disagree, the reason follows the meaning and the code
  keeps the system's word: Windows reports a directory opened as a file, and
  a directory given to DeleteFileW, as ERROR_ACCESS_DENIED (5); when the
  path then names a directory (GetFileAttributesW, asked after the code was
  read) the reason is IsADirectory and the code still 5. macOS's unlink of a
  directory is EPERM (1): IsADirectory, code 1.

## 10. Authority

The raw layers stay behind their contexts:

* **Linux**: `std::linux` is a designated direct module (DIRECT-MODULES.md).
  Every std::linux::fs function that makes a syscall requires `LinuxFS`, so
  the authority reaches callers only as that context, and nothing above
  std::linux::fs is direct for using it. An application module calling
  `std::linux::openat` itself is DIRECT unless it says `direct module`
  (`fs-authority-airlock`).
* **Windows and macOS**: C calls whose pointer parameters are noescape are
  no direct edges ("Foreign is not direct", DIRECT-MODULES.md), so the
  contexts are these modules' design: the Win32 and libSystem declarations
  are `private` (PRIVATE-ACCESS from outside), every public function that
  names a path requires the context, and no public function takes a raw
  handle (`fs-authority-context`). A Windows File's operations need no
  context: the HANDLE is the capability.
* **The unchecked constructors** (`of_valid_text`, which makes a native path
  without validation for a path already proven valid) are internal members
  of the standard library (INTERNAL-NAMESPACE from a program).

An honest limit: any module may declare kernel32's `CreateFileW` itself
(an `extern c fn` is ordinary source), and it then has the authority any C
declaration has. The airlock is the library's, not a sandbox.

## 11. macOS

std::darwin::fs implements the same API through libSystem (`open` with its
genuine variadic prototype and the creation mode as its trailing argument,
`read`, `write`, `close`, `mkdir`, `unlink`, `rmdir`, `opendir`, `readdir`,
`closedir`), errno read through `__error()` right after each failure
(std::darwin's discipline, MACOS-AARCH64-MILESTONE-8.md), and readdir's end
told from its failure by clearing errno first (a native edit of the errno
cell). DarwinPath satisfies FilePath. Its execution tests (`fs-darwin-*`,
darwinIO) run in the macOS acceptance tier; every program is type-checked
for macos-aarch64 on every host (`fs-darwin-programs-compile`).

## 12. Findings

### 12.1 A method-call decision defect (fixed)

`v.concat(a).concat(b)` on a native path was rejected with
TRAIT-NOT-SATISFIED. The candidates of each `concat` are
`std::io::path::concat` (trait-polymorphic over `Path`), the platform's
`concat` and `std::str::concat`. The first build stands every call at its
first candidate; the inner call at `std::io::path::concat` returns a *view*
of `Path`, so the outer call is typed as a trait operation there.
`hir::methods::Fix` added the trait operations of every build to the fixed
calls and never removed them, so when the inner call moved to the
platform's `concat` (the only applicable candidate), the outer call stayed
the trait's -- a decision made from a stand-in, which the rule forbids
(METHOD-RESOLUTION-CORRECTNESS-MILESTONE-1.md, "Relative to the decided
program"). Fixed: the trait operations are recomputed from each build (a
call is the trait's only in a configuration whose build types it as one);
a call that stops being one is open again and certified like any other.
Regression test `mr-trait-stand-in-decides-nothing` (tests/method-resolution.test;
fails before the fix), mutant `trait-stand-in-latched`
(audit/method-resolution/tools/mutants.txt); the independent oracle agrees
over 200 seeds and 200 with contexts; tests/method-resolution.test,
method-filter.test, method-sugar.test, traits.test, static-economics.test
and static-compile.test pass; the static-decisions comparison runs in CI.

### 12.2 A trait-plan defect (recorded, not fixed)

A trait, its witness and the witness's implementation all in the entry
program, the implementation's body needing a context **trait** (std::io::IO
through `std::io::print_line`), is an internal error on every backend:
`malformed IR: trait plan: entry-program binding "show" is not established
here` (CORE MALFORMED). With a context struct, or no context, the same
program runs. Reproducer:
audit/filesystem/findings/trait-plan-entry-context-trait.bot. std::io::fs is
not affected (its witnesses and their implementations live in their own
modules, and the contexts they need are structs); it is out of this
milestone's scope and left for the trait plan's owner.

### 12.3 Language friction met writing the library

Recorded as evidence, worked around in the code, not changed:

* no anonymous functions: element-wise transformations are loops;
* `if` and `loop` values only as the whole right side of `=` or `return`
  (helpers like `kind_name` exist for it);
* no rebinding of a local: state across iterations is a mutable vector or
  recursion (`chunk_size(std::mutable_vector::length(parts))` sizes
  read_rest's reads by how many it has made);
* no integer division (shift and `mod`), no `-> never` result, and a helper
  that always fails is KNOWN-ERROR wherever it is called, so every failure
  is spelled at its site;
* a list literal of Ints is no `List[Byte]` (`std::byte::from_int` per
  element);
* a handler on a call does not cover the calls in its arguments;
* method-style calls with several visible candidates cost whole-program
  builds per call (METHOD-RESOLUTION-CORRECTNESS-MILESTONE-1.md): the
  first versions of the platform modules took 10 to 29 seconds to compile;
  writing the ambiguous calls qualified (`std::linux::close(fd)`) and the
  helpers `private` (invisible to importers' method syntax) brought them to
  2 to 3 seconds.

## 13. Tests, fuzzing, mutation testing, CI

### 13.1 tests/filesystem.test

58 tests (KEEP-INTERNAL census rows: compiler output, multi-file
applications, host filesystems and processes):

* **front end, every host**: the portable surface; witnesses and
  non-witnesses; MISSING-CONTEXT per platform; UNSUPPORTED-PLATFORM; the
  per-witness clone; authority and the airlock; the ten ownership
  experiments and the gaps; native paths (Linux bytes, Windows units, UTF-8
  and UTF-16 strictness, display); Windows kinds and joins (34 + 110
  cases); the Tcl backends' NATIVE-ONLY refusal; no watcher or asynchronous
  API in the standard library; every Windows and macOS program compiled for
  its target;
* **Linux execution** (nativeLinux; native backends): round trips, modes,
  a 3 MiB file, entries and kinds (a FIFO, links, a dangling link), native
  names, paths as written, every directory failure with its errno,
  permissions, entries that disappear, short reads from a FIFO, portable
  code over a LinuxPath, a standalone executable (and under GC stress),
  every operation under GC stress, and three strace fault injections
  (getdents64 EIO, a one-byte write, read EINTR);
* **Windows execution** (windowsIO): the same through kernel32 on NTFS,
  plus case-insensitive names, verbatim trailing periods, sharing against
  an exclusive opener (another process), a path past MAX_PATH;
* **macOS execution** (darwinIO): the same through libSystem on APFS, plus
  APFS's name rules.

Local result (real Linux x86-64): 58 tests, 40 passed, 18 skipped (the ten
windowsIO and seven darwinIO tests, and `fs-linux-permission`, which needs a
user that is not root), 0 failed.

### 13.2 Fuzzing

`audit/filesystem/tools/fuzz.tcl`: three parts.

* `windows`: random (base, component) pairs from Win32's syntax (drive
  designators, `\`, `/`, UNC, device and verbatim prefixes, `.`, `..`,
  trailing periods and spaces, `:`, non-ASCII and astral characters) and
  random UTF-16 unit sequences with unpaired surrogates, against the tool's
  own model of the rules (never the library's code): kinds, concat, native
  join, text, display. Compiled for windows-x86_64 and run on the Tcl
  backends: no Windows needed.
* `linux`: the same for LinuxPath's concat and NativePath's join and random
  byte strings (some not UTF-8).
* `files` (Linux): random file names of 1-12 bytes (anything but 0 and `/`)
  made, listed and read back through native names on the native backends:
  the lossless round trip.

Result (real Linux): `-n 200`, seeds 1 to 5, every part: 2000 cases each,
0 disagreements; the files part with `-n 100 -seed 9 -gc-stress 1` on both
native backends: 200 cases, 0 disagreements. The mutation run below also
showed the generator's first version too weak to build an exact `..`
segment under a verbatim base or a `//?/` device prefix (filesystem.test
killed those mutants, the fuzzer did not): paths are now built from
segments joined by random separators, and the fuzzer kills both.

### 13.3 Mutation testing

`audit/filesystem/tools/mutate.tcl` with 26 mutants in
audit/filesystem/tools/mutants.txt -- Windows syntax (drive-relative joined
as absolute, a separator always inserted, `..` under verbatim, a trailing
period accepted, `//?/` read as UNC), lossy decoding (a surrogate name given
text, Linux bytes given text, Tcl's decoder replacing), enumeration losing
native names (Linux, Windows), `.`/`..` listed, d_type swapped, a failed
enumeration or read leaking its descriptor, a short read taken as the end,
a short write as complete or restarted, a reason lost, a copyable File, the
context bypassed, a Win32 declaration public, an internal constructor
public, std::windows no platform's, and GetLastError read after another
Win32 call. Three are a host's own (`%% HOST`, skipped elsewhere): the
Windows enumeration and GetLastError mutants (`windows-x86_64`) and `.`/`..`
listed by std::darwin::fs (`macos-aarch64`). Each mutant is killed first by
the fuzzer (`-n 60`), else by filesystem.test.

Result:

* **real Linux** (this container, the whole list): 23 of 23 applicable
  mutants killed, 3 skipped as another host's -- 10 by the fuzzer (the
  Windows syntax and lossy-decoding mutants by the path models, Linux
  enumeration and `.`/`..` by the files part's round trip), 13 by
  filesystem.test (`fs-windows-concat`, `fs-authority-context`,
  `fs-authority-airlock` twice, `fs-linux-entries-kinds`,
  `fs-linux-fault-enumeration`, `fs-linux-short-reads`,
  `fs-linux-fault-short-write` twice, `fs-linux-fault-read`,
  `fs-linux-directory-failures`, the four `fs-ownership-*` experiments for
  a copyable File, `fs-wrong-platform`). None survived, none failed to
  apply.
* **macOS** (run 40799420498, the tier item `filesystem-mutants=...`):
  `darwin-dot-entries-listed` killed by `fs-darwin-entries`,
  `fs-darwin-executable`, `fs-darwin-names` and `fs-darwin-portable`.
* **real Windows** (run 40799420515, the same tier item):
  `win-enumeration-loses-native-name` killed by
  `fs-windows-native-roundtrip` (the name with an unpaired surrogate no
  longer reopened its file), `win-last-error-read-late` killed by
  `fs-windows-directory-failures`, `fs-windows-long-path`,
  `fs-windows-modes` and `fs-windows-sharing` (each pins a failure's
  native code, which a GetLastError read after another Win32 call no longer
  reports).

### 13.4 CI

Every run below is on the branch; the final code state is commit
0630321a (the commits after it change only this report).

* `windows-x86_64.yml`: filesystem.test and abi-bytes.test in the smoke
  tier; filesystem.test's Windows tests once more under GC stress; and with
  the system linker. **Run 40799420515: success**, every job -- among
  them the smoke job (the smoke tier with filesystem.test, the filesystem
  GC-stress step) and the `[ci-full]` tier items (the benchmark, the
  fuzzer, the Windows mutants: sections 13.2, 13.3, 14).
* `macos-arm64.yml`: the acceptance tier and the system linker run
  filesystem.test (darwinIO: the macOS execution tests, executables
  included). **Run 40799420498: success**, every job -- among them the
  `[ci-full]` tier items (sections 13.2, 13.3, 14).
* `tests.yml`: every test on Linux x86-64 (interp, compile, the cranelift
  and cranelift-generic coverage, the stub- and system-linked executables
  -- the system-linked ones also under GC stress -- the golden suites, the
  warning gate, the method-call oracle and reference audit, the Rust unit
  tests). **Run 40799446825: success**, every job.
* `tests-arm64.yml`: the same on Linux AArch64 (std::linux::fs's syscalls
  through the AArch64 transport), plus the whole Tcl suite under GC stress.
  **Run 40799449814: success**, every job (interp, compile, both coverage
  jobs, the system-linked executables also under GC stress, the golden
  suites, the Rust unit tests also under GC stress, the GC-stress suite).
* `static-decisions.yml`, dispatched on the branch for the method-decision
  fix (hir/methods.tcl; commit cb771b6f, which holds it): **run
  40787729341: success**, every golden suite's static decisions equal under
  the batched and the sequential scheduler. The later commits change no
  front-end decision (the standard library's filesystem modules, which no
  golden suite imports, and tests).

The first full CI round (commit cb771b6f) failed three tests on every host,
all fixed by 0630321a: `cb-namespace-separation` (std::linux::fs named
std::ffi::c for its File's affine token: the token became std::io::fs::Owner,
section 8), and `nerr-stdlib-identities` and the golden suite
declared-errors-imports, which pin std::io::path's error set (it gained
NotText).

## 14. Performance

`bench/filesystem.tcl` on the host's platform: each row a program running
its operation in a loop, best of 5 runs inside one process (no compilation,
link or process start in a row), per iteration, minus the same loop without
the operation. Linux: this container (real Linux, ext4, x86-64, the machine
otherwise idle); macOS: a `macos-15` runner (APFS, arm64; run 40799420498);
Windows: a `windows-2025` runner (NTFS; run 40799420515) -- both the tier
item `filesystem-bench`. Shared runners and a container are noisy machines: read
the rows as orders of magnitude and ratios, not as fixed costs.

| per operation | Linux (raw syscalls) | macOS (libSystem) | Windows (kernel32) |
|---|---:|---:|---:|
| validate + native (40 characters) | 267 ns | 239 ns | 3.56 us |
| concat (text) | 221 ns | 292 ns | 22.3 us |
| join (native) | 2.58 us | 2.90 us | 6.99 us |
| text (native) | 168 ns | 229 ns | 11.7 us |
| open + close | 1.76 us | 6.74 us | 26.4 us |
| write_file 64 B (replace) | 159 us | 173 us | 195 us |
| read_file 64 B | 6.4 us | 11.8 us | 54.1 us |
| portable write 64 B (FilePath) | 129 us | 153 us | 204 us |
| write_file 1 MiB | 803 us | 758 us | 448 us |
| read_file 1 MiB | 552 us | 598 us | 2.42 ms |
| entries, per entry (100) | 1.48 us | 1.29 us | 7.50 us |
| reopen through the native name, per entry (100) | 11.2 us | 19.4 us | 68.0 us |

What the rows say:

* **The portable layer costs nothing.** `portable write` is `write_file`
  called through `std::io::fs::FilePath` -- the clone per witness -- and
  is within the run-to-run noise of the direct call on every host (lower on
  Linux and macOS, 5% higher on Windows; a replace is dominated by the
  kernel's truncation of the existing file, which varies run to run:
  Python's `open(path, "wb").write(64 bytes)` measured 121 us on the same
  Linux container). No dispatch is left to cost anything
  (`fs-specialized-per-witness`).
* **System calls dominate everything that touches the filesystem.** open +
  close is two syscalls on Linux (1.8 us) and two libSystem calls on macOS
  (6.7 us); a 1 MiB read or write is memory bandwidth plus the kernel copy
  (0.55 to 0.8 ms per MiB).
* **Reading a small file costs 6.4 us on Linux,** open, one read that
  returns 64 bytes, one that returns 0 (the end), close. The first version
  read in fixed 1 MiB requests and took 13.7 us: allocating 1 MiB of
  storage per chunk. Reads now ask for 4 KiB first and double per chunk up
  to 1 MiB (`chunk_size`, every platform module), which halved it and
  keeps large files at large requests.
* **A native join is ten times a textual concat** (2.6 us against 0.22 us):
  std::io::bytepath validates the name and builds the joined List[Byte]
  element by element in Botlish (`joined`), while a textual concat is
  string concatenation. It is still per-path microseconds, far below one
  syscall of the operation that uses the path; a byte-storage primitive
  (`std::abi::bytes::join` exists for Bytes; native paths are List[Byte])
  would remove it if it ever matters.
* **Windows' textual paths cost microseconds, not nanoseconds** -- the one
  real cost this milestone measured. `validate + native` (3.6 us) and
  `text` (11.7 us) convert between a String and UTF-16 code units in
  Botlish, a list pass per step over boxed Ints (`utf16`; `scalars`, the
  unpaired-surrogate scan, `utf8_of`, `decoded`), where Linux's and macOS's
  conversions are the byte-storage primitives (`encode_utf8`,
  `decode_utf8`: 0.2 us). A textual `concat` (22.3 us) is defined through
  the native join -- Windows' syntax is stated once, over code units
  (section 3) -- so it pays text to units, the join, units back to text
  and the result's validation. That is about one open + close (26 us) per
  concat: noticeable in a path-heavy loop, invisible beside the file
  operation the path is for. The fix is a byte-storage primitive pair for
  UTF-16 (`std::abi::bytes` has UTF-8's), not a second statement of the
  syntax on Strings; it is the first item of "Next" (section 15).
* **Windows' file calls cost more per call** (open + close 26 us,
  enumeration 7.5 us per entry, a small read 54 us): kernel32's
  CreateFileW, FindFirstFileW and CloseHandle on a shared runner's NTFS,
  which this milestone measured but did not break down. A 1 MiB write (448 us) is the fastest of
  the three hosts; a 1 MiB read (2.4 ms) the slowest -- the read's growing
  chunks (4 KiB doubling to 1 MiB: about 2 MiB of zeroed storage for a
  1 MiB file, then the join) cost more there; the cause was not isolated
  further.
* **Enumeration costs 1.3 to 1.5 us per entry on Linux and macOS** (on Linux, getdents64's
  4 KiB buffer read back as one byte list through a layout,
  `std::binary::read`, and each record's length, type and name decoded
  from it; on macOS readdir's records read through a native view), and
  re-reading each entry through its native name 11 to 19 us (68 us on
  Windows): the cost of
  open, read, read, close per entry, which is the price of the lossless
  round trip being real file operations, not a property of the path
  representation.

## 15. Not here, remaining limitations, next

**Not here, deliberately** (the milestone's exclusions): no file watching
(no inotify, fanotify, ReadDirectoryChangesW, FSEvents or kqueue), no event
loop, no asynchronous I/O, IOCP, epoll or cancellation, no scheduler, no
resource feature or destructor, no virtual filesystem or sandbox, no
memory mapping, no POSIX layer on Windows (std::windows::fs calls kernel32,
never the C runtime), no complete Win32 wrapper (twelve kernel32 functions),
no metadata, links, renaming or permissions API. `fs-no-watchers` checks the
standard library names none of those APIs.

**Remaining limitations**:

* no portable streaming: FilePath has no `open` until Botlish has
  associated types (or another way for a requirement to return a
  per-witness type);
* a File dropped unclosed leaks (section 8);
* the trait-plan defect of section 12.2;
* native joins walk byte lists in Botlish, and Windows' conversions
  between Strings and UTF-16 units are Botlish list passes: a Windows
  textual concat costs about one open + close (section 14);
* reserved device names are documented, not refused (they are valid syntax,
  and which names are devices depends on the Windows version: W3);
* the airlock is the library's convention on Windows and macOS (section 10).

**Next**: a UTF-16 byte-storage primitive pair (encode a String to code
units, decode units strictly to a String), which removes the Windows path
costs of section 14 without restating the syntax; associated types for a
portable `open`; a resource feature (section 8's five requirements);
metadata (`stat`, GetFileInformationByHandle) and renaming, which are the
next operations programs ask for.

## 16. What to run when changing this

If you change std::io::fs, std::io::bytepath, std::linux::fs,
std::windows::fs, std::windows::path, std::darwin::fs, the path modules'
FilePath implementations, the Linux path syscalls, or `std::abi::bytes::join`,
`slice` or `decode_utf8`:

* `tclsh9.0 tests/filesystem.test` (the Windows and macOS tests on their
  hosts: the Windows workflow's smoke and GC-stress steps, the macOS
  acceptance tier), `tests/linux-path.test`, `tests/portable-io.test`,
  `tests/darwin-io.test`, `tests/windows-io.test`, `tests/abi-bytes.test`,
  `tests/abi-mutable-bytes.test`, `tests/linux-syscall.test`;
* `tclsh9.0 audit/filesystem/tools/fuzz.tcl` (several seeds; once with
  `-gc-stress 1`);
* `tclsh9.0 audit/filesystem/tools/mutate.tcl` (every mutant in its
  `mutants.txt` that applies to the host must still apply and be killed:
  update a mutant's text when you change the code it mutates, keeping it a
  mutant of the same rule; the `%% windows-x86_64` mutants on Windows, the
  `%% macos-aarch64` one on macOS: the tier item `filesystem-mutants`);
* the warning gate (`audit/refactor/tools/gate.tcl`) and
  `tools/compilerpedia.tcl check`;
* `bench/filesystem.tcl` regenerates section 14;
* the experiments (`audit/filesystem/experiments/linux.tcl`, and
  `windows.tcl` through `windows-fs-probe.yml`) when a rule they decided is
  questioned.
