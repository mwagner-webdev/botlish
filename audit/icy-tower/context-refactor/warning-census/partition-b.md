# Warning candidate census, partition B: the Tcl tests' programs and the fuzzers'

Part of ICY-TOWER-CONTEXT-REFACTOR-CENSUS.md, section 11. Partition A
(`partition-a.*`) covers every program and library module outside
`tests/*.test`; this partition applies the same instrument,
`audit/icy-tower/context-refactor/tools/escape-candidates.tcl` (rules R1
carry, R2 raw, R3 view, R4 shape; buckets hit, context-but-ordinary,
no-context, designated-direct), to the Botlish programs the Tcl tests write
and compile, and to the programs six fuzzers generate.

| file | what |
|---|---|
| `census-b.tcl` | runs the partition end to end (the stages below, each tool in a process of its own) |
| `extract-tests.tcl` | runs a test file with the front end's entry points intercepted, writing every program (and its application modules and private library) a test compiles, with the test's own options and the outcome the test got |
| `extract-fuzz.tcl` | a fuzzer's generator run program after program (no backend), each program written with the outcome the fuzzer's model expects |
| `coverage-b.tcl` | per test file: the test bodies the extraction stopped early, and whether the programs they would have compiled were captured by another test anyway |
| `scan-b.tcl` | the instrument over the captured programs (as partition A's scan.tcl, one HIR per distinct program) |
| `classify-b.tcl` | the classification, written as rules, and the summaries below |
| `partition-b.tsv` | one row per site: sources, bucket, location, from, to, rules, what, classification, reason |
| `partition-b-units.tsv` | one row per distinct program (1,494): its set, the tests or fuzzer indices that compiled it, entry, target, the outcome its test or model expected, the scan's outcome, error code and message, sites |

Run: `tclsh9.0 audit/icy-tower/context-refactor/warning-census/census-b.tcl`
(about 8 minutes on a shared 4-core container; front end only, no native
backend, C compiler or SDL needed; `-keep 1` keeps the working directory).
Measured at commit 7c0f7344.

## 1. Result

* **1,494 distinct programs: 901 compiled, 593 rejected.** 592 of the
  rejections are the ones their test or the fuzzer's model expects (the
  test files are mostly rejection tests of the context, direct-module,
  pointer, layout and platform rules: TYPE 153, UNSUPPORTED-PLATFORM 43,
  FOREIGN-BORROW 31, MISSING-CONTEXT 18, DIRECT 17, ...); one is an
  extraction loss (c-pointer-borrowing.test's `cb-tcl-exposure-ends`:
  its module `cbtest` was written outside the captured directory, so the
  scan's compile is UNKNOWN-NAMESPACE).
* **9 sites: 0 hit, 7 no-context, 2 designated-direct, 0
  context-but-ordinary. All 9 LEGITIMATE, 0 SUSPICIOUS, 0 UNDECIDABLE.**
* **No program of the test suite or of the fuzzers has a hit.** No
  contextualized module of any of them hands a C pointer, a non-opaque
  pointer-holding struct or a native view or edit to another module.

## 2. Coverage

Test files (selected as census-b.tcl's header says: every test file where
contexts meet C pointers, native views or edits, extern C functions or
direct modules, plus the ten the brief names), with the number of tests,
of bodies the extraction stopped early (a body that runs a backend or
builds a C fixture: its programs up to that point are captured), and of
programs captured; distinct programs and the scan's outcome per set (a
test file and the fuzzer of the same name share a set; a program compiled
by several tests counts once, owned by the first set that captured it):

| set | tests | stopped | captures | distinct programs | compiled | rejected |
|---|---:|---:|---:|---:|---:|---:|
| contexts.test | 74 | 8 | 96 | 96 | 53 | 43 |
| context-traits.test + fuzzer | 39 | 2 | 78 + 30 | 101 | 42 | 59 |
| direct-modules.test + fuzzer | 56 | 1 | 83 + 30 | 90 | 39 | 51 |
| c-ffi.test + fuzzer | 118 | 32 | 189 + 30 | 187 | 162 | 25 |
| c-abi-types.test + fuzzer | 73 | 0 | 275 + 30 | 299 | 148 | 151 |
| native-view.test + fuzzer | 39 | 1 | 100 + 30 | 124 | 98 | 26 |
| native-edit.test + fuzzer | 55 | 9 | 168 + 30 | 187 | 124 | 63 |
| c-pointer-borrowing.test | 62 | 7 | 126 | 100 | 52 | 48 |
| windows-io.test (host; and @windows, its host-only tests' programs for windows-x86_64) | 27 | 16 | 51 + 53 | 38 + 6 | 14 + 6 | 24 + 0 |
| darwin-io.test (host; and @macos) | 28 | 15 | 60 + 63 | 45 + 11 | 15 + 11 | 30 + 0 |
| stdlib-namespaces.test | 74 | 2 | 189 | 155 | 90 | 65 |
| variadics.test | 58 | 2 | 46 | 46 | 38 | 8 |
| tests/platform/aot-facts.tcl | -- | -- | 9 | 9 | 9 | 0 |
| **total** | | | | **1,494** | **901** | **593** |

Stopped bodies (coverage-b.tcl): of the 95 bodies stopped early, 80 had
every program they compile captured (from another test, or before the
stop); 10 bodies' programs were not captured (contexts 3, c-ffi 3,
native-edit 1, windows-io 1, darwin-io 2), and 5 c-ffi bodies build their
program dynamically, so coverage cannot be judged from the text. Those 15
are the partition's known gap.

