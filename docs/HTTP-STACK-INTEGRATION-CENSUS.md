# HTTP-STACK-INTEGRATION-CENSUS.md

Botlish-managed HTTP/1.1, HTTP/2, HTTP/3 and one shared BoringSSL: an
architectural census with executable integration probes.

> Botlish owns the event loop, scheduling, resource authority and
> application-facing contracts. Rust libraries implement HTTP and QUIC
> protocol machinery. One pinned BoringSSL implementation supplies
> cryptography and TLS. Native libraries participate in the Botlish event
> loop; they do not silently replace it.

This is a census, not a production milestone. Every claim marked
**demonstrated** is checked by `audit/http-stack/tools/check.tcl` against a
real program's own report (section 16 has the run); everything else is a
**projection** and says so. No compiler, runtime, standard-library or
event-loop file changed: the probes live in `audit/http-stack/` and build
under Botlish's cache.

## Contents

1. Executive result
2. Upstream dependency census
3. Hyper integration
4. quiche integration
5. BoringSSL provider
6. Single-link proof
7. TLS
8. Rust/C FFI
9. Botlish airlocks
10. Streaming
11. Resource lifetimes
12. Scheduling
13. Performance
14. Packaging and portability
15. Tokio interoperability
16. Testing
17. Blockers and deficiencies
18. Recommendation

## 1. Executive result

**The architecture is viable with the selected libraries, and the existing
event loop needs no scheduling redesign.** Demonstrated on Linux x86-64
with the production `std::event_loop` and its Linux driver package:

| acceptance criterion | result | evidence (section) |
|---|---|---|
| 1. Hyper HTTP/1.1 without Tokio | met | `h1.bot`, `mem.bot` (3) |
| 2. Hyper HTTP/2, its spawned futures and timers | met | `h2.bot` (two streams, one slow), `stall.bot` (keep-alive timers), `mem.bot` (virtual time) (3) |
| 3. BoringSSL TLS over Botlish I/O, real authentication | met | `tls.bot`: 8 of 8 scenarios, h2 and http/1.1 by ALPN (7) |
| 4. quiche HTTP/3 under Botlish readiness, timeouts, pacing | met | `h3.bot`, `h3time.bot` (loss recovery, pacing, idle timeout) (4) |
| 5. one BoringSSL for crypto, TLS and quiche, one final link | met | `combined.bot` + `linkcheck.tcl` with both Botlish linkers (6) |
| 6. no synchronous reentry; lost wakes tested | met | `sched.bot` and its controls; FFI guard (8, 12) |
| 7. bounded protocol work, unrelated coroutines progress | met for polling; one expensive synchronous call is not bounded (B12) | `sched.bot` (20,000 self-wakes beside a yielding task) and its unbounded control; `measure.bot` (12, 13) |
| 8. backpressure reaches native protocol state | met | `h2.bot`, `h3.bot`, `stall.bot` and its unbounded control (10) |
| 9. explicit FFI ownership, no cross-suspension borrows | met | the handle/notice design, `lifetimes.bot` and its stale-completion control (8, 11) |
| 10. airlocks express the authority boundaries | met, with one language gap | `crypto.bot`/`cryptoonly.bot`, `hstls.bot`, `hsnet.bot` (9, 17) |
| 11. no fundamental scheduling redesign | met | nothing in `std::event_loop` or the driver changed (12) |
| 12. remaining deficiencies identified | done | section 17 |

What it took, in one paragraph: a Rust *bridge* (a bounded, thread-local
executor whose `run(budget)` a Botlish task calls; timers in the Botlish
clock; a readiness registry whose watches Botlish arms; generation-checked
handles; notices Botlish delivers), two Botlish tasks driving it (an
*executor* that yields while Rust work is ready and waits on one source
when none is, and a *timekeeper* that waits on a Botlish timer registration
at the earliest Rust deadline), and one Rust linking unit whose only global
symbols are its C functions and which *references* BoringSSL without
embedding it, so that the final link takes the one provider's archives.

What the census found that the plan did not anticipate (each with a
reproduction in section 17):

* **Cargo's default arrangement embeds BoringSSL twice.** boring-sys and
  quiche's build script both declare `static=crypto`/`static=ssl`, so a
  Rust static library bundles every BoringSSL object twice (1,453 members
  against 639 when BoringSSL is linked rather than bundled); ordinary
  archive linking hides it, `ld -r --whole-archive` fails on it.
* **A different BoringSSL revision links and runs silently.** Bundled into
  the Rust unit beside the provider, the repository's other pin
  (0.20260929.0, API version 43, the C FFI acceptance's) produced a working
  program whose Rust code was compiled against API 43 headers and runs the
  API 44 provider's code (archive order picked the provider's members). No
  linker error; only the census's identity check saw it. Which of two
  bundled copies a link uses is decided by archive order alone.
- **The repository already has two BoringSSL conventions**: the C FFI
  acceptance and binding generator pin 0.20260929.0 built with
  `BORINGSSL_PREFIX=botlish_bssl`; boring 5.4 needs 0.20261020.0 (or close)
  *unprefixed* (boring-sys's bindgen names the unprefixed symbols). One
  provider means converging them.
* **Four integration contracts the bridge must state explicitly**, each
  found as a stall or crash in the first version of a probe: an application
  coroutine's call into Rust must kick the parked executor; a handle several
  coroutines wait on needs a registration per waiter (a Botlish event wakes
  one waiter); a localized Rust unit must rename its one COMDAT group
  (`DW.ref.rust_eh_personality`) or the linker discards it next to the
  Botlish runtime's; converting a library's "in D from now" needs a fresh
  clock reading, and must not chase a zero timeout.
* **A language gap**: a context-trait implementation takes exactly one
  context (its own), so a driver-neutral library cannot be written once over
  a context trait whose Linux implementation needs `Loop` and
  `event_loop_linux::Native`; the probes write the executor loop per driver.
* **quiche 0.30's default congestion control never paces**
  (`get_packet_send_time` returns `now` for CUBIC/Reno); only the BBR2
  "gcongestion" recovery produces `SendInfo::at` in the future.

## 2. Upstream dependency census

Resolved on 2026-10-30 from crates.io and boringssl.googlesource.com; the
workspace's `Cargo.lock` (89 packages) pins every crate.

| component | version | source revision | features used | notes |
|---|---|---|---|---|
| hyper | 1.12.0 (latest) | crates.io | `client server http1 http2`, default features off | depends on `tokio` (`sync`, unconditionally) |
| h2 | 0.4.20 | crates.io | default | depends on `tokio` (`io-util`) and `tokio-util` (`codec io`) |
| tokio | 1.54.1 | crates.io | resolved: `bytes default io-util sync` | **no `rt`, `time`, `net`**: types and traits only, no runtime |
| http / http-body / http-body-util / bytes | 1.5.0 / 1.1.0 / 0.1.5 / 1.12.1 | crates.io | | |
| quiche | 0.30.0 (latest) | cloudflare/quiche `be47c5011215` | `boringssl-boring-crate` (its default, and its only TLS backend) | no vendored BoringSSL any more; declares its own `extern "C"` BoringSSL functions (the QUIC API) and its own `rustc-link-lib=static=ssl/crypto` |
| boring / boring-sys | 5.4.0 (latest) | cloudflare/boring `309bf35b9eb9` | none (no fips, rpk, pq-experimental) | `boring-sys` has `links = "boringssl"`; build script: bindgen 0.72.1, cmake 0.1.58 |
| BoringSSL | tag `0.20261020.0` | commit `d3bf4795ad5b79d646cddf2fec687da5b9b502db`, tag object `6b482f540b02a913d3dbec6fd5c4d598d523cf48` | Release, position-independent, unprefixed, **unpatched** | the revision boring-sys 5.4.0 vendors (its `deps/boringssl` submodule at `309bf35b`) |
| not used | hyper-util 0.1.21, tokio-quiche 0.20.1, tokio-boring 5.3.0 | | | convenience layers over a Tokio runtime |

**Toolchain of the run**: rustc and cargo 1.97.0 (rustc links with
rust-lld by default on x86_64-unknown-linux-gnu), gcc/g++ 13.3.0, GNU ld
2.42, cmake 3.28.3, ninja 1.11.1, Tcl 9.0.1; a 4-core container (Intel Xeon
@ 2.10 GHz, Linux 6.18).

**What boring-sys 5.4.0 does with BoringSSL** (read from its build script,
then exercised):

* Without configuration it builds its vendored source *and always applies
  `boring-pq.patch`* (draft Kyber code points, `SSL_use_second_keyshare`),
  plus feature patches. The patched symbols are used by neither boring
  5.4.0's Rust code nor quiche 0.30.0 (grepped, then proven by building
  and running against unpatched upstream).
* `BORING_BSSL_PATH` takes a prebuilt tree (`lib/libcrypto.a`,
  `lib/libssl.a`, `include/`) and skips the patches with a warning;
  `BORING_BSSL_INCLUDE_PATH` overrides the headers; `BORING_BSSL_SOURCE_PATH`
  builds another source tree (patches then need `BORING_BSSL_ASSUME_PATCHED`
  for some features); `BORING_BSSL_INSTALL_DIR` exports what it built.
