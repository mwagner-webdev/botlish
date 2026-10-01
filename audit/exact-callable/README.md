# Exact callable identity / closed-caller theorem: artifacts

Raw evidence for [EXACT-CALLABLE-CLOSED-CALLER.md](../../EXACT-CALLABLE-CLOSED-CALLER.md).
Observation only: nothing here is a build product. "Before" is the parent fence
`64af2fe` (the tree before this milestone, `native/src` identical); "after" is
the milestone's tree. Every tool runs unchanged on both trees (it uses only
entry points both have), so one script measures both columns.

## Contents

| path | contents |
|---|---|
| `out/census-before.txt`, `out/census-after.txt` | per program: semantic instances, used and emitted codegen instances, generic / exact-callable-keyed / kind-callable-keyed instances, `callvalue` sites, closure allocation sites, machine-code bytes; then per source function instance counts, every emitted function's bytes and every `callvalue` site (`tools/census.tcl`) |
| `out/nir-identity.txt` | which corpus programs' NIR changed (the numerical and aggregate controls are byte-identical) |
| `out/nir-diff-*.txt` | the NIR diffs of the higher-order programs and of `uri-steady` |
| `out/refined-checks-{before,after}.nir` | the whole NIR of the benchmark the milestone repairs |
| `out/codesize.md` | the scalar-assembly corpus (`native/generate-scalar-audit.tcl`), bytes per program and per changed function (`tools/codesize.py`) |
| `out/opcounts-*.txt` | per NIR function: tagged vs raw Int ops, guards and call forms before/after (`tools/opcounts.py`) |
| `out/ranges-refined-checks-{before,after}.txt` | entry / read Ranges of the scanner bindings, with range openness (`tools/ranges.tcl`) |
| `out/closedness-after.txt` | `hir::specialize::closedAudit` for five programs: closed yes/no, proof branch, callers, exact targets, range openness; the last line counts closed-and-range-open disagreements (none) (`tools/closedness.tcl`) |
| `out/budget.txt` | the specialization-budget probe: N exact targets into one HOF, exactLimit 0/1/2/4/8 (`tools/budget.tcl`) |
| `out/callvalue-coverage-diff.txt` | which tests lost / gained / emit fewer `callvalue` sites between the previous tree and this one (`tools/callvalue-coverage*.{sh,py}`) |
| `out/profiles/<program>-{before,after}/` | callgrind, steady state, per run: `census.txt` (per-function self/inclusive Ir, per-site costs), `mix.txt`, `profile.txt` |
| `out/ir-series.txt` | the total Ir/run of every profile (one runtime binary) |
| `out/compiletime-{before,after}.txt` | compile-time phases, median of 5 (`tools/compiletime.tcl`) |
| `probes/*.bot` | the focused programs (run on every backend by `tests/exact-callable-key.test` where they are also tests; `expect:` header gives the value) |

## Tools

| tool | what |
|---|---|
| `tools/run-all.sh BASE SCRATCH` | reproduces everything under `out/` except `callvalue-coverage-diff.txt` (see below) |
| `tools/census.tcl` | the instance / `callvalue` / bytes census above |
| `tools/compiletime.tcl` | prepare / specialize / range / lower / Cranelift / total, median of N |
| `tools/ranges.tcl` | Ranges of named bindings per used instance |
| `tools/closedness.tcl` | the authoritative closedness audit |
| `tools/codesize.py`, `tools/opcounts.py` | machine-code and NIR op comparisons |
| `tools/budget.tcl` | the budget probe |
| `tools/callvalue-coverage.sh TREE LOG` | the whole suite on a copy of TREE with every `callvalue` emission logged by test |
| `tools/callvalue-coverage-diff.py BEFORE AFTER` | compares two such logs |

Reused unchanged: `audit/machine-code-proof-loss/tools/{emit-nir,facts}.tcl`,
`audit/post-r2a-dynamic-census/tools/{build-audit-native,profile-nir}.sh`.

## Reproduce

```sh
export LANG=C.utf8 LC_ALL=C.utf8
cargo build --release --manifest-path native/Cargo.toml
git worktree add -f /tmp/base 64af2fe && ln -s "$PWD/native/target" /tmp/base/native/target
bash audit/exact-callable/tools/run-all.sh /tmp/base /tmp/exact-callable-scratch
```

The `callvalue` coverage logs are not part of `run-all.sh` (the suite takes ten
minutes per tree):

```sh
bash audit/exact-callable/tools/callvalue-coverage.sh /tmp/base /tmp/cv-before.log
bash audit/exact-callable/tools/callvalue-coverage.sh "$PWD" /tmp/cv-after.log
python3 audit/exact-callable/tools/callvalue-coverage-diff.py /tmp/cv-before.log /tmp/cv-after.log
```

Callgrind counts repeat to within about 250 Ir per run on one host; machine
code, NIR and facts are deterministic. The host rustc here (1.97.0) differs from
the investigation's (1.98.1); the "before" `refined-checks` figure (8,190,753)
is within 0.07% of the investigation's 8,196,144.
