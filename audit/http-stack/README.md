# audit/http-stack

Exploratory code of HTTP-STACK-INTEGRATION-CENSUS.md: Hyper (HTTP/1.1,
HTTP/2), quiche (QUIC, HTTP/3) and one pinned BoringSSL under Botlish's
production event loop (`std::event_loop` with the Linux driver package),
with no Tokio runtime. Probes and evidence, not a production HTTP stack:
nothing here is loaded by the compiler, the runtime or the standard library.

## Layout

| path | what |
|---|---|
| `Cargo.toml`, `Cargo.lock` | the Rust workspace (exact versions pinned by the lock) |
| `bridge/` | `hs_bridge`: the bounded executor, Botlish-clock timers, the readiness registry, the handle table, notices, the FFI guard, the foreign-wake shim (`src/notify.c`) |
| `bridge/botlish/` | the bridge's Botlish half: `hs.bot` (executor step, timekeeper, notices, kick), `hsnet.bot` (the executor on the Linux driver: watches), `hsmem.bot` (on the deterministic driver), `hsfx.bot` (executor fixtures), `rogue.bot` / `reject_driver.bot` (a control) |
| `hyper/` | `hs_hyper`: Hyper's runtime traits over the bridge, fd and in-memory streams, exchanges and chunked bodies; `botlish/`: `hsh.bot` and the probes `h1.bot`, `h2.bot`, `stall.bot` |
| `tls/` | `hs_tls`: nonblocking BoringSSL through `boring`, an in-memory test PKI, ALPN; `botlish/`: `hstls.bot`, the probe `tls.bot` |
| `quiche/` | `hs_quiche`: core quiche endpoints over Botlish-watched UDP; `botlish/`: `hsq.bot`, the probes `h3.bot`, `h3time.bot` |
| `boringssl/` | the provider pin (`PIN`), a second pin for the controls (`PIN.repo-c-ffi`), the crypto airlock's C half (`hscrypto.c`); `botlish/`: `bssl.bot` (the provider in the link plan), `crypto.bot`, `cryptoonly.bot`, `bssl_other.bot` / `reject_provider.bot` (a control) |
| `integration/` | `hs_native`: the one Rust linking unit (staticlib, the `hs_*` C ABI; features `hyper tls quiche`, `count-alloc` for measurements, `tokio-control` for the Tokio control); `botlish/`: `probe.bot` and the probes `sched.bot`, `mem.bot`, `lifetimes.bot`, `combined.bot`, `measure.bot`, `tokioctl.bot` |
| `tools/` | `provider.tcl` (fetch, check, build the provider), `build.tcl` (units, applications, runs), `linkcheck.tcl` (the single-link proof), `check.tcl` (every probe and control, with claims) |
| `repro/` | `method-at-list.bot`: an incidental compiler finding (the report's B11) |

## Prerequisites

Linux x86-64; `tclsh9.0` (AGENTS.md, "Installing Tcl 9"); the native backend
built (`cargo build --release --manifest-path native/Cargo.toml`, rustc
1.95+); `cmake`, `ninja`, `cc`, `c++`, `ar`, `ld`, `objcopy`, `nm`,
`readelf`; network access to crates.io and boringssl.googlesource.com for
the first build.

## Reproducing

    export LANG=C.utf8 LC_ALL=C.utf8
    tclsh9.0 audit/http-stack/tools/check.tcl            # everything (about 50 min)
    tclsh9.0 audit/http-stack/tools/check.tcl -parts probes -build 0

or step by step:

    tclsh9.0 audit/http-stack/tools/provider.tcl build   # BoringSSL 0.20261020.0
    tclsh9.0 audit/http-stack/tools/build.tcl unit full  # the Rust unit, link-only BoringSSL
    tclsh9.0 audit/http-stack/tools/build.tcl app probes full
    tclsh9.0 audit/http-stack/tools/build.tcl run probes h2
    tclsh9.0 audit/http-stack/tools/build.tcl run probes sched HS_CENSUS_FAULT 2
    tclsh9.0 audit/http-stack/tools/linkcheck.tcl probes combined -linker system

Everything is built under Botlish's cache directory (`~/.cache/botlish/
http-stack/`: sources, the provider, Cargo targets, units, applications,
`check.txt`), never in the repository.

## Fault injection (negative controls only)

`HS_CENSUS_FAULT` (read when the bridge opens) breaks the bridge on purpose:
1 a foreign wake never posts, 2 a run ignores its budget, 8 an application
call never kicks the executor, 16 quiche's timeouts are never armed, 32 a
QUIC server drops the first datagram, 64 no timekeeper, 128 a release does
not cancel tasks, 256 handles are looked up by index alone, 512 the receive
pump ignores the consumer. `HS_QUICHE_DEBUG` prints quiche timer firings.