* It always emits `rustc-link-lib=static=crypto` and `static=ssl` (bundled
  into its rlib, hence into any static library) and `rustc-link-lib=stdc++`
  (libssl.a is C++: `__cxa_*`, `__gxx_personality_v0`).
* It has no `BORINGSSL_PREFIX` support: its bindgen sees the macro-renamed
  declarations of a prefixed build, so `boring` cannot compile against one.

A documented environment variable therefore does *not* by itself guarantee
reuse of one provider: `BORING_BSSL_PATH` reuses the *archives* -- by
copying them into the static library. Section 6 shows how the census made
the Rust unit reference the provider instead.

**Upstream alternative noted, not used**: BoringSSL ships its own Rust
crates in `rust/` (`bssl-sys`, `bssl-crypto`), versioned with the C library
itself. A production design could bind through them for the crypto-only
consumer and keep `boring` only where quiche requires it.

## 3. Hyper integration

**What Hyper 1.x needs from a runtime** (`hyper::rt`, read from 1.12.0 and
implemented in `hyper/src/rt.rs`, `iox.rs`):

* `rt::Read`/`rt::Write` -- poll-based byte streams over a
  `ReadBufCursor`. The census's `FdStream` makes plain nonblocking system
  calls; one that would block parks its waker in the bridge's readiness
  registry. `MemPipe` is a bounded in-memory duplex for the deterministic
  driver.
* `rt::Executor<F>` -- where Hyper's HTTP/2 background futures go: the
  connection task, every server stream (`H2Stream`), the client's request
  pipes. `Exec` spawns them onto the bridge's executor. No `Send` bound is
  needed by the bridge (it is thread-local); Hyper asks none of the
  executor.
* `rt::Timer` -- `sleep`, `sleep_until`, `reset` and an overridable
  `now()` (1.12.0's default: `Instant::now()`). The census's timer answers `now()` from the Botlish
  clock, so Hyper's own deadline arithmetic (HTTP/2 keep-alive, HTTP/1
  header-read timeout, whose 30 s default needs a timer) runs in the
  driver's time -- virtual under the deterministic driver. `rt::Sleep` must
  be `Send + Sync`: the bridge's sleep holds only ids.

`hyper-util` (the Tokio adapters and the legacy client) is not used:
everything needed is in Hyper itself. The `tokio` crate is still linked
-- Hyper uses `tokio::sync` unconditionally and h2 uses `tokio::io`
traits and `tokio-util`'s codec -- but without its runtime features, and
the census's control (`tokioctl.bot`) shows what a Tokio-runtime call does
there: it panics, the bridge contains it.

**Demonstrated:**

* **HTTP/1.1** (`h1.bot`, Linux): a Botlish server coroutine answers a
  streamed body in five chunks, a Botlish client coroutine reads 55 bytes
  in five reads, a bystander task ticks throughout.
