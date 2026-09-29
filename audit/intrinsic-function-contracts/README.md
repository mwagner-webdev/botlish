# Intrinsic function contract inference -- audit data

Evidence for `INTRINSIC-FUNCTION-CONTRACT-INFERENCE.md`. Every tool is
observation-only and runs against whatever tree it is started in, so the
same script measured the parent commit (`67380f4`, "before") and this
milestone's tree ("after"). Tcl 9.0.1, `LANG=C.utf8 LC_ALL=C.utf8`, native
backend built (`cargo build --release --manifest-path native/Cargo.toml`).

| tool | output | what |
|---|---|---|
| `tools/census.tcl OUTDIR` | `out/census.txt`, `out/params.txt` | corpus-wide body-inference census: every parameter of every function of `bench/*.bot`, `examples/stdlib/*.bot`, `examples/surface/*.bot` and the `lib/*.bot` modules they load (each definition once), with its inferred contract and provenance (spec item 58) |
| `tools/callsites.tcl OUTFILE` | `out/callsites-{before,after}.txt` | every compiled `callvalue` site of the canonical benchmarks (relifted pipeline, as `bench/bench.tcl` compiles), callee type in the source HIR and in the used instance, classified Fn / bare block/native / any (items 49-50, 87) |
| `tools/keyfunctions.tcl OUTFILE` | `out/keyfunctions-{before,after}.txt` | intrinsic signature, exact Block type and structural supertype, and every used instance (label, AOT status and blockers, seeded parameters, result) of `scan_while`, `local_char?`, `label_char?`, ... (items 39, 52-55) |
| `tools/nir.tcl OUTDIR` | (scratch) | instance labels + full NIR of every canonical benchmark, for before/after diffs (items 62, 76) |
| `tools/compiletime.tcl N` | `out/compiletime-{before,after}.txt` | median-of-N front-end compile time (`surface::readProgramFile`) of every canonical benchmark and stdlib program (item 61) |
| `tools/validity.tcl` | `out/validity-implemented.txt`, `out/variant-*.txt` | which canonical programs a tree rejects at compile time |

`out/variant-all-trusted.patch` and `out/variant-checked-structural.patch`
are the two rejected design variants the report measures, as patches
against this milestone's tree; `out/variant-*.txt` are `validity.tcl`'s
output in a scratch copy with each applied:

- **all-trusted** (every inferred requirement treated like a declaration:
  seeded, strictly proven at every call including `any` arguments,
  structural, precondition-bearing): 10 of 31 canonical programs rejected,
  4 of the 8 canonical benchmarks among them.
- **checked-structural** (checked requirements also exposed in exact Block
  structural `Fn` arguments): exactly one rejection,
  `bench/lex-strategy.bot:57:20` `classifier(c)`.

Reproduce (from a tree root):

```sh
export LANG=C.utf8 LC_ALL=C.utf8
tclsh9.0 audit/intrinsic-function-contracts/tools/census.tcl audit/intrinsic-function-contracts/out
tclsh9.0 audit/intrinsic-function-contracts/tools/callsites.tcl audit/intrinsic-function-contracts/out/callsites-after.txt
tclsh9.0 audit/intrinsic-function-contracts/tools/keyfunctions.tcl audit/intrinsic-function-contracts/out/keyfunctions-after.txt
tclsh9.0 audit/intrinsic-function-contracts/tools/compiletime.tcl 7
tclsh9.0 audit/intrinsic-function-contracts/tools/validity.tcl
```
