# LSP-MILESTONE-1.md

Botlish's first usable Language Server Protocol implementation: a
Tcl-orchestrated stdio language server, sharing the compiler service's
semantic facts, with document synchronization, diagnostics, hover,
definition, references, and responsive analysis under active editing.

> An editor should be able to ask Botlish what a program means without
> running it, without implementing compiler semantics itself, and without
> becoming unresponsive while the compiler works. The CLI and LSP must agree
> on the program; the LSP adds transport, scheduling, and presentation, not
> another compiler.

This milestone builds on the compiler service (COMPILER-SERVICE-MILESTONE-1.md,
its census `../audit/compiler-service/COMPILER-SERVICE-CENSUS.md`) and the
canonical `std::` namespace (STD-NAMESPACE.md), both on `main` at `6df89a8e`,
where this work starts. It follows the service report's section 16 ("the
smallest stdio LSP") and keeps every contract that report lists.

No syntax, HIR node, registry, cache format, backend, daemon or incremental
mechanism was added. The compiler service gained one narrowly scoped pair of
calls -- `service::export` and `service::import`, a revision moved between
processes as text with its HIR in the HIR interchange format -- and the
language server's measurements found two costs in the front end, fixed
without changing any result: a DecimalRounded `0.0` took 150 ms to
represent, and the loader's parse cache kept an AST per edit (section 9.3).
Everything else is new code above the service, in `lsp/`.

## Contents

