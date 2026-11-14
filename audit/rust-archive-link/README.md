# audit/rust-archive-link

The evidence of HTTP-MACOS-RUST-ARCHIVE-LINK-FEASIBILITY-MILESTONE-1.md
(docs/): a Rust native unit, localized, packaged for Linux x86-64 and
macOS AArch64 in one `.botpkg`, linked by an independently compiled Botlish
executable beside the Botlish runtime (Rust too).

| Path | What it is |
|---|---|
| `fixture/` | the Rust link fixture, crate `botlish_rlf`: no dependency; the http unit's linkage shape (a staticlib with a C shim from its build script, i64 C functions, opaque state behind handles, a foreign-thread notification through an optional provider, panics caught at the boundary) and a counting `#[global_allocator]` (feature `counting`, default) |
| `provider/rlf_provider.c` | the optional provider's strong `rlfp_post` (the event loop driver's `botlish_event_post2`, for the http unit) |
| `packages/rlf`, `packages/rlf_provider` | the two packages' sources (module, descriptor); `tools/rlf.tcl stage` adds each target's archive and packs them |
| `consumer/` | the clean consumer's programs: `basic.bot` (no provider), `provided.bot` (with it), `rlfchecks.bot` (their shared checks) |
| `tools/rlf.tcl` | the fixture's author tool and acceptance: `unit`, `provider`, `stage`, `consumer`, `controls`, `inspect`, `app`, `control` |
| `tools/http-macos.tcl`, `http/` | the http unit on macOS as a link-feasibility probe: the pinned BoringSSL, the unit from a copy with `http/macos.patch`, localized, linked into `http/probe*.bot` |
| `tools/mutants.txt`, `tools/mutate.tcl` | the milestone's mutants and their harness |

The localization itself is `tools/rust-unit.tcl` (ELF and Mach-O), which
`tools/http-package.tcl` uses too. CI: `.github/workflows/rust-archive-link.yml`.

Run on a Linux host (cargo, cc, tclsh9.0, the native backend built):

    tclsh9.0 audit/rust-archive-link/tools/rlf.tcl controls -compiler "tclsh9.0 $PWD/main.tcl" -work /tmp/rlf-controls
    tclsh9.0 tests/rust-archive-link.test
