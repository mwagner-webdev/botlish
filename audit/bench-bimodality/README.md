# audit/bench-bimodality

Material of [BENCHMARK-BIMODALITY.md](../../docs/BENCHMARK-BIMODALITY.md): why
`bench/bench.tcl`'s native column sits either at Go or at Python. Audit
only: nothing here is loaded by the compiler, the tests or CI.

## tools/

* `measure.tcl ?-runs N? FILE.bot ...` -- best-of-N native (JIT) time and
  value of each program, as bench.tcl's native column measures it.
* `executable.tcl FILE.bot OUT` -- the program's standalone executable, or
  its NIR when it is not AOT-ready (used by profile.sh).
* `profile.sh FILE.bot N1 N2` -- callgrind of N1 and N2 timed runs (the
  executable's driver protocol, or `botlish-native bench`), their difference
  per run: instructions by category and the top functions. Needs valgrind.
* `stage.tcl` -- shared: a program with a `# bench-modules:` header is
  compiled from a private directory holding those modules, then the other
  `.bot` files of the program's own directory (which replace a listed module
  of the same name), as bench.tcl stages its experimental programs.

All of them run from the repository root with `tclsh9.0` (Tcl 9) and a
built native backend (`cargo build --release --manifest-path
native/Cargo.toml`), under `LANG=C.utf8 LC_ALL=C.utf8`.

## variants/

Each directory is one benchmark with one change, the value unchanged
(each file's header says what changed):

| variant | of | the change |
|---|---|---|
| `lex-strategy-typed` | bench/lex-strategy.bot | `lenient_ident_char?(c: str) -> bool`: no generic instance, AOT-ready |
| `lex-strategy-indexed` | bench/lex-strategy.bot | typed, and the tokens walked by index instead of a `chars_of` List |
| `source-checks-typed` | bench/source-checks.bot | declared parameter types on its five functions |
| `refined-checks-ascii` | bench/refined-checks.bot | an ASCII email of the same length |
| `uri-steady-append-char` | bench/uri-steady.bot | the escaping with `char_at`, `append_char`, character literals |
| `json-parse-ascii` | bench/experimental/json-parse.bot | the document's one literal `é` made `e` |
| `game-server-continue` | bench/experimental/game-server.bot | `continue` at the end of `simdrv::release_due`'s loop body (`simdrv.bot`) |
| `lex-strategy-chars` | bench/lex-strategy.bot | characters as `UnicodeChar`s |
| `lex-strategy-chars-indexed` | lex-strategy-indexed | characters as `UnicodeChar`s |
| `source-checks-chars` | bench/source-checks.bot | the leading character as a `UnicodeChar` |
| `refined-checks-local` | bench/refined-checks.bot | `emailish?` (its String version) copied into the program: shows what the move itself costs |
| `refined-checks-chars` | refined-checks-local | its characters as `UnicodeChar`s |

```bash
export LANG=C.utf8 LC_ALL=C.utf8
tclsh9.0 audit/bench-bimodality/tools/measure.tcl -runs 30 \
    bench/lex-strategy.bot audit/bench-bimodality/variants/lex-strategy-typed/lex-strategy.bot \
    audit/bench-bimodality/variants/lex-strategy-indexed/lex-strategy.bot \
    bench/source-checks.bot audit/bench-bimodality/variants/source-checks-typed/source-checks.bot \
    bench/refined-checks.bot audit/bench-bimodality/variants/refined-checks-ascii/refined-checks.bot \
    bench/uri-steady.bot audit/bench-bimodality/variants/uri-steady-append-char/uri-steady.bot \
    bench/experimental/json-parse.bot audit/bench-bimodality/variants/json-parse-ascii/json-parse.bot \
    bench/experimental/game-server.bot audit/bench-bimodality/variants/game-server-continue/game-server.bot
```

## prototype/

`char-classifiers.patch`: `std::char::is_tcl_alpha(c: UnicodeChar)` and
`std::char::is_tcl_alnum(c: UnicodeChar)` on every backend, and
`std::web::emailish?` reading `UnicodeChar`s: the measurement prototype the
report's UnicodeChar numbers were taken with, against the tree of
BENCHMARK-BIMODALITY.md. Both have since landed
(UNICODECHAR-CLASSIFIERS.md: the same natives, with an inline ASCII path), so
the `-chars` variants run on this tree as they are, and
bench/refined-checks.bot measures the ported `emailish?`. The patch is kept
as the record of what was measured; it no longer applies.

## The IR dumps

The report's HIR, NIR, CLIF and machine-code excerpts come from the
ordinary inspection entry points; for a program `P.bot` (an experimental one
staged as stage.tcl does):

```bash
tclsh9.0 main.tcl -warnings off -hir P.bot        # hir::format
tclsh9.0 main.tcl -warnings off -emit-nir P.bot   # native::nir
tclsh9.0 main.tcl -warnings off -emit-clif P.bot  # native::clif
tclsh9.0 main.tcl -warnings off -emit-native-executable P.bot && objdump -d -M intel P
```
