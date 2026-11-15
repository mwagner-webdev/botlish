# audit/rust-archive-link

The evidence of HTTP-MACOS-RUST-ARCHIVE-LINK-FEASIBILITY-MILESTONE-1.md: a
Rust native unit localized into a static archive, packaged for Linux
x86-64 and macOS arm64, and linked beside the Botlish runtime's own Rust.

| Path | What |
|---|---|
| `unit/` | the Rust fixture, crate `botlish_rustlink` (std only): a C ABI, a counting global allocator, unwinding caught at every export, threads, a callback, a lent block, and a notification object -- `notify-weakdef.c` (the default: a weak definition of `botlish_event_post2`) or `packages/http/native/src/notify.c` (http's weak reference) |
| `package/rustlink.bot` | the unit's package (declared as `packages/http/http.bot` declares its unit) |
| `provider/` | a C provider of `botlish_event_post2` and its own package, `rustlink_provider` |
| `consumer/` | the consumer programs (one source for every target) and their expected values |
| `tools/rustlink.tcl` | the harness: build, localize, assemble an application, link, run |
| `tools/experiments.tcl OUT` | the matrix: raw and localized units, both notification objects, two rustc versions, both programs, both linkers |
| `tools/release-unit.tcl OUT` | the release archives (pinned rustc 1.97.0, a fresh target directory) and their record |
| `tools/pack.sh OUT T=DIR...` | both packages, multi-target, each packed twice and compared |
| `tools/http-unit.tcl OUT` | the real http unit localized and linked by a probe (macOS: from a copy with one portability change) |
| `tools/mutants.txt`, `tools/mutate.tcl` | the mutants and their harness |
| `cleanroom/consumer.sh` | the consumer on a machine with the packaged compiler, the artifacts and nothing else |
| `results/` | recorded outputs (local runs; the CI runs are named in the report) |

The tests are `tests/rust-archive-link.test` and `tests/package-native.test`'s
`pn-index-*`; `.github/workflows/rust-archive-link.yml` runs everything on
both hosts. AGENTS.md's "Rust native units" says what to run after a change.
