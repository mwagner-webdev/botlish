# M7.a instance-selection / theorem audit tooling

Non-production observation tools and their outputs for
[M7A-INSTANCE-SELECTION-THEOREM-AUDIT.md](../../M7A-INSTANCE-SELECTION-THEOREM-AUDIT.md).
Nothing here is a test or a compiler contract. Every output is "what the
current compiler does", recorded so M7.b can decide what to pin.

| tool | output |
|---|---|
| `tools/lib.tcl` | shared helpers (instance tables, ConditionOutcome attribution, guard attribution, NIR counts, census) |
| `tools/keytype.tcl` | `artifacts/keytype.txt`: KeyType preservation/erasure per static type category |
| `tools/scenarios.tcl` | `artifacts/scenarios.txt`: 38 synthetic scenarios S01–S15 |
| `tools/corpus.tcl PROGRAM OUTDIR` | `artifacts/uri-steady/`, `artifacts/refined-checks/`: frozen-corpus census |
| `tools/determinism.tcl` | `artifacts/determinism.txt` |
| `tools/counterfactual.tcl VARIANT PROGRAM OUTDIR` | `artifacts/cf-*/`: what-if measurements; patches one `hir::specialize` proc **inside its own process only** |

Run from the repository root with `LANG=C.utf8 LC_ALL=C.utf8`, `tclsh9.0`,
and the release native backend built (`cargo build --release
--manifest-path native/Cargo.toml`).