* **HTTP/2** (`h2.bot`, Linux): one connection, two streams. `/fast` is
  read at once, `/slow` by a consumer sleeping 2 ms per chunk; both server
  handlers offer 64 chunks of 1 KiB as fast as Hyper takes them, with a
  16 KiB stream window. `/fast` completes ~131 ms before `/slow`; the
  `/slow` producer waited for room 63 times and finished 42 ms before its
  consumer; Rust held at most one chunk per exchange; 13 bridge tasks were
  spawned (Hyper's own included); every descriptor was unwatched and closed
  at the end. (`/fast` led by 129-131 ms across the recorded runs.)
* **HTTP/1.1 and HTTP/2 under the deterministic driver** (`mem.bot`): the
  same Botlish modules over in-memory pipes in virtual time, no descriptor
  anywhere; two runs print identical traces (section 16).
* **Polling cost per turn**: the executor's run polled at most 5 futures
  (budget 16) in the HTTP/2 probe; 542-574 polls over 351-381 runs.

**Executor shape.** The census used one thread-local executor per bridge
instance (one per process here). Compared:

| option | ownership | fairness | wakeups | HTTP/2 |
|---|---|---|---|---|
| one per connection | a connection owns its tasks; release drops all | per-connection budgets | a registration per connection | Hyper's spawned streams must reach their connection's executor: the `Executor` value would carry the connection |
| **one per integration instance (chosen)** | the bridge owns tasks; handles own nothing but identity | one budget per turn across all connections, FIFO | one source, one foreign-wake record per batch | natural: `Exec` is a unit value |
| thread-local, many instances | as chosen, shared | as chosen | as chosen | as chosen |

The per-instance executor keeps wake records to one per batch and needs no
per-connection Botlish task; fairness *between* connections is the
executor's FIFO, which is what the Botlish scheduler's dispatch phase does
too. A per-connection budget would only matter for a server with very
unequal connections, and can be added inside the same executor.

## 4. quiche integration

Core quiche only (`quiche/src/lib.rs`): no `tokio-quiche`, no example
servers. Everything the event-loop integration needs is in the core API:
`recv`/`send` with `RecvInfo`/`SendInfo`, `timeout()`/`on_timeout()`,
`SendInfo::at` (pacing), `h3::Connection::{poll, send_request,
send_response, send_body, recv_body}`, and
`Config::with_boring_ssl_ctx_builder` (TLS configured through `boring`,
here with the census's in-memory test PKI).

An **endpoint** is one Botlish-watched UDP socket and one bridge task; each
poll does bounded work and gives the rest back: at most 32 datagrams
received, 64 HTTP/3 events, 32 packets sent; a poll that ran out wakes
itself and returns. A server endpoint routes by connection ID (its own
16-byte IDs and the client's original destination ID).

**Demonstrated** (`h3.bot`, `h3time.bot`, Linux):

* the QUIC/TLS 1.3 handshake in 6.5-13 ms; two HTTP/3 streams on one
  connection, `/fast` read at once and `/slow` by a consumer sleeping 2 ms
  per chunk: the slow stream's Botlish producer waited for room 63 times
  and Rust held at most one 16 KiB chunk -- quiche's stream flow control
  stops the peer while Botlish does not read;
* TLS over QUIC refuses a certificate for another host: the client closes
  with CRYPTO_ERROR 0x12a (bad_certificate);
* releasing a busy endpoint fails its in-flight stream (cancelled), returns
  its socket to Botlish to unwatch and close, and drops its timers;
* **loss recovery on Botlish timers**: with the server dropping the first
  datagram it receives, the client's first Initial (`HS_CENSUS_FAULT=32`),
  the handshake completes after one client-side quiche timeout, fired by a
  Botlish timer registration (10-12 ms into the handshake in the recorded
  runs: which of quiche's timers it was -- loss detection or probe timeout
  -- the census did not trace); with quiche's timeouts never armed (`=48`)
  it never completes (the watchdog reports the stall);
* **the idle timeout on Botlish timers**: a client with a 300 ms idle
  timeout closes 300.5-300.9 ms into an application-level idle period,
  with 7 kernel sleeps in between (no busy polling);
* **pacing honored**: with BBR2, 197-198 of 208 server packets of a
  256 KiB transfer were held until quiche's `SendInfo::at`, each on a
  Botlish timer (6-12 ms of waits in total).

**Pacing finding.** quiche 0.30's default recovery (CUBIC, also Reno)
implements `get_packet_send_time(now)` as `now`: it never asks for a
delayed send. Only the gcongestion recovery (BBR2) has a pacer. With BBR2
the release times are tens of microseconds apart on loopback -- shorter
than a scheduling turn -- so the loop did not sleep between paced packets
(the transfer's CPU time equalled its wall time), and `set_max_pacing_rate`
(2 MB/s and 250 kB/s tried) did not change the transfer's duration on
loopback. Whether that cap applies to BBR2 in 0.30 is unresolved here; the
integration point (a packet held until `at` on a Botlish timer) is.

**Clocks.** quiche reads `Instant::now()` itself; its deadlines reach the
bridge as Durations. Three rules came out of the probes (section 12 has the
general form):

1. Convert with a *fresh* reading of the Botlish clock (the last turn's
   reading plus real time elapsed since): the turn's own reading lags by
   however long the turn has run, and the first version fired 20 of 21
   timers early.
2. A zero `timeout()` is due now: fire it, do not convert it. (Converted
   with a fresh clock it always lands just after the turn's clock, and a
   timer re-armed on every poll never fires: the second version spun for
   300,000 turns.)
3. Move the bridge timer only when the deadline moves earlier, or later by
   more than 1 ms; a Botlish expiry before quiche thinks it is due is
   counted (`early`) and re-armed, never lost.

No numeric relation between `Instant` and the driver's clock is assumed;
both happen to be CLOCK_MONOTONIC on Linux.

**UDP.** Datagram boundaries are kept (one `recvfrom` per datagram, one
`sendto` per packet); source and destination addresses travel with every
packet; a `sendto` that would block parks on writability, and the packet
quiche already counted as sent is left to QUIC's loss recovery (a
production endpoint should hold it for retry). Not exercised: several
connections on one socket at once (implemented: routing by connection ID),
GSO/GRO batching, ECN, migration, multiple paths, 0-RTT, connection
pooling, congestion-control tuning beyond the BBR2 switch.

## 5. BoringSSL provider

**The pin** (`audit/http-stack/boringssl/PIN`) names the URL, the tag, the
tag object and the commit. `tools/provider.tcl` fetches the tag, refuses it
unless both its tag object and its peeled commit equal the pin, checks it
out, and builds it once with upstream's CMake (Ninja, Release,
`CMAKE_POSITION_INDEPENDENT_CODE=ON`, unprefixed, unpatched): 75 s on this
machine. The result is laid out as boring-sys's `BORING_BSSL_PATH` expects
(`lib/libcrypto.a` 369 members, `lib/libssl.a` 38 members, `include/`)
with a `PROVENANCE` record: the pin, the compiler, the flags, and the
SHA-256 of both archives and of every member.

**Integrity.** BoringSSL's release tags are annotated, not signed: there is
no upstream signature to verify. The pin is the authority: the tag object
and the commit are stored in this repository (an independently reviewed
channel), and the fetch refuses a server that disagrees. A digest fetched
from the same server as the artifact would authenticate nothing; the
repository's copy does. The crates' checksums in `Cargo.lock` are
crates.io's own (`.crate` SHA-256): they pin bytes against later change,
not against a compromised registry at first fetch. A production policy can
add an independent second source (the GitHub mirror's commit for the same
tag) and a reproducible-build comparison of the archives.

**Binding compatibility, demonstrated.** boring 5.4.0 and quiche 0.30.0
compile, link and pass the TLS and QUIC probes against the unpatched
upstream tag their own boring-sys vendors. The repository's existing pin
(0.20260929.0) also compiles with boring 5.4.0 (the other-revision control
built and ran), but section 6 shows why "compiles" is not the bar.

**The C++ runtime.** libssl.a needs libstdc++'s exception ABI; the provider
module declares `extern c library "stdc++"` beside the two archives.

## 6. Single-link proof

**How the Rust unit references the provider without embedding it.**
`tools/build.tcl unit NAME -bssl link` points boring-sys's
`BORING_BSSL_PATH` at a directory of two *empty* archives and
`BORING_BSSL_INCLUDE_PATH` at the provider's headers: bindgen and the Rust
code compile against the provider's API, and what boring-sys and quiche
bundle is nothing. The unit is then one relocatable object (`ld -r
--whole-archive`) whose only global definitions are its 73 `hs_*`
functions (`objcopy --keep-global-symbols`), with its private copy of the
Rust standard library localized and its one COMDAT group renamed (section
17, B3). It **defines 0 BoringSSL symbols and leaves 622 BoringSSL
references** for the final link, which Botlish's link plan resolves from
the provider's archives, named once by the provider module `bssl.bot`
(`extern c library "crypto" static at "native/libcrypto.a"`, `ssl`,
`stdc++`), which the crypto airlock and the Rust unit's Botlish module both
import.

**The three consumers in one executable** (`combined.bot`): consumer A,
the crypto airlock (C over libcrypto, no HTTP, no Rust); consumer B, HTTPS
-- Hyper over TLS through boring, HTTP/2 by ALPN, its response body signed
by the airlock; consumer C, HTTP/3 through quiche. All three work in one
process on one event loop beside a bystander task.

**The proof**, by `tools/linkcheck.tcl`, which builds the same program as
an executable with Botlish's own linker, wrapped (`RUSTC` for the rustc
linker, `BOTLISH_NATIVE_SYSTEM_LINKER` for the system linker) to keep the
exact command line and a link map:

| check | rustc linker | system linker |
|---|---|---|
| link plan (Botlish's `BOTLISH_NATIVE_LINK_LOG`) | crypto, ssl (static at the provider's archives), stdc++, hscrypto, event_loop_linux, hs_native | same, plus the runtime archive `libbotlish_runtime.a` the system linker links |
| provider archives on the command line, hashed | match the PROVENANCE record | match |
| archive members included from the provider | libcrypto.a 219, libssl.a 36 | libcrypto.a 219, libssl.a 36 |
| included members of *other* archives defining a provider symbol | 0 (hs_native 1 member, hscrypto 1, event_loop_linux 1) | 0 (the same, and 53 members of the runtime archive) |
| provider global symbols in the executable's whole symbol table (locals included), defined more than once | 0 of 4,271 | 0 of 4,271 |
| at run time: the airlock's `&SHA256` and `EVP_sha256()` against the Rust unit's (boring-sys) | equal | equal |
| at run time: API version the airlock and the Rust unit were compiled against | 44 and 44 | 44 and 44 |
| verdict | ONE PROVIDER | ONE PROVIDER |

**Negative controls** (each a different way to get two implementations):

| control | what the link did | what caught it |
|---|---|---|
| a *private* copy: the provider's archives folded into the localized unit (`-bssl embed`; the unit then leaves 0 BoringSSL references) | linked silently | the run-time identity (different `SHA256`, different method table, the same API version) and the link check (the unit's member defines 4,450 provider symbols; 1,783 are defined twice in the executable) |
| boring-sys's own arrangement: bundled, not localized (`-bssl bundle -localize 0`) | linked silently; the unit holds every BoringSSL member *twice* (boring-sys and quiche both bundle it: `sha256.cc.o` twice, 1,453 members, 192 MB). With the provider's archives first in Botlish's archive group, every BoringSSL member the link used came from the provider; the 222 members it took from the unit define none | nothing to catch, by luck of order: the check says ONE PROVIDER, and rightly. Which copy a link uses is decided by archive order alone; the bundled copies are dead weight that a different order (or a different revision, next row) turns into a second implementation |
| another revision bundled (the repository's 0.20260929.0), not localized | linked and **ran** silently; by the same archive order the code came from the provider (equal addresses), but the Rust unit was *compiled* against the other revision's headers | only the API-version identity check (43 against 44): one program whose Rust code was compiled for one revision and runs another's |
| two modules declaring `crypto` at two archives | compile-time LINK-CONFLICT | the compiler (NATIVE-LINK-PLAN-MILESTONE-1.md's merge rule) |

**Limits of the guarantee.** It holds for one *static* executable:
one link, one symbol namespace. It does not extend to independently loaded
shared objects -- a Botlish native library (`.so`) carries a private
runtime by design (NATIVE-LIBRARY-MILESTONE-1.md), and a process that loads
two of them, or a system library linked to the system's OpenSSL, can hold
several BoringSSL/OpenSSL copies; ELF interposition can then bind one
object's references to another's copy unless the provider is built with
`BORINGSSL_PREFIX` or hidden visibility. The address check assumes no
identical-code folding or LTO merging (neither was used); the symbol-table
check needs an unstripped executable (Botlish's are).

## 7. TLS

**Division of responsibilities.** TLS runs in the native protocol unit,
not in Botlish: Hyper needs a Rust byte stream, and a C airlock would carry
every TLS record through Botlish (two more crossings per record). Botlish
holds the *policy*: a client configuration it makes names the trust anchors
(the census's test CA, never the system store), always verifies the chain
and the host name, and offers ALPN protocols; a server configuration names
its certificate and the protocols it accepts. There is no option to skip
verification (`hstls.bot`).

**Nonblocking mechanism** (`tls/src/lib.rs`): boring's synchronous
`SslStream` over an adapter whose `read`/`write` are the bridge's
nonblocking system calls with the current poll's waker; a call that would
block parks the waker on the descriptor (Botlish arms the watch) and
reports `WouldBlock`, which BoringSSL surfaces as `WANT_READ`/`WANT_WRITE`,
which the wrapper turns into `Pending`. The handshake is the same loop over
`MidHandshakeSslStream`; short reads, short writes and records split across
reads are BoringSSL's to handle and need nothing more.

**Demonstrated** (`tls.bot`; each scenario a fresh server, socket and
client):

| scenario | result |
|---|---|
| valid certificate, ALPN h2 + http/1.1 | handshake, ALPN `h2`, Hyper HTTP/2, status 200 |
| valid certificate, client offers http/1.1 only | ALPN `http/1.1`, Hyper HTTP/1.1, status 200 |
| certificate for another host | refused: X509_V_ERR_HOSTNAME_MISMATCH (62) |
| certificate by an untrusted CA | refused: unable to get local issuer (20) |
| expired certificate | refused: X509_V_ERR_CERT_HAS_EXPIRED (10) |
| client offers only a protocol the server does not serve | refused: no_application_protocol alert (RFC 7301) |
| the peer disappears mid-handshake (listening socket closed under the ClientHello) | the handshake fails (EOF), no hang |
| the owner releases a handshake that cannot progress | released, descriptor unwatched and closed, nothing more heard |

One mapping detail mattered: BoringSSL reports X509_V_ERR_INVALID_CALL (65)
as the verify result of a handshake that ended *before* verification; the
first version reported the ALPN and EOF failures as "verification failed
(65)".

**Projected:** platform trust stores are a policy of the TLS airlock, not
BoringSSL's: Linux a CA bundle file (`SSL_CTX_load_verify_locations`),
macOS/iOS Security.framework, Windows CryptoAPI, Android's verifier --
each a verification callback or a file the airlock chooses. Session
resumption keeps tickets and ticket keys (key material) in the TLS
configuration objects the airlock owns; nothing in the bridge prevents it,
and nothing tested it.

## 8. Rust/C FFI

**The boundary chosen** combines the first two options the brief named:

1. a C ABI around Rust-owned objects -- protocol operations on handles
   (`hs_h_*` for HTTP/1.1 and HTTP/2, `hs_q_*` for QUIC/HTTP/3,
   `hs_tls_*` for TLS policy), every argument and result a C scalar or a
   byte buffer Botlish exposes for one call;
2. a small generic polling bridge -- `hs_run(budget, now)`,
   `hs_next_deadline`, `hs_fire`, `hs_io_ready`, `hs_next_interest`,
   `hs_take_notice`, `hs_kick` -- which the Botlish executor alone calls.

Option 3 (separate minimal C ABIs for Hyper and quiche coordinated by a
shared provider) is what this becomes if the two protocols ship as separate
Rust units; it doubles the private Rust runtime and the polling bridge, and
under symbol localization it is safe (section 6), but each unit needs its
own executor or a shared one through a further ABI. One unit was simpler.
The crypto-only consumer needs none of it: it is C over the provider and
links without the Rust unit (`cryptoonly.bot`).

**Handles.** Botlish holds integers only: `generation << 32 | index` into a
generation-checked table, with a tag bit per table kind. A released handle
is refused (`ERR_STALE`) also after its index is reused. The
stale-completion control (`HS_CENSUS_FAULT=384`: released tasks keep
running, handles looked up by index alone) shows what the generation buys:
a late response to a released exchange lands in the exchange that reused
its slot (status 299 instead of 200).

**Notices**, not callbacks: Rust queues `(handle, a, b)`; the Botlish
executor drains them after each run and posts each to the registrations of
the coroutines waiting on that handle, after checking the handle is still
one somebody waits on (stale ones are counted and dropped). A notice is a
hint; a coroutine reads the state through its handle after every wake and
before its first wait. **Each waiting coroutine has its own registration**:
a Botlish event wakes one waiter, and a handle (an HTTP/2 connection, a
server) can have several; the first version kept one per handle and the
second of two HTTP/2 requests never started.

**Wakes.** A task's waker is an `Arc` with a `queued` flag (a duplicate
wake costs nothing) and a key whose generation the executor checks (a wake
of a cancelled task is dropped). On the loop thread inside a call a wake
only enqueues: Botlish asks the ready count after the call. From another
thread it enqueues under a mutex and, on the inbox's empty-to-non-empty
edge, posts *one* record to the executor's source through the event loop's
integration ABI (`botlish_event_post`, a weak reference so the
deterministic driver's programs link without it). The adapter's wakeup
protocol (EVENT-LOOP-MILESTONE-1.md, 7.2) then guarantees the sleeping loop
wakes. **A third wake path the plan missed**: a Botlish *application*
coroutine's own call (a request, a respond, a chunk offered or taken, a
release) spawns or wakes Rust tasks while the executor task is parked on
its source; nothing wakes it. The bridge sets a kick flag for any spawn,
wake, notice or readiness change outside a run, and every Botlish wrapper
posts a wake record when the call left it set (`hs::nudge`). The first
probe stalled exactly so; `HS_CENSUS_FAULT=8` puts it back.

**Panics and threads.** Every export runs in a guard: a panic becomes
`ERR_PANIC` and never unwinds into C; a task that panics is dropped and
counted, and the executor carries on (demonstrated, `sched.bot`); a call
from a thread other than the loop's is `ERR_WRONG_THREAD`; a call made
while one runs would be `ERR_REENTRANT` (Rust never calls Botlish, so this
cannot happen; the guard makes the claim checkable).

**Buffers.** Two designs were weighed:

* *Copy at the boundary* (chosen): body bytes are copied into Botlish-owned
  `MutableBytes` (a `write noescape` exposure the Rust side fills, returned
  to Botlish by the C-POINTER-BORROWING.md write-back) or out of Botlish
  `Bytes` (`read noescape`), one chunk at a time; Rust keeps at most one
  chunk per direction per exchange. Units are application units -- body
  chunks -- never packets, TLS records or frames.
* *Retain in Rust and expose access*: Botlish has no type for borrowed
  foreign bytes. A native view reads *layouts* from live memory
  (NATIVE-LAYOUT-VIEWS.md) and byte storage is never a pointer value
  (C-POINTER-BORROWING.md), so a zero-copy chunk would need a new
  borrowed-bytes facility with a lifetime tied to a handle -- exactly the
  cross-suspension borrow the brief forbids today. Not pursued.

The copying cost is section 13's. No Rust reference, stack address or
native pointer reaches Botlish; every exposure is valid for one call.

**Cancellation.** Releasing a handle cancels its tasks: their futures are
dropped on the loop thread inside the call, so Hyper resets an HTTP/2
stream or closes an HTTP/1 connection, quiche's endpoint drops its
connections. A Rust destructor never touches Botlish state: a dropped
`FdStream` hands its descriptor back to Botlish, which unwatches and then
closes it (the package's rule; a destructor that closed it could let a
reused descriptor number inherit the watch).

## 9. Botlish airlocks

The existing context pattern expresses the boundaries; the census used
five, all ordinary Botlish:

| boundary | context | what it grants | what it does not |
|---|---|---|---|
| cryptography | `crypto::Crypto` (`crypto.bot`) | hash, MAC, sign with keys held by the airlock (a key is a slot; private bytes never leave C, wiped on release) | no socket, no TLS, no BoringSSL type; `cryptoonly.bot` links no Rust unit and no event loop |
| TLS policy | none: configurations are handles a program makes (`hstls.bot`) | trust anchors, host verification, ALPN, certificates | nothing to disable verification |
| scheduling of native protocol work | `hs::Hs` (`hs.bot`) | wait on handles, release them, run the executor | no descriptor authority |
| readiness / transport | `hsnet::Net` + `event_loop_linux::Native` | watches of the bridge's descriptors | made only from an installed Linux driver (MISSING-CONTEXT under the deterministic driver) |
| the loop | `std::event_loop::Loop`, the Driver | as EVENT-LOOP-MILESTONE-1.md | a library cannot install or replace the driver: `reject_driver.bot` is CONTEXT-INSTALLATION-UNSUPPORTED |

**What is not yet an airlock**: socket creation. The probes call
`hs_tcp_listen`/`hs_tcp_connect`/`hs_udp_bind` with no context; in a
production stack those belong to the transport airlock (a context made by
the application, as `Native` is from the driver), so that a generic HTTP
service gets connections, not the power to open them.

**Mechanism versus policy.** Linking the whole provider does not grant its
operations: what a Botlish library can do is what the airlock modules it
can name export and the contexts it is given require. That holds for
Botlish code; it is not memory safety. Native code in the unit and the
provider can do anything their process can, and the airlocks' guarantees
are only as good as the foreign boundaries' implementations (the census's
follow the C-POINTER-BORROWING.md and C-FFI.md rules and were not
fuzzed).

**A language gap.** A context-trait implementation takes exactly one
context, its own (`hsnet::arm declares 4 context parameters ...: an
implementation takes exactly one`). The census first wrote the executor
once, over a context trait `Readiness` implemented by a Linux and a
deterministic context; the Linux implementation needs `Loop` and
`event_loop_linux::Native` to make watches, so that design is not
expressible. The probes write the executor loop per driver (`hsnet`,
`hsmem`) over a shared `hs::step`.

## 10. Streaming

Both body directions cross in chunks with one chunk of Rust buffering
(`hyper/src/body.rs`, the quiche streams):

* **incoming**: a pump task polls Hyper's `Incoming` (or reads quiche's
  stream) for the next frame only when Botlish has taken the last; while
  a chunk waits, the pump is silent;
* **outgoing**: Botlish offers one chunk; it is accepted only into an empty
  slot; Hyper's body (or the quiche stream) takes it and notices the
  producer, which waits otherwise.

**Where the backpressure goes**, demonstrated: a Botlish consumer that does
not read leaves the chunk in the bridge → the pump stops polling the body
→ HTTP/2: Hyper does not release the stream's flow-control capacity, so no
WINDOW_UPDATE goes out and the peer's stream stops at its window; HTTP/1:
the connection stops reading, the socket buffer fills, TCP's window closes;
HTTP/3: the bytes stay in quiche's stream buffer, no MAX_STREAM_DATA, the
peer stops → the peer's Botlish producer finds its slot full and waits.

| probe | measurement |
|---|---|
| `h2.bot` | the slow stream's producer waited for room 63 times; finished 42 ms before its consumer (the window and the buffers below it); the fast stream unaffected |
| `h3.bot` | the same over QUIC: waited 63 times; Rust held at most one 16 KiB chunk |
| `stall.bot` | a consumer that stops for 500 ms after one chunk: the producer got 64 KiB ahead of a 4 MiB body (16 KiB stream window), Rust held at most 16 KiB, RSS did not grow; then 4 MiB drained with Rust holding at most 16 KiB |
| `stall.bot`, `HS_CENSUS_FAULT=512` (the pump ignores the consumer) | the producer finished all 4 MiB during the stall, Rust held 4 MiB, RSS grew 4.8 MB: a small Botlish queue hiding an unbounded Rust one, detected |

The event loop's Delivery policies are not applied to bodies: a body is
not an event stream, and its flow control is the protocol's. What reaches
Botlish are notices (Coalesce registrations, one per waiter) saying "look
again"; the bytes themselves are pulled through handles at the consumer's
pace.

The bound, stated: per exchange, one chunk in the bridge per direction
plus the protocol library's own buffers -- Hyper's HTTP/1 read buffer (up
to its configured maximum, ~400 KiB by default), the HTTP/2 stream and
connection windows, quiche's stream and connection limits -- all
configuration, none growing with what the producer offers.

## 11. Resource lifetimes

Ownership is explicit in the probes (release by handle); the table is the
next milestone's requirement list.

| resource | created by | owned by | identity observable without ownership | depends on | affine | transferable | may outlive its creator | cancellation | lexical scope exit should | coroutine abandonment | cleanup needs Botlish | cleanup may yield / fail |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| TCP/UDP socket | transport airlock (Rust `socket`) | the Rust object using it; its close is Botlish's | the descriptor number (reusable!) | -- | yes | to a Rust object, once | yes (accepted connections outlive the listener) | release the object | unwatch, then close | leaks until shutdown today | yes (unwatch) | no / close can fail (ignored) |
| event-loop watch | `hsnet` (Botlish) | the executor's tables | watch id + registration tag | the socket, the executor's source | yes | no | -- | unwatch | unwatch before the socket closes | as above | yes | no / no |
| registration (Reg) | Botlish | its creator | `native_slot`/`generation` | the Loop | not today (identity) | copies are identities | yes | revoke | revoke | stays registered (EVENT-LOOP-MILESTONE-1.md, 9) | yes | no / no |
| TLS configuration | Botlish (`hstls`) | the bridge's table | its handle | the provider | yes | shared by connections (refcounted inside) | yes | release | release (key material wiped by BoringSSL's free) | leaks | no | no / no |
| TLS connection | the handshake task | its HTTP connection | -- | socket, configuration | yes | no | no | drop (no close_notify) | close_notify then drop: needs I/O, i.e. a turn | dropped with the connection | no | yes / yes |
| Hyper connection task | `hs_h_client`, accept | the client / connection object | its handle | TLS or socket | yes | no | its exchanges die with it | release: futures dropped now | graceful shutdown (GOAWAY, drain) needs turns | leaks | no | yes / yes |
| HTTP request or response body | an exchange | the exchange | the exchange handle | the connection | yes | no | no | release: HTTP/2 RST_STREAM, HTTP/1 connection closed | release | leaks; the peer sees a stall | no | no (reset is queued) |
| HTTP/2 stream | Hyper (spawned) | the connection | -- | the connection | yes | no | no | as body | as body | -- | no | -- |
| quiche connection | an endpoint | the endpoint | -- | the socket, timers | yes | no | no | endpoint release | CONNECTION_CLOSE then draining needs turns and a timer | leaks | no | yes / yes |
| QUIC / HTTP/3 stream | `hs_q_request`, a peer | the endpoint | its handle | the connection | yes | no | no | release: shutdown both directions | as release | leaks | no | no |
| Rust future / executor task | spawn | the executor | its key (generation) | whatever it captured | yes | no | yes | cancel: dropped on the loop thread | cancel | dropped at `hs_close` | no | no / no |
| native buffers | the bridge (one chunk) | the exchange | -- | the exchange | yes | no | no | freed with the exchange | free | -- | no | no |
| key material | the airlock (slot) | the airlock | the slot number | the provider | yes | no | yes | release (wiped) | wipe | leaks until process exit | no | no / no |

