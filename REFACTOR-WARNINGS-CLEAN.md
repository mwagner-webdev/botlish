# The warning-driven refactor: the corpus under its own warnings

## Outcome

The seven compiler warnings (WARNINGS-*.md, milestones 1-7) were verified and
audited against the corpus, and by standing rule no corpus code was edited.
This milestone is their consumer. At the pinned post-affine kickoff commit
**6e3f9f7** the consolidated sweep found **491 findings** in the corpus (every
program of `examples/`, `bench/` and `lib/`, and a one-line loader of every
library module). Every one of them now has exactly one closing mechanism, and
none is "deliberate":

| mechanism | findings | how it was verified |
|---|---:|---|
| **converted** | 411 | 355 method-sugar respellings, each by the round-trip law (identical HIR text, core IR and NIR, call by call); 56 one-character literals converted to characters or removed by restructure, by behavior probes on every backend and the expected outputs |
| **marked** (`nomethod`) | 26 | five shipped natives, each with a stated reason and a pinned test |
| **merged** | 7 | six same-return exits and one same-failure guard pair, by behavior probes |
| **annotated** (`-> list`) | 5 | the checker proves the annotation; the expected outputs |
| **manifested** | 42 | each with the obstruction that keeps it open, named per finding |

Forty-one of the 42 manifested findings are `ONE-CHAR-STRING-LITERAL`. Their
obstructions are the design data this refactor was built to produce:

* **24 need character-to-text construction** (`char->text`): a single
  character that must become text -- an operand of `str::concat`, a String
  result, a table of text. Botlish has no `str::of_char` and no append of a
  UnicodeChar to a String; the only literal-free spelling slices the
  character out of a longer literal, which keeps the one-character String at
  run time and only hides it from a literals-only check.
* **10 are coupled to a String-taking classifier** (`classifier`): the
  character is also handed to `str::is_tcl_alnum`/`str::is_tcl_alpha`, in the
  same predicate or through a uniform predicate contract (`Fn{args: [str]}`),
  so it is a one-character String there.
* **1 is blocked by the index proof** (`index-proof`): the natural
  `path.char_at(n - 1) == '/'` is not proven in range, and the function's
  errors are fixed by a trait.
* **6 are test data whose length 1 is the case's subject** (`test-datum`,
  hypothesis H2).

The 42nd is `examples/surface/13-hygiene.bot`'s `FIXED-ARITY-LIST-RETURN`
(`core-ir-roundtrip`): its answer is `-> list`, but the annotation is a source
fact core IR cannot carry, and the sample is a fixture of the check that its
HIR is what analysis of its core IR derives.

A **gate** now holds the corpus there: `audit/refactor/tools/gate.tcl` (CI
job `warning-gate`) asserts that the observed warnings are exactly the
manifest, `audit/refactor/manifest.txt`, and compiles every program and
loader without an entry under `-warnings error` -- **42 of the 68 units** (32
programs, 10 of the 14 library loaders). It demonstrably fails on a planted new
warning, a closed-but-listed finding, a drifted location, an unlisted program
and a strict-mode regression (`tests/warning-gate.test`).

The two hypotheses:

* **H1 -- falsified.** `clean_char`'s three one-character return values can
  be made warning-clean on today's surface, with the contract intact and the
  behavior identical -- by a translation table -- but the restructure is a
  contortion: it keeps the one-character String at run time (the warning is
  literals-only; the finding's subject, the missing character-to-text
  construction, is untouched), adds an unstated invariant and reads worse.
  As written, with the table at program level, it also makes `clean_from`'s
  scan quadratic again (60 MB of UTF-8 seeking on a 10,000-character input,
  against 0) -- a cost of where the table lives, not of the table (section
  15, finding 11). The M6 argument for "deliberate" (a
  variable-length String result) was not the real obstruction; the real one
  is character-to-text construction.
* **H2 -- confirmed for 6 findings, falsified for 2.** Of the eight test-data
  literals, the needles and the replacements a case actually inserts carry
  their length into the code path and the pinned output; the two
  replacements of the absent-needle and empty-haystack cases are never
  inserted, so only their non-emptiness matters -- they became `"yz"` with
  the subject intact, and the manifest shrank by two.

The honest remainder for the libraries: **11 of 14 library modules are
warning-clean**, and the other three carry only manifested
`ONE-CHAR-STRING-LITERAL` findings -- `lib/web.bot` 23, `lib/io.bot` 2,
`lib/linux/path.bot` 2 -- which print for every program that loads them. The
"no system header" limitation is therefore retired for every module except
those three; for them the quantified demand is character-to-text
construction (20 of their 27), character classifiers (6) and the index proof
(1). Five modules
still do not compile *as entry programs* (P0): two because a module cannot
spell its own namespace's intrinsics in a way valid both as a module and as
an entry program, three because an entry program's value is its last
declaration and theirs cannot be a value. All fourteen load.

One candidate for a future warning came out of the work -- a constant String
scanned one character at a time as a table, with a List of characters
suggested instead (section 15, finding 11). Measured on the H1 attempt, the
suggestion removes a small linear decoding cost while the quadratic cost that
attempt showed came from where the table lived, untouched by the spelling;
and the shipped corpus has no instance. The recommendation is to record it
with graduation criteria, not to build it now.

Full regression at the final tree (991c666): interp 6813/6813, compile 6809
passed and the kickoff's 4 skipped, native coverage 0 failed with the same 60
unsupported tests as at kickoff (section 17).

## Contents