1. [Result](#1-result)
2. [Architecture](#2-architecture)
3. [Protocol](#3-protocol)
4. [Documents and revisions](#4-documents-and-revisions)
5. [Coordinates and URIs](#5-coordinates-and-uris)
6. [Scheduling decision](#6-scheduling-decision)
7. [Correctness](#7-correctness)
8. [Tests](#8-tests)
9. [Performance](#9-performance)
10. [Files and usage](#10-files-and-usage)
11. [Limitations](#11-limitations)
12. [Next milestone](#12-next-milestone)

## 1. Result

### Launching it

```text
botlish -lsp                                  the single executable
tclsh9.0 main.tcl -lsp                        a checkout
tclsh9.0 main.tcl -lsp -lsp-scheduler sync    the in-process reference scheduler
```

The server speaks the Language Server Protocol on stdin and stdout and
writes nothing else there; its log (a worker started, a change ignored, a
crash) goes to stderr. It takes no input file: the editor sends the
documents. Of the other options only `-warnings` and `-target` combine with
it (they decide the analysis, as for `-check`); anything else is a usage
error (exit 2), never ignored. It needs no daemon, socket, configuration
file or network.

For an editor with a standard LSP client the whole configuration is:

| Setting | Value |
|---|---|
| command | `botlish -lsp` (or `tclsh9.0 /path/to/main.tcl -lsp`) |
| transport | stdio |
| documents | files with the extension `.bot` (language id: anything; the server does not read it) |
| root | not needed: a program's application root is its own file's directory |
| initialization options | `{"debounce": MS}`, optional (default 250 ms) |

`editors/neovim/botlish.lua` is that configuration for Neovim 0.10 or
later: the `.bot` filetype and one shared client for every Botlish buffer.

### An editor session

`tests/lsp-neovim.test` runs Neovim 0.11.4, headless, with that file and a
driver that does what a user does (`tests/lsp-neovim.lua`). On a two-module
program --

```text
shapes.bot   fn area(w: int, h: int) -> int:
                 w * h

main.bot     import shapes
             import std::list

             a = shapes::area(3, 4)
             b = std::list::get([1, 2], 5, 0)
             a + b + nosuch
```

-- Neovim's own client, unmodified, sees:

| Step | What Neovim shows |
|---|---|
| open `main.bot` | filetype `botlish`; server `botlish` attached; position encoding `utf-16` |
| diagnostics | line 6, column 9: `unbound name "nosuch"`, code `CORE SEMANTIC UNBOUND`, source `botlish` |
| hover (K) on `shapes::area` | ```` ```botlish ````  `fn shapes::area(w: int, h: int) -> int` |
| go to definition on `shapes::area` | jumps to `shapes.bot`, line 1, column 3 (the name `area`) |
| go to definition on `std::list::get` | jumps to the standard library's `list.bot`, line 76 (`get`) |
| references of `area` (with the declaration) | `shapes.bot:0`, `main.bot:3` |
| an unsaved fix of line 6 (Neovim's own `didChange`) | the error goes; the program's warning (`METHOD-ELIGIBLE`), which an error hides, appears |
| an unsaved syntax error on line 6 | `expected an expression, found end of line` (`SURFACE SYNTAX`) |
| hover on `shapes::area` during it | the signature, and *stale: analyzed before the latest changes to main.bot* |
| the syntax error fixed | no error; hover fresh again |
| the file on disk | never written (the buffer stays modified) |

The same session, framed by hand in bash, runs against the single
executable in `single/smoke-test.sh` (stock Ubuntu, no Tcl installed): its
analysis worker starts from the executable itself, and the definition of
`std::list::get` is a file the editor can open
(`~/.cache/botlish/stdlib-ID/list.bot`, the library copied out of the
archive once per build, below).

What a client receives, for the record (the same session against a checkout,
frames shown without their headers):

```text
{"jsonrpc":"2.0","method":"textDocument/publishDiagnostics","params":{"uri":"file:///.../main.bot","version":1,"diagnostics":[{"range":{"start":{"line":5,"character":8},"end":{"line":5,"character":14}},"severity":1,"code":"CORE SEMANTIC UNBOUND","source":"botlish","message":"unbound name \"nosuch\"","data":{"topic":"error.unbound"}}]}}
{"jsonrpc":"2.0","id":2,"result":{"contents":{"kind":"plaintext","value":"fn shapes::area(w: int, h: int) -> int"},"range":{"start":{"line":3,"character":4},"end":{"line":3,"character":16}}}}
{"jsonrpc":"2.0","id":3,"result":{"uri":"file:///home/user/botlish/stdlib/list.bot","range":{"start":{"line":75,"character":3},"end":{"line":75,"character":6}}}}
```

The hover and the definition were asked before the first analysis had
finished; they waited for it (section 4.6).

## 2. Architecture

```text
 editor ── stdin/stdout ──┐
                          │  lsp/transport.tcl   Content-Length framing; bytes only
                          │  lsp/json.tcl        typed JSON values
                          │  lsp/jsonrpc.tcl     JSON-RPC 2.0 messages
                          │  lsp/server.tcl      lifecycle, documents, programs,
                          │                      publication, queries, staleness
                          │  lsp/positions.tcl   UTF-16/UTF-32 <-> compiler scalars
                          │  lsp/uri.tcl         file: URIs <-> paths
                          │  lsp/scheduler.tcl   where analyses run (one interface)
                          ▼
                   service/service.tcl   (the compiler service, unchanged in
                                          meaning; + export/import)
                          │
          ┌───────────────┴────────────────┐
     sync: in process              worker: main.tcl -lsp-worker
     (the reference design)        (lsp/worker.tcl, a persistent process;
                                    private protocol on its stdin/stdout,
                                    revisions back as service::export text)
```

| Layer | Owns | Never |
|---|---|---|
| `transport.tcl` | framing as a pure state machine (`reader`, `feed`, `finish`, `frame`); channels in binary, nonblocking mode on Tcl's event loop | JSON, methods, analysis |
| `json.tcl` | `{TYPE PAYLOAD}` values (`null bool num str arr obj`); strict UTF-8; numbers kept as their JSON text | guessing a category from a Tcl string |
| `jsonrpc.tcl` | classifying a body (request, notification, response, invalid, parse error); building responses and notifications; error codes | LSP methods or lifecycle |
| `server.tcl` | the LSP: lifecycle, documents and versions, programs and ownership, diagnostics publication, hover/definition/references, the stale policy, deferral and cancellation | semantics: every fact is the service's |
| `scheduler.tcl` | `sync` and `worker`, behind `submit`/`cancel`/`busy`/`document` and a delivery callback | deciding what to analyze (the server's) |
| `worker.tcl` | the worker process: a workspace mirroring the server's overlay, `service::analyze`, `service::export` | holding revisions between jobs |
| `stats.tcl` | the server's own measurements (`BOTLISH_LSP_STATS`) | anything a client sees |

**One analysis.** Both schedulers run `service::analyze` -- the compiler's
lenient compilation, whose diagnostics are the strict compilation's
(COMPILER-SERVICE-MILESTONE-1.md, sections 3 and 5) -- in a workspace with
the server's configuration and overlay. The worker returns the revision as
`service::export` text and the server imports it into its own workspace
(`service::import`), so every query of either design is `service::at` on a
revision of the server's process. The server keeps the documents, the
revisions it answers from, what it published and every request; the worker
keeps the compiler warm and nothing else.

**The replaceable boundary.** JSON and JSON-RPC are separate from the
service and from the handlers: a handler receives typed JSON params and
returns typed JSON, and `lsp::json::decode`/`encode` turn bytes into values
and back. A native Botlish implementation (the census's plan: an
`exported c fn` over UTF-8 bytes) can replace `json.tcl` and
`jsonrpc.tcl` behind those calls without changing document
synchronization or a query.

## 3. Protocol

The baseline is LSP 3.18; nothing outside the common 3.17 set is used.

### Methods

| Method | Kind | Implementation |
|---|---|---|
| `initialize` | request | negotiates the position encoding and the hover format, reads `initializationOptions.debounce`, starts the scheduler (the worker boots while the editor opens files), answers the capabilities and `serverInfo` |
| `initialized` | notification | nothing to do |
| `shutdown` | request | answers every waiting request first, releases every revision, stops the worker, answers `null` |
| `exit` | notification | exits 0 after `shutdown`, 1 otherwise |
| `$/cancelRequest` | notification | a waiting request is answered `RequestCancelled` (-32800); one already answered is left alone |
| `textDocument/didOpen` | notification | the document becomes an overlay entry (its text, never the disk's) |
| `textDocument/didChange` | notification | the whole new text (full synchronization); a version that does not advance is ignored and logged |
| `textDocument/didSave` | notification | re-checks every program's sources against the disk (`service::stale`) and re-analyzes those that changed |
| `textDocument/didClose` | notification | the document is the disk's again |
| `textDocument/publishDiagnostics` | notification (sent) | the compiler's diagnostics, per file (section 4.5) |
| `textDocument/hover` | request | `service::at`'s hover text, with its range |
| `textDocument/definition` | request | the declaration's name (`Location`), or `null` |
| `textDocument/references` | request | every reference resolved to the same binding (`Location[]`), the declaration first when `includeDeclaration` |
| `window/logMessage` | notification (sent) | a worker that died mid-analysis, so the editor's log says why diagnostics did not refresh |

### Capabilities

```json
{"positionEncoding":"utf-16",
 "textDocumentSync":{"openClose":true,"change":1,"save":{"includeText":false}},
 "hoverProvider":true,"definitionProvider":true,"referencesProvider":true}
```

exactly (`lsp-proto-initialize`). The position encoding is the first of the
client's `general.positionEncodings` the server implements (`utf-16`,
`utf-32`), else `utf-16`; `utf-8` is never chosen and never advertised
(`lsp-proto-position-encoding`). Hover is markdown (a ```` ```botlish ````
block) when the client lists markdown first, else plain text.

### Lifecycle and errors

| Situation | Answer |
|---|---|
| a request before `initialize` | `ServerNotInitialized` (-32002); a notification is dropped |
| a second `initialize` | `InvalidRequest` (-32600) |
| a request after `shutdown` | `InvalidRequest`; only `exit` is heard |
| a body that is not JSON or not UTF-8 | `ParseError` (-32700), id `null` |
| JSON that is no JSON-RPC 2.0 message (no `"jsonrpc":"2.0"`, a non-string method, params neither object nor array, an object id, a batch) | `InvalidRequest`, with the message's id when it had a usable one |
| an unknown method | `MethodNotFound` (-32601) |
| missing or mistyped params; a URI the server cannot read (`untitled:`, `http:`, another host) | `InvalidParams` (-32602) |
| an internal failure of a handler | `InternalError` (-32603), its trace on stderr |
| a message longer than 64 MiB (well framed) | skipped as it arrives, never buffered; `InvalidRequest` with id `null` |
| a header that cannot be framed (no or contradictory `Content-Length`, a negative or non-numeric one, a header over 8 KiB, a charset other than UTF-8) | the input is unreadable: exit 1, the reason on stderr |
| the end of input inside a message, or without `exit` | exit 1 (0 after `shutdown`) |

Every request gets exactly one response, waiting ones included (cancelled,
answered at `shutdown`, or after 30 seconds with what the server knows);
notifications get none, known, unknown or malformed (`lsp-proto-notifications`).
Request ids come back exactly as sent: `0`, `-3`, the string `"7"`, an
integer no 64-bit word holds (`lsp-proto-request-ids`). A `null` params is
taken for none (clients send it for `shutdown` and `exit`).

### Not implemented

Completion, signature help, rename, code actions, formatting, semantic
tokens, inlay hints, document and workspace symbols, workspace-wide
references, incremental (range) synchronization, pull diagnostics,
`workspace/didChangeWatchedFiles`, progress reporting. None is advertised.

## 4. Documents and revisions

### 4.1 Source overlays

An open document is an entry of the server's workspace overlay
(`service::setDocument`): its text, as the editor sent it, is what every
analysis reads instead of the file, a module's included, standard-library
modules included; the compiler normalizes it at its seam
(surface/source.tcl). `didClose` removes the entry (`clearDocument`), and the
disk is read again. The server never writes a file (`lsp-lang-overlay`
checks the file's contents and modification time). A document opened that
does not exist on disk is a source like any other (`lsp-lang-loader-error`
creates the module an import names as an unsaved document, and the
loader's error goes).

A document's version in the overlay is `G/V`: its `V`, the LSP version,
within its `G`-th opening, so a document closed and reopened (whose
versions restart) never repeats one. The worker's workspace mirrors the
overlay: before each job the scheduler sends the entries that changed since
the worker last heard, then the job, on one ordered pipe, so the worker
analyzes exactly the documents the server had when it dispatched.

### 4.2 Programs and ownership

The service analyzes one entry program and the modules it loads. Which
open document is a program is decided by one rule (`UpdateRoots`, `Owner`):

1. Every open document is a candidate program, except a standard-library
   module: the library is no program (`lsp-lang-library-document`).
2. A candidate that another program's revisions read -- imports, directly
   or not -- is that program's module, not a program of its own. Among
   candidates that read each other, the one opened first is the program.
3. Every path -- open or not, application or library -- belongs to the
   program opened first among those that read it: its *owner*. Only the
   owner's revisions publish its diagnostics and answer queries in it.

So a module opened alone is analyzed as a program (exactly as `botlish
-check module.bot` would), until a program that imports it is opened and
analyzed; then it is that program's module (`lsp-lang-shared-module`: opened
before its two importers it is first a program, then the first importer's;
closing the first importer passes it to the second, and its diagnostics are
never withdrawn in between). A module imported by two open programs is
answered from the first one's analysis, deliberately: the two programs are
two semantic universes, and a module's facts (its diagnostics, the types
inferred for its functions' parameters) can differ between them. The rule is
deterministic: it depends on the order documents were opened, never on the
order analyses finish.

A program's revisions are the latest and the latest with a HIR (when the
latest has none: a syntax or loader error); its *reads* are the sources
either read. The union keeps ownership stable through a syntax error in an
entry, after which the compilation reads no module.

### 4.3 Dependency invalidation

Every source a program's revisions observed -- read, or probed and found
absent -- is a dependency: a change to any of them schedules the program's
re-analysis. That is the service's own record (`service::revision`'s
sources: every path the snapshot answered for), not a resolver of the
server's: the server builds no module graph. An edit of an open imported
module therefore re-analyzes the program, whose diagnostics are then
published for its unchanged version (`lsp-lang-module-edit`), and a module
created in the editor where an import found nothing resolves it.
`didClose` of a module with unsaved changes re-analyzes its importers
against the disk (`lsp-lang-close-module`); `didSave` re-checks every
program's sources against the disk with `service::stale` (another tool may
have changed a closed file) and re-analyzes those it finds changed. A
closed file changed on disk with no save in the editor is noticed at the
next analysis of its program, as the census's validity rule allows (no
watcher: COMPILER-SERVICE-CENSUS.md, section 9.2).

### 4.4 Freshness, obsolete and stale results

A revision is *fresh* while every source it observed is what the editor
and the disk hold now: an open document at the version it read (or the same
text), a closed one still the disk's (taken to be unchanged since it read
it, unless it read the document's unsaved buffer, which is then compared
with the disk), a path it found nothing at still empty (`Fresh`,
`SameSource`).

* **Only a fresh revision publishes.** A result whose input changed while
  it ran never publishes for text it did not analyze
  (`lsp-sched-stale-result`: a module the program imports only since the
  edit that started the analysis changes during it; nothing is published
  for that analysis, the program is analyzed again, and only the right
  diagnostics appear).
* **Results are ordered.** Each submission is a job with an increasing
  number; a result older than the one already applied for its program is
  obsolete: released, never the program's revision (`lsp-sched-obsolete-result`,
  with the `hold-result` test hook delivering the first result after the
  second).
* A result that is not fresh becomes the program's latest revision (for
  stale queries, below), and the program is analyzed again if nothing is
  pending for it.

### 4.5 Diagnostics publication

`textDocument/publishDiagnostics` per file, from the owner's fresh latest
revision (`Reconcile`): every diagnostic located in the file, errors then
warnings in the compiler's order, with

* `range` -- the service's range, converted (section 5); a zero-width one
  for a diagnostic whose compiler location is a point; for one with no
  location at all (`range none`: a compiler failure, a module file that
  cannot be read), the start of the program's entry file;
* `severity` -- 1 for an error, 2 for a warning (the compiler's two
  severities, its reported set: `hir::recovery::reported`, nothing
  filtered or added);
* `code` -- the code as the command line shows it (`CORE SEMANTIC
  UNBOUND`, `SURFACE SYNTAX`, `METHOD-ELIGIBLE`);
* `source` -- `botlish`;
* `message` -- the compiler's message without its location;
* `relatedInformation` -- each related location, where it still denotes
  the same text, with the compiler's own wording (a warning's `note`, else
  "related location");
* `data` -- `{"topic": ID}`, the Compilerpedia topic main.tcl's `help:` line
  names (`service::explain`). There is no stable web page to give as a
  `codeDescription` URL, so none is invented; the association is kept for a
  future code action (the protocol returns `data` with code-action
  requests).

An open document hears about every version analyzed, with that version (an
empty list says "no problems"); a closed file only of a change, with no
version (`lsp-lang-closed-module-diagnostics`: an error in a module no
editor has open is published for that module's file). A file whose owner
changes, or whose program closes, has what the previous owner published
withdrawn unless the new owner says it again. What the client holds is
tracked, and only differences are sent.

### 4.6 Queries and stale semantics

`hover`, `definition` and `references` read `service::at` on one of the
owner's two revisions. The policy, in order (`Answer`):

1. The position is taken in the text the client had when it asked (the
   document's text at the request).
2. A revision may interpret it only where the text it analyzed holds the
   same character: the texts are identical, or the position lies in the
   unchanged prefix or suffix of one contiguous edit between them
   (`Mapping`: the common prefix and suffix of the two texts, character for
   character). The answer's own range must lie in that unchanged text too,
   or there is no answer.
3. The answer is *fresh* when the texts are identical and the revision is
   fresh (4.4). A hover from a stale revision answers at once, marked: "stale:
   analyzed before the latest changes to FILE, ..." (markdown in italics,
   plain text in parentheses). A definition or references from a stale
   revision waits while an analysis that will answer fresh is pending; with
   none pending (the latest analysis ended in a syntax error) it answers.
4. A location -- a definition, a reference, a related location -- is
   returned only where it denotes the same text in the document as it is
   now: mapped through that document's own edit when it is open and
   changed, else checked against the disk; one in changed text is dropped
   (`lsp-lang-stale-locations`: a broken line inserted above everything
   moves every location down a line; a reference whose text was deleted is
   not returned at its old place).
5. With no revision able to interpret the position, the request waits for
   a pending analysis (or is answered when its document moves on, when it is
   cancelled, at `shutdown`, or after 30 seconds); with none pending, it is
   `null` (no locations).

So during a syntax error the unchanged text keeps answering: hover, marked
stale; definitions and references, located in the text as it is
(`lsp-lang-session`, `lsp-sched-advanced-beyond`). A position the client
asks about in text no analysis saw gets no answer rather than a guess.
Lines are never assumed to correspond because their numbers did.

### 4.7 Revision release

A program keeps at most two revisions (its latest, its latest with a HIR):
each newer one releases what it replaces (`service::release`); obsolete
results are released on arrival; a program closed or demoted to a module
releases its revisions; `shutdown` closes the workspace. At the end of
`lsp-sched-rapid-versions-*` (twelve versions in quick succession, then four
analyzed one by one) the server holds at most two (its `liveRevisions`
measurement, which the `revisions-not-released` mutant breaks). The worker
releases each revision right after exporting it.

## 5. Coordinates and URIs

### 5.1 Positions

The compiler counts Unicode scalar values of the normalized text a revision
analyzed (`\r\n` and a lone `\r` are `\n`): 0-based offsets, 1-based lines
and columns. The protocol counts 0-based lines and, within a line, code
units of the negotiated encoding: UTF-16 (two units for a character outside
the Basic Multilingual Plane) or UTF-32 (one per scalar value). Conversion
happens in `positions.tcl` and only there, always against one exact
normalized text: the text the revision analyzed (for what the compiler
reports) or the text the client's position was taken in (for what it asks).
Because the protocol counts `\n`, `\r\n` and `\r` each as one line end, a
position's line in the client's text is its line in the normalized text and
its character is the same within it: the editor's CRLF buffer and the
compiler's LF text agree without any mapping (`lsp-lang-line-endings`: LF,
CRLF, lone CR and mixed versions of one document give the same diagnostics
at the same positions and the same answers).

| Case | Rule | Tests |
|---|---|---|
| ASCII, BMP, astral, combining | UTF-16 counts an astral character twice, everything else (a combining mark included) once; UTF-32 counts scalar values | `lsp-positions-encodings`, `lsp-positions-round-trip` (every offset, both encodings), `lsp-lang-unicode-positions` (a diagnostic and hovers after two emoji and after `e` + U+0301, UTF-16 and UTF-32 sessions) |
| a character inside a surrogate pair | the pair's character | `lsp-positions-edges` |
| past a line's end | the line's end (the protocol's rule) | `lsp-positions-edges` |
| past the last line | no position: `null` (no locations) | `lsp-positions-edges` |
| a negative or non-integer line or character | `InvalidParams` | `lsp-proto-invalid-params` |
| end of line, end of file | positions like any other | `lsp-positions-round-trip` |

### 5.2 URIs

`uri.tcl` converts `file:` URIs and paths, for either platform's rules on
any host (the functions take the platform, so both are tested everywhere):

* percent-escapes decode as UTF-8 (spaces, `#`, `%`, any Unicode name);
  a path encodes everything outside `A-Za-z0-9/._~-`;
* Windows: `file:///C:/x` and `file:///c%3A/x` (as VS Code writes it) are
  the drive paths `C:/x` and `c:/x`; `file://server/share/x` is the UNC path
  `//server/share/x`; backslashes are separators;
* Unix: `file://localhost/x` is `/x`; a URI with another host names
  another machine's file and is refused;
* another scheme, a malformed escape, escapes that are not UTF-8, a NUL:
  `{LSP URI UNSUPPORTED}` with the reason (a request: `InvalidParams`).

Paths are compared normalized (`file normalize`, as the compiler's own are).
For an open document the server answers with the URI the client opened it
by, so a client that compares URIs as strings finds its diagnostics.
`lsp-uri-unix`, `lsp-uri-windows` and `lsp-lang-unicode-paths` (a project in
a directory named `é dir 😀`) cover it.

**The standard library inside the single executable** is in its zipfs
archive (`//zipfs:/app/botlish/stdlib`), where no editor can open a file.
At the first location in it the server copies the library's `.bot` files,
once per build, to the cache directory the executable already uses
(`~/.cache/botlish/stdlib-ID`) and translates paths between the two at the
URI boundary only (`External`, `Internal`); the compiler keeps reading the
archive. A library module the editor then opens maps back to the archive's
path, so its owner is found as for any module. `single/smoke-test.sh`
checks it.

## 6. Scheduling decision

The compiler service's analysis takes 0.2-1.5 s on the repository's
applications and about 7.5 s on the 2048 golden program, and Tcl's event loop
reads nothing while a procedure runs. Two strategies were built behind one
interface (`scheduler.tcl`: `submit`, `cancel`, `busy`, `document` and a
delivery callback) and measured against each other.

**Synchronous and debounced** (`-lsp-scheduler sync`). A change restarts
the program's debounce timer (250 ms by default); when it fires, the
analysis runs in the server's process, on its event loop, in the
workspace whose overlay is the editor's documents; the result is delivered,
diagnostics published, waiting requests answered. A newer version replaces
a queued job; a running one cannot be interrupted, and its result -- fresh
when it ends, since nothing was read meanwhile -- is published before the
messages that arrived during it are read. Simple, one process, one copy of
everything.

**A persistent worker** (`-lsp-scheduler worker`, the default). The server
keeps the protocol, the event loop, the documents and their versions, the
revisions it answers from, what it published and every request; a worker
process (`main.tcl -lsp-worker`, started at `initialize`, so it boots while
the editor opens files) keeps the compiler loaded, its bytecode compiled and
its parse cache warm, and runs the analyses. They talk over the worker's
stdin and stdout with a private, versioned protocol (Content-Length
framing, each message a UTF-8 Tcl list): `hello` (protocol version and
front-end fingerprint: a worker of another tree is refused), `documents`
(the overlay entries that changed since the worker last heard), `analyze`,
and back `revision` (the `service::export` text) or `failed`. Each revision
carries its HIR in the HIR interchange format -- no other serialization of
compiler semantics was invented -- plus the query indexes of the documents
the editor has open, which the worker computes where its parse cache is
warm (`service::prepare -paths`, `service::export -derived 1`); the server
imports it as a revision of its own workspace (`service::import`), whose
queries activate its HIR like any other's (COMPILATION-ISOLATION.md).

The debounce is the server's, so it is the same for both: a change
submits its programs' jobs 250 ms after the last change before it.

**Supersession and cancellation.** A program has at most one job queued: a
newer submission replaces it, so an intermediate version is never analyzed
when a later one is available. A newer job for the program whose job is
running supersedes it: the worker is killed (`kill -KILL`, `taskkill /F` on
Windows) and reaped, and a new one starts for the newer job; the old job's
partial output can never be taken for a result (an incomplete frame is no
message), and nothing it would have said is published. Supersession of an
analysis and cancellation of a request are distinct: `$/cancelRequest`
answers the waiting request `RequestCancelled` and leaves the analysis
alone (another request, or the diagnostics, still want it); closing a
program cancels its job. A worker that dies on its own -- a crash, or
output that breaks its protocol (the worker treats an error of its own as
fatal rather than going silent) -- is reported on stderr and to the
editor's log (`window/logMessage`), its job reported crashed, the last
revision kept, and the next job starts a new worker; at most five restarts
a minute. The worker is no daemon: it reads its stdin, and exits when the
server closes it, says `exit`, or dies; a server never leaves one behind
(`lsp-sched-shutdown-outstanding`, `lsp-sched-superseded`,
`lsp-sched-worker-crash` check every worker process is gone).

**The measurement.** `bench/lsp.tcl` replays one scripted editing session
per workload through both strategies -- the real server in a child process,
over real pipes: open the entry and the module it edits; then 40 edits of
the imported module, one every 150-300 ms (seeded), each a different text;
inside each interval a hover of the entry (answerable from an available
revision: the entry is unchanged, so its last revision interprets the
position, stale or fresh), and every third interval one of the edited
module, in text the edit does not touch; then 20 hovers once idle. The
workloads are the compiler-service census's: csv (one file: the entry is
the edited module), the 2048 demo (8 files), the icy-tower headless program
and the 2048 golden suite, the largest program in the repository.

The comparison, from section 9's run (40 edits per session; milliseconds):

| workload | hover p95 editing: worker / sync | longest callback: worker / sync | last edit to its diagnostics: worker / sync | analyses killed (worker) | intermediate versions published: worker / sync |
|---|---:|---:|---:|---:|---:|
| csv | 8 / 168 | 53 / 315 | 544 / 436 | 0 | 1 / 12 |
| 2048 | 5 / 1,421 | 116 / 1,762 | 2,017 / 2,508 | 13 | 1 / 5 |
| icy | 8 / 805 | 61 / 1,015 | 1,453 / 1,632 | 8 | 1 / 6 |
| 2048-golden | 5 / 7,328 | 206 / 8,606 | 7,934 / 16,083 | 8 | 1 / 3 |

**What the numbers say.**

* *Responsiveness.* With the synchronous scheduler a request waits for
  whatever analysis is running: hover's p95 while editing is the analysis
  time (168 ms on csv, 1.4 s on the 2048 demo, 0.8 s on icy-tower, 7.3 s
  on the golden suite), and the longest stretch the server read nothing is
  one whole analysis (0.3-8.6 s). With the worker, hover's p95 is 5-8 ms on
  every workload, and the longest callback is a revision's import or a
  message (53-206 ms): the target of about 200 ms p95 is met by the worker
  on all four workloads and by the synchronous design on the smallest
  only.
* *Diagnostics.* From the last edit to its diagnostics both take about one
  analysis on the applications (the worker 0.1 s longer on csv, whose
  analysis is shorter than the export, transfer and import add to it, and
  0.2-0.5 s shorter on the 2048 demo and icy-tower); on the golden suite the
  synchronous scheduler takes two (an analysis started before the last edit
  must finish first), the worker one, because it abandons the obsolete
  analysis. While edits keep coming faster than an analysis, the worker
  publishes nothing in between (a result whose input has changed is never
  published: 4.4), and the synchronous scheduler publishes a version the
  user has already typed past -- fresh by the server's clock only because it
  read nothing meanwhile.
* *Work.* The worker kills the analyses that edits overtake (8-13 per
  40-edit session on the three larger workloads, 3.6-7.9 s of analysis);
  the synchronous scheduler cannot, and runs them to completion before it
  reads the next edit. Each kill costs a new worker's start (about 80 ms
  to its `hello`, then an analysis with the compiler's caches empty), which
  the measurements include.
* *Transfer and memory.* A revision crosses the pipe as 0.3-3 MiB of text
  (its HIR, its sources' texts and the open documents' indexes) and is
  imported in 9-107 ms. The two processes together hold 1.6-1.9 times
  what the synchronous server holds alone (section 9.3): the server keeps
  the revisions and the front end its queries need, the worker the
  compiler and its caches.
* *Equivalence.* On every workload both strategies end with identical
  diagnostics and identical idle hover answers, and exit 0.

**Decision: the persistent worker is the production scheduler**
(`-lsp-scheduler worker`, the default). It is the only one of the two that
keeps the editor responsive during the analyses of real programs, which take
longer than a keystroke interval on everything but the smallest program, and
it costs one more process, more memory -- the two processes together hold
1.6-1.9 times what the synchronous server alone does (section 9.3) -- and an
import per result. The synchronous scheduler stays, as `-lsp-scheduler
sync`: it is the reference the tests compare the worker with
(`lsp-lang-schedulers-agree`), and it needs no second process where one
cannot be started.

## 7. Correctness

The server is a consumer of the compiler service, never a second source of
compiler truth. What that means, and how each part is held to it:

* **Diagnostics are the CLI's.** `lsp-lang-agrees-with-check` opens a
  program with an error in its entry and one in a closed module, and
  another with a warning, and compares what is published with what
  `main.tcl -check` prints for the same files -- message, code, line and
  column, per file, in order -- and every published range with the
  service's own record for a direct analysis in the test's process. They
  are equal. Both report `hir::recovery::entries` of the strict
  compilation's reported set; the server converts, it never parses the
  CLI's text or filters a diagnostic (when an error hides a warning, it is
  hidden in both).
* **Queries are the service's.** `lsp-lang-agrees-with-service` asks hover
  and definition at every other column of every line of a program with
  functions, parameters, locals, destructured fields, loop variables,
  function values and calls into a module and the standard library -- over
  170 positions -- and compares each answer with `service::at` on a direct
  analysis of the same text, converted. They are equal (the hover of a
  standard-library symbol adds its Compilerpedia topic line, from the same
  facts).
* **References are by identity.** `lsp-lang-references-identity`: two
  parameters named `n` in two functions each have their own references;
  `includeDeclaration` adds the declaration. The server never searches
  text (the `references-by-spelling` mutant, which does, is killed).
* **Compilerpedia by identity.** A diagnostic's `data.topic` is
  `service::explain`'s (the topic main.tcl's help line names); a hover's
  topic line comes from the service's `topics` fact, which associates a
  topic only with what a name resolves to: a program's own `get` gets none,
  `std::list::get` gets `stdlib.std::list::get` (`lsp-lang-topics`).
* **The schedulers agree.** `lsp-lang-schedulers-agree` replays one editing
  session -- open, hover four ways, definitions into a module, `std::` and
  the entry, references, a semantic error and its fix, a syntax error with
  stale answers, recovery -- through the synchronous scheduler and through
  the worker, and requires identical results; the benchmark checks the same
  on the census's workloads (section 6).
* **The worker's revisions are the analysis's.** `cs-export-import-agrees`
  compares an exported and imported revision with the original -- summary,
  diagnostics, texts, and the facts at every position of every source (more
  than 500) -- after programs with conflicting declarations were analyzed
  in between; `cs-export-import-activation` shows the imported revision's
  queries reading its own declarations (activation) after such a program;
  `cs-export-import-outcomes` covers revisions without a HIR (syntax,
  loader) and a trait program, whose queries read the checked source build
  the export includes; `cs-import-refuses` refuses text that is not an
  export, an export of another configuration, and HIR of another front end.

## 8. Tests

### 8.1 What runs

| File | Tests | What |
|---|---:|---|
| `tests/lsp.test` | 67 | below |
| `tests/lsp-neovim.test` | 1 | Neovim's own LSP client, headless, end to end (section 1); constraint `neovim`: `BOTLISH_NVIM`, or an `nvim` 0.10 or later on the path |
| `tests/compiler-service.test` | 5 new (54) | `service::export`/`import`: agreement, activation, outcomes without a HIR and with traits, refusals, query indexes (section 7); `cs-revision-bounded` now also checks that an edited file has one AST in the parse cache (section 9.3) |
| `tests/main-cli.test` | 9 new (61) | eight malformed invocations (an input file, `-backend`, `-check`, an unknown scheduler, `-lsp-scheduler` without `-lsp` or with `-lsp-worker`, `-lsp` with `-lsp-worker`, an unknown target), each exit 2 with its message; `-lsp` at the end of its input exits 1 having written nothing |
| `tests/numeric-looking-names.test` | -- | its `nl-no-string-ternary` source rule covers `lsp/` |
| `single/smoke-test.sh` | -- | a scripted `-lsp` session through the single executable, no Tcl installed |

`tests/lsp.test` has four parts. Every server test starts the real server
(`main.tcl -lsp`) as a child process and talks to it over real pipes through
`tests/lsp-client.tcl`, a protocol client written for the tests: it frames,
reads and decodes what the server writes, records every message in order with
its arrival time, and fails a test on a timeout instead of hanging.

| Part | Tests | Covers |
|---|---:|---|
| the layers (`lsp-json-*`, `-frame-*`, `-rpc-*`, `-positions-*`, `-uri-*`) | 19 | JSON round trips, escapes, malformed text (offsets), depth, types, a megabyte of text, valid UTF-8 output; framing split at every byte, several messages in one read, header variants, every framing error, oversize messages skipped as they arrive; JSON-RPC classification; positions in both encodings at every offset, surrogates, line ends; URIs on both platforms' rules |
| protocol (`lsp-proto-*`) | 16 | the capabilities exactly; encoding negotiation; the lifecycle in every order; exit codes; a message written a byte at a time; two in one write; request ids of every kind; non-ASCII; malformed JSON and JSON-RPC; invalid params; notifications never answered; end of input; oversize; an unreadable header; stdout holding nothing but frames (both schedulers, the worker's logging included) |
| language (`lsp-lang-*`) | 19 | the editing session; the two schedulers agreeing; agreement with `main.tcl -check` and with the service (section 7); references by identity; module edits, closes and loader errors; overlays never written; two programs and a shared module (ownership); LF, CRLF and CR; astral and combining characters; Unicode paths; a library document; diagnostics of closed modules; out-of-order versions; stale locations; Compilerpedia topics |
| scheduling (`lsp-sched-*`) | 13 | rapid versions (both schedulers: skipped, ordered, released); a hover during a long analysis (both: answered at once by the worker, after it by sync); cancellation; a document advanced beyond its analysis; a worker crash; an obsolete result; shutdown with requests waiting; supersession; closing a program with a job pending; a stale result never published; a superseded analysis really stopped |

The scheduling tests make time deterministic with the server's test hooks
(`BOTLISH_LSP_FAULT`, read only at start, never set in production):
`analysis-delay=MS` lengthens every analysis, `crash-marker=TEXT` makes a
worker die mid-result when a document contains TEXT (it writes half a frame
first), `hold-result=1` holds the first result until the second has
arrived. No test sleeps for a fixed time to wait for the server: each waits
for the message it expects, with a timeout.

### 8.2 Results

| Run | Result |
|---|---|
| `tclsh9.0 tests/lsp.test` | 67 passed (about 40 s alone; 53-57 s beside other test files) |
| `tclsh9.0 tests/lsp-neovim.test` (Neovim 0.11.4) | 1 passed |
| `tclsh9.0 tests/local.tcl` with `lsp.test`, `lsp-neovim.test`, `compiler-service.test`, `main-cli.test`, `numeric-looking-names.test`, `compilerpedia.test`, `decimal-rounded.test`, `hir-interchange.test`, `hir-cache.test`, `surface-modules.test`, `imports.test`, `application-modules.test`, `diagnostic-recovery.test`, `std-namespace.test`, `golden.test` | every file on interp and compile, and the golden suites holding their duplicates on four backends: all ok |
| the front-end fixes (section 9.3) | `decimal-rounded.test` 42 passed, its golden suite 37/37 on four backends, `audit/decimal-rounded/tools/fuzz.tcl` seeds 1, 17 and 41 with no disagreement, its 24 mutants killed, `cargo test --lib decimal`; every mutant of the harnesses that edit `core/` or `surface/modules.tcl` still applies |
| `tclsh9.0 tools/compilerpedia.tcl check` | 0 problems (782 topics, 579 examples) |
| `tclsh9.0 audit/golden/migration/merge.tcl ... -check` | the manifest is current (82 rows added, none changed; the new tests are KEEP-INTERNAL -- the layers -- or KEEP-MULTI-PROGRAM -- server sessions, processes and pipes: nothing a golden suite can express) |
| `single/build.sh` and `single/smoke-test.sh` | the -lsp session passes (hover, diagnostics, definition into the extracted library, the worker started from the executable) |
| CI | Linux (`tests.yml`, every job, at `be9b1ef3`): passed -- the whole Tcl suite on interp and compile, `lsp.test` and `lsp-neovim.test` (Neovim 0.11.4) included, 9113 tests on interp, 0 failed; Windows x86-64 smoke (main-cli.test among its files) passed at `fab5d4cb`; the macOS and Windows acceptance tiers (`lsp.test` and `compiler-service.test` among them) were still running when this was written |

### 8.3 Mutation testing

`audit/lsp/tools/mutate.tcl` applies each mutant of `audit/lsp/tools/mutants.txt`
to a private copy of the tree, runs the test files its `%%` line names
(restricted to the tests that can see it, to keep the run under an hour), and
requires a failure. The 30 mutants are the milestone's failure modes, one each:

| Area | Mutants |
|---|---|
| transport | `length-in-characters` (Content-Length counts characters), `fragment-is-message` (a partial body is taken for a message) |
| JSON, JSON-RPC | `string-is-boolean` (the string `"true"` written as `true`), `notification-answered`, `missing-id-is-request` |
| coordinates | `positions-in-bytes` (UTF-8 offsets for UTF-16), `no-normalization` (CRLF counted as two characters), `default-encoding-utf32`, `uri-drive-letter` (a Windows drive URI kept as `/C:/...`) |
| documents | `overlay-ignored` (analyses read the disk), `closed-not-withdrawn`, `importer-not-reanalyzed`, `every-document-a-program`, `out-of-order-accepted` |
| stale results | `stale-publishes`, `stale-not-reanalyzed`, `obsolete-applied`, `location-not-mapped`, `stale-hover-unmarked`, `stale-definition-at-once` |
| queries | `references-by-spelling`, `topics-by-name` |
| scheduling | `sync-despite-worker`, `worker-not-killed`, `crash-ends-server`, `cancel-unanswered`, `revisions-not-released`, `log-to-stdout` |
| the service's export | `export-without-trait-source`, `import-any-configuration` |

All 30 are killed. The first complete run left four alive, and each
taught something:

* `overlay-ignored` removed the editor's text from the server's workspace
  only, where the worker scheduler does not analyze: the mutant was
  incomplete. It now withholds the text from both workspaces, and its
  focus includes `lsp-lang-schedulers-agree`, whose sync half analyzes in
  the server's.
* `stale-not-reanalyzed` survived because in `lsp-sched-stale-result` the
  module that changed was owned by the program itself, whose next job
  re-analyzed it anyway. The test now makes another open program the
  module's owner, so only the re-analysis rule brings the right
  diagnostics.
* `worker-not-killed` survived because a superseded worker's result is
  correctly discarded either way. Not killing it has a cost the tests did
  not see: closing the pipe of a live child waits for it.
  `lsp-sched-supersede-responsive` sends a request right after a
  supersession, while the old analysis (lengthened to 4 s) would still be
  running, and requires the answer within 2 s.
* `revisions-not-released` survived because the rapid-versions test's
  revisions were all released through supersession of queued jobs, never
  replaced. The test now ends with four versions analyzed one by one and
  reads the server's own count of live revisions.

The second complete run killed all 30, and so did a third on the final
tree (`audit/lsp/results/mutate.md`).

The compiler service's own mutants (`audit/compiler-service/tools/mutate.tcl`,
21) are all still killed with `export` and `import` added; the HIR
interchange and diagnostic-recovery mutants still apply.

## 9. Performance

`tclsh9.0 bench/lsp.tcl -edits 40 -memory 40`
(`audit/lsp/results/bench.md`), on the 4-processor development container,
nothing else running; Tcl 9.0.1; every analysis with `-warnings off`, as the
census measured. The method is section 6's: per workload and scheduler, one
server, two documents open (the entry and the module edited), 40 edits of
the module 150-300 ms apart with hovers in between, then 20 hovers once
idle. Latency is measured by the client, from writing the request to reading
its response; everything else the server measures itself
(`BOTLISH_LSP_STATS`, lsp/stats.tcl). The analyses themselves are the
service's (COMPILER-SERVICE-CENSUS.md, section 7.2: about 0.2 s for csv, 1.3
s for the 2048 demo, 0.8-1 s for the icy-tower program, 6-8 s for the 2048
golden suite).

### 9.1 Requests

| workload | scheduler | editing: median | p95 | p99 | max | idle: median | p95 | max |
|---|---|---:|---:|---:|---:|---:|---:|---:|
| csv | worker | 3 | 8 | 14 | 14 | 2 | 3 | 5 |
| csv | sync | 3 | 168 | 269 | 269 | 1 | 2 | 7 |
| 2048 | worker | 3 | 5 | 94 | 94 | 2 | 2 | 14 |
| 2048 | sync | 241 | 1421 | 1599 | 1599 | 2 | 3 | 46 |
| icy | worker | 3 | 8 | 66 | 66 | 2 | 2 | 4 |
| icy | sync | 6 | 805 | 965 | 965 | 2 | 4 | 34 |
| 2048-golden | worker | 3 | 5 | 20 | 20 | 2 | 3 | 11 |
| 2048-golden | sync | 3586 | 7328 | 7415 | 7415 | 2 | 4 | 131 |

The hover target -- p95 around 200 ms or better, on the census's workloads
-- holds for the worker with a wide margin: 5-8 ms at p95, at most 94 ms.
The idle latency of either scheduler (1-2 ms median) is the cost of a query
on a prepared revision: `service::at` reads indexes built once per revision,
in the worker for the open documents (section 6), and the protocol around
it. The maximum idle latency (up to 46 ms on the 2048 demo and 131 ms on the
golden suite with the synchronous scheduler, 14 ms with the worker) is the
first query of a document whose indexes no one prepared -- a module that is
not open, or the first hover before the server's own `Prepare` ran. With the
synchronous scheduler a hover while editing waits for the analysis in
progress, and its p95 is the analysis time.

### 9.2 Diagnostics, the event loop, analysis work

| workload | scheduler | first diagnostics (ms) | last edit to its diagnostics (ms) | longest callback (ms) | analyses run | killed (ms of their work) | intermediate versions published |
|---|---|---:|---:|---:|---:|---:|---:|
| csv | worker | 411 | 544 | 53 (warm) | 11 of 11 submitted | 0 (0) | 1 |
| csv | sync | 297 | 436 | 315 (analysis csv.bot) | 13 of 13 submitted | 0 (0) | 12 |
| 2048 | worker | 1882 | 2017 | 116 (worker message) | 2 of 16 submitted | 13 (7056) | 1 |
| 2048 | sync | 1825 | 2508 | 1762 (analysis demo.bot) | 6 of 7 submitted | 0 (0) | 5 |
| icy | worker | 1173 | 1453 | 61 (worker message) | 4 of 13 submitted | 8 (3602) | 1 |
| icy | sync | 990 | 1632 | 1015 (analysis headless.bot) | 7 of 8 submitted | 0 (0) | 6 |
| 2048-golden | worker | 8350 | 7934 | 206 (worker message) | 2 of 11 submitted | 8 (7912) | 1 |
| 2048-golden | sync | 7705 | 16083 | 8606 (analysis golden.bot) | 4 of 5 submitted | 0 (0) | 3 |

"Longest callback" is the longest time the server's event loop was busy in
one callback, with what it was doing: with the worker, importing a revision
or handling a message; with the synchronous scheduler, an analysis.
"Analyses run" counts the analyses that finished: a submission replaced
while queued never starts, and a killed one never finishes. "Intermediate
versions published" counts publications of a version that was already
superseded when published.

### 9.3 Worker, transfer, memory

| workload | scheduler | server start (ms) | worker starts | worker start to hello (ms, mean) | analysis in the worker (ms, mean) | indexes and export in the worker (ms, mean) | import (ms, mean) | transferred (KiB, mean) | server RSS max (MiB) | worker RSS max (MiB) | processes |
|---|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| csv | worker | 102 | 1 | 82 | 220 | 20 | 9.0 | 276 | 30 | 28 | 2 |
| csv | sync | 87 | 0 | - | - | - | - | - | 34 | - | 1 |
| 2048 | worker | 77 | 14 | 80 | 1477 | 97 | 68.7 | 1870 | 84 | 79 | 2 |
| 2048 | sync | 86 | 0 | - | - | - | - | - | 97 | - | 1 |
| icy | worker | 75 | 9 | 84 | 866 | 78 | 28.3 | 910 | 57 | 56 | 2 |
| icy | sync | 73 | 0 | - | - | - | - | - | 72 | - | 1 |
| 2048-golden | worker | 71 | 9 | 94 | 7410 | 242 | 106.5 | 3138 | 138 | 175 | 2 |
| 2048-golden | sync | 77 | 0 | - | - | - | - | - | 212 | - | 1 |

* **Start.** The server answers `initialize` within about 100 ms of being
  started (it loads the compiler service; the compiler's bytecode is
  compiled lazily, by the first analysis). The worker, started at
  `initialize`, says `hello` about 80 ms after it is started; its first
  analysis then pays the compiler's warm-up, which the first diagnostics'
  time includes.
* **Transfer.** A revision's text is 0.3 MiB (csv) to 3 MiB (the golden
  suite): its HIR in the interchange format, the texts of its sources (the
  stale policy compares them), and the open documents' query indexes. Its
  import takes 9-107 ms; the indexes and the export cost the worker
  20-242 ms beside its analysis.
* **The import's one bottleneck, fixed.** The first measurements showed
  icy-tower's import at 167 ms, against 49 ms for the 2048 demo, whose
  revision is twice as large. 150 of those milliseconds were one decimal
  constant: choosing the representation of `0.0` (HIR interchange carries a
  DecimalRounded constant's decimal, and the reader chooses its binary64
  again: HIR-INTERCHANGE.md) compared its exact binary64 with the two
  subnormals beside it, and ruling a subnormal out walks some 320
  precisions of 1074-bit rationals. `core::decimal::Represent` now returns a
  binary64 that is the decimal exactly before looking at its neighbors --
  nothing can satisfy the guarantee better, so the choice is unchanged
  (`tests/decimal-rounded.test`, its golden suite, its fuzzer on three
  seeds and its 24 mutants agree) -- and the import takes 21 ms. Every
  compilation of a program with a DecimalRounded `0.0` saves the same time.
* **Memory, and the second bottleneck fixed.** The first long sessions
  (40 analyzed edits of the module) showed the process that analyzes --
  the worker, or the synchronous server -- growing by 2.5 MiB per edit
  (the worker 79 to 182 MiB on the 2048 demo, 177 to 282 MiB on the golden
  suite), while the worker design's server stayed flat (96-98 and 160 MiB:
  it releases what it replaces, 4.7). The growth was the loader's parse
  cache (`surface::modules::parsed`), keyed by a file's path and text:
  every edited text of the module was a new entry, kept until the cache's
  bound of 64 entries cleared it whole -- the plateau of about 220 MiB
  COMPILER-SERVICE-MILESTONE-1.md measured for analysis in a loop. For a
  language server that plateau is dead ASTs of texts the editor has moved
  past. The cache now keeps one AST per file -- a file's newer text
  replaces its older one; every unchanged module is still reused, and the
  bound stays -- and 40 analyzed edits leave the analyzing process at its
  first round's size (68 to 72 MiB, in process; `cs-revision-bounded`
  checks the edited file has one entry). The long sessions after the fix:

| workload | scheduler | round 1 | round 10 | round 20 | round 30 | round 40 | max |
|---|---|---:|---:|---:|---:|---:|---:|
| csv | worker | 27/28 | 30/28 | 30/28 | 29/28 | 30/28 | 30 / 28 |
| csv | sync | 33/- | 34/- | 34/- | 34/- | 34/- | 34 / - |
| 2048 | worker | 78/87 | 97/87 | 97/79 | 97/79 | 97/87 | 97 / 87 |
| 2048 | sync | 94/- | 97/- | 97/- | 98/- | 98/- | 98 / - |
| icy | worker | 49/58 | 56/59 | 56/59 | 56/59 | 56/59 | 56 / 62 |
| icy | sync | 68/- | 71/- | 71/- | 71/- | 71/- | 71 / - |
| 2048-golden | worker | 124/173 | 156/175 | 156/175 | 158/175 | 158/175 | 158 / 175 |
| 2048-golden | sync | 206/- | 211/- | 211/- | 211/- | 211/- | 211 / - |

Both designs now reach their size within the first ten edits and keep it.
After 40 edits the worker design's two processes hold 58 (csv), 184 (2048),
115 (icy) and 333 MiB (the golden suite), the synchronous server 34, 98, 71
and 211 MiB: 1.6 to 1.9 times as much, the price of a second process with
its own copy of the front end.