**Demonstrated** (`lifetimes.bot`): releasing a *listener* stops accepting
and closes its socket, while the connection it accepted keeps serving
(status 200 on the same connection after the release); releasing an
*HTTP/2 client connection* fails both its in-flight streams (cancelled) and
wakes their waiters; an exchange released while its response is in flight
never delivers it -- not to its waiter, not to the exchange reusing its
slot (two stale notices dropped) -- and its control shows the opposite; at
shutdown no descriptor is watched or open.

**Requirements for lexical cleanup** that follow:

1. A cleanup that must change Botlish state (unwatch, revoke) cannot be a
   Rust destructor: the destructor queues, Botlish completes. The scope-end
   action is Botlish's.
2. Order matters across the boundary: unwatch before close; a stream
   before its connection only when graceful (release of the connection
   takes the streams with it); a listener independent of its connections.
3. Graceful protocol endings (TLS close_notify, HTTP/2 GOAWAY, QUIC
   CONNECTION_CLOSE and draining) need I/O and timers after the scope ends.
   The scope-end action must be able to *start* a release that the
   executor finishes in later turns (detach to the executor), with abrupt
   release (drop now) as the fallback the probes use.
4. Abandoned coroutines (`shutdown`, `abandon`) release their coroutines
   without running code: handles they held stay live until `hs_close`.
   Scope-bound handles must be released by the scope's owner even when the
   coroutine never resumes.
