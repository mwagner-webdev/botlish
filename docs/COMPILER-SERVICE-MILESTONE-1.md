# COMPILER-SERVICE-MILESTONE-1.md

Botlish's first shared, in-process compiler service: structured front-end
diagnostics, a source-provider seam, immutable analysis revisions, semantic
position queries, Compilerpedia associations and `main.tcl -check`.

> Compilation and editor tooling must agree on what a program means. The
> compiler owns semantic facts and diagnostics; a reusable service makes
> those facts accessible without executing the program, inventing a second
> analysis, or requiring a daemon.

The census (`../audit/compiler-service/COMPILER-SERVICE-CENSUS.md`, at
`c7e4d4fd`) recommended three consecutive pieces of work -- P1, structured
front-end diagnostics; P2, a source-provider seam; S1, the service -- and
this milestone implements all three, on `main` at `9737bf0a` (the census's
own commit). The canonical `std::` namespace milestone it was concurrent with
has not landed (its branch, `claude/botlish-std-namespace-milestone-rjfef8`
at `c4a41f33`, is unmerged), so the seam is built on `main`'s loader; section
13 records a trial merge with that branch.

No syntax, HIR node, Core IR form, NIR instruction, registry, cache format,
backend or daemon was added. The compiler core gained the location of every
front-end diagnostic as data, one seam through which program source enters,
and two presentation functions; everything else is new code above it.

## Contents