### 9.4 Crash recovery

| workload | crash reported after (ms) | next edit to its diagnostics (ms) | workers started | exit |
|---|---:|---:|---:|---:|
| csv | 258 | 585 | 2 | 0 |
| 2048 | 264 | 2171 | 2 | 0 |
| icy | 262 | 1149 | 2 | 0 |
| 2048-golden | 273 | 8431 | 2 | 0 |

A worker that dies mid-result is reported about 260 ms after the edit that
crashed it (most of it the analysis it was running), the job is reported
crashed, the last revision keeps answering, and the next edit starts a new
worker: its diagnostics arrive in one analysis plus the new worker's start.
The server exits 0 after `shutdown`.

### 9.5 Against the census

The census answered that whole-program analysis is acceptable for a first
server -- diagnostics after a debounce, queries from the last revision
(its answer 2) -- and left open how a long analysis should coexist with an
event loop without threads (its question 3), proposing to compare blocking
with supersession against a worker `tclsh` per analysis that returns
diagnostics only, no HIR crossing. Both answers are now measured. Blocking
is what `sync` does, and its hover p95 is the analysis time. The worker
built here differs from the census's proposal twice, each for a measured
reason: it is persistent, because a process per analysis would pay the
compiler's load (80 ms) and a cold compiler every time; and its revisions
do cross, as HIR interchange text, because hover, definition and
references need the analyzed program and a server that only received
diagnostics would have to analyze again to answer them. The cost of moving
a revision -- export and indexes in the worker, transfer, import --
is 30-350 ms per result, small against the analyses. The
census's query target (a position query of 5 ms or less at 2048-golden size)
holds through the protocol: the idle hover median is 1-2 ms.