5. Key material is wiped synchronously at release; nothing else needs to
   run code at scope end on the Rust side.

## 12. Scheduling

**Bounded progress, demonstrated** (`sched.bot`): a Rust future that wakes
itself 20,000 times beside a Botlish task that yields every turn: the
executor's runs poll at most what was ready when they started (here one
future per run, budget 16), the yielding task ran in every one of the
20,003 turns, and the spinner finished. With `HS_CENSUS_FAULT=2` (a run
polls everything, including what wakes during it) one run polled 20,001
times and the yielding task got 3 turns: starvation, detected.

**The rules the bridge keeps**, mirroring the Botlish dispatch phase: a run
polls exactly the futures ready when it starts, at most BUDGET, each once,
FIFO; a future woken during a run is polled by a later run; the executor
task yields (`yield_now`) while Rust work is ready -- so every other ready
Botlish task runs before the next Rust run -- and waits on its source when
none is. A protocol task with more work than one poll should do yields
itself (quiche's endpoint after a budget of datagrams, events or packets).

**Timers.** The Rust side keeps one heap in the Botlish clock; its earliest
deadline is what the timekeeper task waits for with an ordinary Botlish
timer registration; an earlier deadline revokes that timer and the
timekeeper re-arms. Hyper's time is the Botlish clock (virtual under the
deterministic driver: a 5 s Rust sleep completes at exactly +5,000,002 µs
of virtual time, in milliseconds of wall time); quiche's follows the three
rules of section 4. The deterministic control (`HS_CENSUS_FAULT=64`, no
timekeeper) leaves that sleep pending forever, and the Botlish watchdog
reports it. Deterministic protocol-time testing holds for Hyper (whose
clock the bridge supplies) and not for quiche (which reads `Instant::now()`
itself): QUIC timing claims are measured under the Linux driver only.

**Wakeups, demonstrated:** a future completed by another OS thread after
20 ms completes 20.6-20.7 ms after it started (one record posted through the
integration ABI); with the post suppressed (`HS_CENSUS_FAULT=1`) only an
unrelated wake 500 ms later finds it. A Rust timer started by an
application call completes in ~10.3 ms; without the kick (`=8`) it waits
for an unrelated wake.

**Idle**: an open HTTP/2 connection with keep-alive pings every 200 ms, idle
for one second: 2.9-3.4 ms of CPU, 26-28 kernel sleeps, 10 Rust timers
fired. A
QUIC connection's idle timeout closed it during an application sleep with
7 kernel sleeps (section 4).

**Unrelated work.** Bystander tasks sleeping 1-2 ms at a time beside the
probes were late by at most 0.1-10 ms in different runs (section 13 has the
cause): the loop's fairness holds per turn, and one turn's cost is whatever
the Rust run and the ready Botlish tasks in it do.

## 13. Performance

Representative, not benchmarks: one 4-core shared container, numbers from
the probes' own counters (`hs::rstat`, `hs::counter`) and the measurement
probe `measure.bot`; no comparison with a Rust-only Tokio server was made
(it would compare a production server with a probe).

