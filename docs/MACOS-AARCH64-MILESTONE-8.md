# MACOS-AARCH64-MILESTONE-8.md

Milestone 8 of the macOS Apple Silicon port: Darwin IO -- the process's
standard streams and minimal file IO on `macos-aarch64` through Apple's
public C library, libSystem, behind the portable `io::IO` context trait
(CONTEXT-TRAITS.md). Developed on Linux; every macOS fact below was observed
on GitHub's `macos-15` arm64 runners through
`.github/workflows/macos-arm64.yml` (the shared Apple Silicon development
machine was not used). The audit it updates is MACOS-AARCH64-PORT-AUDIT.md
(its roadmap entry 9); the milestones before it are
MACOS-AARCH64-MILESTONE-1.md to -7.md.

> Don't port Linux's syscalls to macOS. Port the Botlish library's
> implementation of the same useful operations. Keep the portable contract
> stable, let libSystem own Darwin's kernel boundary, and let Botlish's
> existing type, borrowing and context mechanisms enforce everything around
> it.

## Result

```botlish
import io
import darwin::io

fn hello() errors io::WriteFailed:
    io::print_line("Hello, world!")

with context darwin::io::create()

hello():
    on io::WriteFailed:
        unit
```

examples/io/hello-darwin.bot is examples/io/hello.bot with another context:
`hello` is the same function, and on macOS it compiles to a direct call of
`darwin::io::write_text`, which calls libSystem's `write(2)` with the UTF-8
bytes exposed for that call (`read noescape`). A standalone Mach-O
executable of it prints `Hello, world!` with nothing but system libraries
(`di-hello-executable` and the native-status probe `darwin-executable`,
macOS run
[39593142355](https://github.com/mwagner-webdev/botlish/actions/runs/39593142355);
every macOS result below is that run's, at 7bdd5e2, unless another run is
named).

No runtime, C ABI or lowering code changed; the front end changed by one row
of the platform table and the wording of its diagnostic. The milestone is
three library modules, that row, tests and tools:

* **core/cabi.tcl**: `darwin` is designated the macOS platform's namespace
  (`platforms`), so `darwin` and everything under it are UNSUPPORTED-PLATFORM
  for every other target, exactly as `linux` is for non-Linux targets.
* **lib/darwin.bot** (a direct module): libSystem's `write`, `read`, `open`,
  `close` and `__error` by their C prototypes, and thin wrappers -- one C call
  each, the C result and, on failure only, the errno it left.
* **lib/darwin/io.bot**: the opaque `DarwinIO` context of the three standard
  descriptors, implementing `io::IO` structurally with LinuxIO's completion
  policy.
* **lib/darwin/path.bot**: `DarwinPath`, the textual path open(2) receives
  as UTF-8 and one NUL.
* **tests/darwin-io.test** (27 tests), native-status probes, 19 mutants, a
  benchmark, and the 2048 demo on both platforms.

## 1. Prerequisites from milestone 7

| needed | from |
|---|---|
| C calls link and run on macOS AArch64, both native backends and executables | milestone 6 (C-FFI.md on Apple's toolchain) |
| `read noescape` exposure: write(2)'s buffer, no copy | milestone 7 (bb-read-*, bb-system-library) |
| `write noescape` exposure: read(2)'s buffer, a private copy returned as the write-back value | milestone 7 (bb-write-*) |
| exposures stay live through the call under GC stress and in coroutines | milestone 7 (bb-gc-stress, bb-coroutines) |
| a C pointer result (`__error()`'s) carried in all 64 bits | milestone 6 (cf-pointer-width) |
| a native layout view of a C pointer (NATIVE-LAYOUT-VIEWS.md) | native-view.test on macOS: its C oracle since milestone 6, its allocation and GC-stress tests since milestone 7 |
| a variadic C call with Apple's stack placement of trailing arguments | VARIADICS-VERTICAL-SLICE-1.md, checked on macOS in milestone 6 (`cf-va-*`) |
| Mach-O executables, the `NATIVE TARGET` refusal | milestones 5 and 2 |

Milestone 7's report records that byte borrowing needed no change on macOS;
Darwin IO uses exactly those two exposures.

## 2. The Linux IO architecture this milestone started from

```text
io::print_line ---> io::IO (context trait, lib/io.bot)
                       |  selected statically: the one installed context implementing it
                       v
             linux::io::LinuxIO (opaque context: stdin, stdout, stderr FileDescriptors)
             write_text --> write_all (short writes completed; failure, no progress: WriteFailed)
                       |
                       v
             linux::write / linux::read (lib/linux.bot: the raw kernel result, -errno on failure)
                       |
                       v
             linux::sys (lib/linux/sys.ARCH.bot) --> linux::abi::ARCH::syscall (transport)
```

`linux` is the Linux platform's namespace in core/cabi.tcl's `platforms`
table (MACOS-AARCH64-MILESTONE-2.md); `linux::io` is contextualized (its
direct calls mediated by its own LinuxIO); `io` is ordinary and knows no
platform. The portable surface is outcome-oriented: unit or
`io::WriteFailed`, never a count or errno.

## 3. The Darwin platform namespace

`core::cabi::platforms` is now `linux -> linux, darwin -> macos`. The
designation is the table's, never the namespace's spelling: `PlatformCheck`
(surface/modules.tcl) reads the root of an imported namespace, finds its
platform's operating system and refuses the import for a target of another
one. Its message names the root that carries the designation:

```text
namespace "darwin::io" belongs to the macOS platform (the standard namespace
darwin and every namespace under it), which is unavailable for target
linux-x86_64 (Linux on x86_64): a macOS module is never chosen for, mapped
to or substituted on another operating system, whatever the architecture;
compile for a macOS target (-target macos-x86_64) or import no macOS
namespace (SURFACE MODULE UNSUPPORTED-PLATFORM)
```

(previously the parenthesis read "the standard namespace linux" for every
platform; there was only one.) The namespaces: `darwin` (lib/darwin.bot),
`darwin::io` (lib/darwin/io.bot), `darwin::path` (lib/darwin/path.bot).
None is architecture-specific: libSystem's prototypes are the same on arm64
and x86-64 macOS, so there is no `darwin.ARCH.bot` and the loader's
architecture rule is not involved. `macos-x86_64` is a macOS target too: a
Darwin program compiles for it (`di-platform-rule`), though no native
backend runs there.

The rule has no way around it (`di-platform-no-way-around`): a type import
of a Darwin namespace is refused like an import; a Darwin program's HIR
records `macos-aarch64` and its interchange text is refused for any other
target (`HIR INTERCHANGE TARGET`); a native backend refuses to run it on a
host of another target (`NATIVE TARGET`). The Linux platform's namespaces
stay refused for macOS, and a namespace merely named like a system belongs
to no platform.

## 4. libSystem C declarations

```botlish
extern c fn c_errno_location named "__error"() -> ffi::c::Ptr[ffi::c::Int] independent
extern c fn c_write named "write"(fd: ffi::c::Int, buf: ffi::c::Ptr[ffi::c::Void] read noescape, nbyte: ffi::c::ULong) -> ffi::c::Long
extern c fn c_read named "read"(fd: ffi::c::Int, buf: ffi::c::Ptr[ffi::c::Void] write noescape, nbyte: ffi::c::ULong) -> ffi::c::Long
extern c fn c_open named "open"(path: ffi::c::Ptr[ffi::c::Char] read noescape, oflag: ffi::c::Int, variadic) -> ffi::c::Int
extern c fn c_close named "close"(fd: ffi::c::Int) -> ffi::c::Int
```

The SDK's prototypes (`<unistd.h>`, `<fcntl.h>`, `<sys/errno.h>`):
`ssize_t write(int, const void *, size_t)`, `ssize_t read(int, void *,
size_t)`, `int open(const char *, int, ...)`, `int close(int)`, `int
*__error(void)`. On macOS AArch64 (LP64, core/cabi.tcl's row, checked
against Apple clang in milestone 2): `int` is 32 bits (`ffi::c::Int`),
`size_t` is `unsigned long` (`ffi::c::ULong`), `ssize_t` is `long`
(`ffi::c::Long`), pointers 64 bits. The NIR records them so:

```text
foreign 0 "write" params="i32 ptr u64" result=i64 name="darwin::c_write"
foreign 1 "__error" params="" result=ptr name="darwin::c_errno_location"
```

`di-c-declarations` pins every declaration's NIR line and contract;
`di-sdk-facts` (macOS) compiles a C probe against the runner's SDK and
compares: the open flags (`O_RDONLY` 0, `O_WRONLY` 1, `O_RDWR` 2, `O_CREAT`
0x200, `O_TRUNC` 0x400, `O_EXCL` 0x800, `O_CLOEXEC` 0x1000000 -- macOS's,
not Linux's), the errno values the tests expect, `mode_t` unsigned 16 bits,
`size_t` and `ssize_t`, and the link symbols Apple clang's own calls use
(`_write`, `_read`, `_open`, `_close`, `___error`: the declarations' names
with Mach-O's underscore, which the object writer adds). No `extern c
library` is declared: libSystem is in the system link of every macOS
executable, and the C calls bind to it (`di-hello-executable` reads `otool
-L`: system libraries only, libSystem among them).

## 5. C byte-borrowing contracts

| parameter | contract | why |
|---|---|---|
| write's `buf` | `read noescape` | write(2) reads `nbyte` bytes during the call and keeps nothing (POSIX) |
| read's `buf` | `write noescape` | read(2) writes at most `nbyte` bytes during the call and keeps nothing |
| open's `path` | `read noescape` | open(2) reads the NUL-terminated name during the call |

Each fact is declared by the binding's author from the functions' documented
behavior, as C-POINTER-BORROWING.md requires: no fact comes from `const`, a
name or a header. They are the milestone 7 exposures, unchanged:

* **write**: the Bytes' own storage, exposed as it is (`op bytesaddr`), kept
  alive after the call (`op keepalive`): no copy.
* **read**: a private copy of the caller's MutableBytes (`op mbytesclone`,
  the detach), exposed for writing; the copy is the write-back value's
  `buf`, which `darwin::read` returns as `ReadResult.data`. The caller's
  buffer never changes (`di-stdin` checks it after every read).
* **open**: the C string (section 9), built for the call and exposed for it
  alone.

The count is never a separate argument a caller could get wrong:
`darwin::write(fd, data)` passes `abi::bytes::length(data).value`, an
`abi::Usize`'s value, which on a 64-bit target is proven a `ffi::c::ULong`
with no run-time check (mutant `darwin-write-count-mismatch`).

## 6. read and write

```botlish
fn write(fd: ffi::c::Int, data: abi::bytes::Bytes) -> WriteResult:
    n = fd.c_write(data, abi::bytes::length(data).value)
    if n < 0:
        failure = errno()
        return WriteResult {count: n, errno: failure}
    WriteResult {count: n, errno: 0}

fn read(fd: ffi::c::Int, data: abi::bytes::MutableBytes) -> ReadResult:
    r = fd.c_read(data, abi::bytes::mutable_length(data).value)
    if r.result < 0:
        failure = errno()
        return ReadResult {count: r.result, errno: failure, data: r.buf}
    ReadResult {count: r.result, errno: 0, data: r.buf}
```

One C call per operation; no loop, no retry, no buffering. A result keeps
the three outcomes apart: a count (`> 0`, or a short write or read), `0`
(end of file for read, no progress for write) and `-1` with the errno. The
errno is 0 exactly when the call succeeded: it is never read after a
success, where its value means nothing (mutant `darwin-errno-on-success`).
`open`, `create`, `create_new` and `close` follow the same shape
(`OpenResult {fd, errno}`, `CloseResult {status, errno}`).

Darwin's convention is not Linux's: Linux's raw syscall returns `-errno` in
the result register (linux::write's `-9` for EBADF), Darwin's C function
returns `-1` and leaves the reason in errno. Nothing here encodes an errno
in a count (mutant `darwin-linux-error-convention`).

The result structs cost nothing natively: escape analysis returns them as
scalars (`retmulti`), so `darwin::write` builds no object:

```text
func 4 "darwin::write" params=2 ... results=2
    %2 = callmulti 2 %1                  ; abi::bytes::length(data)
    %3 = op bytesaddr %1                 ; the storage's payload address
    %4 = foreigncall 0 %0 %3 %2 exposed=1
    %5 = op keepalive %1
    ...
    %8 = op ilt %4 %6                    ; n < 0
    br %8 L0 L1
  label L0
    %10 = call 3                         ; errno()
    retmulti %4 %10
  ...
    retmulti %4 %12                      ; {n, 0}
```

## 7. errno

errno is per thread: `<sys/errno.h>` defines `errno` as `(*__error())`.
`darwin::errno()` calls `__error()` and reads the `int` it points to through
a native view of a one-field layout:

```botlish
layout ErrnoCell:
    size 4
    align 4
    field value: ffi::c::Int at 0

fn errno() -> int:
    location = c_errno_location()
    cell = binary::native::view(ErrnoCell, location):
        on NativeViewNull:
            return 0
    cell.value
```

No pointer dereference operator, no pointer arithmetic, no stored pointer:
the view is a word used once (its NIR is one `foreigncall` and one
`nativeload` at offset 0 of width `int`). `__error()` never returns null;
the handler exists because a view of a null pointer is a declared error.

**Ordering.** For a C call with a failure sentinel the wrappers call the
function, compare its result, and on failure call `errno()` before
anything else. `di-errno-read-first` reads the NIR of every wrapper and
pins the operations, calls and allocations between the C call and
`errno()`:

| wrapper | between the C call and `errno()` |
|---|---|
| write | `keepalive` of the buffer, the comparison (`ilt`) |
| open (`open_with`; `open_mode`, behind create and create_new) | `keepalive` of the C string, the result's unboxing to a raw int (`runbox`), the comparison (`rilt`) |
| close | `runbox`, `rilt` |
| read | `keepalive`, **two `structnew`s** (the write-back value: the copy's MutableBytes and the `{result, buf}` struct), a `structget`, the comparison |

None but read's allocates or calls anything.

`read` is the one exception, and it is a real one. Native lowering builds a
write exposure's write-back value right after the call (native/lower.tcl's
`BorrowCall`), and every heap object is allocated with the system
allocator: two small `malloc`s (and, when the heap is due, a collection,
whose frees go to `free`) run before the errno read. POSIX leaves errno
unspecified after a successful call of a function that does not promise
otherwise, so an allocator is permitted to change it. Apple's libmalloc
does not on success in practice, and the evidence agrees: `di-errno` reads
EBADF after a failed read twenty times, inside a coroutine, and under GC
stress -- a collection at every allocation site, so the frees run in exactly
that window -- and gets 9 every time (macOS run 39593142355). It remains an
allocator behavior the library relies on, not a guarantee. The fix is a
representation change in the compiler, not in this library: let a write
exposure's write-back value be scalar-replaced like a syscall's result
(escape analysis's `Classify` recognizing the borrow call as a local
construction, `BorrowCall` handing back its field registers, and the copy's
MutableBytes wrapper flattened as a nested field), so that `read`'s
comparison and `errno()` follow the call with nothing between. Section 28
records it; this milestone does not change the borrowing lowering.

**Threads and coroutines.** A Botlish program runs on one native thread;
coroutines switch stacks, never threads (COROUTINES.md), so the errno a
wrapper reads is its own thread's. A `yield` is a statement of a coroutine's
own body and never occurs inside these wrappers, so no suspension comes
between a call and its errno read; `di-errno` repeats its sequence inside a
coroutine before and after a suspension. errno is never cached (each read
calls `__error()`), and no pointer to it is kept.

**Who can read it.** `c_errno_location` is a member of `darwin`, a direct
module: calling it from ordinary code is a DIRECT edge (DIRECT-MODULES.md),
and making a view of it needs `binary::native`, designated direct. No
ordinary application code reaches the errno pointer.

**Tests** (`di-errno`, macOS): ENOENT (2) for a missing file, EBADF (9) for
a write to a bad descriptor, a close of a closed one and a read, EEXIST (17)
for `create_new` of an existing file, EISDIR (21) for a directory opened for
writing -- distinct errnos in succession, each followed by successes
reporting 0, never a stale value. `di-file-errors` adds ENOTDIR (20).
Every constant is the SDK's (`di-sdk-facts`).

## 8. The variadic `open`

`open(2)` is `int open(const char *, int, ...)`, and it is declared so. On
Apple arm64 a variadic call's trailing arguments travel on the stack, each
in an 8-byte slot, while a fixed parameter travels in a register
(VARIADICS-VERTICAL-SLICE-1.md): a declaration with a fixed third parameter
would put the mode in `w2`, where `open`'s `va_arg` never looks.
`darwin::create` passes the mode as the one trailing argument:

```botlish
fn open_mode(path: darwin::path::DarwinPath, oflag: ffi::c::Int, mode: ffi::c::UShort) -> OpenResult:
    fd = c_open(c_string(path), oflag, mode)
```

`mode_t` is `unsigned short` on macOS (`di-sdk-facts`), so the argument is
an `ffi::c::UShort`, which C's default argument promotion passes as an
`int` -- exactly what `open` reads with `va_arg(ap, int)`. The NIR records
the promotion on the call (`varargs=u16:i32`, `di-c-declarations`). Only
`create` and `create_new` pass a mode, and they always do: `O_CREAT` can
never be used without one, and `darwin::open` passes no flag that would
need it. Every descriptor is opened close-on-exec (`O_CLOEXEC`).

`di-files` (macOS) creates a file with mode 0640 under a known umask (022)
and reads its permissions back: `0o640`, so open received the mode as its
variadic argument (mutant `darwin-open-mode-omitted` drops it). The same
test calls `fcntl` both ways: `F_GETFD` with no trailing argument and
`F_SETFD` with one (`c_int(0)`), showing close-on-exec set and then
cleared.

## 9. Paths and NUL termination

`darwin::path::DarwinPath` is a refinement of `str` (REFINEMENT-VALUES.md):
a non-empty String without U+0000, proven by `valid?` or `validate`. It is
textual eligibility only -- it claims nothing about existence, permissions,
PATH_MAX, APFS normalization or the working directory, and normalizes
nothing ("." and ".." and "a//b" stay as written). It satisfies the portable
`io::path::Path` through its module's own `concat` and `text`, as
LinuxPath does (`concat` joins with one "/" unless the path ends in one, and
refuses an empty, absolute or NUL-containing component).

open(2) receives the C string `c_string(path)` builds: the path's UTF-8
bytes and one terminating 0 (`str::encode_utf8(path).append(terminator())`,
then `abi::bytes::from_list`; `terminator` is the module's converter `fn
terminator() -> byte::Byte: 0`, since a bare `0` appended would widen the
list to `List[int]`), exposed `read noescape` for that call alone.
Because a DarwinPath holds no U+0000, that NUL is the only one and ends the
string. A String literal holding a NUL is not a DarwinPath (TYPE, at compile
time), and a computed one fails `validate` before any C call
(`di-path-validity`). `di-c-string` checks the bytes on every backend (pure
code): a Unicode name with spaces, its non-ASCII bytes as UTF-8, exactly
one 0 at the end (mutant `darwin-path-not-terminated`).

## 10. The opaque descriptor and the context

```botlish
opaque struct FileDescriptor:
    raw: ffi::c::Int

opaque context struct DarwinIO:
    stdin: FileDescriptor
    stdout: FileDescriptor
    stderr: FileDescriptor

fn create() -> DarwinIO        # descriptors 0, 1 and 2
```

LinuxIO's shape, with the token a C `int` (what every libSystem descriptor
is) instead of an `abi::I32`. Both are opaque (OPAQUE-STRUCTS.md): only
`darwin::io` constructs them or looks inside, so no code outside the module
can make a DarwinIO for another descriptor. The token claims nothing about
the descriptor being open. `darwin::io::write`, `write_error` and `read`
give the raw results for the standard streams; the raw `darwin::write` and
`darwin::read` stay available to direct code that wants any descriptor.

## 11. `io::IO` by structural satisfaction

```botlish
fn write_text(text: str, context io: DarwinIO) -> unit errors io::WriteFailed:
    io.stdout.write_all(str::encode_utf8(text))

fn write_error_text(text: str, context io: DarwinIO) -> unit errors io::WriteFailed:
    io.stderr.write_all(str::encode_utf8(text))
```

Ordinary functions of DarwinIO's owner module whose one context parameter
is a DarwinIO and whose signatures match io::IO's requirements: that is all
satisfaction reads (`hir::contexts::satisfiesTrait`, the owner namespace
only). Nothing registers them (`di-implements`), and lib/io.bot did not
change: the trait knows no platform.

## 12. Static specialization

`hello` declares no context. It requires io::IO through `io::print_line`,
and the one top-level call selects the one installed context implementing
it (`di-transitive-selection`). The program's NIR (`main.tcl -target
macos-aarch64 -emit-nir examples/io/hello-darwin.bot`):

```text
func 7 "darwin::io::write_text" ... instance="str"
    %1 = contextload 8
    %2 = op strutf8bytes %0
    %3 = call 6 %1 %2                    ; darwin::io::write_all(io.stdout, bytes)
func 8 "io::print_line<io::IO=darwin::io::DarwinIO>" ...
    %1 = char 10
    %2 = op strappendchar %0 %1
    %3 = call 7 %2                       ; write_text, directly
func 9 "hello<io::IO=darwin::io::DarwinIO>" ...
    %0 = str "Hello, world!"
    %1 = call 8 %0
```

The clones carry the selection in their names; every call is a direct
`call` with no context operand and no `callvalue` -- no dispatch, no
provider table, no hidden argument. `di-same-function-two-platforms`
compiles hello.bot for Linux and hello-darwin.bot for macOS and checks that
the two programs differ only in the platform import and the installed
context, and that each compiles `hello` to the same shape over its own
context's `write_text`. Selection stays exact (`di-selection-diagnostics`):
no installed context is MISSING-CONTEXT, DarwinIO beside another
implementation is AMBIGUOUS-CONTEXT-IMPLEMENTATION (never ranked), and a
context whose operations do not match implements nothing.

## 13. Authority

| module | status | why |
|---|---|---|
| `darwin` | designated direct (`direct module`) | its operations take any descriptor and any path, with no context, and `errno()` makes a native view |
| `darwin::io` | contextualized | each direct call is made by a function requiring DarwinIO, a context it declares itself (`write_all` requires it for that reason although it reads only its descriptor argument) |
| `darwin::path` | ordinary | text only |
| `io`, an application using `io` and `darwin::io` | ordinary | calls no direct callable |

A program that calls `darwin::write` itself must say `direct module`
(DIRECT without it); one that only uses DarwinIO and says it is
STALE-DIRECT-MODULE (`di-authority`). This is exactly linux/linux::io's
structure (mutant `darwin-io-direct` marks `darwin::io` direct).

## 14. Standard output and error

DarwinIO's `write_text` and `write_error_text` write descriptors 1 and 2
through `write_all` (section 17), which returns before any call when the
text is empty. On macOS arm64, all 27 tests of darwin-io.test ran and
passed in acceptance shard 1/2 (none skipped: every constraint they carry,
`darwinIO`, `writeInject`, `cCompiler`, `posixShell`, `nativeCoroutines`,
held on the runner). The stream tests run a standalone executable and read
its descriptors 1 and 2 as bytes:

| test | what runs | observed |
|---|---|---|
| `di-hello-executable` | hello-darwin.bot's executable, moved out of the tree, the source deleted, run under `env -i PATH=/nonexistent` | descriptor 1 exactly `Hello, world!\n` and then the runner's `unit` result line; descriptor 2 empty; status 0; the same bytes under GC stress; `otool -L` lists system libraries only, libSystem among them |
| `di-routing-utf8` | `print`, `print_line`, `write_error`, `write_error_line` with `é` (two bytes) and `𝄞` (four) | `out: é 𝄞\n` and the result line on 1 (18 bytes), `err: done\n` on 2 |
| `di-text-edges` | the empty String, a String holding U+0000, empty lines, on both streams | `a\0b\nline\n` on 1 and `e\0\n` on 2: the NUL is a byte like any other (bytes, not a C string), each line one newline, the empty String nothing |
| `di-deep-and-modules` | an application module whose functions require `io::IO`, output forty calls down | `first\nsecond\n` on 1, `first!\nsecond!\n` on 2, in program order |

## 15. Standard input

`darwin::io::read(buffer)` is one read(2) of descriptor 0 into a logical copy
of the buffer. `di-stdin` (macOS) feeds a 16-byte buffer of A's:

| input | count, errno | the bytes |
|---|---|---|
| the empty request (a 0-byte buffer) | 0, 0 | nothing read, the input left |
| 5 bytes | 5, 0 | the first 5 written, the other 11 still A's |
| 16 bytes | 16, 0 | all 16 |
| end of file | 0, 0 | not an error |
| `00 ff 80 c3 28` | 5, 0 | non-UTF-8 and zero bytes as they are |
| standard input opened write-only | -1, 9 (EBADF) | the empty request too: the kernel checks the descriptor first |

The caller's own buffer is unchanged every time (the test prints it after
each read). Text input (decoding, lines) is not here: the raw read is the
abstraction milestone 8 promises, as Linux's.

Observed on macOS arm64 exactly as tabled (`di-stdin`): for each input the
program printed the copy's bytes and `[none.count, none.errno, r.count,
r.errno, 16, 16]` -- `[0, 0, 5, 0, 16, 16]` for `hello`, `[0, 0, 16, 0, 16,
16]` for 16 bytes, `[0, 0, 0, 0, 16, 16]` at end of file, `[0, 0, 5, 0, 16,
16]` for `00 ff 80 c3 28` (the five bytes as they are), and `[-1, 9, -1, 9,
16, 16]` with standard input opened write-only -- and the caller's 16 A's
reached descriptor 2 unchanged every time.

## 16. File creation and reading

`di-files` (macOS): in a private directory whose name has spaces,
`darwin::create(path, WriteOnly, 0o640)` of `fïlé 🙂.txt` (a DarwinPath built
by `concat`), `write` of 11 bytes, `fcntl` (close-on-exec set, then cleared
through the variadic `F_SETFD`), `close`; `open(path, ReadOnly)`, a `read`
of 64 bytes that returns 11 (a short read: the rest of the copy stays
zeros), a second `read` that returns 0 (end of file), `close`; then a
relative path opened from the run's working directory. The file holds
exactly the bytes written, with mode 0640. `di-file-errors`: ENOENT,
ENOTDIR (a path through a file), EISDIR, EEXIST (`create_new`), EBADF (a
closed and an invalid descriptor).

Observed on macOS arm64 (`di-files`, under `umask 022` so the mode checked
is the one open(2) received): `[true, 0, 11, 1, 0, 0, 0, true, 11, 0, 0, 11,
0, true, 3, 0]` -- a descriptor of at least 3 with errno 0, 11 bytes
written, F_GETFD 1 (close-on-exec set: `darwin::open` passes O_CLOEXEC),
F_SETFD 0 through the variadic call and F_GETFD 0 after it, the close 0, the
second open's descriptor, a read of 11 into the 64-byte copy, end of file 0
with errno 0, the 11 bytes written back to descriptor 1 exactly, the close
0, the relative path opened from the working directory and its 3 bytes
read. The file's permissions are `0o640` and it holds exactly `first
line\n`. `di-file-errors`: `[-1, 2, -1, 20, -1, 21, -1, 17, 0, 0, -1, 9, -1,
9]` -- ENOENT, ENOTDIR, EISDIR, EEXIST, a successful close, then EBADF for
the closed descriptor and for -1.

## 17. Short writes and failures

`darwin::io::write_all` is linux::io's policy, line for line:

* a positive count below the length writes the unwritten suffix (indices
  `written..n-1`, which the range analysis proves inside the list), again
  until done -- one write(2) in the common case;
* `-1` (whatever the errno: EINTR and EAGAIN are not retried, as on Linux)
  and `0` for a non-empty request are `io::WriteFailed`; no count or errno
  reaches the portable caller.

Linux's tests inject faults with `strace -e inject=write:...`; macOS has no
strace, so tests/cffi/write-inject.c stands where the kernel would answer: a
dynamic library whose `__DATA,__interpose` section makes dyld bind the
program's references to libSystem's `write` to its own function, loaded into
one run of the standalone executable with `DYLD_INSERT_LIBRARIES`. It
follows a plan per call on one descriptor (`N` bytes at most, `0`, or `-E`:
-1 with errno E) and logs every call. Botlish knows nothing of it: the
program calls the real libSystem symbol.

Observed on macOS arm64; each call the interposer logged as `{ASKED
RESULT ERRNO}`:

| test, plan | output | the first calls |
|---|---|---|
| `di-short-write-completed`, 5 | `Hello, world!\n` and `"ok"` | `{14 5 0} {9 9 0}`: the 9-byte suffix next |
| the same, 3,4,2 | the same | `{14 3 0} {11 4 0} {7 2 0} {5 5 0}` |
| the same, 5, under GC stress | the same | (completed identically) |
| `di-write-failures`, -9 / -4 / -35 / 0 | `"failed"`: the portable handler ran | one call each: `{14 -1 9}`, `{14 -1 4}`, `{14 -1 35}`, `{14 0 0}` -- no retry of EINTR (4) or EAGAIN (35), no retry of no progress |
| the same, 5,-9 / 5,0 | `Hello` then `"failed"` | `{14 5 0}` then `{9 -1 9}` / `{9 0 0}`: nothing written again |
| `di-stderr-failure`, 3 on descriptor 2 | both streams complete | `{4 3 0} {1 1 0} {6 6 0}` |
| the same, -9 on descriptor 2 | `"failed"`, nothing on 2 | `{4 -1 9}` |

The policy is LinuxIO's; on Linux the same rows are injected with strace
in portable-io.test (unchanged).

## 18. GC stress and coroutines

Four darwin-io.test tests run their executable a second time with
`BOTLISH_NATIVE_GC_STRESS=1` (a collection attempted at every allocation
site) and require the same bytes: `di-hello-executable`,
`di-coroutines-gc-stress`, `di-short-write-completed` (a short write
completed under stress) and `di-errno`. All four passed on macOS arm64.

`di-coroutines-gc-stress` writes from coroutine bodies through the portable
API: two coroutines started, each suspended holding a managed list, resumed
in the other order. Observed: `ant starts\nbee starts\nbee resumes\nant
resumes\n[1, 2, 3, 1, 2, 3]\n` on descriptor 1 and `ant ends\nbee ends\n`
on 2, the same under GC stress. `di-errno` reads errnos inside a coroutine
before and after a suspension (2, then 17) and twenty rounds outside it,
also under GC stress. Contexts stay static across suspension: the
coroutines' DarwinIO is the one selected at their construction, and no
context machinery is added to either runtime (COROUTINES.md).

## 19. Native linked runs

A program that calls C is never JIT-run: the native backends link it as an
executable into a private directory and run it (C-FFI.md, native/src/
main.rs's `run_linked`), its standard streams the driver's own.
`di-native-backends` (macOS): the program's value on `cranelift` and
`cranelift-generic`, and `main.tcl -backend cranelift` passing the program's
own output through to its standard output (native program output,
POST-2048-PRODUCT-FIXES.md).

Observed on macOS arm64: `{value "ok"}` on both `cranelift` and
`cranelift-generic`, and main.tcl's output `Hello, world!` followed by its
own `   value: unit` line. `di-errno` runs its program on both native
backends too and requires their value to equal the executable's output.

## 20. Standalone Mach-O executables

`native::executable` (and `main.tcl -emit-native-executable`) of a Darwin
program is a Mach-O arm64 executable, linked by rustc through Apple's ld
with the plan milestone 6 made (the bare `-L`/`-l` list; `extern c
library` names none here: libSystem is linked by default). Observed on
macOS arm64:

* the native-status probe `darwin-executable`: `{macho arm64 execute}` and
  `Hello, world!` from the executable;
* `di-hello-executable`: moved out of the source tree with the source
  deleted, run with an empty environment and no Tcl, compiler or source
  reachable, it writes exactly its output (section 14); `otool -L` names
  only libraries under /usr/lib, libSystem among them, and its header is
  the host's executable header (`binaryHeader`);
* `tests/platform/aot-facts.tcl` in the smoke job: `ok: native objects and
  executables on macos-aarch64 are as recorded`.

## 21. The portable Hello World

| | Linux | macOS |
|---|---|---|
| program | examples/io/hello.bot | examples/io/hello-darwin.bot |
| platform import, context | `linux::io`, `linux::io::create()` | `darwin::io`, `darwin::io::create()` |
| `hello` | the same function | the same function |
| clone | `hello<io::IO=linux::io::LinuxIO>` | `hello<io::IO=darwin::io::DarwinIO>` |
| the write | `linux::abi::ARCH::syscall` (write, 1) | libSystem `write(1, ...)` |
| executable | ELF, static runtime, no libc call for IO | Mach-O, libSystem |

hello.bot's NIR on Linux is byte-identical to main's before this milestone
(section 26).

## 22. The 2048 workload

The demo (examples/games/2048/demo.bot) was one file holding the game's
presentation, its play loop and its entry -- the entry being the only part
that names a platform. It is now three:

* `demo_play.bot`: everything that was demo.bot except the entry, an
  application module requiring `io::IO` (its functions declare no context);
* `demo.bot`: the Linux entry (`import linux::io`, `with context
  linux::io::create()`, `demo_play::main()`);
* `demo-darwin.bot`: the macOS entry, the same three lines with `darwin::io`.

The engine (game2048.bot) and the benchmark (bench.bot) did not change:
neither does IO. The split is an application module (IMPORTS.md) and
nothing else; the workload's documented workarounds stay. On Linux the
demo's NIR has the same 61 functions with the same instruction counts and
registers as before; only their names gained `demo_play::` (and the
numbering moved), and its output is unchanged
(`workload-2048-demo-executable`, `workload-2048-demo-main-native`).
`workload-2048-demo-two-platforms` compiles both entries and checks they
select their own context through the same `demo_play` functions;
`workload-2048-demo-darwin-executable` (macOS) runs the macOS demo as a
standalone executable and requires the Linux demo's exact output.

On macOS arm64, workload-2048.test ran and passed (main's run
[39603310734](https://github.com/mwagner-webdev/botlish/actions/runs/39603310734),
acceptance shard 2/2, and the dispatch
[39603460215](https://github.com/mwagner-webdev/botlish/actions/runs/39603460215)):
`workload-2048-demo-darwin-executable` -- demo-darwin.bot as a standalone
Mach-O executable printing the whole game through libSystem, byte for byte
the Linux demo's output, the same under GC stress --,
`workload-2048-demo-two-platforms` and `workload-2048-bench-executable`
among them. The two Linux-only tests (`workload-2048-demo-executable`,
`workload-2048-demo-main-native`: `nativeLinux`) are skipped there, as
before.

## 23. Mutation results

19 mutants (`darwin-*` in audit/context-traits/tools/mutants.txt; the tool
now runs without `timeout(1)`, knows per-host mutants (`%% macos-aarch64`)
and reports SKIPPED; tier item `darwin-io-mutants`):

| mutant | the bug | host |
|---|---|---|
| `darwin-import-on-linux` | the platform rule lets `darwin` compile for Linux | any |
| `darwin-falls-back-to-linux` | `darwin` designated Linux's | any |
| `darwin-write-unsigned-result` | write's result declared `ULong` (-1 becomes 2^64-1) | any |
| `darwin-write-borrow-writable` | write's buffer declared `write noescape` | any |
| `darwin-read-borrow-readable` | read's buffer declared `read noescape` | any |
| `darwin-write-count-mismatch` | write passes one byte fewer than the buffer holds | macOS |
| `darwin-read-returns-original` | read returns the caller's buffer, not the copy C wrote | macOS |
| `darwin-errno-on-success` | a successful call reports the current errno | macOS |
| `darwin-errno-after-another-call` | errno read after another C call | any (the NIR) |
| `darwin-errno-constant` | errno read as a constant (EBADF) | any (the NIR) |
| `darwin-linux-error-convention` | the result read as Linux's `-errno` | macOS |
| `darwin-open-mode-omitted` | create's mode not passed | any (the NIR) |
| `darwin-path-not-terminated` | the C string without its NUL | any |
| `darwin-short-write-complete` | a short write taken as complete | macOS |
| `darwin-short-write-repeats-prefix` | the completion writes the text again from its start | macOS |
| `darwin-zero-write-retried` | a write of no progress retried | macOS |
| `darwin-stdout-is-stdin` | the context's stdout is descriptor 0 | macOS |
| `darwin-stderr-is-stdout` | write_error_text writes descriptor 1 | macOS |
| `darwin-io-direct` | `darwin::io` marked direct | any |

**On Linux x86-64** (`tclsh9.0 audit/context-traits/tools/mutate.tcl`, the
whole file on the merged tree, in four `-only` groups): 42 mutants, **33
killed, 9 skipped, 0 survived**. The 23 context-trait and path mutants that
predate this milestone are all still applied and killed; of the 19 Darwin
ones, 10 are killed on Linux -- by the front-end half of darwin-io.test (the
platform rule, the declarations' NIR, `di-errno-read-first`, the C string,
the authority table) -- and 9 need a Darwin process and are SKIPPED there.
Two were first marked macOS-only (`darwin-errno-after-another-call`,
`darwin-errno-constant`); strengthening `di-errno-read-first` to count C
calls and to read `open_mode` too made the NIR see both on any host, and
they lost their marks.

**On macOS arm64** (the tier item `darwin-io-mutants`, the dispatch
[39603460215](https://github.com/mwagner-webdev/botlish/actions/runs/39603460215),
Tier C shard 1/3: `audit/context-traits/tools/mutate.tcl -only darwin-*`,
646 s): **19 mutants, 19 killed, 0 survived, 0 skipped**. Every Darwin
mutant, the nine Linux cannot run among them, is killed by darwin-io.test
(the context-trait fuzzer, which knows nothing of Darwin, survives every
one, as expected):

| mutant | killed by (failed tests) |
|---|---|
| `darwin-import-on-linux` | 2: di-platform-no-way-around, di-platform-rule |
| `darwin-falls-back-to-linux` | 13: di-authority, di-c-declarations, di-c-string, di-errno-read-first, di-implements, di-path-validity, ... |
| `darwin-write-unsigned-result` | 5: di-c-declarations, di-errno, di-errno-read-first, di-stderr-failure, di-write-failures |
| `darwin-write-borrow-writable` | 26 |
| `darwin-read-borrow-readable` | 26 |
| `darwin-write-count-mismatch` | 6: di-errno, di-files, di-short-write-completed, di-stderr-failure, di-stdin, di-write-failures |
| `darwin-read-returns-original` | 2: di-files, di-stdin |
| `darwin-errno-on-success` | 1: di-errno |
| `darwin-errno-after-another-call` | 3: di-errno, di-errno-read-first, di-file-errors |
| `darwin-errno-constant` | 3: di-errno, di-errno-read-first, di-file-errors |
| `darwin-linux-error-convention` | 1: di-errno |
| `darwin-open-mode-omitted` | 3: di-c-declarations, di-errno-read-first, di-files |
| `darwin-path-not-terminated` | 1: di-c-string |
| `darwin-short-write-complete` | 3: di-short-write-completed, di-stderr-failure, di-write-failures |
| `darwin-short-write-repeats-prefix` | 3: di-short-write-completed, di-stderr-failure, di-write-failures |
| `darwin-zero-write-retried` | 1: di-write-failures |
| `darwin-stdout-is-stdin` | 10: di-coroutines-gc-stress, di-deep-and-modules, di-hello-executable, di-native-backends, di-routing-utf8, di-short-write-completed, ... |
| `darwin-stderr-is-stdout` | 6: di-coroutines-gc-stress, di-deep-and-modules, di-routing-utf8, di-stderr-failure, di-stdin, di-text-edges |
| `darwin-io-direct` | 16: di-authority, di-coroutines-gc-stress, di-deep-and-modules, di-hello-executable, di-native-backends, di-platform-no-way-around, ... |

Four mutants are killed by one test only (`darwin-errno-on-success`,
`darwin-linux-error-convention`, `darwin-path-not-terminated`,
`darwin-zero-write-retried`): each is the one behavior that test pins
(di-errno's successes reporting 0 and its -1 results, di-c-string's
terminator, di-write-failures' no-progress write).

## 24. Performance

`bench/darwin-io.tcl` (tier item `darwin-io-bench`) measures each platform
on its own host -- darwin's rows on macOS, linux's on Linux, never one
against the other -- as per-iteration time inside one process: the loop
runs RUNS times in the executable (macOS: a linked program repeats the run
itself; Linux: the driver), best of RUNS, standard output /dev/null,
standard input /dev/zero. Compilation, linking and process startup are
reported apart (part 3), and partial-write completion through the
interposer on macOS (part 2).

**Linux x86-64** (the reference for the same rows, the linux module through
the syscall transport; a 4-core container, 2026-10-21; best of 5 runs of
100 000 iterations; ns per iteration):

| row | loop | + call | call |
|---|---:|---:|---:|
| write 14 B | 44.5 | 244.8 | 200.3 |
| write 64 KiB | 71.7 | 277.5 | 205.8 |
| write EBADF | 48.2 | 218.1 | 169.9 |
| read 64 | 42.6 | 439.5 | 396.9 |
| read 4096 | 56.6 | 960.5 | 903.9 |
| read 65536 | 70.5 | 7929.1 | 7858.6 |
| read EBADF 64 | 53.6 | 385.0 | 331.4 |
| read EBADF 4096 | 43.9 | 858.2 | 814.3 |
| read EBADF 65536 | 89.9 | 6377.7 | 6287.8 |
| print 14 B | 42.0 | 659.3 | 617.4 |
| print 4 KiB | 45.5 | 10242.5 | 10196.9 |
| print_line 13 B | 54.5 | 656.8 | 602.3 |

Build and process: front end 343 ms, `native::executable` 596 ms; a
process of hello 1.67 ms against 1.66 ms for an executable that does no
IO.

What the numbers separate:

* **The write exposure copies nothing**: a 64 KiB write costs what a
  14-byte one does (the kernel's /dev/null reads nothing either).
* **The read detach is Botlish's value semantics**: read EBADF, where the
  kernel returns at once, grows from 331 ns to 6.3 us with the buffer -- the
  private copy of the caller's buffer; the kernel's own fill is the
  difference to the successful read (66 ns at 64 B, 1.6 us at 64 KiB).
* **The portable text path costs about 400 ns over the raw write** for a
  short line (print 14 B against write 14 B) and about 2.4 ns per byte for a
  4 KiB text: write_text encodes the String into a `List[Byte]` and
  write_all makes a Bytes from it -- two size-linear passes before the one
  write. linux::io's write_text and write_all do the same: it is the
  portable path's cost, not Darwin's.
* **Process startup dwarfs the IO**: one print_line adds nothing
  measurable to a process's 1.7 ms.

(An earlier version of the benchmark had an "encode 14 B" row; it measured
nothing, because a constant text's encoding is folded into a static
storage at compile time, and was removed.)

PENDING-BENCH-MACOS

## 25. macOS GitHub Actions runs

PENDING-RUNS

## 26. Linux x86-64 regression

`audit/context-traits/tools/fuzz.tcl` (generated context-trait programs
against its own oracle; DarwinIO's satisfaction is the same structural rule
the generated contexts exercise), three disjoint seed ranges of 20 programs
on this milestone's tree:

| seeds | accepted (selections) | rejected | disagreements |
|---|---|---|---:|
| 100-119 | 7 (15) | 13 (MISSING-CONTEXT 11, AMBIGUOUS-CONTEXT-IMPLEMENTATION 2) | 0 |
| 200-219 | 9 (12) | 11 (MISSING-CONTEXT 11) | 0 |
| 300-319 | 9 (15) | 11 (MISSING-CONTEXT 11) | 0 |

PENDING-LINUX-CI

## 27. Linux AArch64 regression

PENDING-ARM64

## 28. Remaining platform IO gaps

* **read's errno window** (section 7): two allocations by the system
  allocator run between read(2) and the errno read. Closing it is a
  compiler representation change (a scalar-replaced write-back value), not a
  library one.
* **No portable file API.** `darwin::open`/`create`/`close` are Darwin's
  raw layer (direct); there is no `io::` file operation and no Linux
  counterpart in lib/linux.bot (Linux has write and read only). A portable
  `write_file_text(path, text)` needs a context-trait requirement whose
  implementation is chosen by two witnesses, the context and the Path
  (CONTEXT-TRAITS.md, "The io library": `TRAIT-OTHER-TRAIT`).
* **No descriptor ownership.** A `FileDescriptor` is a token; closing is the
  caller's, by `darwin::close`; nothing closes a descriptor that goes out of
  scope (an affine descriptor with a drop is a design of its own).
* **No text input.** `read` returns bytes; decoding, line splitting and
  buffering are not here, on either platform.
* **No retry policy.** EINTR and EAGAIN are failures, as on Linux; a caller
  that wants a retry has the raw layer.
* **One thread.** errno is read on the program's one native thread; a
  threaded runtime would keep the property only if a C call and its errno
  read stayed on one thread with no suspension between.
* **macOS x86-64** compiles Darwin programs but has no native backend here;
  Windows has no IO module (WINDOWS-X86-64-MILESTONE-1.md).
* **The 2048 demo** keeps one entry file per platform: the language has no
  conditional import, and choosing the context is the entry program's job.

## 29. Prerequisites for future input, filesystem and event-loop APIs

* **Multi-witness context traits**: a requirement taking another trait's
  witness (`write_file_text(path: io::path::Path, text: str)` implemented
  per context *and* path type), so portable file operations can be added
  without erasing provenance.
* **An errno-exact write exposure**: the scalar-replaced write-back value of
  section 7, so that a write-exposing C call's errno can be read with
  nothing between.
* **Descriptor lifetime**: affine descriptors released by a static drop
  (AFFINE-VALUES.md) or an explicit close protocol, before files are a
  portable resource.
* **Text input**: a decoding layer over raw reads (UTF-8 validation,
  partial sequences across reads, lines), and buffering behind `io::`.
* **Event loops**: kqueue on macOS and epoll on Linux are C and syscall APIs
  with record layouts (`struct kevent`; C-BINDGEN-LAYOUTS.md generates such
  layouts) and, for callbacks, retained C pointers -- which borrowing
  refuses today (C-POINTER-BORROWING.md, "Retained pointers"). An event
  loop needs a lifetime protocol for buffers the kernel keeps between calls.