## 10. Files and usage

### Production

| File | Role |
|---|---|
| `lsp/lsp.tcl` (new) | loads the language server |
| `lsp/transport.tcl` (new) | Content-Length framing over Tcl channels |
| `lsp/json.tcl` (new) | typed JSON values: reading (strict UTF-8, scalar values only) and writing |
| `lsp/jsonrpc.tcl` (new) | JSON-RPC 2.0 messages and error codes |
| `lsp/positions.tcl` (new) | UTF-16 and UTF-32 positions and the compiler's scalars |
| `lsp/uri.tcl` (new) | `file:` URIs and paths, Unix and Windows |
| `lsp/server.tcl` (new) | the language server |
| `lsp/scheduler.tcl` (new) | the synchronous and worker schedulers, the worker protocol |
| `lsp/worker.tcl` (new) | the analysis worker |
| `lsp/stats.tcl` (new) | the server's own measurements |
| `service/service.tcl` | `service::export`, `service::import`, `service::prepare -paths -compilerpedia` |
| `core/decimal.tcl` | `Represent` returns an exact binary64 before weighing its neighbors (section 9.3) |
| `surface/modules.tcl` | the loader's parse cache keeps one AST per file (section 9.3) |
| `main.tcl` | `-lsp`, `-lsp-scheduler`, `-lsp-worker`: the option table, the usage, the header comment, the option policy |
| `compilerpedia/topics/backends.topic` | `cli.lsp` (new), `cli.options`, `cli.usage`, `cli.exit-status` |
| `single/package.tcl`, `single/main.tcl` | packs `lsp/`; `-lsp` and `-lsp-worker` install no native backend |
| `editors/neovim/botlish.lua` (new) | the Neovim configuration |