1. [Result](#1-result)
2. [The contracts this milestone kept](#2-the-contracts-this-milestone-kept)
3. [Structured front-end diagnostics (P1)](#3-structured-front-end-diagnostics-p1)
4. [The source-provider seam (P2)](#4-the-source-provider-seam-p2)
5. [The service (S1)](#5-the-service-s1)
6. [Position queries](#6-position-queries)
7. [Compilerpedia](#7-compilerpedia)
8. [main.tcl -check](#8-maintcl--check)
9. [Syntax and loader failures](#9-syntax-and-loader-failures)
10. [Invariants](#10-invariants)
11. [Tests](#11-tests)
12. [Performance](#12-performance)
13. [Compatibility, and the std:: milestone](#13-compatibility-and-the-std-milestone)
14. [Limitations](#14-limitations)
15. [Deviations from the census's contract](#15-deviations-from-the-censuss-contract)
16. [Next milestone: the smallest stdio LSP](#16-next-milestone-the-smallest-stdio-lsp)
17. [Files, and what to run when changing this](#17-files-and-what-to-run-when-changing-this)

## 1. Result

### The command line

```text
$ tclsh9.0 main.tcl -check examples/surface/01-arithmetic.bot
== 01-arithmetic.bot (check)
   ok

$ tclsh9.0 main.tcl -check main.bot
== main.bot (check)
   error: main.bot:5:25: unbound name "missing" (CORE SEMANTIC UNBOUND)
   help: tclsh9.0 main.tcl -help error.unbound
   error: main.bot:9:14: argument for parameter "w" cannot be proven to satisfy int (argument type: str) (CORE SEMANTIC TYPE)
   help: tclsh9.0 main.tcl -help rule.type-argument
$ echo $?
1
```

`-check` analyzes each `.bot` input exactly as a compilation does and prints
what that compilation reports -- the same error lines, in the same words and
order, with the same `help:` lines, its warnings on stderr under the
`-warnings` policy -- without evaluating the program, generating native code,
linking or writing anything. A program that would loop forever when run is
checked at once (`cli-check-runs-nothing`). On the 14 cases of the
diagnostic-recovery corpus its error and help lines are byte-identical to a
run's (`cli-check-diagnostic-recovery-corpus`).

### The service, from Tcl

```tcl
source service/service.tcl
set ws [service::workspace -warnings default -cache ""]
# An unsaved CRLF edit of the imported module shapes.bot, version 7.
service::setDocument $ws $dir/shapes.bot "fn area(w: int, h: int) -> int:\r\n    w * h * 1\r\n" -version 7
set rev [service::analyze $ws $dir/main.bot]
service::diagnostics $rev            ;# structured records, below
service::at $rev $dir/main.bot 5 17  ;# the facts at line 5, column 17
service::release $rev
```

For the program of the command-line example (main.bot imports shapes.bot and
calls `shapes::area(s, missing)` on line 5), the session prints:

```text
semantic
CORE SEMANTIC UNBOUND 5:25-5:32 unbound name "missing"
CORE SEMANTIC TYPE 9:14-9:20 argument for parameter "w" cannot be proven to satisfy int (argument type: str)
construct: ref 5:9
hover:     fn shapes::area(w: int, h: int) -> int
definition: shapes.bot 1:4-8
references: main.bot:5:9 main.bot:9:1
binding:   id b1 name shapes::area kind local module shapes node area()
unavailable at 5:25: the name is not resolved (its diagnostic says why)
topics at 5:25: error.unbound
source of shapes.bot: exists 1 from buffer version 7 read 1
stale: .../shapes.bot                    (after setDocument ... -version 8)
refused: revision rev1 analyzed version "7" of its buffer at .../shapes.bot, not version "8": its positions are not that text's
state: workspaces 1 revisions 0 hirs 0 derived {}
```

What now works:

* **One analysis path.** The service's analysis is the front end's own
  lenient compilation (`surface::readProgramFile -strict 0`, the very build a
  strict compilation raises from), read through a source provider, and its
  diagnostics are the entries a strict compilation raises -- the same
  procedure produces both (section 3).
* **Unsaved buffers** for the entry and for any module, standard-library
  modules included; files created, deleted or replaced in the editor; any
  number of versions of one file; CRLF and lone-CR text analyzed exactly as
  its LF twin (section 4).
* **Immutable revisions** that keep answering about the text they analyzed
  after the workspace changes and after other programs are analyzed, refuse a
  query about another version, say which of their sources changed, and are
  released explicitly (section 5).
* **Position queries**: the construct, its range, the binding it declares or
  refers to, its type and hover text (never `block(eN)`), the definition's
  *name* range, every reference to the same binding in the revision, the
  diagnostics there and their Compilerpedia topics -- each fact present or
  explicitly unavailable with a reason (section 6). A query takes under
  0.1 ms at the median and about 0.5 ms at the 99th percentile on the
  census's largest workload, where the census's unindexed scan took 7.2 ms
  (section 12).
* **`main.tcl -check`**, with the service as its engine (section 8).

## 2. The contracts this milestone kept

The inventory (the census's section 2, re-read against the code before any
change) and what became of each contract:

| Contract | Where | Kept |
|---|---|---|
| Recovering and strict parsing | `surface::parse` (`-recover 1` returns every syntax diagnostic; strict raises them all, one error) | unchanged; the strict raise is now `surface::raiseSyntax`, and the entries it raises are built by `surface::syntaxEntries`, which the service reuses |
| Strict = lenient build + `reported` | `BuildProgram` always builds `-strict 0`; `surface::lower::Finish` raises `hir::recovery::reported` | unchanged: the service runs the same build and reports the same `reported` |
| Program-file compilation | `surface::readProgramFile` -> `compileProgramFile` | same options and results; now one source snapshot per compilation |
| Source acquisition | `core::ReadFile`, `file exists`/`file isfile` at 8 sites of `surface/modules.tcl`, the cache's `Contents`, the requires scan, `main.tcl`'s entry read | every site goes through `surface::source` (section 4); `core::ReadFile` itself is unchanged (it reads `.ir`/`.hir` files and cache entries) |
| Loader errors | `surface::modules::Error` | same code and text, now with the span as data |
| Deferred reference errors | `CollectAndLoad`'s trap, `RaiseReferenceErrors` | same order and text, each entry kept whole |
| Activation | `hir::activate`, `hir::declarations` | unchanged; the service calls it at its query boundary |
| HIR facts | origins (`file fN node ID start end line column endLine endColumn`), `ref.binding`, binding origins, types | read, never changed |
| Type presentation | `hir::types::show`, `hir::signatures::of`, `hir::semantic::SourceName`/`CallableName` | reused; `hir::types::presented` and `hir::signatures::text` added beside them |
| Interchange, front-end cache | `hir/interchange.tcl`, `surface/cache.tcl` | format unchanged; dependencies now read through the snapshot; a compilation that read a buffer is not stored |
| CLI presentation | `printError`, `helpHint`, `warningHints` | unchanged output; `warningHints` takes codes so `-check` shares it |
| Compilerpedia | `compilerpedia::topicForDiagnostic`, the catalogue | unchanged; `symbolTopics` added (an exact lookup in the catalogue's own symbol table) |
| The command line | `cliOptions`, `parseCommandLine`, usage, the `cli.options` topic, main.tcl's header | `-check` added to all four |

The test suites that pin these contracts -- `diagnostic-recovery`,
`compilation-isolation`, `main-cli`, `surface-*`, `imports`,
`application-modules`, `hir-cache`, `hir-interchange`, `warnings`,
`target-model` and the golden corpus on four backends -- pass unchanged but
for two expectations that pinned a dict's exact key set (section 13).

## 3. Structured front-end diagnostics (P1)

Every front-end diagnostic now carries its location as data at the place it
is produced, beside the text it always had. The shape is the one
`core::raiseDiagnostics` already took -- `{errorcode CODE message TEXT
?shown SHOWN?}` -- with four optional keys every producer now fills:

| Key | What |
|---|---|
| `summary` | the message without its `FILE:LINE:COLUMN: ` |
| `location` | the span TEXT names: `{file PATH start S end E line L column C endLine L2 endColumn C2}` (scalar offsets and columns of the normalized text, 1-based lines and columns, END exclusive), or `""` |
| `related` | the further spans it names, in order |
| `record` | the producer's own richer record: the HIR diagnostic, the warning, the syntax diagnostic |

The producers, each changed at the producing boundary, never by parsing text:

| Producer | Diagnostics | Change |
|---|---|---|
| `surface::diagnostic` (surface/ast.tcl) | every lexer and parser diagnostic | the dict gains `endLine` and `endColumn` from the span it was made from |
| `surface::syntaxEntries` / `raiseSyntax` (surface/parser.tcl) | a strict parse's error | factored out of `surface::parse`; entries located |
| `surface::modules::Error` | every loader error (UNKNOWN-NAMESPACE, CYCLE, MODULE-COLLISION, ...) | raises one located entry through `core::raiseDiagnostics` instead of a bare `throw` |
| `CollectAndLoad` | deferred qualified-reference errors | keeps each `Error` entry whole |
| `hir::recovery::entries` | semantic diagnostics | factored out of `hir::recovery::raise`; `location` from the origin, `related` from the diagnostic's related origins |
| `hir::warnings::Rejection` / `entry` | the warning policy's rejection; warnings | the rejection is one statement shared by `run` and the service; `entry` locates a warning (primary, secondaries) |

Precision: a location is the span the compiler already reported the
diagnostic at -- the import's namespace, the qualified reference, the
expression, a struct field's initializer. Where a producer located a
diagnostic at a whole statement (an INVALID-TOPLEVEL statement), that
statement is the culprit; no location was moved, because moving one changes
the CLI's text.

The explicit fallback, for a diagnostic with less than a span (the service's
`range`):

* `span` -- start and end exact (every diagnostic of the front end today);
* `point` -- the compiler gave a start only: the end is set to the start, a
  zero-width range, never extended to a guess;
* `none` -- no source location (a module file that cannot be read, a compiler
  failure): `file` and every position are `""`; nothing is invented.

Compatibility: every printed message, code, order and exit status is
unchanged. Two things a test could see changed: a syntax diagnostic's dict
(also the third element of a `{SURFACE SYNTAX DICT}` errorcode) has two more
keys, and a loader error and a warning rejection now come with
`-diagnostics` (one entry), as every other compiler error already did; main.tcl
prints such an entry exactly as it printed the bare error. One test pinned
the dict (`lex-error-code`) and was updated.

## 4. The source-provider seam (P2)

`surface/source.tcl` is the only way program source enters the front end:

```text
surface::source::exists PATH        1 if PATH is a usable source file
surface::source::text PATH          its text, normalized
surface::source::with PROVIDER SCRIPT    SCRIPT in a new snapshot of PROVIDER
surface::source::session SCRIPT     the snapshot in force, or a new one of the disk
surface::source::observed           what the snapshot answered
surface::source::persistable        1 if every answer was the disk's
```

A provider is a command prefix answering `lookup PATH` (`{exists 0|1 from
disk|buffer ?version V?}`) and `text PATH`. `surface::source::disk` is the
default; `surface::source::overlay ENTRIES ?BASE?` answers for the paths it
holds -- a buffer's text, or `absent` -- and asks BASE about every other.
The loader's eight acquisition sites, `compileProgramFile`'s entry read, the
front-end cache's dependency reads, `surface::readProgramFile`'s requires
scan and main.tcl's entry read all call `exists`/`text`; nothing is wrapped
or renamed (`cs-seam-is-not-wrapping`). The provider answers for paths and
never decides resolution: which file a namespace denotes is still the
loader's search-free mapping, so every resolution rule -- application
modules, RESERVED-NAMESPACE, architecture files, platform namespaces -- is
untouched.

**Normalization** is one operation, `surface::source::normalize` ("\r\n" and
a lone "\r" become "\n"), applied once, in `text`, to every provider's text.
The disk provider reads without translation and the overlay stores what the
editor has; neither normalizes. That is exactly what `core::ReadFile`'s
`auto` translation always did to files, so a file analyzes as before, and a
buffer of the same document -- CRLF, lone CR or LF -- analyzes identically
(`cs-normalize-disk-equals-buffer`: the same diagnostics, positions, facts
and text for the six combinations). Coordinates inside the compiler stay
Unicode scalar values of the normalized text; no UTF-16 enters it.

**A snapshot.** Inside `with` (or a compilation's `session`), every path is
asked about once and every answer recorded: the paths read, with their text,
origin (disk or buffer) and the buffer's version, and the paths probed and
found empty. One compilation therefore sees one consistent set of sources
even if the disk changes meanwhile, and the record is its dependency set.

**The front-end cache** reads its dependencies through the snapshot, so a
lookup validates an entry against what this compilation sees -- a buffer
equal to the file is a hit, one that differs is stale
(`cs-cache-not-from-buffers`) -- and stores an entry only when every answer
of the compilation came from the disk (otherwise the new stats counter
`buffered`): an editor's transient text never displaces the disk's entry.
Validity stays a matter of contents and configuration; the key and the
entry format are unchanged.

The overlay probes of the census (`overlay.tcl`'s 17 checks) are permanent
tests on the real seam: a workspace that exists only in memory, unsaved fixes
and unsaved errors of the entry, an imported module's interface changed in a
buffer, v1/v2/v1/v2 alternation, a module created and one deleted in the
editor, a buffer that would be a standard namespace (RESERVED-NAMESPACE), a
standard-library module's buffer, a syntax error in a module's buffer.

One deliberate change: the loader asked `file exists` at five standard-library
sites and `file isfile` at the application site and in the cache. The seam
has one question, "is there a usable source file", answered `file isfile` by
the disk. A directory named like a standard module (`stdlib/foo.bot/`) used to
pass the loader's check and then fail to be read (an uncaught Tcl error); it
is now no module file (UNKNOWN-NAMESPACE), as it always was for the cache
and for application modules.

## 5. The service (S1)

`service/service.tcl`, namespace `service`, is new Tcl over the front end. It
loads the compiler front end, never a backend. Its interface:

| Call | Does |
|---|---|
| `workspace ?-target T? ?-warnings MODE? ?-cache DIR? ?-root DIR?` | a compilation environment: the C target, the warning policy, the front-end cache directory, the directory relative paths are taken from |
| `setDocument WS PATH TEXT ?-version V?` / `deleteDocument` / `clearDocument` / `documents` | the workspace's overlay: an unsaved buffer, an unsaved deletion, back to the disk |
| `analyze WS ENTRY ?-version V?` | a new revision |
| `revision REV` | what it analyzed (entry, version, configuration, every source with its origin and version) and how it ended |
| `diagnostics REV ?-severity S?` | its diagnostics |
| `sourceText REV PATH` | the text it analyzed at PATH |
| `stale REV` | the sources that changed since |
| `hir REV` | its HIR, for a caller that compiles or runs it |
| `at REV PATH LINE COLUMN ?-version V?` | the facts at a position (section 6) |
| `prepare REV` | builds its query indexes now |
| `explain DIAGNOSTIC` | its Compilerpedia topic |
| `release REV`, `closeWorkspace WS`, `revisions`, `state` | lifetime |

**A workspace** owns its overlay and its revisions. An entry program's
application root is the compiler's -- its file's directory (IMPORTS.md) --
whatever `-root` says; `-root` only resolves relative paths.

**A revision** is the analysis of one entry against one snapshot. It holds
the entry and the caller's version, the configuration the front-end cache
would key it by (target, warning mode, cache directory, application root,
library directory, loaded Tcl libraries, the front end's fingerprint, the
static scheduler), the snapshot's sources (text, origin, buffer version, and
the absences), the HIR (none for a syntax, loader or failure outcome), the
structured diagnostics, and its derived query indexes. Outcomes:

| Outcome | HIR | Meaning |
|---|---|---|
| `ok` | yes | no error (warnings possible) |
| `semantic` | yes | the errors a strict compilation reports; under `-warnings error`, the policy's rejection with the warning's code |
| `syntax` | no | the entry's syntax errors (all of them), or a module's (all of them) |
| `loader` | no | a module could not be loaded: an import that does not resolve, a qualified reference the file may not make, a module file that cannot be read |
| `failure` | no | the compiler failed (not a diagnostic of the program); its error and errorInfo are kept |

**Its diagnostics** are `Record`s of the entries of section 3 -- `severity`,
`code` (as the CLI shows it), `message`, `text` (the compiler's own located
text, a warning's rendering with its note lines), `range`, `file`, offsets,
line, column, `endLine`, `endColumn`, `related`, `record` -- errors first, in
the compiler's order, then the warnings the compilation attached. Errors are
`hir::recovery::entries` of `hir::recovery::reported`, the loader's and the
parser's own, plus `hir::warnings::Rejection` under `-warnings error`; the
service filters, merges and rewords nothing.

**One compilation per analysis.** `analyze` runs `surface::readProgramFile
-strict 0` once, in the revision's snapshot, through the workspace's
front-end cache. The entry is not parsed ahead of it: the compilation parses
it itself, raising every syntax error, unless the cache has its HIR, so a hit
parses nothing (`cs-cache-hit-parses-nothing`). Only when the compilation
fails before it reaches the entry -- a library a `# requires:` line names
does not exist -- does the service parse the entry (usually from the parse
cache), so that the entry's syntax errors are reported first, as main.tcl's
run reports them (`cs-entry-syntax-first`).

**Consistency.** A revision never changes. Editing the workspace afterwards
changes nothing in it (`cs-revision-immutable`); `sourceText` answers with the
text it analyzed. A query may name the version of the buffer its position is
in (`-version V`): a revision that read another version, or the disk, refuses
(`{SERVICE STALE}`) rather than mixing positions of one text with facts of
another. `stale REV` names each source whose current answer -- the
workspace's documents and the disk -- differs from the snapshot's (text,
presence, origin or version), so a transport can decide to re-analyze or to
answer from an older revision marked stale; the service never decides that
for it.

**Activation.** Type printing reads the process-wide registries the last
compilation filled (COMPILATION-ISOLATION.md). Every query obtains its
revision through `service::Use`, which activates the HIR the query reads.
`cs-activation-interleaved` alternates queries of two retained programs that
declare conflicting `geo::Point`/`geo::Small`, with a third program's
analyses in between; `cs-activation-control` is its positive control:
without activation, showing the retained revision's refined type fails
(`unknown type`), through the service it is shown.

**Lifetime.** `release` drops a revision and everything derived from it;
`closeWorkspace` releases a workspace's revisions; `state` counts what the
service holds. Nothing runs code: no backend is entered on any path of the
service (`hir REV` hands the HIR to a caller that wants to).

## 6. Position queries

`service::at REV PATH LINE COLUMN` answers, for the compiler's position (1-based
line and column, Unicode scalars of the revision's normalized text):

| Fact | What |
|---|---|
| `syntax` | the innermost AST node: `{kind node range}` (any source the revision read has one, a module that failed to parse included) |
| `construct` | the declaration whose name is written there (`kind declaration`), else the innermost HIR expression, with `enclosing`, the expressions around it |
| `binding` | `{id name kind module node}`: the binding it declares or refers to, by its source name (never a hygiene rename), the canonical module declaring it and its declaration's AST node id |
| `type` | `{text T}`: `hir::types::presented` |
| `hover` | a function's signature (`hir::signatures::text`), `NAME: TYPE` for another binding, the type otherwise |
| `definition` | the range of the declaration's name |
| `references` | every reference resolved to the same binding in this revision |
| `diagnostics` | the revision's diagnostics whose range holds the position |
| `topics` | Compilerpedia topics of those diagnostics and of a standard-library binding (section 7) |

and `unavailable`, mapping each fact it does not have to the reason -- every
fact is in exactly one of the two (`cs-facts-explicit`).

**The index.** A revision builds, on first use, per source file: the interval
index of its HIR expressions (each expression's origin span), the interval
index of its AST nodes, its declaration sites, its line starts, and one
reverse index from bindings to their references. An interval index sorts the
ranges by start (outermost first among equal starts) and records each one's
innermost enclosing range; the innermost range holding an offset is a binary
search and a walk up those parents: logarithmic in the expressions, linear
only in the nesting. Among expressions with *equal* ranges -- the expansion
the front end wrote for one construct (`a != b`, an operator's root
reference) -- the one first in the HIR's pre-order, the written construct,
is the answer, and the rest are its `enclosing`. `cs-index-matches-scan`
checks the index against a scan of every expression at every offset of a
program, its module and `stdlib/list.bot`. `prepare` builds every index ahead
of the first query; a query builds what it needs otherwise. For a trait
program the query HIR is its checked source build (`traitSource`, what
warnings are about), where each written expression exists once; the
monomorphized program clones functions per witness.

**Definitions** are declaration *names*: a binding is declared where the
source text spells its written name -- its declaration's AST `nameSpan` (a
function's, a binding's), else its origin's own span (a parameter's, a loop
variable's, a destructured field's are just the name). A binding the front
end introduced (a destructuring's hygienic temporary) has no such place: it
is no declaration construct, and its definition falls back to its whole
construct. Intrinsics have no definition ("a compiler intrinsic: no source
declares it"). `cs-definition-names` covers a function, a local, a
parameter, a destructured field, a loop variable, an imported module's
function and a function value.

**References** are the revision's `ref` expressions whose binding is the
same BindingId -- never a comparison of names (`cs-references-by-identity`:
two parameters `n` in two functions; `cs-references-match-a-walk`: every
binding, against a walk of the HIR).

**Types** never show an internal id. `hir::types::presented` is `show` with
each exact callable (`block(e8)/2 -> int`, a native) replaced by its
structural contract (`hir::types::structuralOf`), the `Fn{args: [...],
return: ..., errors: [...]}` an annotation spells; `hir::signatures::text`
spells a function's head from `hir::signatures::of`: `fn add(a: int, b: int)
-> int`, each parameter with the contract a call must meet. Everything else
is `show`'s own notation -- a source domain type reads `int[geo::Small]`, as
every diagnostic prints it. `cs-hover-no-internal-ids` queries every
position of a program with function values, lists of functions and
higher-order calls.

**Identity across revisions.** Within a revision a binding's identity is its
BindingId. A query also reports the binding's `module` (canonical namespace,
`""` for the entry program) and `node` (the AST node id of its declaration):
the census's `{module, node}` key, measured stable across edits elsewhere.
It is reported as information, not promised as an identity: a statement's id
counts same-keyed siblings, so inserting a type declaration before another
renumbers it, and two entry programs' declarations share the entry's empty
module. No cross-revision matching is done.

Not answered in this milestone: positions in type annotations, struct and
enum declarations and field names in a declaration (they are not HIR
expressions; the AST node is still the `syntax` fact), and references across
entry programs.

## 7. Compilerpedia

The service reuses the catalogue and nothing else. A diagnostic's topic is
`compilerpedia::topicForDiagnostic` of its code and text -- the lookup main.tcl's
`help:` lines make -- so the service and the command line point at the same
topic (`service::explain`; `cs-topics-diagnostic`). A query's `topics` add,
for a binding the compiler resolved to a standard-library symbol -- a root
native by its registered name, a declaration of a standard-library module by
its canonical name -- the topic documenting exactly that symbol
(`compilerpedia::symbolTopics`, new: an exact lookup in the catalogue's own
`symbols` table, which `generated/stdlib.topic` fills from the same registry
and `stdlib/`). A program's own function named `at` gets no topic: nothing is
associated because a name resembles a catalogue entry (`cs-topics-symbol`).
Each topic says why it is there (`for {diagnostic CODE}` or `{symbol NAME}`),
apart from the semantic facts.

Compilerpedia acquired no dependency: `compilerpedia.tcl` names no service
procedure, and its lookups run in a process with neither the service nor the
compiler loaded (`cs-compilerpedia-standalone`); `main.tcl -help` still
sources Compilerpedia alone. The service loads it only when a topic is asked
for.

## 8. main.tcl -check

`-check` is an option of the `cliOptions` table (group "Checking", shown in
the usage), documented in the `cli.options`, `cli.output`, `cli.exit-status`
and `cli.usage` topics and in main.tcl's header comment
(`cli-options-documented` checks all three). main.tcl sources the service only
when `-check` is given; other modes are unchanged.

* Exit 0 when every input checks without an error, 1 when one has an error
  (or cannot be read), 2 for a malformed invocation.
* Each input: `== FILE (check)`, then each error as a run prints it (`text`
  and `code` of the service's record, through main.tcl's `helpHint`), or
  `ok`. Warnings go to stderr with their help lines, exactly as a run's do;
  `-warnings error` rejects as a run does.
* Only `-warnings` and `-target`, which decide the analysis, combine with it.
  Every other option runs, builds or inspects, which `-check` never does, so
  naming one is a usage error (`-check cannot be combined with -backend:
  ...`), as is an input that is not a `.bot` file. Nothing is silently
  ignored.
* The front-end cache is used as a run uses it (BOTLISH_HIR_CACHE).

Its equivalence with a run is tested on programs with entry syntax errors,
module syntax errors, loader errors, deferred reference errors, semantic
errors with suppressed dependents, bounds proofs, warnings in both policies,
several inputs, and the whole diagnostic-recovery corpus (`cli-check-*`).
Where a run passes the strict boundaries and the service the lenient build,
their agreement is by construction -- both report `hir::recovery::entries` of
`reported`, `surface::syntaxEntries`, the loader's entries -- and by test.

## 9. Syntax and loader failures

A syntax error or a loader failure in any file still prevents the
whole-program HIR. The service represents that honestly:

* the revision's outcome is `syntax` or `loader`, `hir REV` is `""`, and its
  diagnostics are exactly the command line's (all of the entry's syntax
  errors; all of a module's; the loader's first error, or every deferred
  reference error);
* every source the analysis read keeps its text, and its AST -- the entry's
  recovered AST, a module's, the failing module's recovered AST -- answers
  the `syntax` fact (`cs-syntax-error-queries`);
* every semantic fact is `unavailable` with the reason ("no semantic
  analysis: the revision's outcome is syntax (no HIR)"); no type, binding or
  definition is invented;
* an older revision the caller still holds is untouched and answers as
  before; whether to answer an editor from it, marked stale, is the
  transport's policy (section 16), which `stale` and the per-source versions
  make possible.

Lowering recovered module ASTs, or reusing a module's last good analysis, is
separate work (the census's open question 2).

## 10. Invariants

1. **Diagnostic authority.** The service's diagnostics are the strict
   compilation's entries for the same sources and configuration, in order;
   the warning policy is `hir::warnings::Rejection`, shared with `run`.
   Nothing is filtered, merged, added or reworded.
2. **One text, one analysis.** Program source enters the front end only
   through `surface::source`; normalization happens once there; positions
   are scalar offsets and 1-based lines and columns of the normalized text.
3. **Revisions are values.** A revision is a function of its snapshot and
   configuration; nothing changes it; derived indexes are pure functions of
   it, computed on first use, released with it.
4. **Source identity.** A revision records, per source, its text, whether
   the disk or a buffer said so, and the buffer's version; a query about
   another version is refused; `stale` reports what changed.
5. **Activate before reading.** Every query reads its revision through
   `service::Use`, which activates the HIR it reads.
6. **Ownership.** The service owns workspaces and revisions; a revision owns
   its HIR, texts and indexes and nothing else; release frees them.
   Process-wide state the analysis uses is the compiler's, unchanged: the
   loader's parse cache (at most 64 ASTs), the front-end fingerprint,
   Compilerpedia's catalogue.
7. **No execution, no daemon.** No query or analysis enters a backend or
   runs program code; everything runs in the caller's `tclsh9.0`; there is
   no socket, pipe, watcher or background process.

## 11. Tests

Added:

* `tests/compiler-service.test` (49 tests): structured locations of syntax,
  loader, deferred-reference, related and warning diagnostics and the range
  fallbacks; the service against the strict compilation on every corpus case
  (field by field, never from formatted text) and the text-location agreement
  of every corpus diagnostic; suppressed dependents; both warning policies;
  every overlay case of the census; the snapshot record; the seam is not
  wrapping; normalization (six combinations); revision immutability,
  staleness and version refusal, release and boundedness; activation with
  its positive control; definitions, declaration sites, intrinsics,
  references by identity and against a walk; hover and the absence of
  internal ids at every position; explicit facts; semantic-error and
  syntax-error queries; a module of declarations only, at every position;
  Unicode positions (BMP, astral, combining); position errors; the index
  against a scan at every offset; Compilerpedia topics, symbols and
  independence; the cache's buffer rule, a lenient entry read back, a hit
  that parses nothing, and the entry's syntax errors first.
* `tests/main-cli.test` (19 tests): `-check`'s output and exit status, that it
  runs nothing, generates no native code and writes nothing, its equivalence
  with a run per failure class and on the corpus, warnings in both policies,
  several inputs, a missing file, and six malformed invocations.
* `audit/compiler-service/tools/mutate.tcl` with 21 mutants, one per rule
  (activation, normalization, the cache's buffer and content rules,
  references by identity, definitions by name, unfiltered diagnostics,
  unlocated loader errors, syntax ends, related locations, the warning
  rejection, internal ids in hover, the written construct among equal
  ranges, revisions reading the workspace, the version check, release,
  the entry's syntax errors first, a hit parsing the entry, -check's option
  policy, -check writing, -check's text).
* `bench/compiler-service.tcl`, the performance report (section 12).
* Census rows for the new tests (`audit/golden/migration/census/`), the
  names file and the regenerated manifest (68 rows added, none changed).

Changed: one mutant of another milestone's harness.
`audit/hir-interchange/tools/mutants.txt`'s `deps-read-when-kept` (an entry
records its modules' texts when it is kept, not the texts the build read)
survived on this branch, because it had become an equivalent mutant: it
dropped the cache's use of the build's reads, and a read when kept now goes
through the compilation's snapshot, which answers with the text the build
read. The rule now holds twice over. The mutant now also reads past the
snapshot (the disk directly), which is what "read when kept" means here, and
`hc-module-edited-during-build` kills it as before.

**Results on Linux x86-64** (Tcl 9.0.1, this branch, 4 jobs):

| Command | Result |
|---|---|
| `tclsh9.0 tests/local.tcl` (213 Tcl test files on interp and compile, 103 golden suites on all four backends; 41 min) | Tcl: interp 6737 passed, compile 6732 passed, 1 failed on each (below); golden: 103 suites, 0 failed: interp 4997/4997, compile 4997/4997, cranelift-generic 4905/4905, cranelift 5007/5007 |
| the one failure, rerun: `tests/local.tcl` on `mutable-vector`, `surface-lexer`, `compiler-service`, `hir-cache`, `diagnostic-recovery`, `compilation-isolation` | 218/218 on interp and on compile; the `mutable-vector` golden suite 74/74 on each backend |
| `tests/compiler-service.test`, `tests/main-cli.test` (in the full run) | 46/46 and 52/52 on each backend; with the three tests added after the run (below), `compiler-service.test` 49/49 and `main-cli.test` 52/52 on each backend |
| `audit/compiler-service/tools/mutate.tcl` | 19 mutants, 19 killed; 21 of 21 after the two added below |
| `audit/diagnostic-recovery/tools/mutate.tcl` | 25 mutants, 25 killed |
| `audit/hir-interchange/tools/mutate.tcl` | 27 mutants, 27 killed (26 before the change above; the changed one rerun alone: killed) |
| `audit/hir-interchange/tools/roundtrip.tcl -via cache` | 12 suites, 120 artifacts and outcomes compared, 0 differ |
| `audit/hir-interchange/tools/roundtrip.tcl -via interchange` | 12 suites, 108 artifacts and outcomes compared, 0 differ |
| `audit/refactor/tools/gate.tcl` | passed: the observed warnings are exactly the manifest (71 programs, 27 library loaders) |
| `tools/compilerpedia.tcl check` | 778 topics, 575 examples run, 0 problems |
| `single/build.sh`, then `single/smoke-test.sh` and `-check` through the built executable | built (8.5 MB); smoke test passed; `botlish -check` prints the same diagnostics with `botlish -help` hints, and refuses `-check -backend` (exit 2) |
| every other mutation harness's edits (mutants files, and the nine harnesses that keep their mutants inline) | each replaced text still occurs exactly once: none of this milestone's edits moved a mutant's target |

The failure in the full run was `mutable-vector.test`'s `mv-type-syntax`,
on both backends: it reads a syntax diagnostic's message as the last element
of its error code, and an early version of this milestone put
`endLine`/`endColumn` after the message. The message is last again
(`surface::diagnostic`), and the pinned `lex-error-code` expectation and the
`syntax-no-end` mutant were updated to that order. The diagnostic-efficiency
corpus (`audit/diagnostic-recovery/tools/efficiency.tcl`) runs inside
`diagnostic-recovery.test` (`dr-corpus-efficiency`), which passed.

The performance report found one bug after that run: the query index had an
interval index per file built from the expressions written there, so a
module of declarations only -- `stdlib/compiler.bot`, an enum, imported by the
2048 golden program -- had none, and a query in it failed. Every file of a
revision now has one, the empty one when no expression is written there;
`cs-declarations-only-module` queries every position of such a module (it
fails without the fix).

It also measured a `-check` of the 2048 golden program with a warm
front-end cache at 535 ms, against 198 ms for the census's nearest command:
317 ms of it was the service parsing the entry ahead of the compilation, as
main.tcl's run does, which a cache hit never needs. The service now parses
the entry only when the compilation fails before parsing it (section 5);
`cs-cache-hit-parses-nothing` and `cs-entry-syntax-first` pin both halves, and
the mutants `hit-parses-entry` and `entry-syntax-not-first` are killed by
them. After both changes `compiler-service.test` passes 49/49 and
`main-cli.test`, `hir-cache.test` and `diagnostic-recovery.test` pass on both
backends.

**Results on macOS arm64 and Windows x86-64** (GitHub Actions, on this
branch's push of `6cddb577`, the final code; `tests (macos arm64)` and
`tests (windows x86-64)`, whose acceptance tiers run every Tcl test file --
neither platform excludes any (`tests/platform/tier.tcl`'s `notYet` is empty
for both) -- on the interp backend, and the golden suites):

| Platform | Jobs | Result |
|---|---|---|
| macOS arm64 (`macos-15`) | smoke; acceptance shard 1/2 (`compiler-service`, `diagnostic-recovery`, `hir-cache`, `surface-lexer`, `mutable-vector`), shard 2/2 (`main-cli`); the Linux control | all succeeded |
| Windows x86-64 (MSVC) | smoke; acceptance shard 1/4 (`compiler-service`, `diagnostic-recovery`, `mutable-vector`), 2/4, 3/4 (`hir-cache`, `surface-lexer`), 4/4 (`main-cli`) | all succeeded |

The opt-in Tier C jobs were not requested. The jobs' logs live in GitHub's
blob storage, which this environment cannot reach, so the record is the
jobs' conclusions; the test files each shard ran are `tier.tcl -list 1`'s
for that shard. No platform-specific limitation was found: the same tests,
CRLF and lone-CR sources and Windows paths included, pass on the three
platforms.

## 12. Performance

Measured by `tclsh9.0 bench/compiler-service.tcl` (its four sections, then
`-sections memory -rounds 150`) on an otherwise idle machine at `6cddb577`:
Linux x86-64, 4 × Xeon @ 2.10 GHz, Tcl 9.0.1, the census's machine class
(COMPILER-SERVICE-CENSUS.md, section 7). The census's own figure for the
same workload is in parentheses. Times are medians of five runs, in ms
unless marked µs.

**Analysis in a warm process** (`service::analyze`, no front-end cache,
warnings off; each edit an unsaved buffer of the file it edits; the census
measured its probe library's lenient analysis before the service existed):

| workload | first | unchanged | implementation edit | interface edit | semantic error | syntax error |
|---|---:|---:|---:|---:|---:|---:|
| arith | 31.0 (42) | 2.61 (4.5) | 3.69 (5.2) | - | 4.25 (4.4) | 1.32 (1.3) |
| csv | 160 (208) | 150 (208) | 144 (165) | 172 (169) | 149 (171) | 29.9 (31) |
| 2048 | 1213 (1276) | 1139 (1250) | 1301 (1233) | 1269 (1287) | 755 (847) | 128 (99) |
| icy | 999 (1006) | 548 (785) | 843 (1006) | 870 (1014) | 804 (904) | 139 (172) |
| 2048-golden | 5554 (6223) | 6566 (6994) | 7254 (7441) | 7310 (7870) | 4328 (4793) | 116 (644) |

The service's analysis costs what the census measured: lower in 25 of the
29 cells, and the four higher ones are within run-to-run noise (two runs of
this table at nearby commits differ by up to half in a small cell, and by up
to 30% in a large one). Nothing was added to it: each source is read once per analysis (the
snapshot), the entry is parsed once (by the compilation, or not at all on a
cache hit), nothing is serialized, the HIR is built once. No cache or
incremental mechanism was introduced; the loader's parse cache, which makes
"unchanged" cheaper than "first", predates this milestone. The 2048-golden
syntax error (116 against 644) is cheaper because the entry is not parsed
again: the census's probe parsed it before each analysis, the service leaves
that to the compilation, whose parse cache holds the unchanged entry.

**Position queries** (`service::at` on a retained revision, in µs; the
census's 200 positions of the entry file by its formula, and 1000 random
positions of the entry and its modules, seeded; `prepare` builds every
index first, the one-time cost a first query otherwise pays for what it
uses; in parentheses the census's unindexed query: median, p90, max):

| workload | expressions | prepare, ms | census positions: median | p90 | p99 | max | random: median | p90 | p99 | max |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| arith | 11 | 1.32 | 11.0 (27) | 36.0 (58) | 334 | 1338 (926) | 13.0 | 35.0 | 94.0 | 208 |
| csv | 322 | 7.87 | 46.0 (664) | 126 (988) | 192 | 349 (3798) | 22.0 | 119 | 235 | 1057 |
| 2048 | 1777 | 69.7 | 19.5 (1209) | 85.0 (1851) | 336 | 493 (15967) | 33.0 | 170 | 380 | 662 |
| icy | 1558 | 38.3 | 18.0 (1214) | 66.0 (2197) | 223 | 299 (13523) | 41.0 | 166 | 361 | 921 |
| 2048-golden | 5374 | 129 | 97.5 (7188) | 178 (11062) | 507 | 959 (54474) | 37.0 | 163 | 411 | 842 |

The target -- at most 5 ms per query on 2048-golden -- is met with a wide
margin: median 37-98 µs, p99 0.4-0.5 ms, the slowest of 1200 queries under
1 ms; the census's unindexed query took 7-54 ms there. The index is built
once per revision (129 ms for 2048-golden, or the part a first query needs:
about 80 ms for the entry's), and Compilerpedia's catalogue once per process
(195 ms). Each sample is one query; the tails are dominated by single
outliers: in an earlier run of the same table one 2048-golden sample took
4.5 ms, and the same 1000 positions measured five times each gave a median of
39 µs, p99 330 µs, maximum 758 µs. The slowest positions are those that
answer the most: a binding with 58 references, each returned with its range.
Activation adds about 16 µs when consecutive queries read different
revisions (two alternating programs: 65 µs per pair of queries, 40 µs
without the switch), in line with the census's tens of microseconds.

**Memory in a long-running process.** The 2048 demo analyzed 150 times in
one process, each round a different unsaved edit of `game2048.bot`, 20
queries, and the previous revision released:

| round | 1 | 10 | 20 | 30 | 40 | 50 | 60 | 70-150 (every 10) |
|---|---:|---:|---:|---:|---:|---:|---:|---:|
| RSS, MiB | 68 | 114 | 139 | 163 | 188 | 213 | 222 | 222 |
| revisions the service holds | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 |
| derived structures | 4 | 4 | 4 | 4 | 4 | 4 | 4 | 4 |
| ASTs in the parse cache | 12 | 21 | 31 | 41 | 51 | 61 | 18 | 28-58 |

The census measured 68, 184 (round 40), 220 (60) and 220 (120) MiB for
analysis alone. The service-owned state is constant: one revision and its
four derived indexes. The resident set grows only while the loader's parse
cache fills (each round's edited module is a new text, so a new AST) and
stops at its bound: past 64 entries the cache is cleared whole, the
allocator reuses the memory, and from round 60 to 150 the resident set does
not move. Process-wide state, apart from live revisions:

| What | Bound |
|---|---|
| the loader's parse cache (`surface::modules::parsed`) | 64 ASTs, cleared whole past that |
| the loader's reads of one compilation (`surface::modules::reads`) | reset by each compilation |
| the front-end fingerprint | one value, computed once (7 ms) |
| Compilerpedia's catalogue | loaded once, on the first topic lookup |
| the active declaration state (COMPILATION-ISOLATION.md) | one: activation replaces it |
| the source seam's snapshot | exists only during an analysis |

A retained revision costs what its HIR and texts cost. Ten revisions of the
2048 demo retained at once, in the warm process, added 112 MiB, about 11
MiB each (62 MiB in the full run, whose allocator had more freed memory to
reuse). From a fresh process each further retained revision added about 24
MiB for the 2048 demo and 37 MiB for 2048-golden (one new AST of the edited
module included); building its query indexes added nothing measurable. After
`release`, `state` reports no revision; the memory returns to Tcl's
allocator, which reuses it rather than returning it to the system.

**Fresh processes: `main.tcl -check -warnings off FILE`**, process start to
exit, beside the census's `-emit-hir-interchange` (the nearest command
before `-check` existed: the front end, then writing the HIR):

| workload | no front-end cache | warm front-end cache |
|---|---:|---:|
| arith | 107 (127) | 72.5 (99) |
| csv | 265 (337) | 80.9 (92) |
| 2048 | 1354 (1486) | 121 (142) |
| icy | 916 (1069) | 227 (266) |
| 2048-golden | 5478 (5998) | 145 (198) |

`-check` costs at most what the census's nearest command did, in every cell.
Loading the compiler and the service takes 63 ms (a process that only
sources `service/service.tcl`, 70 ms, less a bare `tclsh9.0`, 7 ms; the
census: 80 ms for the compiler); `-check` loads no backend and Compilerpedia
only for a help hint. No daemon is involved: every figure above is one
ordinary `tclsh9.0`.

## 13. Compatibility, and the std:: milestone

* **CLI.** Every message, code, order, help line and exit status of the
  existing modes is unchanged; the corpus and `main-cli.test`'s existing
  tests pass unchanged. main.tcl's entry read now goes through the seam (the
  same text) and the parse cache, so a run parses its entry once instead of
  twice.
* **Diagnostics as data.** Two pinned expectations changed:
  `surface-lexer.test`'s `lex-error-code` (the syntax diagnostic dict has
  `endLine`/`endColumn`) and `hir-cache.test`'s `hc-environment` (the cache's
  stats dict has `buffered`).
* **Cache.** Same key, entry format and validation by contents; the
  dependencies are read through the compilation's snapshot (from the disk
  for every compilation but the service's), and a compilation that read a
  buffer is not stored.
* **Namespace resolution** is untouched: the provider answers for the paths
  the loader computes. The one behavior difference is a directory at a
  standard module's path (section 4).
* **Compilerpedia** is independent of the compiler and the service, as
  before; `-help` loads nothing else.
* **The single executable** packs `service/` (single/package.tcl,
  SINGLE-EXECUTABLE.md).

**The std:: milestone.** It has not landed, so this milestone builds on
`main`. To check that its seam survives that refactoring -- the census
predicted the same two primitives at the same kind of sites -- a trial
merge of this branch into `claude/botlish-std-namespace-milestone-rjfef8`
(`9e8900f6`) was made and discarded, and repeated against that branch's
later head `c4a41f33` (the same five conflicts; the same resolution of
`modules.tcl` applies unchanged, that commit having changed only comments
there):

* five files conflict: `surface/modules.tcl` (the std branch rewrote the
  code around the same acquisition sites), `single/package.tcl`,
  `AGENTS.md` and `SINGLE-EXECUTABLE.md` (`stdlib/` is `stdlib/` there) and the
  generated manifest; every other file -- the parser, the cache, the HIR
  files, main.tcl, the tests -- merges by itself;
* the resolution is mechanical: the std side of `modules.tcl` with each of
  its nine acquisition sites (one more than `main`'s: `NoSuchNamespace`'s
  check of an application root inside the standard library) going through
  `surface::source`, and this milestone's `Error`, reference trap,
  `ParseModule`/`Parse` and `compileProgramFile` re-applied;
* on the merged tree, `tests/compiler-service.test` passes 42 of 46 once its
  test programs use the std spelling (`import std::list`,
  `std::list::at`); of the other four, two differ by spelling alone (a
  qualified reference's span is longer when it reads `std::str::concat`,
  and one `std::list::at` the rewrite of the test left unqualified) and two by
  the std model's own rules (an application `list.bot` no longer collides
  with `std::list`, and an application namespace is no longer probed for
  in the standard library, so the snapshot records no such absence). No
  service code changed.

Whichever milestone lands second does that resolution; nothing here
pre-empts the std model (no namespace rule moved), and nothing there needs
undoing.

## 14. Limitations

* **No semantics through a syntax or loader error.** One such error anywhere
  removes the HIR (section 9); the service keeps syntax facts and earlier
  revisions, and leaves "answer from the last good revision" to the
  transport.
* **Whole-program analysis per revision.** An edit costs a whole analysis
  (0.15-1.3 s for the repository's applications, 4.3-7.3 s for the 2048
  golden program: section 12); there is no incremental or module-granular
  reuse, by design (the census's strategy A).
* **Queries** answer value positions: expressions and binding declarations.
  Type annotations, struct, enum, layout and trait declarations, a struct's
  field names and import headers are answered by the `syntax` fact only.
* **References** are within one revision: one entry program and the modules
  it loads. Another entry program importing the same module is another
  revision; there is no rename.
* **Hover text** is the compiler's notation: a callable's structural contract
  where a function value is nested in a type, `int[NAME]` for a domain, a
  refinement's own spelling.
* **Revisions are retained in full**: a revision holds its HIR and texts
  until released (about 11-24 MiB resident for the 2048 demo, 37 MiB for
  the 2048 golden program: section 12); the service never evicts on its
  own.
* **The front-end fingerprint** is computed once per process (it hashes the
  front end's sources).

## 15. Deviations from the census's contract

* **`at` instead of separate hover/definition/references calls.** The census
  listed capabilities; one query returns every fact at a position, each
  explicitly present or unavailable. A transport picks the facts it needs.
* **Indexes are lazy, plus `prepare`.** The census suggested a sort of each
  file's origins per revision. It is built on first use, so `-check` and a
  service that only publishes diagnostics never pay for it; `prepare` builds
  it ahead of a request.
* **Declarations are constructs.** A position on a declaration's name answers
  with that binding (the census's probe returned the enclosing statement),
  because "find references" is usually asked there.
* **The cache may be read from buffers.** Rule 6 of the census's section 5.4
  -- write only all-disk revisions -- is kept; a lookup from a buffer
  analysis is allowed, because a hit is validated by contents.
* **Staleness is reported, not resolved.** The census described answering a
  query for another version "as stale or re-analyzed". The service refuses
  it (`{SERVICE STALE}`) and reports staleness through `stale`; re-analysis
  and stale answers are transport policy.
* **Warnings under `-warnings error`.** The service collects warnings in
  the default mode and applies the policy's rejection itself (the shared
  `hir::warnings::Rejection`), so the rejected program's HIR stays
  queryable; a strict compilation stops there.

## 16. Next milestone: the smallest stdio LSP

S2 should be a Tcl process speaking LSP over stdin/stdout (binary
translation, `Content-Length` framing, a small JSON reader and writer --
pinned Tcl has none), whose handlers call this service:

* `initialize`/`shutdown`/`exit`; `didOpen`/`didChange` (full sync) to
  `setDocument` with the document version, `didClose` to `clearDocument`,
  `didSave`; `publishDiagnostics` from `diagnostics`; `hover` and
  `definition` from `at`; `references` from `at`'s references.
* URI <-> path and UTF-16 <-> scalar columns, converted against the
  revision's `sourceText`, never against the current buffer; a request whose
  document version is not the revision's either waits for a newer revision
  or answers from the old one with positions mapped only if the text is
  unchanged.
* During a syntax or loader error, hover and definition from the last
  revision with a HIR, its staleness known from `stale`.

**The event loop.** The census measured whole-program analyses of 0.2-1.3 s
on the repository's applications and 6-8 s on its largest program; Tcl
blocks while one runs (the pinned Tcl has no `Thread` package). Two designs
should be built behind one interface ("analyze this version, call back with
a revision") and measured against each other:

* **Synchronous and debounced.** One process. A change restarts a debounce
  timer (`after`); when it fires, the analysis runs on the event loop; a
  request that arrives meanwhile waits; a result whose document has moved on
  is discarded and the next analysis scheduled (cancellation by
  supersession, never interruption). Queries are answered from the latest
  revision between analyses, in microseconds. Simple, no serialization, one
  copy of everything; its cost is that a hover during an analysis waits for
  the analysis to finish.
* **An isolated worker process.** The server keeps the event loop, the
  documents and the revisions it answers queries from; a worker `tclsh9.0`
  (persistent, so its compiler, bytecode and parse cache stay warm) runs
  `analyze` and returns the revision's diagnostics as data and its HIR as
  HIR interchange text (a hit-like decode: 73-209 ms on the census's
  workloads). A superseded analysis is cancelled by killing the worker, and a
  compiler crash does not take the server down. Its costs: serialization of
  every revision, a second process's memory, and a service constructor for a
  revision whose HIR arrived as text (S2's one addition to this interface).

**How S2 should decide.** Replay scripted editing sessions (the census's
workloads, edits every 150-300 ms, hovers interleaved) through both designs
and record, per design: hover latency (median, p95, max) while an analysis
runs; time from the last keystroke to published diagnostics; analysis time
spent on superseded versions; event-loop blocking (the longest gap between
two serviced messages); memory. Start with the synchronous design: it is
correct by construction and enough for the repository's applications
(sub-second analyses). Switch to the worker when the recorded p95 hover
latency during typing exceeds an interactive budget (about 200 ms) on the
programs being edited -- the census's 2048-golden certainly does. Neither
design may change semantic authority: both run the same `analyze`, so a
test replays one session through both and requires identical published
diagnostics and identical query answers.

## 17. Files, and what to run when changing this

| File | Role |
|---|---|
| `surface/source.tcl` (new) | the source-provider seam: providers, the snapshot, normalization |
| `service/service.tcl` (new) | the compiler service |
| `surface/modules.tcl` | acquisition through the seam; located loader errors; `Parse` (the shared parse cache); a compilation is one snapshot |
| `surface/cache.tcl` | dependencies through the snapshot; buffers never stored |
| `surface/parser.tcl`, `surface/ast.tcl` | syntax diagnostics with ends; `syntaxEntries`, `raiseSyntax` |
| `surface/surface.tcl`, `core/programfile.tcl` | the requires scan of the snapshot's text |
| `core/errors.tcl` | the structured keys of a diagnostic entry (documentation) |
| `hir/recovery.tcl` | `entries` |
| `hir/warnings.tcl` | `Rejection`, `ErrorEntry`, `entry` |
| `hir/hir.tcl` | `hir::originSpan` |
| `hir/types.tcl`, `hir/signatures.tcl` | `presented`, `text` |
| `compilerpedia/compilerpedia.tcl` | `symbolTopics` |
| `main.tcl` | `-check` |
| `compilerpedia/topics/backends.topic` | `cli.options`, `cli.output`, `cli.exit-status`, `cli.usage` |
| `single/package.tcl` | packs `service/` |
| `tests/compiler-service.test` (new), `tests/main-cli.test` | the tests |
| `audit/compiler-service/tools/` (new) | the mutation harness |
| `bench/compiler-service.tcl` (new) | the performance report |

If you change the seam, the cache's use of it, a diagnostic producer or the
service, run `tests/compiler-service.test`, `tests/main-cli.test`,
`tests/diagnostic-recovery.test`, `tests/hir-cache.test`,
`audit/compiler-service/tools/mutate.tcl`,
`audit/diagnostic-recovery/tools/mutate.tcl`,
`audit/hir-interchange/tools/mutate.tcl` and
`audit/hir-interchange/tools/roundtrip.tcl -via cache` (AGENTS.md, "The
compiler service and the source seam").