1. [Kickoff](#1-kickoff)
2. [The hypotheses](#2-the-hypotheses)
3. [The law and how each class is verified](#3-the-law-and-how-each-class-is-verified)
4. [Phase log](#4-phase-log)
5. [P0: library repair](#5-p0-library-repair)
6. [P1: nomethod markings](#6-p1-nomethod-markings)
7. [P2: the method-eligible sweep](#7-p2-the-method-eligible-sweep)
8. [P3: the one-character literals](#8-p3-the-one-character-literals)
9. [P4: the structural conversions](#9-p4-the-structural-conversions)
10. [P5: H2](#10-p5-h2)
11. [The closing-mechanism table](#11-the-closing-mechanism-table)
12. [The manifest](#12-the-manifest)
13. [The gate and the CI step](#13-the-gate-and-the-ci-step)
14. [Bench before and after](#14-bench-before-and-after)
15. [Design findings](#15-design-findings)
16. [Documentation](#16-documentation)
17. [Full regression](#17-full-regression)
18. [Deviations and known limitations](#18-deviations-and-known-limitations)
19. [Required questions](#19-required-questions)

## 1. Kickoff

### The prerequisite

The affine MutableArray/MutableVector work was on `main` before this
milestone began: the session's branch and `origin/main` were both at
**6e3f9f7** ("Regenerate the scalar assembly audit corpus", after
MUTABLE-ARRAY.md's final commits). That commit is the pinned kickoff tree of
every count below; a worktree of it served as the "before" tree throughout.

### The consolidated re-audit

All seven warnings' corpus tools were re-run at 6e3f9f7
(`audit/refactor/kickoff/*.txt`, one file per code), plus the consolidated
sweep `audit/refactor/tools/sweep.tcl` (new: the union of the seven tools'
corpora -- `examples/{stdlib,surface,refinement,io,abi,linux}/*.bot`,
`bench/*.bot`, `lib/*.bot` and `lib/*/*.bot` compiled standalone -- plus
milestone 7's one-line loader `import NS` for each of the 14 library modules,
every warning of every code deduplicated by code and anchor). Its result,
`audit/refactor/kickoff/sweep.txt`, **supersedes the per-milestone ledgers**:

Per file and code at kickoff:

| file | ME | OC | SRV | FA | SF | PN | MB | total |
|---|---:|---:|---:|---:|---:|---:|---:|---:|
| `bench/lex-strategy.bot` | 16 | 2 |  |  |  |  |  | 18 |
| `bench/loop-count.bot` | 1 |  |  |  |  |  |  | 1 |
| `bench/refined-checks.bot` | 2 |  |  |  |  |  |  | 2 |
| `bench/source-checks.bot` | 4 | 2 |  |  |  |  |  | 6 |
| `bench/sum-refined.bot` | 1 |  |  |  |  |  |  | 1 |
| `bench/test-selection.bot` | 9 |  |  |  |  |  |  | 9 |
| `bench/uri-steady.bot` | 3 |  |  |  |  |  |  | 3 |
| `examples/io/child-path.bot` |  | 1 |  |  |  |  |  | 1 |
| `examples/linux/read-stdin.bot` | 3 |  |  |  |  |  |  | 3 |
| `examples/linux/write.bot` | 1 |  |  |  |  |  |  | 1 |
| `examples/refinement/refined-strings.bot` | 1 |  |  |  |  |  |  | 1 |
| `examples/stdlib/ai_text_clean.bot` | 5 | 22 |  | 1 |  |  |  | 28 |
| `examples/stdlib/csv.bot` | 21 | 8 |  |  |  |  |  | 29 |
| `examples/stdlib/csv_chunked.bot` | 32 | 8 |  |  |  |  |  | 40 |
| `examples/stdlib/csv_geometric.bot` | 34 | 8 |  |  |  |  |  | 42 |
| `examples/stdlib/csv_records.bot` | 94 | 8 | 1 | 1 |  |  |  | 104 |
| `examples/stdlib/hashtable.bot` | 61 |  | 2 | 1 |  |  |  | 64 |
| `examples/stdlib/matmul.bot` | 14 |  |  |  |  |  |  | 14 |
| `examples/stdlib/string_replace.bot` | 15 | 7 |  | 1 |  |  |  | 23 |
| `examples/stdlib/string_reverse.bot` | 4 | 1 |  | 1 |  |  |  | 6 |
| `examples/surface/11-boolean-operators.bot` | 3 |  |  |  |  |  |  | 3 |
| `examples/surface/13-hygiene.bot` | 1 |  |  | 1 |  |  |  | 2 |
| `lib/abi/bytes.bot` |  |  |  |  | 1 |  |  | 1 |
| `lib/byte.bot` | 11 |  |  |  |  |  |  | 11 |
| `lib/io.bot` |  | 2 |  |  |  |  |  | 2 |
| `lib/linux/io.bot` | 3 |  |  |  |  |  |  | 3 |
| `lib/linux/path.bot` |  | 2 |  |  |  |  |  | 2 |
| `lib/web.bot` | 42 | 26 | 3 |  |  |  |  | 71 |
| **total** | **381** | **97** | **6** | **6** | **1** | **0** | **0** | **491** |

| code | per-milestone ledger | kickoff (same corpus) | kickoff, consolidated | what moved it |
|---|---:|---:|---:|---|
| `METHOD-ELIGIBLE` | 365 | 373 | **381** | post-M2 code (the rewritten `lib/web.bot`, `examples/linux`, `lib/linux/io.bot`, `examples/refinement`); 8 more in the corpora M2's tool does not compile |
| `ONE-CHAR-STRING-LITERAL` | 97 | 97 | **97** | none: the M6 ledger was taken at the post-affine tree's corpus |
| `SAME-RETURN-VALUE` | 4 | 6 | **6** | `hashtable.bot`'s `ht_delete` (the affine work made it return the table from two exits) and `web.bot`'s `valid_from?` (the refinement work's `uri_query_value?`) |
| `FIXED-ARITY-LIST-RETURN` | 8 | 6 | **6** | `csv_chunked.bot`'s two builder-state findings closed by the affine work (the builder became the `ChunkedBuilder` struct value); the fixed-arity tool's curated patch for them no longer applies, its one failure at kickoff |
| `SAME-FAILURE` | 1 | 1 | **1** | none |
| `PROVES-NAMING` | 0 | 0 | **0** | none |
| `MANY-BOOLEAN-ARGUMENTS` | 0 | 0 | **0** | none |
| **total** | 475 | 483 | **491** | |

The METHOD-ELIGIBLE tool's round-trip law held for all 99 distinct
(callee, receiver-form) patterns, and its whole-program respelling for every
program (0 failures); the one-character tool's spelling law held 97 of 97.

### Library compile-state inventory

| module | standalone (entry program) | loader `import NS` | cause |
|---|---|---|---|
| `abi`, `abi::x86_64`, `ascii`, `byte`, `linux`, `mathish`, `web`, `abi::bytes`, `linux::path` | compiles | loads | -- |
| `list`, `mutable_array` | `MISSING-IMPORT` | loads | the module calls its own namespace's intrinsic (`list::at`, `mutable_array::at`) |
| `io`, `linux::io` | `CONTEXT-FUNCTION-VALUE` | loads | an entry program's value is its last statement; the module's last declaration requires a context |
| `io::path` | `TRAIT-POLYMORPHIC-FUNCTION-VALUE` | loads | the same, with a trait-polymorphic last declaration |

Nothing the affine work shipped fails for a new reason (`mutable_array`'s
failure predates it, as milestone 2 recorded). P0 below has the analysis.

### The nomethod queue, re-derived

The fresh METHOD-ELIGIBLE audit's curated `nomethod` classification lists the
same four candidates as milestone 2 (`mutable_array::copy` 4 findings,
`bit_and` 8, `bit_or` 5, `bit_xor` 1). Re-deriving it over the fresh
callee list (86 callees) found one more, by the same criterion -- a receiver
reading that misleads: **`mutable_array::create`** (8 findings), which the
affine work had made an intrinsic, and whose first argument is the new
array's *length*: the sweep would have written `1.create(0)` and
`chunk_size().create(...)`. No other callee qualifies: the shifts' first
argument is the shifted value (`v.shift_right(6)`), `mod`'s the dividend,
the corpus helpers' their subject (a text, a table, a builder). The callees
new since milestone 2 (`str::char_at`, `linux::read`/`write`,
`abi::bytes::freeze_prefix`, `web.bot`'s `cont`) all read naturally as
receivers. `mutable_array::generate` has the same shape as `create` but no
finding, so it is not marked (the fence: only the re-derived queue); it is
recorded for its author in the design findings.

Re-verifying that no call site uses the queue's sugar found **one**, added by
the affine work in a test program (`tests/mutable-array.test`, `ma-ops`:
`a.copy(1, b, 1, 2)`). Its subject is copy's semantics, not the spelling; it
became the functional call. No corpus program used any of the five.

### Baseline regression

At 6e3f9f7, before any edit: interp **6801/6801**, compile **6797 passed, 4
skipped** (the `coreScoping` constraint), **0 failures** (3079 s for the
compile pass). The expected-output check (`audit/refactor/tools/expect.tcl`,
new) held for all **30** corpus programs that state an `# expect:` value, on
all four backends (`audit/refactor/kickoff/expect.txt`).

## 2. The hypotheses

**H1 -- fixable today.** *The three `clean_char` findings
(`examples/stdlib/ai_text_clean.bot`'s one-character return values `"-"`,
`"'"`, `"\""`) can reach warning-clean by program restructure alone, on
today's language and stdlib, without weakening the function's contract and
without new API.* Verdict rule: confirmed if the findings are gone, behavior
probes identical, the contract (name, signature, result type, errors)
unchanged and the restructure not a contortion; falsified otherwise, with the
obstruction named.

**Verdict: falsified.** The restructure exists (`audit/refactor/h1-attempt/`):
a translation table -- `marks = "–—‘’“”"`, `normalized = "--''\"\""` and
`normalized.substring(i, i + 1)` for the mark found at `i` -- compiles, is
warning-clean, keeps `clean_char`'s contract (the compiler proves the slice in
range, so no error joins it) and passes every probe. It is a contortion:

1. *It keeps the one-character String and only hides it.* At run time the
   slice is `"-"`; the warning is literals-only by design, so the restructure
   removes the finding without removing what it reports.
2. *It adds an invariant nothing states*: two parallel literals whose lengths
   and positions must agree; an unequal edit adds `LowerUnderrun`/
   `UpperOverrun` to `clean_char` -- a contract change from a data edit.
3. *As written, it costs the traversal.* On `bench/ai_text_clean.tcl`'s
   punctuation fixture `clean_from` loses its traversal plan: UTF-8 seek
   bytes 2,483,588 / 9,751,421 / 38,647,782 at 2,000 / 4,000 / 8,000
   characters (x3.93, x3.96: quadratic), against 0 for the P3 program at
   every size. The cause is the table's placement, not its form: `clean_char`
   reads two program-level bindings, which makes it a value-capturing closure
   with non-Int captures, and those stay generic (`hir/specialize.tcl`, "Which
   instance a call uses") -- `clean_char`, `clean_ai_text` and the
   `clean_from` instance it calls -- while a traversal plan is only ever given
   to a specialized instance. Moved into `clean_char`, the same table keeps
   the plan and costs only its own decoding: 88,647 / 174,984 / 347,727 seek
   bytes, linear, about 44 bytes per character cleaned
   (`audit/refactor/h1-attempt/variants/`; section 15, finding 11). Reasons
   1, 2 and 4 hold in either placement, and 1 is decisive.
4. *It reads worse*: each normalization is no longer beside its condition.

The obstruction is **character-to-text construction**. M6's stated reason for
"deliberate" -- the result type is a variable-length String -- is not the
obstruction (the table form shows a String result is no barrier); the barrier
is that a character, once compared as a character, cannot become the text
`clean_from` appends. The three findings are manifested, tagged `H1`.

**H2 -- unfixable today.** *The eight test-data findings
(`string_replace.bot`'s `sample`, 7; `string_reverse.bot`'s `sample`, 1)
cannot reach warning-clean today without weakening their tests' subject.*

**Verdict: confirmed for 6, falsified for 2** (P5). Per finding:

| finding (post-refactor location) | datum | verdict | why |
|---|---|---|---|
| `string_replace.bot:51:20` | needle `"x"`, absent | confirmed | the needle's length drives the scan (`index + str::length(needle)`): a 1-character needle is the one whose absence check visits every position, the last included |
| was `49:26` | replacement `"y"` of the absent `"x"` | **falsified** | never inserted; only non-emptiness matters (it makes a wrong insertion visible: `""` would hide one). Now `"yz"`: subject intact, output identical |
| `51:46` | needle `"b"`, found | confirmed | the single-character substitution, the length-1 boundary of a needle that occurs |
| `51:51` | replacement `"X"` | confirmed | length-preserving substitution, in the pinned output `"aXc"` |
| `51:78` | replacement `"b"` of `"aa"` | confirmed | shrinks each match to one character, visibly in the pinned `"bb"` (two non-overlapping matches) |
| `51:124` | needle `"x"`, empty haystack | confirmed | the needle that exceeds the haystack by exactly one: the boundary of the end guard |
| was `49:133` | replacement `"y"` of the empty haystack | **falsified** | never inserted, as `49:26`; now `"yz"` |
| `string_reverse.bot:31:39` | `"a"` | confirmed | the length-1 boundary of reversal, between the pinned `""` and `"abc"` |

For every confirmed datum no spelling on today's surface states "a String of
length exactly 1, namely `x`" as directly: `'x'` is a UnicodeChar (`replace`
takes Strings, `str::length('x')` is a `TYPE` error), and
`"xy".substring(0, 1)` is computed, hiding the datum the case is about.

## 3. The law and how each class is verified

Observable behavior is identical, verified mechanically per class:

* **Programs with expected outputs.** `audit/refactor/tools/expect.tcl` runs
  every corpus program with an `# expect:` line (30: the nine stdlib
  programs, the twelve surface samples that compile, `refined-strings`,
  `numeric-domains` and seven bench programs) on interp, compile,
  cranelift-generic and cranelift, before and after every phase: all 30
  identical, every time. `tests/stdlib.test`'s hand-written cases (every
  backend) pin the stdlib programs' functions further.
* **Programs without direct tests: behavior probes.**
  `audit/refactor/tools/probe.tcl` compiles each probe -- a driver calling a
  converted function -- against the tree before the phase (extracted from its
  commit with `git archive`) and the tree after it, with this checkout's
  compiler, runs it on all four backends, and requires identical outcomes
  (value or error code). The probe files (`audit/refactor/tools/probes/*.tcl`)
  are part of the deliverable: 285 probes over nine programs and modules -- `ai_text_clean` 42 (`clean_char` over its whole documented domain, `clean_ai_text` over texts mixing every class), `csv` 44, `csv_chunked` 43, `csv_geometric` 46 and `csv_records` 54 (each scanner at every boundary: quotes, doubled quotes, delimiters, the end of the text, out-of-range indices; `csv_records` also runs the hash-table probes), `hashtable` 4 (insert, replace, growth, delete and reinsert over tombstones), `web` 49 (`emailish?`, `uri_query_value?` and `uri_escape_text`, Unicode inputs, and 40,000-character inputs that would overflow a non-tail recursion), `linux::path` 2 and `abi::bytes` 1 (`replace` at and past both ends) -- each run before and after on all four backends. A probe whose outcome a
  conversion changes on purpose is declared (`differs`) and must differ: the
  four CSV programs' scanners now fail with `IndexNotFound` where they failed
  with `LowerUnderrun` for a negative index -- an index no caller passes --
  and the probe shows both outcomes. Out-of-range probe indices are hidden
  from the analysis (`hash("probe") - hash("probe")`): with a constant one
  the compiler may decide the failure statically (`KNOWN-ERROR`), a fact about
  the probe's constants, which an early version of the probes measured
  instead of the scanner.
* **The mechanical sweep: the round-trip law, call by call.**
  `audit/refactor/tools/method-sweep.tcl` reuses milestone 2's rewrite
  machinery (`me::sugarCall`) and fingerprint: after each respelling the
  unit must compile, lose exactly that finding, keep every other warning,
  and have the original tree's HIR text, core IR and NIR (specialized and
  generic). 355 of 355 calls passed; then every one of the 68 units was
  compared once more (`audit/refactor/method-sweep-log.txt`).
* NIR identity is not required elsewhere: the one-character conversions
  change code on purpose. Their cost is measured separately (section 14).

## 4. Phase log

| phase | commit | findings after | change | regression |
|---|---|---:|---|---|
| kickoff | 6e3f9f7 | 491 | -- | interp 6801/6801, compile 6797 + 4 skipped |
| P0 library repair | -- | 491 | no tree edit: five standalone failures named (section 5) | -- |
| P1 markings | 3f8c0fc | 465 | 5 natives `nomethod`, 26 findings | covered by P2's run (section 17) |
| P2 method sweep | 7697789 | 110 | 355 calls respelled, 24 files | interp 6807/6807, compile 6803 + 4 skipped (the kickoff's four), 0 failed |
| P3 one-character | 316731d | 56 | 54 literals converted in 6 files (`ai_text_clean`, the four CSV programs, `lib/web.bot`) | targeted test files only; five stale pins found later (section 18), covered by the final run |
| P4 structural | 97e13ed | 44 | 5 annotated, 7 merged | targeted run (62 test files naming a touched program): found P3's stale pins and three costly merges |
| P5 H2 | c412959 | 42 | 2 test data respelled | covered by the final run (the expect line pins the sample) |
| P6 gate, docs | bad5b8d | 42 = manifest | gate, CI job, tests, documentation | covered by the final run |
| P4 follow-up | aa4cb40, 47a328d, 991c666 | 42 = manifest | three merges respelled without conjunctions (section 15, finding 12); the pins the refactor moves, updated and attributed | at 47a328d: interp 6808/6813, compile 6804 + 4 skipped, 5 failed on both (five pins P3 had moved, fixed in 991c666); at 991c666: interp 6813/6813, compile 6809 + 4 skipped, 0 failed; native coverage 0 failed |

Every phase's edits were performed and verified on a scratch copy of
`examples/`, `bench/` and `lib/` first (the consolidated sweep, the expected
outputs and the probes against it), and applied to the tree only after.

## 5. P0: library repair

No tree edit could make the five failing modules compile *as entry programs*
without adding a member or changing the language, so P0 changed nothing and
names the obstructions; all fourteen modules load through their loaders, which
is how the gate verifies them (the manifest lists the five as `fails`, with
their codes).

* **`list`, `mutable_array`: own-namespace intrinsics.** `lib/list.bot`'s
  `get` calls `list::at`. As module `list`, the file needs no import for its
  own namespace's intrinsic and may not import its own namespace
  (`SELF-IMPORT`); as an entry program it is in no namespace and needs
  `import list` (`MISSING-IMPORT`). No spelling is valid in both: method
  syntax `xs.at(index)` compiles in both -- and then, when `get` is
  instantiated with a List, is a field projection (`at` is not a visible
  function inside the module), a `TYPE` error at the first use. `get` cannot
  avoid the intrinsic (it is `list::at` with `IndexNotFound` handled).
  Same for `mutable_array.bot`'s `get`.
* **`io`, `linux::io`, `io::path`: the entry-program value.** An entry
  program's value is its last statement; a module file's last declaration is
  a function, and these modules' last functions cannot be values
  (`print`/`write_error_line` require the `IO` context;
  `write_error_text` requires `LinuxIO`; `io::path::text` is
  trait-polymorphic). The checker admits a context function "bound to another
  name as a statement", but a module may contain no top-level expression
  statement, and moving `error`/`context trait` declarations last changes
  nothing (they are not value statements). Only `linux::io` could be
  reordered (`create()` is context-free); that would make its standalone
  compile depend on an invariant no declaration states ("create stays last"),
  so it was not done.

Both are design findings (section 15): the first asks for a way to compile a
library file *as its module*, or for its own intrinsics to be spelled the same
in both contexts; the second for a module file's value to be `unit`.

## 6. P1: nomethod markings

Five registry declarations (`core/scalarbits.tcl`, `core/mutarray.tcl`:
`-nomethod 1`), each with its reason in the source and a pinned test in
`tests/method-eligible.test`:

| native | reason | findings closed | test |
|---|---|---:|---|
| `bit_and` | symmetric operands: neither is a receiver | 8 | `me-nomethod-shipped-bit-and` |
| `bit_or` | the same | 5 | `me-nomethod-shipped-bit-or` |
| `bit_xor` | the same | 1 | `me-nomethod-shipped-bit-xor` |
| `mutable_array::copy` | its first argument is the copy's *destination* (`dst.copy(at, src, from, n)` reads as copying `dst`) | 4 | `me-nomethod-shipped-mutable-array-copy` |
| `mutable_array::create` | its first argument is the new array's *length* (`n.create(x)`) | 8 | `me-nomethod-shipped-mutable-array-create` |

Each test pins the receiver form's `NOMETHOD-CALL` (message and location),
that the functional call is never reported, and its value;
`me-nomethod-shipped-shifts-stay-eligible` pins that the shifts were
deliberately not marked, and `me-nomethod-native-default-off` (which pinned
"no shipped native is nomethod") now pins exactly these five. The one sugar
call site (`ma-ops`) became functional. The markings precede the sweep, as
the phase order requires: no marked function's call was respelled.

## 7. P2: the method-eligible sweep

All **355** remaining findings (381 minus the 26 the markings closed), in 24
files -- 21 example and bench programs (the nine stdlib programs, two surface
samples, `refined-strings`, two `examples/linux` programs, seven bench
programs), and
`lib/byte.bot` (2), `lib/linux/io.bot` (3), `lib/web.bot` (37) -- respelled by
`method-sweep.tcl`: for each file, through a unit that compiles it (the file
itself, or a library module's loader), always the **last** finding in source
order (innermost first: a call is respelled before the calls its receiver
contains, milestone 2's lesson), each call verified by the round-trip law
before the next. **355 of 355 passed, 0 failed**; every unit of the corpus was
then compared against the original once more (same fingerprint, no
`METHOD-ELIGIBLE` left, every other warning unchanged), and the respelled files
were copied over the tree only then. No site fell outside the eligible
receiver forms, so none was a warning-design stop, and none was converted by
hand. Bench programs are included; test files' programs are not (they are
outside the gate, and many have the spelling as their subject). The expected
outputs held (30/30).

The sweep surfaced one readability question it was not its place to answer
(section 15): literal receivers, which milestone 2's eligibility table admits,
read oddly for position-first helpers -- `0.scan_while(local_char?)`,
`500.drive(0)`, `1.pair(2)`, `"abc".replace("x", "y")`.

## 8. P3: the one-character literals

### H1 first

The H1 attempt (section 2) ran first, on a scratch copy, before any other
one-character conversion was applied: its verdict -- falsified, the
obstruction character-to-text construction -- fixed the production-side
policy for every other finding: **a restructure closes a production-side
finding only when it removes the need for a one-character String; slicing
the character out of a longer literal emulates the missing construction and
is not a closing.**

### The consumption side: 54 converted

| program | findings | conversion |
|---|---:|---|
| `examples/stdlib/csv.bot`, `csv_chunked.bot`, `csv_geometric.bot`, `csv_records.bot` | 4 x 7 | `scan_unquoted` and `scan_record`/`scan_record_rest` read the character with `text.char_at(index)` under an `index < str::length(text)` bound and compare it with `','` and `'\n'`; the quote tests go through a new `quote_at?(text, index)` (`index < str::length(text) and text.char_at(index) == '"'`) |
| the same four | 4 x 1 | `scan_quoted`'s doubled quote appended `"\""`; it now appends `character`, the quote's own text, which the scanner already holds (`peek`'s slice, appended for every other character too): the restructure removes the need for the literal, so it is a closing |
| `examples/stdlib/ai_text_clean.bot` | 19 | `clean_char` reads the character its one-character text holds, once, under `str::length(character) > 0` (which proves `character.char_at(0)` in range, so no error joins its empty error set); `cleaner_emoji` and every normalization test compare characters (`'😀'`, `'–'`, ...). `clean_char`'s contract is unchanged; `peek` stays, so `clean_from` keeps its traversal plan |
| `lib/web.bot` (`emailish?`) | 3 | `domain?`'s two `"."` tests and the `"@"` test read the character at a position through a new guarded `char_is?(i, c)` (the guard `i < 0 or i >= n` is `char_at`'s own, and makes `v.char_at(i)` provable, so `emailish?` stays total) |

The scanners' error sets gain `IndexNotFound` (`str::char_at`'s error for an
index outside the String) where `peek`'s `LowerUnderrun` covered the same
unproven lower bound; the samples handle it. For every index a caller passes
(0 up) the behavior is identical; for a negative one -- no caller passes one
-- the error is now `IndexNotFound` (the probes' `differs` entries show it).

Two spellings were rejected along the way, both as evidence:

* A handler form for `clean_char`
  (`c = character.char_at(0): on IndexNotFound: return character`) made the
  warnings report a new `SAME-RETURN-VALUE` (`character` from two exits): the
  guard form above has one fall-through exit.
* The positional helper's calls are written `j.char_is?('.')`,
  `(j - 1).char_is?('.')`, `local_end.char_is?('@')`, and the CSV programs'
  `text.char_at(index)`, `text.quote_at?(index)`: every new two-parameter call
  is in method form, so P3 introduced no `METHOD-ELIGIBLE` finding.

### The production side: no today-mechanism

Twenty-four findings need a single character *as text*. Each was examined for
a restructure that removes the need; only the CSV quotes had one (the text was
in hand). The rest are manifested `char->text`. **The quantified API case**:

| shape | findings | functions |
|---|---:|---|
| a table of characters as text, indexed and appended | 16 | `web.bot`'s `hex_digits`, read by `hex_pair` |
| a fixed character appended to text | 2 | `io::print_line`, `io::write_error_line` (`"\n"`) |
| a fixed character prepended to text | 1 | `web.bot`'s `pct` (`"%"`) |
| two texts joined by a fixed character | 2 | `linux::path::concat` (`"/"`), `examples/io/child-path.bot`'s `run` (`" "`) |
| a character-valued result its caller appends as text | 3 | `ai_text_clean.bot`'s `clean_char` (H1) |
| **total** | **24** | **7 functions, 4 files** |

Twenty-one of the 24 are *appends*: what they need is not a String made from a
character (`str::of_char('\n')` would be a longer spelling of `"\n"`) but an
append of a character to text -- a `str::concat` (or a builder) that takes a
UnicodeChar, after which `hex_digits` is a `List[UnicodeChar]` and the joins
and newlines are character literals. The three `clean_char` results are text
by role (their siblings are `""` and `"..."`): a character-to-text
construction would let `clean_char` map a character to a character, but its
natural result stays text. Twenty of the 24 are in libraries (17 in
`lib/web.bot`, 2 in `lib/io.bot`, 1 in `lib/linux/path.bot`) and print for
every program that loads them, so the demand is concrete: **an append of a
UnicodeChar to a String would make `io` -- and with it every portable I/O
program -- strict-clean, and close 21 findings in 6 functions.**

### The classifier coupling: 10 manifested

Ten consumption-side findings did not convert, for one reason: the character
is also a String for a String-taking classifier.

* `lib/web.bot`: `local_extra_chars` (5) is queried by
  `local_char?(c: str) -> bool`, which classifies the same `c` with
  `str::is_tcl_alnum` and is passed to `scan_while` beside the native
  `str::is_tcl_alpha` under `Fn{args: [str], return: bool}`; `label_char?`'s
  `c == "-"` (1) sits beside `str::is_tcl_alnum(c)`.
* `bench/lex-strategy.bot`: `lenient_ident_char?`'s `"_"`, `"-"` (2), joined
  with `str::is_tcl_alnum` at a callable join (`choose_classifier`).
* `bench/source-checks.bot`: `is_underscore?`, `is_hyphen?` (2), members of a
  List of classifiers with `str::is_tcl_alpha`/`alnum`, applied to one value.

Converting them means decoding the String the classifier needs:
`str::length(c) == 1 and c.char_at(0) == '_'` is the exact equivalent of
`c == "_"` and strictly worse to read; for `emailish?`, the alternative is
redesigning `scan_while`'s contract around positions, which its proof-pinned
repeatability and exact-callable design (R2A/REFINEMENT-VALUES) rest on --
beyond any closing. The demand: **character classifiers** (`is_tcl_alnum`/
`is_tcl_alpha` over a UnicodeChar) would make the whole predicate chain
character-typed and close all ten.

### The index proof: 1 manifested

`linux::path::concat` tests whether PATH ends with `"/"` as
`path.substring(n - 1, n) == "/"`. The character spelling
`path.char_at(n - 1) == '/'` is not proven in range: the completion proof
relates an *index* to a String's length only through a guarded name
(`IndexBounds`), not through the linear form `n - 1 < n` that the *slice*
proof uses, so `IndexNotFound` would join an errors clause the `io::path::Path`
trait fixes. A bound name with a lower guard (`last = n - 1`, `last >= 0`)
is not proven either; `path.substring(n - 1, n).char_at(0) == '/'` is, but it
decodes a slice made only to be decoded, at two allocations a call where the
comparison allocates none. Manifested `index-proof`; routed as a proof-gap
finding.

### Cost, measured (native)

* **CSV**: allocations identical before and after on ASCII and non-ASCII
  input (300 rows: csv 8,320, csv_geometric 8,630, csv_chunked 9,254,
  csv_records 8,688); UTF-8 seeking on non-ASCII input 122,207,268 ->
  132,103,099 bytes (+8%): the scanners were already outside the traversal
  plan (their start index is not the literal 0), and `str::char_at` seeks
  from byte 0 like the slice.
* **ai_text_clean**: on the 10,000-character punctuation fixture, String
  allocations 19,127 -> 29,182 (+52%); seeking stays 0. The cause is one
  `shorttostr` per character: `str::char_at` on the one-character slice
  materializes it (a slice compared with a literal is a String region and
  allocates nothing; a slice handed to `str::char_at` becomes a substring and
  then a heap String). A design finding for the native backend (section 15),
  measured in the bench table (section 14).

## 9. P4: the structural conversions

| finding | mechanism | the change |
|---|---|---|
| `FIXED-ARITY-LIST-RETURN` x 5 | annotated | `-> list` on `ai_text_clean`, `string_replace`, `string_reverse`'s `sample`, `csv_records` and `hashtable`'s `sample_checks` (their results are the samples' lists of checks and values, printed and compared with `# expect:`, never destructured). The affine work had already turned `csv_chunked`'s two builder-state findings into the `ChunkedBuilder` struct, so no struct conversion remained |
| `FIXED-ARITY-LIST-RETURN` `13-hygiene.bot`'s `pair` | manifested | the example is about the list literal, so `-> list` is its answer, not a struct; but the annotation is a source fact core IR cannot carry, and `tests/surface-samples.test` checks that this sample's HIR is what analysis of its core IR derives: annotated, the round trip re-types `pair` and the check fails. Obstruction `core-ir-roundtrip` (section 12) |
| `SAME-RETURN-VALUE` `ht_find_insert` x 2 (`hashtable.bot`, `csv_records.bot`) | merged | the two `return index` exits end the search for the same reason, the probed slot is the answer: the function becomes one `if`/`elif` chain over the slot's state, with the original conditions verbatim -- an empty slot returns an earlier tombstone if there is one, the key's own slot does nothing (`unit`), a tombstone or another key's slot probes on -- and both answers fall through to one final `index`. The first merge spelled the reading as conditions (`if state == ht_empty_state() and first_tombstone >= 0: return first_tombstone` then `if state == ht_empty_state() or (...): return index`); it tested `state == ht_empty_state()` twice and branched on two materialized bools, 245 machine instructions and 40 jumps for `ht_find_insert` against the unmerged 222 and 31; the chain has 213 and 32 (section 15, finding 12) |
| `SAME-RETURN-VALUE` `ht_delete` | merged | its early `return table` is the guard inverted around the deletion: `if index >= 0:` deletes, and the one exit returns `table` |
| `SAME-RETURN-VALUE` `domain?` | merged | an on-sight rejection (a leading or doubled `"."`, a character that is not a label character) leaves the scan with `break`, so every rejection is the one `false` after the loop; the comment says so |
| `SAME-RETURN-VALUE` `emailish?` | merged | the three nested tests keep their `if`s, negated (`local_end > 0`, `local_end < n`, `local_end.char_is?('@')`), with `return domain?(local_end + 1)` innermost, and every rejection falls through to one `false`. The conjunction it spells (`local_end > 0 and local_end < n and ... and domain?(local_end + 1)`) was the first merge and was rejected by the tests that pin `refined-checks`' analysis: an `and` operand is not narrowed by the operands before it, so `domain?`'s entry range grew to 2^62 and its parameter lost its raw (untagged) ABI (section 15, finding 12). The nested form keeps every instance and raw-ABI decision of `refined-checks` and `uri-steady`, with four entry ranges one tighter at the bottom (`local_end > 0` narrows where the original `== 0` test's else-branch did not: `char_is?`, `domain?`, `tld?` and a `scan_while` instance each start one higher, `domain?` at 2); `local_end != 0`, the literal negation, lowers as a materialized bool |
| `SAME-RETURN-VALUE` `valid_from?` (`uri_query_value?`) | merged | a valid escape or character continues by a returned tail call (`return valid_from?(i + 3)` / `(i + 1)`), and everything else falls through to one `false`. An `and` chain was rejected: it would take the self-call out of tail position (the probes include a 40,000-character value, unchanged on every backend) |
| `SAME-FAILURE` `abi::bytes::replace` | merged | the in-range case returns from inside the two nested tests (`if index >= 0: if index < mutable_byte_store::count(data.storage): return ...`) and the one `fail IndexNotFound` follows them. Milestone 4's verified merge, `if index < 0 or index >= count: fail IndexNotFound`, was the first spelling; its `or` lowers to NIR as a materialized bool and a branch on it (10 -> 13 registers, two extra jumps), where the nested tests branch directly as the unmerged code did (section 15, finding 12) |

Every restructure carries behavior probes (section 3); none needed a manifest
entry. The probes ran twice: on P4's first spellings, and on the final ones
(108 probes over `hashtable`, `abi::bytes`, `web` and `csv_records`,
identical on every backend). Each final merge was also compared with the
unmerged tree below the source: the range analysis of `refined-checks` and
`uri-steady` (every instance, entry range and raw-ABI decision: P3's, or one
tighter at the bottom where `local_end > 0` narrows), their NIR (the same
operations; joins of `false` become joins of `unit` before one final
`false`), and the machine instructions of each merged function (`emailish?`
83 against 77, `domain?` 122 against 151, `valid_from?` 187 against 184,
`ht_find_insert` 213 against 222, `ht_delete` 199 against 206,
`abi::bytes::replace` 61 against 60).

## 10. P5: H2

H2 was attempted last, after every other mechanism had been exercised, so
that "no non-weakening closing exists" is informed. The search covered every
mechanism the other phases used -- a character literal (rejected statically or
at run time: `replace` takes Strings), a table slice or computed String
(hides the datum), restructuring the sample (changes the pinned output) -- and
one more question per finding: *is the length of this datum part of what its
case checks?* Section 2 has the per-finding verdicts: six are (the manifest
carries each with its own argument), two -- the replacements of the
absent-needle and empty-haystack cases, never inserted -- are not, and were
respelled `"yz"` with a comment saying why only their non-emptiness matters.
The expected output (`["abc", "aXc", "bb", "", ""]`) and every stdlib case are
unchanged.

## 11. The closing-mechanism table

`audit/refactor/closings.txt` lists **every** finding of the kickoff sweep --
491 lines, by the kickoff tree's location -- with exactly one mechanism, the
phase that applied it and its verification (generated by
`audit/refactor/tools/closings.py` from the kickoff audits' own records).
There is no "deliberate" entry.

| code | converted | annotated | merged | marked | manifested | total |
|---|---:|---:|---:|---:|---:|---:|
| `METHOD-ELIGIBLE` | 355 | | | 26 | | 381 |
| `ONE-CHAR-STRING-LITERAL` | 56 | | | | 41 | 97 |
| `SAME-RETURN-VALUE` | | | 6 | | | 6 |
| `FIXED-ARITY-LIST-RETURN` | | 5 | | | 1 | 6 |
| `SAME-FAILURE` | | | 1 | | | 1 |
| `PROVES-NAMING` | | | | | | 0 |
| `MANY-BOOLEAN-ARGUMENTS` | | | | | | 0 |
| **total** | **411** | **5** | **7** | **26** | **42** | **491** |

## 12. The manifest

`audit/refactor/manifest.txt` lists all 54 corpus programs: 47 `program`
entries, two `rejected` (`examples/surface/09` and `10`, untouched), five
`fails` (the P0 standalone failures, each with its code and obstruction), and
the **42 expected findings**, each with its code, location, hypothesis tag and
a one-line obstruction stated per finding:

| file | entries | obstructions |
|---|---:|---|
| `lib/web.bot` | 23 | char->text 17 (the hex-digit table, `"%"`), classifier 6 (the local-part set, the label `"-"`) |
| `examples/stdlib/string_replace.bot` | 5 | test-datum, H2 |
| `examples/stdlib/ai_text_clean.bot` | 3 | char->text, H1 |
| `lib/io.bot` | 2 | char->text |
| `lib/linux/path.bot` | 2 | char->text 1, index-proof 1 |
| `bench/lex-strategy.bot` | 2 | classifier |
| `bench/source-checks.bot` | 2 | classifier |
| `examples/stdlib/string_reverse.bot` | 1 | test-datum, H2 |
| `examples/io/child-path.bot` | 1 | char->text |
| `examples/surface/13-hygiene.bot` | 1 | core-ir-roundtrip (`FIXED-ARITY-LIST-RETURN`) |

### Prediction and outcome

The brief predicted the manifest from the re-audit's classifications: the 8
H2 findings, the 3 `clean_char` findings if H1 failed, the concat-shaped
findings if no today-mechanism existed (the M6 catalog's `str::concat`
argument row, 9, and its `hex_digits` row, 16), and possibly nothing else.

| class | predicted | outcome | what the attempt changed |
|---|---:|---:|---|
| H2 test data | 8 | 6 | two never-inserted replacements closed (H2 falsified for them) |
| H1 `clean_char` returns | 3 (if H1 fails) | 3 | H1 falsified |
| concat-shaped production | 25 | 20 | the four CSV `"\""` appends closed by restructure (the quote's own text was in hand); `ai_text_clean`'s three returns are counted under H1 |
| consumption side (comparisons, sets) | 0 | 11 | 10 coupled to String-taking classifiers, 1 blocked by the index proof: the brief expected all comparison and set rows to convert |
| `13-hygiene`'s `pair` (`FIXED-ARITY-LIST-RETURN`) | 0 | 1 | its `-> list` would break the sample's HIR/core-IR round trip |
| every other code | 0 | 0 | as predicted |
| **total** | **36** | **42** | |

The manifest is minimal: every entry was attempted, and each states why the
mechanisms tried do not close it.

## 13. The gate and the CI step

`audit/refactor/tools/gate.tcl` (sourcing `sweep.tcl`):

1. the corpus programs and the manifest's programs are the same set (a new
   program must be listed; a listed path must exist);
2. every unit -- the 54 programs standalone and the 14 loaders -- compiles,
   or fails with exactly the manifest's code (`rejected`, `fails`);
3. each compiling unit's observed warnings, as `{CODE FILE LINE COL}`
   records, equal the manifest entries of every file the unit compiled (its
   own and its modules'): a new warning anywhere, a missing one, and a
   drifted location all fail;
4. every manifest entry is observed by some unit (a closed finding must
   leave the manifest);
5. every unit whose expected set is empty compiles under `-warnings error`.

It reports 42 strict units (32 programs, 10 loaders) and 19 carrying
entries, in about 20 seconds; CI runs it as the `warning-gate` job of
`.github/workflows/tests.yml` on every push and pull request (no native build
needed: warnings are discovered before any backend). `-root DIR` gates another
tree's corpus with this checkout's compiler, which is how
`tests/warning-gate.test` tests the ratchet: on a scratch copy it plants a new
one-character literal in `lib/mathish.bot` (fails: "unexpected warning
ONE-CHAR-STRING-LITERAL at lib/mathish.bot:..."), closes the manifested
`reverse_chars("a")` datum (fails: "expected warning ... not observed" and
"manifest entry not observed by any unit"), inserts a line above it (fails:
drift), adds an unlisted program (fails), and plants a `METHOD-ELIGIBLE`
call in the strict `01-arithmetic.bot` (fails twice: the unexpected warning,
and the strict-mode compile). The gate is the milestone's lasting deliverable:
it makes the cleanup a ratchet.

## 14. Bench before and after

Both trees -- the kickoff (6e3f9f7) and the final one (991c666) -- ran every
benchmark script that measures a touched program, back to back on one
machine with nothing else running: `bench/bench.tcl` (the `bench/*.bot`
programs on every backend, with the Python, Rust and Go reference
implementations), `bench/corpus.tcl` (the stdlib corpus on every backend),
`bench/ai_text_clean.tcl`, `bench/csv_records.tcl`, `bench/hashtable.tcl` and
`bench/uri-steady.tcl`, in two rounds. The session's container restarted
twice during the runs and came back on a different machine, so only a
before/after pair measured on the same host is compared: round 1 for
`bench.tcl`, `corpus.tcl`, `ai_text_clean` and `csv_records`; round 2 for
everything except `bench.tcl`. A timing delta counts as real only when it
has the same sign and a similar size in both same-host rounds, or, where one
round is all there is, lies far outside the swing of code that did not
change: at microsecond scale the unchanged reference implementations moved
-49% to +116% between the two sides, and P2's NIR-identical `lex-strategy`
and `test-selection` +51% and +100%. Allocation counts and code bytes are
deterministic and need no noise floor.

| program | backend | before -> after (round 1 / round 2) | verdict |
|---|---|---|---|
| `ai_text_clean`, 100K characters | cranelift | ascii +22% / +33%, punctuation +31% / +54%, emoji +29% / +20%; Strings allocated +50-54% (ascii 200,110 -> 300,165), deterministic | **slower**: one materialized String per character (finding 3) |
| `csv`, `csv_geometric`, `csv_chunked`, 10,000 rows | cranelift | -16% / -14%, -16% / -16%, -24% / -22% | **faster**; each 449-480 B less machine code (section 18) |
| `csv_records` (`csv_records.tcl`) | cranelift | csv-only parse -46% to -75%, the realistic schema -17% to -52%, both rounds; allocations identical | **faster** |
| the four CSV programs | Tcl interp | +10% to +22%, both rounds | **slower** |
| the four CSV programs | Tcl compile | +22% to +44%, both rounds | **slower** (below) |
| `hashtable` | cranelift | construction and operations: deltas of either sign within the round's own swing; allocations and probe metrics identical | unchanged |
| `uri-steady` | cranelift | median 2,822 -> 2,830 us (spreads 3.4%, 1.5%); allocations 10,509 and machine code 7,100 B identical | unchanged |
| `string_reverse`, `string_replace`, `matmul` | every backend | within noise | unchanged (P2 respellings only: identical NIR) |
| `bench/*.bot` | Tcl interp, compile | within +-6% | unchanged |
| `bench/*.bot` | cranelift | within the reference implementations' swing | unchanged |

**The Tcl backends' CSV slowdown, attributed** (`csv`, 1,000 rows, compile
backend, best of 3): the P2 program 970 ms, the P3 program 1,098 ms; P3 with
`quote_at?` inlined into `scan_field` 987 ms, P3 with `scan_unquoted`'s test
spelled `==`/`or` instead of `!=`/`and` 1,028 ms. The character reads are not
the cost: over 20,000 characters, `str::char_at` and a character comparison
take 8.3 s on interp and 413 ms on compile, `peek` and a String comparison
12.5 s and 415 ms. So it is the helper call, which the Tcl backends do not
inline, and the conjunction (finding 12's shape again); native inlines both
and got faster. The Tcl backends are the reference implementations, not the
production path, so the source was not reshaped for them.

**`ai_text_clean` is the one native regression**, and the language offers no
cheaper spelling: `str::char_at` is the only character reader, and reading
the character from the text itself (`text.char_at(index)`) would leave the
traversal plan, a quadratic seek (finding 4). The fix is the runtime's:
`str::char_at` on a short String or a region without materializing it
(finding 3).

An observation that did not survive: `uri-steady`'s lowering time looked
halved in round 1 (about 200 -> 107 ms per session); re-measured directly
with each tree's compiler and library, the same configuration ranged from
148 to 255 ms between runs, so it is noise, not an effect.

## 15. Design findings

Recorded for the language's next milestones; none was acted on here (the
fence). LANGUAGE-LIBRARY-DEFICIENCIES.md collects the language, library,
analysis and backend deficiencies among them, with their measurements and
what each one forces on code, in one place.

1. **Append a character to text** -- 21 findings in 6 functions (section 8):
   a `str::concat` (or builder) that takes a UnicodeChar. This, more than
   `str::of_char`, is what the production side asks for; `str::of_char('\n')`
   would be a longer spelling of `"\n"`.
2. **Character classifiers** -- 10 findings: `str::is_tcl_alnum`/`alpha`
   over a UnicodeChar would let `emailish?`'s classes, `lex-strategy`'s and
   `source-checks`' uniform classifier contracts be character-typed.
3. **`str::char_at` and the String-region / short-string representations**
   (native): `str::char_at` of a one-character slice materializes it (a
   substring, then a heap String), where `==` with a literal and `str::length`
   allocate nothing. The char idiom in `ai_text_clean` costs one String per
   character for that reason alone: +50-54% Strings and +20-54% time at 100K
   characters (section 14); a region form of `char_at` (`decodecharat` exists
   for the traversal) would make it free.
4. **Traversal plans for `str::char_at` scans** (native): `hir/traversal.tcl`
   recognizes only `peek`-shaped (width-1 substring) accessors at a zero
   start. A `char_at`-indexed scan has no byte cursor: the CSV scanners' UTF-8
   seeking on non-ASCII input is quadratic (it was before too: their start is
   not the literal 0). H1's table form shows how easily a recognized scan
   drops back to quadratic: one function reading a program-level String (or
   List) binding is a closure with a non-Int capture, which stays generic
   with its callers, and only a specialized instance gets a plan (finding
   11).
5. **The index proof** (`hir/completions.tcl`'s `IndexBounds`): an index is
   related to a length only through a guarded *name*, not through linear forms
   (`n - 1 < n`) as the slice proof does, and a recursive scanner's index is
   never proven non-negative (so `IndexNotFound` joins the CSV scanners'
   error sets where `LowerUnderrun` was).
6. **Literal receivers read poorly for position- and count-first helpers**
   (a question for the `METHOD-ELIGIBLE` milestone, not a false positive: every
   respelling is sound): `0.scan_while(local_char?)`, `500.drive(0)`,
   `1.pair(2)`, `"abc".replace("x", "y")`, `"%".concat(hex_pair(b))`. Milestone
   2's table admits literal receivers; whether a numeric literal should be one
   is the warning's design decision.
7. **`ONE-CHAR-STRING-LITERAL` on text by role**: `clean_char`'s `"-"` is a
   length-1 instance of a variable-length text result (its siblings are `""`
   and `"..."`). The warning is context-blind by design (M6); this is data for
   that decision, not a false positive.
8. **Compiling a library file**: a module cannot spell its own namespace's
   intrinsics validly both as a module and as an entry program (`list`,
   `mutable_array`), and an entry program's value is its last declaration, so a
   module of context or trait functions cannot compile as one (`io`,
   `io::path`, `linux::io`). A "compile as module" mode, or a module file's
   value being `unit`, would retire both.
9. **`mutable_array::generate`** has `create`'s shape (its first argument is
   the length) but no corpus finding, so the re-derived queue does not mark
   it; its author may want to.
10. **Mixed spellings from the ambiguity rule**: where a module defines a
    member with a native's short name (`linux::path::concat`, `io::path`'s
    `concat`), the native's calls stay functional (`str::concat(path,
    component)`) beside sugared ones elsewhere -- the warning is correctly
    silent (the sugared form would be ambiguous); the file reads mixed.

11. **A candidate warning: a constant String scanned as a character table**
    -- "do not loop exhaustively through a constant String; prefer a List of
    characters". Recorded as a recommendation, not built (a new warning code
    is outside this milestone's fence). The shape is the H1 attempt's:

    ```botlish
    marks = "–—‘’“”"
    ...
    loop i from 0 to str::length(marks):
        if marks.char_at(i) == c:
    ```

    a sequence of characters spelled as text and decoded one index at a time.
    The suggested spelling exists today: a `List[UnicodeChar]` literal,
    `marks = ['–', '—', '‘', '’', '“', '”']`, read with `marks.at(i)`, or
    iterated with `loop m in marks` where the position is not needed.

    *Measured* (`audit/refactor/h1-attempt/variants/measure.tcl`: native,
    `native::allocationReport`, `clean_ai_text` on `bench/ai_text_clean.tcl`'s
    punctuation fixture at 2,000 / 4,000 / 8,000 characters; the H1 attempt's
    `marks` spelled both ways and placed both ways, `normalized` unchanged):

    | `marks` | where | UTF-8 seek bytes | List element copies | Strings allocated |
    |---|---|---:|---:|---:|
    | String | program level (the H1 attempt) | 2,483,588 / 9,751,421 / 38,647,782 | 6 / 6 / 6 | 2,062 / 4,062 / 8,062 |
    | List of characters | program level | 2,394,941 / 9,576,437 / 38,300,055 | 12 / 12 / 12 | 2,062 / 4,062 / 8,062 |
    | String | in `clean_char` | 88,647 / 174,984 / 347,727 | 6 / 6 / 6 | 5,968 / 11,771 / 23,377 |
    | List of characters | in `clean_char` | 0 / 0 / 0 | 12,336 / 24,336 / 48,336 | 5,968 / 11,771 / 23,377 |
    | (no table: the P3 program) | | 0 / 0 / 0 | 6 / 6 / 6 | 5,968 / 11,771 / 23,377 |

    What the List removes is real but small: the decoding of a non-ASCII
    constant on every read (a read at index i decodes from byte 0; about 44
    bytes per call here, linear in the input; an all-ASCII constant has no
    such cost, its byte and character positions agree). What it adds, inside
    a function, is the literal rebuilt on every call (six element copies per
    call). The cost that made the H1 table quadratic is the *placement*, and
    the List does not touch it: read from program level, either spelling
    makes `clean_char` a closure with a non-Int capture, generic with its
    callers (finding 4). Nor would the List have changed the H1 verdict:
    `normalized`, the table's other half, must stay text (char->text), and
    two parallel Lists keep the alignment invariant two parallel Strings had.

    *Census*: the shipped corpus (54 programs, 14 modules) has no such scan.
    Its character sets already use the forms the suggestion points to: an
    `or` chain of character comparisons (`ai_text_clean`'s `cleaner_emoji`),
    `byte::set(['-', '.', '_', '~'])` (`lib/web.bot`'s unreserved
    characters), an `ImmutableSet` (`lib/web.bot`'s `local_extra_chars`, of
    one-character Strings because of a String classifier: finding 2). The one
    instance is the H1 attempt, which is not corpus and was rejected.

    **Recommendation: do not build it now; keep it as a candidate with
    graduation criteria.** As phrased, it has no corpus evidence (no finding
    would fire on shipped code), and its advice is not a measured improvement
    on today's backends: it trades a small linear decode for a per-call
    rebuild, or, hoisted, keeps the dominant cost. "Exhaustively" also needs
    care: a List makes each read cheap, not the search shorter, and for
    membership it costs more than the `or` chain today. Measured on
    `ai_text_clean`'s 12-way emoji chain (`audit/refactor/ripple/`, 100K
    characters, native): the chain 16.7-28.0 ms; a loop over a List built in
    the function 27.9-30.7 ms and one more object per character; an
    `ImmutableSet` built per call 81-90 ms; an `ImmutableSet` bound at
    program level 3.4-3.7 s, because reading it makes the function a generic
    closure and the scan loses its traversal plan (6-7 GB re-decoded). A
    "prefer a List (or set) over an `or` chain" warning, the converse
    candidate, would steer code to the slower spellings for the same reasons,
    and there is no `list::contains` for it to suggest. If a
    re-audit finds the shape in shipped code, the version that would meet this
    repository's rule for warnings (backed by a compiler proof, no opt-out,
    no fixit unless proven) is narrower than the phrase:

    * *Rule*: a String `const` (exact value, `hir::exact::Of`) bound to a name
      whose every use is `str::char_at(K, i)` with `i` proven in
      `[0, str::length(K))` (the loop bound, or the index proof).
    * *Proof*, the round-trip law's analogue: respelled as the List literal of
      K's exact characters, every read yields the same character and neither
      spelling raises; checked by compiling the respelled program to the same
      values and error sets.
    * *Not covered*: a width-1 slice `str::substring(K, i, i + 1)` consumed as
      text (the H1 table's `normalized`): no List of characters is equivalent
      there, and a List of one-character Strings is what
      `ONE-CHAR-STRING-LITERAL` reports. That slice is also how the H1 table
      evades the literals-only `ONE-CHAR-STRING-LITERAL` (a one-character
      String computed from a longer literal); whether a provably width-1 slice
      of a constant should be reported is a separate question for that
      warning's successor, not part of this candidate.
    * *Prerequisites*, so that following the warning never costs more than
      ignoring it: a constant List literal materialized once rather than per
      call (native), and a function that reads a program-level constant
      specialized like one that does not (finding 4). Without them, the
      warning would steer code toward the rows of the table above that are
      not better.

12. **Conjunctions cost what nested tests do not** (`hir/range.tcl`;
    native lowering). The merge warnings (`SAME-RETURN-VALUE`,
    `SAME-FAILURE`) point at exits a condition can join, and the natural
    spelling of that condition is an `and`/`or`. Today both halves of the
    compiler treat it worse than the nested tests it replaces:

    * *Range narrowing does not flow through `and`.* A comparison narrows
      the then-branch of an `if` it is the condition of, but neither the
      later operands of an `and` nor the then-branch of an `if` whose
      condition is an `and`. `emailish?`'s first merge, `local_end > 0 and
      local_end < n and local_end.char_is?('@') and domain?(local_end + 1)`,
      left `local_end < n` unused: `domain?`'s entry range became
      [1, 2^62] instead of [1, 2^62 - 1], and its parameter lost its raw
      (untagged) ABI in the default configuration
      (`tests/closure-int-keys.test`'s RawInt plan; the same with the `and`
      as an `if` condition).
    * *Native lowers an `and`/`or` condition, and `!=` on raw Ints, as a
      materialized bool* -- each operand's outcome moved into a register
      and branched on again -- where nested `if`s branch directly.
      `ht_find_insert`'s first merge (`state == ht_empty_state() and ...`,
      `state == ht_empty_state() or (...)`) cost 245 machine instructions
      and 40 jumps against the unmerged 222 and 31; `abi::bytes::replace`'s
      `index < 0 or index >= count` 13 NIR registers against 10.

    Every merge in the corpus now keeps nested tests or an `if`/`elif`
    chain (section 9), and its analysis and machine code were checked
    against the unmerged tree: `refined-checks`' and `uri-steady`'s
    instances, entry ranges and raw-ABI decisions are those of P3 or
    tighter (`emailish?`'s `local_end > 0` starts `domain?` at 2), and the
    merged functions' instruction counts are within a few of P3's
    (`ht_find_insert` 213, `ht_delete` 199 against 206, `domain?` 122
    against 151). Narrowing through `and` and branch-lowering of `and`/`or`
    conditions would let the merge warnings' natural answer be the cheap
    one; until then, a merge that writes a conjunction should be measured.

13. **The character type does not ripple to the read.** P3 converted the
    sites the warning reports -- literals compared with a character -- and
    the values reaching them stayed one-character Strings: `ai_text_clean`
    reads each character with `peek` (a slice) and decodes it
    (`char_at(0)`); the CSV scanners still `peek` the character `scan_quoted`
    appends to a field. A computed one-character String is never a finding
    (the warning is literals-only), so nothing in the refactor's mechanism
    reached the producers. Carrying the character up to the read is the
    better program and, today, a pathological one (`audit/refactor/ripple/`,
    `ai_text_clean` at 100K characters, native): `clean_from` reading
    `text.char_at(index)` allocates 7 Strings where the merged program
    allocates 290,328 -- every unchanged character is output as a slice of
    the input -- but takes 7.2-8.4 s instead of 17-28 ms, re-decoding 11-13 GB
    of UTF-8, because a traversal plan exists only for `peek`-shaped reads
    (finding 4). Two obstructions remain past that one: the output is text,
    and a character cannot become text (finding 1: the three normalizations,
    the hex digits, `"\n"`, `"/"`, the CSV fields built a character at a
    time); and `str::is_tcl_alnum`/`is_tcl_alpha` take Strings (finding 2).
    Possible today and not done, because no finding pointed there:
    `scan_quoted` could build a field from the slices between doubled
    quotes instead of a character at a time.
14. **`METHOD-ELIGIBLE` is blind to receiver types.** Its candidate rule
    counts the functions of the name visible to the call, not the ones
    whose parameter types admit the receiver. `hashtable.bot`,
    `csv_records.bot` and `csv_chunked.bot` import `list` (for
    `list::append`) and `mutable_array`, and both define `at`, so their 28
    `mutable_array::at(...)` calls stay functional beside sugared
    `.set(...)` calls in the same functions. Where the receiver is an
    untyped parameter (`ht_rehash_scan`'s `controls`) that is right:
    `controls.at(i)` is `AMBIGUOUS-METHOD-CALL (list::at, mutable_array::at)`.
    Where it is typed (`a: MutableArray[int]`), `a.at(i)` compiles and
    resolves to `mutable_array::at`, and the warning is still silent. Two
    language facts compound it: an import brings in every member of the
    namespace (there is no selective import, by design: IMPORTS.md), and
    the method resolver decides between same-named members only by receiver
    type.
15. **Where a warning consistently cannot be applied.** Three kinds, all
    seen in this corpus:
    * *It fires and no closing exists today*: the 42 manifested findings --
      character to text (24), String-typed classifiers (10), test data whose
      length is the subject (6), the index proof (1), a `-> list` that core
      IR cannot carry (1). Every program that imports `web`, `io` or
      `linux::path` inherits their findings, and with one warning policy per
      compilation (by design) it can never compile under `-warnings error`
      until they close.
    * *It should fire and structurally cannot*: `METHOD-ELIGIBLE` under name
      ambiguity even when the receiver's type decides it (finding 14), on a
      module's own intrinsics inside the module, and on a native shadowed by
      a module member (finding 10); `ONE-CHAR-STRING-LITERAL` on any computed
      one-character String -- a slice, a table entry -- including the H1
      table that evades it (finding 13).
    * *Its closing costs more than the finding, or raises another*: the
      merges' natural conjunctions (finding 12); the handler form of a
      `ONE-CHAR-STRING-LITERAL` conversion, which raised `SAME-RETURN-VALUE`
      (section 8); literal receivers of position-first helpers, which only
      `nomethod` on the callee can stop (finding 6); `ai_text_clean`'s
      character idiom on native (finding 3).
    `PROVES-NAMING` and `MANY-BOOLEAN-ARGUMENTS` never fired in the corpus,
    so this refactor exercised neither.

**Warning false positives** (required question 12): none. No conversion that
would have been sound was rejected by a warning; the one new warning a
conversion attempt produced (`SAME-RETURN-VALUE` on the handler form of
`clean_char`) reported a true fact, and the conversion was rewritten.

## 16. Documentation

* **The standing rule**, stated once each where readers look: README §23
  ("The shipped code is held to these warnings": the gate, the manifest, the
  three modules that still carry findings and why, and that a program loading
  none of them can use `-warnings error`), AGENTS.md (a new "The warning gate"
  section: how to run it and how to answer a new warning -- in the code,
  never by a manifest entry -- plus the corrected library-findings paragraph),
  and this report.
* **The no-system-header limitation** is retired in a successor note in every
  per-warning report's known limitations (WARNINGS-*.md, all seven): retired
  outright for six codes (no library carries one), and for
  `ONE-CHAR-STRING-LITERAL` except `lib/web.bot`, `lib/io.bot` and
  `lib/linux/path.bot`, whose findings are manifested.
* **Where the corpus now exemplifies the idioms**: README §1 ("Strings and
  characters") points at the cleaned scanners as the character idiom's first
  corpus presence, and at the manifest for what still needs a one-character
  String; README §17's `nomethod fn` paragraph lists the five shipped
  markings and their reasons (it said "no shipped function is marked");
  MULTI-VALUE-RESULTS.md notes that the corpus's sample functions are now
  declared `-> list`. FLAGS.md is unchanged: the corpus exemplifies no new
  flag idiom (the census's nine single-option bools stay recorded, not
  converted).
* **`BOTLISH_WARNINGS` and the command line gained nothing** (README §23 says
  so): the gate is a separate tool, not a compiler mode.

## 17. Full regression

Each run is the whole suite (`tests/all.tcl`) in a worktree of the commit,
interp and compile in parallel with private `-tmpdir`s; native coverage is
`tests/native-coverage.tcl` (the whole suite on the cranelift backend,
every test classified).

| tree | interp | compile | native coverage (cranelift) |
|---|---|---|---|
| kickoff 6e3f9f7 | 6801/6801 | 6797 passed, 4 skipped, 0 failed | 2713 native, 3959 independent, 69 passed-partial, 60 unsupported, 0 failed |
| P2 7697789 (P1 included) | 6807/6807 | 6803 passed, 4 skipped, 0 failed | -- |
| 47a328d | 6808 of 6813, 5 failed | 6804 passed, 4 skipped, 5 failed | 2717 / 3962 / 69 / 60 / 5 failed |
| **final 991c666** | **6813/6813** | **6809 passed, 4 skipped, 0 failed** | **2718 / 3966 / 69 / 60 / 0 failed** |

The five failures at 47a328d were the same five tests on every backend, pins
P3 had moved (section 18); 991c666 updates them and changes nothing else. The
four compile skips are the kickoff's own (the `coreScoping` constraint). The
twelve new tests are P1's six marking tests and `tests/warning-gate.test`'s
six. The unsupported tests are the same 60 in the same construct groups
before and after: the refactor added no native gap. Commits after 991c666
change only this report.

## 18. Deviations and known limitations

* **The libraries are not all warning-clean.** The brief's P0 standard
  ("shipped libraries are warning-clean") holds for 11 of 14 modules; `web`,
  `io` and `linux::path` carry 27 manifested `ONE-CHAR-STRING-LITERAL`
  findings, each with its obstruction (section 12). The standing rule is
  stated with that remainder, and the no-system-header limitation is retired
  except for those three.
* **Five modules do not compile as entry programs** (P0): the obstructions
  are named; all fourteen load, and the gate verifies them through their
  loaders and pins the five failures' codes.
* **The P1 regression was not run separately.** P1 (the markings) and P2
  (the sweep) were committed back to back; the P2 regression covers both
  cumulatively. A separate P1-only run was started and stopped to free cores
  for the probes; the P2 run, which includes every P1 change, is the record.
* **P3 and P4 were committed with stale pins, and P4 with three first
  merges that cost more than the code they merged.** P3 was checked by its
  probes, the expect check and the test files I chose for it (`stdlib`,
  `native-csv-records`, `typed-mutarray-builder`, `native-escape`,
  `hir-specialize`, `hir-aot`), not by a full regression; the targeted run
  for P4 (every test file that names a touched program) found what that
  choice missed. P3's new `char_is?` and `quote_at?` changed analysis facts
  that five tests pin: the dormant instance set gains `char_is?<generic>`,
  `char_at` has fewer callers, its two NIR variants are emitted in the other
  order, the corpus guard accounting moves, and `region-csv-corpus-1`'s
  fixture no longer makes the `peek()` comparisons it measures (it now reads
  the frozen kickoff `csv.bot`; the live one allocates 14 Strings with or
  without the optimization, the kickoff one 97 without it and 14 with). P4's
  `emailish?`, `ht_find_insert` and `abi::bytes::replace` merges were
  respelled (section 9; section 15, finding 12), which also moved one HIR
  node id a contexts test pins. All of it is in aa4cb40 (the merges) and 47a328d (the pins),
  verified by the probes again. The full regression of 47a328d (and its
  native coverage run) then found five more pins P3 had moved, in files the
  targeted runs had not selected: `tests/struct-scalar-replacement.test`'s
  census of the four CSV programs counts multi-value calls, and `peek()`'s
  String-region companion calls, gone with its comparisons, were among them
  (no `structnew` or `structget` count moved), and
  `raw-internal-abi-refined-checks-demand-off` lists `char_at`'s two
  variants in the order that changed. Fixed in 991c666, whose full
  regression is the record (section 17). The lesson is the obvious one: a
  corpus edit is checked by the full suite, not by a selection of it.
* **The CSV scanners' error contract changed** (`IndexNotFound` for an index
  outside the String where `peek` raised `LowerUnderrun`): identical for every
  index the scan reaches, different for a negative one no caller passes,
  shown by the `differs` probes. Tests that hand-write handlers around a
  CSV driver (`native-escape.test`'s `csvHir`) handle the new error too.
* **`ai_text_clean` is slower on native** (+50-54% Strings, +20-54% time at
  100K characters), and the CSV programs are slower on the Tcl backends
  (interp +10-22%, compile +22-44%) while faster on native (section 14). The
  first is a runtime representation gap with no cheaper source spelling
  (finding 3); the second is a helper call and a conjunction the Tcl backends
  do not optimize. Neither was traded away: the refactor's law is observable
  behavior, and these are its measured costs.
* **The bench ran on two hosts.** Two container restarts moved the session
  between machines mid-bench; only same-host before/after pairs are compared
  (section 14).
* **The CLI backend-independence tests read a frozen fixture.** Six tests
  whose subject is real warning-bearing programs read
  `audit/refactor/kickoff-corpus/` (the stdlib corpus, `refined-strings` and
  `lex-strategy` at 6e3f9f7) instead of the live, now clean, corpus; the live
  corpus is the gate's. `oc-cli-backend-independent-corpus` named a sample
  that never existed (`examples/surface/06-csv-records.bot`; main.tcl failed
  identically on every backend, so it passed vacuously); it is dropped.
* **A stale pre-existing pin**: `native-escape.test`'s `escape-csv-2` checks
  `listnew` sites at csv.bot lines that held `[field, index]` list literals
  before STRUCTS.md (the scan results are structs now, so the check was
  already vacuous at kickoff); left as found, recorded here.
* **Branch.** AGENTS.md says to push finished work to `main`; this session was
  assigned a development branch and told not to push elsewhere without
  permission, so the work is pushed to that branch.
* **The scalar assembly audit corpus** (`audit/native-scalar-asm/`) is derived
  from the corpus; it was regenerated at the final tree: 178 functions and
  72,887 bytes of machine code, against 177 and 74,702 at kickoff. The four
  CSV programs are 449-480 bytes smaller each (their scanners read
  characters instead of `peek`ing one-character Strings), `ai_text_clean` 94
  bytes larger (`clean_char` decodes its character, finding 3), `hashtable`
  40 smaller, `refined-checks` one function (`char_is?`) and 1 byte more;
  the other six programs are byte-identical.

## 19. Required questions

1. *Kickoff re-audit: all seven codes' fresh counts, at which commit?* At
   **6e3f9f7**: `METHOD-ELIGIBLE` 381 (373 in milestone 2's own corpus),
   `ONE-CHAR-STRING-LITERAL` 97, `SAME-RETURN-VALUE` 6, `FIXED-ARITY-LIST-RETURN`
   6, `SAME-FAILURE` 1, `PROVES-NAMING` 0, `MANY-BOOLEAN-ARGUMENTS` 0 -- **491**
   (section 1; `audit/refactor/kickoff/`). The per-milestone ledgers (365, 97,
   4, 8, 1, 0, 0) are superseded, each movement explained.
2. *H1 verdict?* **Falsified.** The restructure exists and is shown
   (`audit/refactor/h1-attempt/`: warning-clean, contract unchanged, probes
   identical) but is a contortion -- it keeps the one-character String and
   only hides it from a literals-only check, adds an unstated invariant and
   reads worse (as written, with its table at program level, it also makes
   `clean_from` quadratic: 0 -> 60 MB of UTF-8 seeking on 10,000 characters, a
   cost of the table's placement; section 15, finding 11). The obstruction:
   character-to-text construction.
3. *H2 verdict?* Per finding (section 2): **confirmed for 6** (three needles
   and two inserted replacements of `string_replace`, and `string_reverse`'s
   `"a"`, each with its weakening argument), **falsified for 2** (the
   replacements of the absent-needle and empty-haystack cases, never
   inserted: respelled `"yz"`, subject and output intact).
4. *Every finding's closing mechanism?* `audit/refactor/closings.txt`, 491
   lines, one mechanism each: converted 411, marked 26, merged 7, annotated 5,
   manifested 42; no "deliberate" (section 11).
5. *Manifest: final content, and prediction-vs-outcome?* 54 programs (47
   compile standalone, 38 of them with no entry of their own; 2 rejected; 5
   failing standalone with named obstructions) and 42
   expected findings: 41 `ONE-CHAR-STRING-LITERAL` (char->text 24, classifier
   10, test-datum 6 (H2), index-proof 1) and `13-hygiene.bot`'s
   `FIXED-ARITY-LIST-RETURN` (core-ir-roundtrip) (section 12). Predicted 36 (8
   H2 + 3 H1 + 25 concat-shaped); outcome 42: H2 -2, concat-shaped -5 (the CSV
   quotes closed by restructure), consumption side +11 (classifier coupling and
   the index proof, which the prediction expected to convert), and the
   surface sample +1.
6. *Behavior identity: how proven per program class?* Expected outputs: all
   30 programs with an `# expect:` line, on four backends, at kickoff and after
   every phase (`expect.tcl`), plus `tests/stdlib.test`'s cases. Probes:
   285 probes over 9 programs and modules
   (`audit/refactor/tools/probes/`: ai_text_clean, the four CSV programs,
   hashtable, `web`, `linux::path`, `abi::bytes`), before and after on four
   backends, identical except four declared contract changes (the CSV
   scanners' negative-index error). The sweep law: 355 calls, each verified by
   the round-trip law, then all 68 units again.
7. *Markings: which, with reasons; any call site found using their sugar?*
   `bit_and`, `bit_or`, `bit_xor` (symmetric operands), `mutable_array::copy`
   (the receiver would be the destination), `mutable_array::create` (the
   receiver would be the length; new in the re-derived queue). One call site,
   in a test program the affine work added (`tests/mutable-array.test`
   `ma-ops`, `a.copy(1, b, 1, 2)`), now functional; none in the corpus.
8. *Lib repair: every module standalone-compiles and loads? The io.bot and
   affine-module outcomes?* All 14 load. 9 compile standalone; 5 do not, for
   two named obstructions with no today-repair: `list` and `mutable_array`
   (the affine work's module) call their own namespace's intrinsics, valid
   only without an import as a module and only with one as an entry program;
   `io`, `io::path`, `linux::io` end in a function that cannot be an entry
   program's value (context-requiring or trait-polymorphic), and a module has
   no other kind of last statement to give. `io.bot` is warning-clean except
   its two manifested newlines. 11 of 14 modules are warning-clean.
9. *Bench deltas?* Section 14, two rounds of same-host before/after pairs:
   `ai_text_clean` is slower on native (+20-54% time and +50-54% Strings at
   100K characters: one materialized String per character, finding 3); the
   CSV programs are faster on native (-14% to -24% at 10,000 rows,
   `csv_records`' parse -46% to -75%, allocations identical) and slower on
   the Tcl backends (interp +10-22%, compile +22-44%: an uninlined helper
   call and a conjunction); `hashtable`, `uri-steady`, `string_reverse`,
   `string_replace`, `matmul` and the `bench/*.bot` programs are unchanged
   within noise, which on this machine reaches -49%/+116% for unchanged code
   at microsecond scale.
10. *The quantified API case?* 24 findings in 7 functions need a character as
    text, in five shapes (section 8); 21 of them, in 6 functions, are appends
    -- the demand is an append of a UnicodeChar to a String more than
    `str::of_char`. 20 are in libraries; `io`'s 2 alone keep every portable I/O
    program from `-warnings error`. A further 10 need character classifiers.
11. *Gate: what does CI now assert, and what fails it?* That the corpus
    programs are the manifest's, each unit compiles or fails with its listed
    code, the observed warnings equal the manifest exactly (code, file, line,
    column, per unit including its modules), every entry is observed, and every
    unit without an entry compiles under `-warnings error`. It fails on a new
    warning, a closed-but-listed finding, a drifted location, an unlisted or
    vanished program, a changed compile outcome, and a strict-mode failure
    (`tests/warning-gate.test` plants each; section 13).
12. *Warning false positives found by the attempt?* None: every warning the
    attempt met stated a true fact, and no sound conversion was rejected.
    Two design questions are routed to the warning milestones: literal
    receivers of position-first helpers (`0.scan_while(...)`), and
    `ONE-CHAR-STRING-LITERAL` on text by role (`clean_char`'s `"-"`).
13. *Full regression?* At the final tree (991c666): interp 6813/6813;
    compile 6809 passed, the kickoff's 4 skipped, 0 failed; native coverage
    2718 native, 3966 independent, 69 passed-partial, 60 unsupported (the
    kickoff's 60, same groups), 0 failed. Kickoff: 6801/6801, 6797 + 4, and
    2713 / 3959 / 69 / 60 / 0. P3 and P4 went in with stale pins that a
    targeted run and then the 47a328d full run found (section 18).
14. *Design findings for the language?* Section 15: an append of a character
    to text; character classifiers; `str::char_at` on String regions and short
    strings (native); traversal plans for `char_at` scans; the index proof's
    linear forms and non-negative recursive indices; literal receivers; the
    context-blindness on text by role; compiling a library file as its module;
    `mutable_array::generate`'s shape; mixed spellings from the ambiguity rule;
    and a candidate warning for constant Strings scanned as character tables
    (finding 11: not to be built yet, with its rule, proof, prerequisites and
    the measurements behind that recommendation); and what an `and`/`or` costs the range
    analysis and native code that nested tests do not (finding 12), which
    made three of the first merges more expensive than the code they
    merged; why the character type stops short of the read (finding 13);
    `METHOD-ELIGIBLE`'s blindness to receiver types (finding 14); and where a
    warning consistently cannot be applied (finding 15).
    LANGUAGE-LIBRARY-DEFICIENCIES.md gathers the deficiencies among them.