### Tests, harnesses, packaging checks

| File | Role |
|---|---|
| `tests/lsp.test` (new, 67 tests) | the layers on their own; the server over real pipes: protocol, language, scheduling |
| `tests/lsp-client.tcl` (new) | the protocol client the tests and the benchmark drive the real server with |
| `tests/lsp-neovim.test`, `tests/lsp-neovim.lua` (new) | Neovim's own client end to end (needs Neovim; skipped without) |
| `tests/compiler-service.test` | five tests of `service::export`/`import`; `cs-revision-bounded` checks one AST per edited file |
| `tests/main-cli.test` | eight malformed `-lsp` invocations, `-lsp` at the end of its input |
| `tests/numeric-looking-names.test` | its source rule now covers `lsp/` |
| `audit/lsp/tools/mutate.tcl`, `mutants.txt` (new) | the mutation harness, 30 mutants |
| `bench/lsp.tcl` (new) | the scheduling comparison and the performance report |
| `audit/lsp/results/` (new) | the benchmark's report and the mutation run |
| `single/smoke-test.sh` | a scripted `-lsp` session through the single executable |
| `.github/workflows/tests.yml` | a pinned Neovim for `tests/lsp-neovim.test` |
| `audit/golden/migration/census/lsp.tsv`, `lsp-neovim.tsv` (new), `compiler-service.tsv`, `main-cli.tsv`, `tcl-names.txt`, `tests/golden/manifest.tsv` | census rows of the new tests, the regenerated manifest (82 rows added, none changed) |