**Per request and per streamed chunk** (`measure.bot`: 100 sequential
small requests on one connection per protocol, each answered with one
4 KiB chunk, then one 1 MiB HTTP/2 body in 4 KiB chunks; client *and*
server run in the probe's one process, so every figure counts both ends;
averages of the totals; Linux driver, loopback; the counts were identical
in both recorded runs, the wall times are the two runs' range):

| per | FFI calls | Rust polls | wakes | executor runs | notices | readiness reports | interest changes | kicks | bytes copied out / in | Rust allocations (bytes) | turns | wall µs |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| HTTP/1.1 request | 75 | 9 | 7 | 7 | 6 | 2 | 2 | 3 | 4,106 / 4,105 | 33 (7.7 KB) | 8 | 99-141 |
| HTTP/2 request | 87 | 13 | 10 | 10 | 6 | 2 | 2 | 2 | 4,106 / 4,105 | 43 (12.7 KB) | 11 | 114-169 |
| HTTP/3 request | 66 | 6 | 6 | 4 | 6 | 3 | 3 | 3 | 4,096 / 4,105 | 118 (123 KB) | 5 | 214-215 |
| HTTP/2 streamed 4 KiB chunk | 20 | 3 | 3 | 1 | 2 | 0.5 | 0.5 | 1 | 4,096 / 4,096 | 3.7 (12.4 KB) | 1 | 48-66 |

Reading it:

* **Crossings are the dominant count, not their cost.** 66-87 C calls
  per exchange (both ends) and 20 per streamed chunk: the executor's step
  (run, interest, notices, deadline) and each application call with its
  kick check. Wall time is 0.1-0.21 ms per request and 48-66 µs per
  4 KiB chunk (60-85 MB/s through Botlish coroutines on both ends, one
  turn per chunk). Batching the step's queries into one call (run returns the
  interest, notice and deadline counts) would remove most of the step's
  calls; none of this is near a per-packet or per-frame cost.
* **Copies are exactly the body**: each body byte is copied once into
  Botlish-owned storage on receipt and once out of it on sending -- 4,096
  bytes per 4 KiB chunk each way, and the request line.
* **Rust allocations** are Hyper's, h2's and quiche's own, measured by a
  counting global allocator in the unit (BoringSSL's `malloc` calls and
  Botlish's heap not included): ~33 per HTTP/1.1 exchange, ~43 per HTTP/2,
  ~118 per HTTP/3 (123 KB: quiche's packet and stream buffers), 3.7 per
  streamed chunk (the copied-in chunk, Hyper's frame and h2's buffers).
  The Botlish side allocates a fresh `MutableBytes` per `recv` (the
  `write noescape` exposure, B8), not counted here.
* **Polls per run**: at most 5 in the two-stream HTTP/2 probe (budget 16),
  1.4-1.6 on average; the bounded-progress probe is one per run by
  construction.
* **Idle**: an open HTTP/2 connection with 200 ms keep-alive: ~3 ms of CPU
  per idle second, 26-28 kernel sleeps, 10 Rust timers; an open QUIC
  connection idle until its 300 ms timeout: 7 kernel sleeps.
* **Unrelated work**: a bystander sleeping 1 ms at a time beside the
  whole measurement was late by at most 5.3-8.1 ms. The longest single
  Rust call in those runs took 5.0-7.6 ms (the longest executor run
  0.6 ms): a
  synchronous call that makes the QUIC server's TLS context, where the
  test PKI generates keys and signs certificates, is the one expensive
  call the probe makes (inferred: no call was timed individually).
  Bounded runs do not bound a single expensive *operation*: key
  generation and similar work belongs off the loop thread, completed
  through the integration ABI's endpoints (section 17, B12).
* **Sizes**: the Rust unit is 31 MB as a static archive (unstripped; its
  own Rust standard library, Hyper, h2, quiche, boring); a probe
  executable with it, the provider and the Botlish runtime is ~45 MB
  unstripped. A probe compiles and links in about 40 s.

The event loop's own dispatch cost is EVENT-LOOP-MILESTONE-1.md's (0.35 µs
per `yield_now` dispatch); the census did not change it and did not
remeasure it.

## 14. Packaging and portability

**What today's infrastructure expresses** (demonstrated):

* an archive shipped *inside* an application or a package, linked by a
  path relative to it (`extern c library "NAME" static at "PATH"`,
  NATIVE-LINK-PLAN-MILESTONE-1.md): the census's applications carry
  `libhs_native.a`, the provider's two archives and the airlock's;
* one declaration of the provider for a whole program, imported by every
  consumer (`bssl.bot`), and LINK-CONFLICT when a second module declares
  the same library at another archive;
* a C++ runtime dependency (`extern c library "stdc++"`).

**What it cannot express:**

* **Cargo.** The driver package's installer runs `cc` and `ar`
  (tools/event-loop-linux.tcl); a Rust unit needs cargo, the pinned rustc,
  network or a vendored registry, bindgen's libclang, and the post-link
  steps (`ld -r`, `objcopy`, COMDAT renaming). Nothing in the package model
  builds it; the census's `tools/build.tcl` does what a package build step
  would.
* **A provider shared across packages.** Package scopes are downward only
  (BOT-MODULES-MILESTONE-1.md): two packages cannot both import a sibling
  "boringssl" package, and two packages that each declare `crypto` at
  their own archive are LINK-CONFLICT. The merge rule offers a way that the
  census did not exercise: a package declares the library *without* a path
  (`extern c library "crypto"`, a requirement) and the application's
  provider module declares it `static at` (the strictest wins). That keeps
  the choice of the provider the application's, as the choice of the driver
  is.
* **Provider identity in the plan.** The link plan names archives by path;
  it has no version, revision or hash. The census's provenance checks
  (linkcheck, the run-time identity) are what a production build step must
  do: verify the archives against the pin, and refuse a unit built against
  another provider's headers (the API-version check caught the silent
  mixing that the linker did not).
* **Rebuilding consumers on a provider update.** A unit records the
  provider it was compiled against (`UNIT.txt`); a production cache must
  key units by the provider's commit, so that updating the pin rebuilds
  every consumer and a stale unit cannot be linked against a new provider.

**Reproducibility**: crate versions are pinned by `Cargo.lock`; the
provider by tag object and commit, built with recorded flags; the provider
archives' and members' SHA-256 are recorded and verified before every link.
Not done: bit-for-bit reproduction across machines (compiler versions are
recorded, not pinned) and a vendored crates registry.

**Portability** (projections; only Linux x86-64 was executed):

| target | compiler and libraries | event-loop driver | census tooling |
|---|---|---|---|
| Linux AArch64 | hyper, quiche, boring and BoringSSL support it | the Linux driver exists (EVENT-LOOP-MILESTONE-1.md) | the same (GNU binutils) |
| Windows x86-64 | BoringSSL and boring support MSVC; quiche supports Windows (`windows-sys`) | none: an IOCP driver posts *completions*, so the readiness registry needs a completion form | COFF: no `objcopy --keep-global-symbols`; lib.exe and a `.def`, and the C++ runtime is MSVC's |
| macOS AArch64 | supported | none: kqueue / CFRunLoop | Apple ld has `-r` and `-exported_symbols_list`; no objcopy |
| Android | boring-sys supports the NDK (`ANDROID_NDK_HOME`) | none; a host-stepped driver (EVENT-LOOP-MILESTONE-1.md, 10) | as Linux |
| iOS | static libraries only; supported by the crates | none; host-driven | as macOS |

Nothing in the protocol-level Botlish modules names epoll: readiness is
`hsnet`'s, and a completion-based driver would change the bridge's
readiness registry (Rust would own the buffers of in-flight operations),
not the HTTP-facing modules.

## 15. Tokio interoperability

Neither direction is implemented; the census establishes the boundary.

**A Tokio-managed library hosted by Botlish.** Today such a library cannot
run under the bridge: `tokio::spawn`, `tokio::time` and Tokio's I/O types
need a Tokio runtime in the calling thread's context, and the census's
control shows the failure mode (`tokioctl.bot`: `tokio::spawn` panics, the
bridge contains it). The explicit integration point is a *Tokio island*: a
runtime on its own thread, made only by the application through a context
(as the driver is), exchanging data with Botlish through the integration
ABI's endpoints (posts carry copies, Reliable delivery gives
backpressure), never sharing the Botlish thread. Missing for that: a
contract for what crosses (records are four scalars today; bulk data needs
an owned-buffer handoff), and a way to account the island's CPU and
lifetime to the application. Driving a current-thread Tokio runtime from
Botlish turns instead is not possible with Tokio's public API: its I/O
driver parks on its own epoll, and there is no "run one bounded tick".

**Botlish hosted by a Tokio application.** The Tokio side calls a Botlish
native library (NATIVE-LIBRARY-MILESTONE-1.md); the same scheduler runs
externally paced (the host-stepped driver of EVENT-LOOP-MILESTONE-1.md,
10). Missing: persistent scheduler state across exported calls (an
instance holding the Loop), an exported "run one turn, report the next
deadline" entry the Tokio task calls and then sleeps on
(`tokio::time::sleep_until`), a wake path from Botlish's native producers
to a Tokio `Notify`, and a thread rule: a Botlish instance is thread-affine,
so the Tokio side must keep it on one thread (a `LocalSet` or a dedicated
thread). None of it needs a second Botlish scheduler.