Fuzzers: 30 programs each, seed 1, of `audit/direct-modules/tools/fuzz.tcl`,
`audit/c-ffi/tools/fuzz.tcl`, `audit/c-abi-types/tools/fuzz.tcl`,
`audit/context-traits/tools/fuzz.tcl`, `audit/native-view/tools/fuzz.tcl`
and `audit/native-edit/tools/fuzz.tcl` (180 programs, multi-module ones
included: the direct-modules fuzzer generates applications of 1 to 4
modules with own and foreign contexts).

Nine repository programs a test compiled (examples/ffi/tcl, examples/ffi/
sha256, examples/linux, examples/io/hello-darwin) are partition A's and
not scanned again.

## 3. The sites

| bucket | location | from -> to | rules | what | classification |
|---|---|---|---|---|---|
| designated-direct | native-edit.test#ne-direct-modules main.bot:9:32 | entry -> std::nedemo::raw | R1,R2,R3 | call `std::nedemo::raw::open` | LEGITIMATE: the test's subject. `raw` is a designated `direct module` that makes write authority from a C pointer; the entry program is the airlock (its own context mediates the call). A raw layer's surface is raw by declaration |
| designated-direct | native-view.test#nv-direct-modules main.bot:9:31 | entry -> std::nvdemo::raw | R1,R2,R3 | call `std::nvdemo::raw::open` | LEGITIMATE: the same, for a view |
| no-context | native-edit.test#ne-direct-modules main.bot:9:5 | entry -> std::nedemo::writer | R3 | call `std::nedemo::writer::set_a` | LEGITIMATE: the test's subject. An ordinary module storing through an edit someone else made stays ordinary (NATIVE-LAYOUT-WRITES.md); its layout is pointer-free |
| no-context | native-view.test#nv-direct-modules main.bot:9:5 | entry -> std::nvdemo::reader | R3 | call `std::nvdemo::reader::a_of` | LEGITIMATE: the same, reading a view (NATIVE-LAYOUT-VIEWS.md) |
| no-context | stdlib/windows/io.bot:78:5, 82:5, 100:14 | std::windows::io -> std::windows | R1,R2 | call `std::windows::write_file` | LEGITIMATE: partition A's section 6, D (the borrowed standard handle passed back within one call to the thin, context-free Win32 layer) |
| no-context | stdlib/windows/io.bot:97:14 | std::windows::io -> std::windows | R1,R2 | call `std::windows::standard_handle` | LEGITIMATE: the same |
| no-context | windows-io.test#wi-c-declarations main.bot:19:5 (and 5 other tests' copies) | entry -> std::windows | R1,R2 | call `std::windows::standard_handle` | LEGITIMATE: a test calling the thin layer directly, as an application of it may |

The four stdlib/windows/io.bot sites are the same sites partition A
reports (the module compiled for windows-x86_64 by the tests).

## 4. What this partition says about the warning

* The test suite and the fuzzers exercise every rule the instrument looks
  at -- contexts installed and required across modules, retaining C calls
  mediated and not, designated direct modules, views and edits made in one
  module and used in another -- and produce **no hit**. The rule's hit
  bucket is empty outside the two programs written to exhibit the
  problem (partition A: the baseline Icy Tower, reproducer g1).
* The R3 sites here are views and edits of **pointer-free** layouts passed
  to ordinary modules. The proposed rule fires only at a contextualized
  module's boundary (the hit bucket), so they are out of its scope; were
  the rule widened to every module, R3 would need the layout to hold a
  pointer field to be worth reporting (a pointer-free view leaks no
  authority beyond the bytes it reads).
* Designated direct modules are raw layers by declaration; the rule must
  keep excluding them, as it does.