### Commands

```sh
export LANG=C.utf8 LC_ALL=C.utf8
# The server
tclsh9.0 main.tcl -lsp                         # or: botlish -lsp
tclsh9.0 main.tcl -lsp -lsp-scheduler sync     # the reference scheduler
BOTLISH_LSP_STATS=/tmp/s.txt tclsh9.0 main.tcl -lsp   # its measurements at exit
# The tests
tclsh9.0 tests/lsp.test
BOTLISH_NVIM=/path/to/nvim tclsh9.0 tests/lsp-neovim.test
tclsh9.0 tests/compiler-service.test -match 'cs-export-* cs-import-*'
tclsh9.0 tests/local.tcl tests/lsp.test tests/compiler-service.test tests/main-cli.test
tclsh9.0 audit/lsp/tools/mutate.tcl            # ?-only NAME,...?
tclsh9.0 bench/lsp.tcl                         # ?-workloads ...? ?-edits N? ?-memory ROUNDS? ?-out FILE?
single/build.sh -o /tmp/botlish && single/smoke-test.sh /tmp/botlish
```

Neovim: `dofile('/path/to/botlish/editors/neovim/botlish.lua')` in
`init.lua`, with `vim.g.botlish_lsp_cmd = { 'tclsh9.0',
'/path/to/botlish/main.tcl', '-lsp' }` for a checkout (the default is
`botlish -lsp`). Any other client: the command `botlish -lsp` over stdio,
for `.bot` files (section 1).