## 16. Testing

`tclsh9.0 audit/http-stack/tools/check.tcl` builds everything, runs every
probe and control, and checks each claim on the program's own report.
Recorded on 2026-10-30 in two invocations on the final code: `check.tcl`
(build, probes, controls, determinism: 41 claims, ~45 minutes) and
`check.tcl -parts "link compile" -build 0` (9 claims, 5 minutes; the link
part was re-run after the counting allocator became a feature and the
bundled-copy expectation was corrected, both described in section 6 and
B3). Each invocation writes its transcript to
`~/.cache/botlish/http-stack/check.txt`. Addresses are shown as `<addr>`;
the table keeps each program's own words (`budget exhausted` counts the
runs that left work ready -- mostly futures woken during the run, which by
the snapshot rule wait for the next run).

| part | claim | result | the program's own report |
|---|---|---|---|
| build | `provider-provenance` | PASS | pinned 0.20261020.0 d3bf4795ad5b79d646cddf2fec687da5b9b502db, archives hash as recorded |
| build | `unit-link-only` | PASS | the Rust unit defines 0 BoringSSL symbols and leaves 622 for the final link |
| probes | `A-crypto-only` | PASS | known answers, Ed25519 sign/verify, key wiped on release; no Rust unit, no event loop in the link (api version 44) |
| probes | `hyper-http1` | PASS | client: body bytes 55 reads 5 end -1 |
| probes | `hyper-http2-streams` | PASS | two streams on one connection; /fast done 129 ms before /slow |
| probes | `hyper-http2-backpressure` | PASS | the /slow producer waited for room 63 times and finished 42 ms before its consumer; Rust held at most 1 chunk |
| probes | `hyper-http2-cleanup` | PASS | watched after stop 0 retired 3 watches made 3 interest changes 0 |
| probes | `hyper-http2-bounded-polls` | PASS | rust: polls 542 runs 375 max polls per run 5 budget exhausted 218 spawns 13 timers fired 0 |
| probes | `tls-scenarios` | PASS | tls good-h2: 2 expected 2 -- ok status 200 body over tls; tls good-http1.1: 1 expected 1 -- ok status 200 body over tls; tls wrong-host: -91062 expected -91062 -- ok; tls untrusted-ca: -91020 expected -91020 -- ok; tls expired: -91010 expected -91010 -- ok;... |
| probes | `tls-cleanup` | PASS | watched after stop 0 retired 20 |
| probes | `quiche-http3-streams` | PASS | h3 handshake: state 1 after us 6539; /fast done 35 ms before /slow |
| probes | `quiche-http3-backpressure` | PASS | h3 producer GET /slow waited for room 63; Rust held at most 16333 bytes |
| probes | `quiche-tls-verify` | PASS | h3 wrong-host: state -92298 (CRYPTO_ERROR bad_certificate) |
| probes | `quiche-release` | PASS | h3 released endpoint: stream state -90008 endpoint state -90004; watched after stop 0 retired 4 |
| probes | `quiche-pacing` | PASS | h3 paced: bytes 262144 wall us 16645 cpu us 16229 server paced packets 198 pacing wait us 8341 datagrams out 208 |
| probes | `quiche-idle-timer` | PASS | h3 idle: closed with state -92000 after us 300457 kernel sleeps 7 timeouts 1 |
| probes | `bounded-progress` | PASS | bounded: spinner 20000 over turns 20002 max polls per run 1; yielder: turns 20003 |
| probes | `foreign-wake` | PASS | foreign: completed after us 20732 (thread slept 20000) posts 1 lost 0 foreign wakes 1 |
| probes | `application-call-kick` | PASS | kick: a 10 ms Rust sleep started by an application call finished after us 10371 nudges 3 |
| probes | `panic-containment` | PASS | panics: contained 2 call returned -90001 other thread got -90002 executor still runs |
| probes | `deterministic-driver` | PASS | http/2: status 200 bytes 1230 reads 40 at virtual us 100011; rust sleep of 5 s (virtual): woke at 5000002 after start, loop now 5000003 |
| probes | `lifetime-listener` | PASS | listener: before release status 200 body fast; after release, same connection status 200 body fast; listening socket closed, connect attempt fd 6 retired so far 1 |
| probes | `lifetime-connection` | PASS | both streams of the released connection failed (-90008, cancelled) |
| probes | `lifetime-stale` | PASS | stale: released exchange, reused slot got status 200 body fast; its status 80 ms later 200; stale notices dropped 2 |
| probes | `lifetime-shutdown` | PASS | shutdown: tasks dropped 13 watched 0 retired 9 |
| probes | `stalled-consumer` | PASS | stall 500 ms: producer offered bytes 65536 consumer took 4096 rust received 16384 rust holds at most 16384 rss growth kb -536; drained: bytes 4194304 rust held at most 16384 |
| probes | `idle-cpu` | PASS | idle 1 s with an open HTTP/2 connection (keep-alive every 200 ms): cpu us 2926 kernel sleeps 26 rust timers fired 10 client state 2 |
| probes | `combined-consumers` | PASS | B https: protocol 2 status 200 body over h2, signature bytes 64; C http/3: status 200 body over h3 |
| probes | `combined-one-provider` | PASS | provider: SHA256 airlock <addr> rust <addr>; EVP_sha256 airlock <addr> rust <addr>; api 44 and 44 -- ONE PROVIDER |
| probes | `no-tokio-runtime` | PASS | tokio::spawn without a runtime: fixture result 0 panics contained 1 executor still runs (the control's unit has tokio's runtime feature; tokio::spawn finds no runtime, the panic is contained) |
| probes | `measurements-recorded` | PASS | measure.bot: 6 lines (section 13 of the report) |
| probes | `tokio-features` | PASS | tokio in the probes' unit (a dependency of hyper and h2): no `rt`, `time` or `net` feature. `cargo tree -e features -i tokio` lists bytes, default, io-util, sync; the recorded run's extraction printed only two of them (a pairing bug in check.tcl, fixed after the run) |
| negative controls | `control-unbounded-poll` | PASS | bounded: spinner 20000 over turns 2 max polls per run 20001; yielder: turns 3 |
| negative controls | `control-lost-foreign-wake` | PASS | foreign: completed after us 500279 (thread slept 20000) posts 0 lost 1 foreign wakes 1 |
| negative controls | `control-no-kick` | PASS |  watchdog: STALLED after us 8013189 |
| negative controls | `control-missing-timer` | PASS | STALLED: parts finished 2 of 3 after 20 s of virtual time |
| negative controls | `quiche-loss-recovery` | PASS | first Initial dropped: h3 handshake: state 1 after us 11937 client timeouts 1 early 0 |
| negative controls | `control-quiche-timer-never-armed` | PASS | first Initial dropped, timeouts never armed: watchdog: STALLED after us 6015231 |
| negative controls | `control-stale-completion` | PASS | stale: released exchange, reused slot got status 200 body fast; its status 80 ms later 299; stale notices dropped 5 |
| negative controls | `control-no-backpressure` | PASS | stall 500 ms: producer offered bytes 4194304 consumer took 4096 rust received 4194304 rust holds at most 4190208 rss growth kb 4784 |
| determinism | `deterministic-trace` | PASS | two runs under the deterministic driver: 21162 trace lines, identical: 1 |
| single-link proof | `link-one-provider-rustc` | PASS | verdict: ONE PROVIDER |
| single-link proof | `link-one-provider-system` | PASS | verdict: ONE PROVIDER |
| single-link proof | `control-private-copy-runtime` | PASS | provider: SHA256 airlock <addr> rust <addr>; EVP_sha256 airlock <addr> rust <addr>; api 44 and 44 -- DIFFERENT PROVIDERS |
| single-link proof | `control-private-copy-link` | PASS | verdict: NOT ONE PROVIDER: other archives define provider symbols: libhs_native.a (4450); 1783 provider symbols defined more than once |
| single-link proof | `bundled-twice` | PASS | boring-sys and quiche both bundle libcrypto.a: sha256.cc.o appears 2 times in the Rust staticlib |
| single-link proof | `bundled-link-order` | PASS | the program ran (provider: SHA256 airlock <addr> rust <addr>; EVP_sha256 airlock <addr> rust <addr>; api 44 and 44 -- ONE PROVIDER); the link took every BoringSSL member from the provider's archives (first in the group): verdict: ONE PROVIDER |
| single-link proof | `control-other-revision` | PASS | the program linked and ran: provider: SHA256 airlock <addr> rust <addr>; EVP_sha256 airlock <addr> rust <addr>; api 44 and 43 -- DIFFERENT PROVIDERS |
| compile-time controls | `control-second-provider-declared` | PASS | LINK-CONFLICT: library "crypto" is declared with two static archives, "native/other/libcrypto.a" here and "native/libcrypto.a" at bssl.bot:12:37 |
| compile-time controls | `control-library-installs-driver` | PASS | a protocol library installing its own driver: rejected |

50 passed, 0 failed

**The brief's required negative controls**, each failing for its own
reason:

| control | how | detected by |
|---|---|---|
| a waker that never notifies Botlish | `HS_CENSUS_FAULT=1` (foreign wake), `=8` (application-call kick) | completion only after an unrelated wake 500 ms later |
| a poll loop that processes unbounded ready futures | `=2` | 20,001 polls in one run; a yielding Botlish task gets 3 turns instead of 20,003 |
| a quiche timeout never rearmed | `=48` (with a lost Initial) | the handshake never completes; the watchdog reports it |
| a cancelled connection whose completion still arrives | `=384` | the late response lands in the exchange reusing the slot (299, not 200) |
| a slow consumer without effective backpressure | `=512` | 4 MiB buffered in Rust, RSS +4.8 MB |
| an invalid TLS peer certificate | `tls.bot` | wrong host, untrusted CA, expired: each refused with its own verify code |
| a second or incompatible BoringSSL | `-bssl embed`, `-bssl bundle`, another pin, a second declaration | run-time identity, link map, symbol table, API version, LINK-CONFLICT |
| a source that changes driver ownership | `reject_driver.bot` | CONTEXT-INSTALLATION-UNSUPPORTED |
| (also) a missing timer | `=64` under the deterministic driver | a 5 s virtual sleep never completes |
| (also) accidental Tokio runtime dependence | `tokioctl.bot` | Tokio panics without a runtime; contained |

**Defects found by the probes and fixed in the bridge** (each first
appeared as a stall or a crash): the missing kick from application calls;
one registration per handle shared by several waiters; the COMDAT group
discarded beside the Botlish runtime; a short-header packet parsed with
quiche's maximum CID length (every post-handshake packet dropped: a bug of
the census's endpoint, not an architectural one); the stale-clock and
zero-timeout timer conversions; the X509_V_ERR_INVALID_CALL mapping;
missing TCP_NODELAY on accepted sockets (drains crawled at the delayed-ACK
interval); `MutableArray` passed to two coroutines as shared state (a value:
each held a copy). And one in the census's own harness: its first full run
restored the environment with `array unset ::env`, which in Tcl deletes the
`env` array's link to the process environment, so the fault-injection
controls ran *without* their faults and failed as they should -- by
reporting the healthy behavior. `provider::WithEnv` restores only the
variables it set.

**Not tested here**: the event loop's own suites (`tests/event-loop.test`,
`tests/event-loop-linux.test`) and anything else in the repository were not
changed and not rerun; GC stress; other hosts.

## 17. Blockers and deficiencies

None blocks the architecture. Each is reproducible with the census's
tools.

* **B1. BoringSSL bundled twice into a Rust static library** (upstream
  packaging). `tools/build.tcl unit X -bssl bundle -localize 0`, then
  `ar t ~/.cache/botlish/http-stack/units/X/libhs_native.raw.a | grep -c
  '^sha256.cc.o$'`: 2. With `-localize 1`, `ld -r --whole-archive` fails
  with thousands of "multiple definition". Cause: boring-sys and quiche's
  build script both emit `rustc-link-lib=static=crypto`/`ssl`. Remedy
  used: link-only mode (empty archives at `BORING_BSSL_PATH`, headers at
  `BORING_BSSL_INCLUDE_PATH`). Upstream remedy: quiche should rely on
  boring-sys's link directives (or use `static:-bundle`).
* **B2. A second BoringSSL revision links and runs silently.**
  `tools/build.tcl unit otherpin -bssl pin:audit/http-stack/boringssl/PIN.repo-c-ffi
  -localize 0 -features {hyper tls quiche}`, `tools/build.tcl app otherpin
  otherpin`, `tools/build.tcl run otherpin combined`: "api 44 and 43 --
  DIFFERENT PROVIDERS" (equal addresses: the provider's code, the other
  revision's headers). Remedy: the provider check of section 14 as a build
  step.
* **B3. COMDAT collision of a localized Rust unit.** Remove the
  `--redefine-sym` of `tools/build.tcl` and link any probe: rust-lld:
  "relocation refers to a symbol in a discarded section:
  DW.ref.rust_eh_personality". The renaming fixes it; a Botlish native-link
  step for Rust units must do the same. Leaving the unit unlocalized is no
  way out: the same toolchain's standard-library symbols then coincide with
  the runtime's (the first `h1.bot` linked that way, silently sharing one
  copy and coupling the unit to the runtime's toolchain), and a unit with a
  `#[global_allocator]` of its own does not link at all -- rust-lld:
  "duplicate symbol: __rustc::__rust_dealloc", `__rust_realloc`,
  `__rust_alloc_zeroed` against the runtime's allocator shim (the census's
  counting allocator did this to the unlocalized bundled control, which is
  why that allocator is a feature only the measurement unit enables).
* **B4. A context-trait implementation takes exactly one context**
  (language). Any context trait whose implementation function declares a
  second context parameter: MISSING-CONTEXT ("an implementation takes
  exactly one"). The census's workaround: per-driver executor modules.
* **B5. The Linux driver package's watch interest is fixed at creation**
  (`event_loop_linux::watch`; `rearm` re-arms the same interest). A
  protocol whose write interest comes and goes needs unwatch + watch (two
  epoll_ctl calls; counted by `hsnet::count(2)`, zero in these probes
  because they arm read-or-write per descriptor). A `rearm` with an
  interest is a package API addition.
* **B6. quiche 0.30's default congestion control never paces** (upstream
  design): `get_packet_send_time` of `recovery/congestion/recovery.rs` is
  `now`. Use BBR2 gcongestion for pacing.
* **B7. boring-sys cannot consume a prefixed BoringSSL**, and the
  repository's C FFI acceptance builds one (`botlish_bssl`, 0.20260929.0).
  One provider for both needs either an unprefixed provider (and the C FFI
  bindings regenerated unprefixed at the new pin) or bindings for boring
  through `link_name`.
* **B8. No borrowed foreign bytes in Botlish** (language/runtime): body
  chunks are copied, and each `recv` allocates a fresh `MutableBytes`
  (`std::abi::bytes::zeroed`) on the Botlish side.
* **B9. No integer division in Botlish** (known): the first readiness API
  packed `fd * 8 + interest` and had to be split into two calls.
* **B10. `extern c fn` cannot be `nomethod`** (known,
  EVENT-LOOP-MILESTONE-1.md 15.3): every C call whose first argument is a
  converted Int is written with method syntax to satisfy METHOD-ELIGIBLE.
* **B11. A method-style call resolved to an invalid candidate**
  (incidental, compiler). With only `std::mutable_array` imported,
  `a.at(0)` on a `List[int]` parameter compiles and fails at run time on
  every backend ("std::mutable_array::at: expected mutarray, got [1, 2]");
  expected: a compile-time rejection. Reproduction:
  `audit/http-stack/repro/method-at-list.bot`. Not investigated further.
* **B12. One expensive synchronous operation blocks the loop.** Bounded
  executor runs do not bound a single call: the slowest Rust call measured
  5.0-7.6 ms (section 13), and an unrelated task was late by 5.3-8.1 ms. Key
  generation, certificate signing and similar work must run off the loop
  thread and complete through an endpoint, or be split.

## 18. Recommendation

After lexical resource cleanup, **the native Rust FFI and transport
foundation**, smallest form:

1. **The bridge, permanent.** `hs_bridge`'s contracts as a maintained Rust
   crate (bounded executor with snapshot runs, Botlish-clock timers,
   readiness registry, generation-checked handles, notices, the guard, the
   foreign-wake post, the kick) and its Botlish half as a package (`hs`,
   the per-driver executors). Its rules are this report's sections 8 and
   12; its tests are this census's probes and controls, ported.
2. **Scope-bound handles** from the lexical-cleanup milestone: release at
   scope end, with "start the release now, the executor finishes it" for
   graceful endings (section 11).
3. **The provider as an application decision.** A provider module the
   application installs (as it installs a driver), packages declaring
   requirements only; a build step that verifies the provider against its
   pin and refuses units compiled against another (sections 6, 14);
   converge the repository's two BoringSSL conventions (B7).
4. **Rust units in the native link plan**: localization with COMDAT
   renaming (B3) as a Botlish build step, or a rule of one Rust unit per
   executable, decided with the native-library work.
5. **Two small API additions**: `rearm` with an interest in the Linux
   driver package (B5); socket creation behind a transport context
   (section 9).
6. **Expensive operations off the loop thread** (B12): key generation and
   similar work as bridge tasks that complete on a worker thread through
   the integration ABI, so that bounded runs bound the loop.
7. **The context-trait question** (B4): whether an implementation may
   require further contexts, decided as a language question; the bridge
   does not need it.

Then **HTTP/1.1 and HTTP/2 with TLS** on Hyper as the first production
protocol milestone (client and server, the trust-store policy, graceful
shutdown), **HTTP/3** on quiche after it (multi-connection endpoints,
retry and version negotiation, socket send retry, BBR2 tuning), and
**explicit Tokio interoperability** (section 15) last. No step needs a
second scheduler.