## 11. Limitations

* **Whole-program analysis per change.** A change costs a whole analysis of
  each program it concerns (0.2-1.5 s on the repository's applications,
  about 7.5 s on the 2048 golden program: section 9). The worker keeps the
  editor responsive meanwhile; it does not make diagnostics arrive sooner
  than the analysis takes. No incremental or module-granular reuse, by
  design.
* **No semantics through a syntax or loader error.** One such error anywhere
  in a program removes its HIR (COMPILER-SERVICE-MILESTONE-1.md, section 9).
  The last analysis keeps answering where the text is unchanged (hover
  marked stale), but nothing is answered about the text being typed, and a
  module with a syntax error contributes nothing.
* **One edit region.** A stale revision interprets a position only in the
  unchanged prefix or suffix of one contiguous difference between the text
  it analyzed and the current one. Two separate edits since the last
  analysis with a HIR leave everything between them unanswered until the
  next one (`lsp-lang-stale-locations` shows a single region; a line-based
  difference would map more).
* **Stale semantics are not proven current.** A hover from a stale revision
  can be wrong about meaning (an import changed it); it says so. A stale
  definition or reference is returned only when no analysis is pending and
  its location denotes the same text, but its *target* is the old
  analysis's.
* **References within one program.** References are one analyzed program's
  (its entry and the modules it loads); another open program importing the
  same module is another analysis, and a module imported by two is answered
  from the first one opened (4.2). There is no workspace index, rename or
  workspace symbol search.
* **Queries answer value positions.** Type annotations, struct, enum,
  layout and trait declarations, field names and import headers have no
  hover or definition (the service answers them with syntax facts only).
* **Closed files changed outside the editor** are seen at the next analysis
  of their program, or at a save: there is no file watcher.
* **Revisions are retained whole**: up to two per program, each what its HIR
  and texts cost (section 9).
* **The worker is restarted on supersession.** A superseded analysis is
  stopped by killing the worker, which then pays its start (about a tenth of
  a second, plus warm-up) on the next job; an analysis is never interrupted
  more finely.
* **Neovim is the one real editor tested.** Others need only the command
  (section 1); VS Code would need a small extension to start a server, which
  this milestone does not include.

## 12. Next milestone

The recommendation follows from what the editor sessions of this milestone
showed, not from the protocol's list.

**What editing looked like.** With the worker, the editor never waits on
the compiler: hovers are answered in milliseconds while 2048-golden's
analyses take seconds (section 9). What degrades is *meaning while typing*.
Every keystroke that leaves an expression unfinished -- `a + `, an open
bracket, a half-written `fn` line -- is a syntax error, and a syntax error
anywhere removes the program's HIR. In the Neovim session, typing `a + ` on
the last line turned the whole program's semantics stale: hover still
answered from the last analysis, marked stale, but only in text identical
to what that analysis saw; the line being typed -- where a user most often
asks -- answered nothing, and two separate edits (fixing an import while a
statement below is half-typed) leave everything between them unanswered.
The same holds for a module: one syntax error in an imported module makes
every importer's analysis a syntax outcome. The scripted sessions of the
benchmark never type invalid text, so they understate this; an editor
session cannot avoid it.

The candidates, against that:

1. **Syntax-error-tolerant analysis** (the census's open question 2): lower
   a recovered AST's well-formed statements -- or keep a module's last good
   declarations -- so that a program with a syntax error still has a HIR
   for everything but the broken construct, with diagnostics that never
   include one a clean build would not (the fidelity bar the census set,
   measured on the diagnostic-recovery corpus). It turns every query
   during typing from stale-or-nothing into fresh, removes most of the
   one-edit-region limitation (there is a current revision to ask), and is
   the prerequisite of completion, which is asked almost exclusively in
   incomplete text.
2. **Richer declaration and type-position queries**: hover and definition
   on type annotations, struct and enum declarations, field names and
   imports, which the service answers with syntax facts only. Real gaps, but
   in text that is usually well formed; they do not make the editor go
   dark while typing.
3. **Completion**: the most visible feature, but without (1) it would
   answer only in syntactically complete text, where it is least needed.
4. **Faster re-analysis**: the worker already hides latency from requests;
   diagnostics after an edit take one analysis (0.5-2 s for the
   applications, 8 s for the golden program). Worth doing for large
   programs (the census's P5, library reuse within a compilation), but no
   editor interaction was blocked by it.

**Recommendation: syntax-error-tolerant analysis next**, scoped as the
census framed it: recovered module and entry ASTs contribute their
well-formed top-level declarations; a construct the parser skipped is
poison where it is used (DIAGNOSTIC-RECOVERY.md); the fidelity of the
diagnostics is the acceptance criterion; the language server then needs no
stale mapping for the typed text, only for text a newer analysis has not
seen yet. Completion and type-position queries follow it.
