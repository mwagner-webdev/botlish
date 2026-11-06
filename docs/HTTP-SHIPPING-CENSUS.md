# HTTP-SHIPPING-CENSUS.md

What it would take to make Botlish's HTTP/1.1, HTTP/2 and HTTP/3 code an
official part of the standard library and of the single-file compiler: a
census. Nothing is implemented here, and no file outside `docs/` changed.

The code in question is HTTP-STACK-INTEGRATION-CENSUS.md's
(`audit/http-stack/`): Hyper and core quiche over one pinned BoringSSL,
driven by `std::event_loop` and the Linux driver package through a Rust
*bridge*. That census asked whether the architecture is viable and answered
yes, with 50 checked claims. This one asks what separates that code from
something the project ships, and where the project's own rules put it.

Evidence labels:

* **observed**: read in this checkout at the cited place, or printed by a
  command run for this census (section 11 lists them);
* **cited**: a demonstrated claim of another report, named;
* **inferred**: follows from documented rules or code read here, not
  exercised;
* **projected**: a design consequence, not built.

**Status (HTTP-CLIENT-PACKAGE-MILESTONE-1.md).** Since this census, the
package route (section 6) has been built for HTTP/1.1 and HTTP/2 with TLS
on Linux x86-64: the packages `boringssl` (the provider) and `http` (the
client), their release recipes, a test suite against independent peers, a
mutation harness and a clean-room consumer with the single-file compiler.
Section 4 records each open item's state after it; section 10's work plan
marks what is done, deferred or still blocking. The rest of this document
is the census as it was written.

## Contents

1. Answer
2. What exists
3. From probes to a library
4. The integration census's open items, today
5. The standard-library route
6. The package route
7. The single executable
8. Cross-cutting requirements
9. Decisions the project has to make
10. Work plan
11. Method and limits

## 1. Answer

**What exists is an integration proof, not a client/server library.** The
protocol engines underneath are production libraries (Hyper 1.12.0, quiche
0.30.0, BoringSSL 0.20261020.0), and the census proved that Botlish can
drive them on its own event loop. The Botlish-facing layer the census built
is deliberately a probe surface (`audit/http-stack/README.md`: "Probes and
evidence, not a production HTTP stack"). Observed in its code (section 3):
sockets reach `127.0.0.1` only and are named by port; the HTTPS client's
only trust anchor is a CA the process generates at start, so it cannot
verify any certificate on the internet; requests carry a method and a path
and nothing else (the `Host` header is fixed to `localhost`), responses a
status and nothing else; handles are bare integers; a third of the C ABI is
fault injection, fixtures and counters; and the bridge reads a
fault-injection environment variable when it opens.

**Neither destination can take it as it is, and they are blocked by
different rules.**

* **The standard library** (`std::...`) cannot hold the protocol engines
  under three rules in force today (section 5): a standard-library module's
  native archive cannot resolve (NATIVE-LINK-PLAN-MILESTONE-1.md, section
  8: `base ""`, "never the compiler's own files"); a standard-library module
  cannot import a package, and the Linux event-loop driver the engines need
  is a package; and the driver-neutral form that would avoid naming the
  package is the census's language gap B4 (a context-trait implementation
  takes exactly one context), still open (`hir/contexts.tcl:298`). What
  *can* be standard library is the pure-Botlish vocabulary: methods,
  statuses, header and URI validation, request and response types, errors.
* **The single executable** packs exactly what `single/package.tcl`'s
  `StageCompiler` stages (`stdlib/` among it) plus three native files
  (section 7). Anything added to `stdlib/` in pure Botlish ships in it, and
  in Botlish.app, with no further work. Native code does not, by the same
  link-plan rule.

**The route that breaks the fewest rules is a set of official packages**
(the `event_loop_linux` and `raven` precedent: built on the author's side,
released as `.botpkg`, recorded in `packages/RELEASES.tsv`), published next
to the single executable. Even that route meets one structural gap (section
6.2, inferred): an HTTP *library* package must name the application's
event-loop driver, and packages cannot share an instance of another
package: BOT-MODULES-MILESTONE-1.md calls that a *peer* arrangement,
"which the language does not express yet". One of three changes closes it:
peer dependencies, a driver-neutral readiness capability in `std` (B4), or
the Linux driver itself in `std`.

So what it takes is four bodies of work (section 10): productizing the
bridge and its API (section 3, the largest), the structural decisions of
section 9 (D1-D3), a Rust build path in the package-author image (section
6.3), and the repository's admission bar for a shipped facility (tests,
GC stress, mutants, CI, documentation: section 8).

## 2. What exists

Observed (line counts by `wc -l` over `audit/http-stack/`):

| part | lines | what it is |
|---|---:|---|
| Rust, `bridge/` (`hs_bridge`) | 1,186 | the bounded executor, Botlish-clock timers, readiness registry, generation-checked handles, notices, panic guard, foreign-wake post, kick |
| Rust, `hyper/` (`hs_hyper`) | 1,236 | Hyper's runtime traits over the bridge, fd and in-memory streams, exchanges, chunked bodies |
| Rust, `tls/` (`hs_tls`) | 476 | nonblocking BoringSSL through `boring`, ALPN, the in-process test PKI |
| Rust, `quiche/` (`hs_quiche`) | 973 | QUIC endpoints over Botlish-watched UDP, HTTP/3 exchanges, pacing, timers |
| Rust, `integration/` (`hs_native`) | 881 | the one linking unit: 73 `hs_*` C functions, fixtures (245), a counting allocator (45) |
| C | 130 | the foreign-wake shim (`notify.c`), the crypto airlock (`hscrypto.c`) |
| Botlish, library-like modules | ~1,080 | `hs`, `hsnet`, `hsmem`, `hsh`, `hsq`, `hstls`, `bssl`, `crypto` |
| Botlish, probes and controls | ~1,850 | `h1`, `h2`, `h3`, `tls`, `sched`, `lifetimes`, `combined`, `measure`, ... |
| Tcl tools | 929 | provider fetch and build, unit and application builds, the single-link check, `check.tcl` |

The Rust code has 46 occurrences of `unsafe` (observed, `grep -c`).

**The dependency graph** (observed: `cargo metadata --locked` on the
census's workspace, Linux targets, the unit's default features): 89
packages in `Cargo.lock`; 53 in the unit's normal dependency closure (5 of
them the workspace's own crates), 22 more needed only to build (bindgen,
clang-sys, cmake, cc, regex and their dependencies). Tokio is in the
closure with features `bytes default io-util sync` only: no runtime
(agreeing with the census's `tokio-features` claim). Licenses in the
closure: dual MIT/Apache-2.0 for most, MIT for 15, BSD-2-Clause for quiche
and octets, Apache-2.0 for boring, Unicode-3.0 additionally for
unicode-ident; BoringSSL's own top-level `LICENSE` at the vendored revision
is Apache-2.0 (observed in boring-sys 5.4.0's `deps/boringssl`). Nothing in
the closure is copyleft; shipping binaries still means shipping notices
(section 8.7).

**What was demonstrated** (cited, HTTP-STACK-INTEGRATION-CENSUS.md
sections 3-13, Linux x86-64 only): HTTP/1.1 and HTTP/2 client and server on
Hyper without a Tokio runtime; HTTP/3 on quiche with loss recovery, idle
timeout and pacing on Botlish timers; TLS with real chain, host-name,
expiry and ALPN checks; streaming backpressure reaching the protocols' flow
control; one BoringSSL shared by a C crypto airlock, boring and quiche in
one link; bounded executor runs; generation-checked release; the
deterministic driver for Hyper. Never run: GC stress, Linux AArch64, any
other host.

## 3. From probes to a library

What a user of an official HTTP facility would expect, against what the
probes have. Every "probe" cell is observed in the cited file.

### 3.1 Transport and addressing

| need | probe | what it takes |
|---|---|---|
| connect to a host name | none: `hs_tcp_connect(port)` (`integration/src/fixtures.rs` `socket`) connects to `127.0.0.1:PORT`, IPv4, no name | name resolution (`getaddrinfo` blocks: it belongs off the loop thread, B12), IPv4 and IPv6, address types in Botlish, connect timeouts |
| listen on an address | `hs_tcp_listen(port)` binds `127.0.0.1` with `SO_REUSEADDR`, backlog 128 | bind address, port 0 and its report (exists: `hs_local_port`), listen options |
| UDP for QUIC | `hs_udp_bind(port)`, `127.0.0.1` | the same, plus the census's untested items: several connections per socket, send retry on `EAGAIN` (a packet quiche counted as sent is dropped today), GSO/GRO and ECN optional |
| authority to open sockets | none: any module that can name `hs_tcp_connect` opens sockets, with no context | a transport context the application makes (census section 9, "What is not yet an airlock"); section 8.1 |

### 3.2 HTTP semantics

| need | probe | what it takes |
|---|---|---|
| request headers | none crossing to Botlish: `hs_h_request(method, path, streaming)`; Rust adds `host: localhost` (`hyper/src/lib.rs:383`); HTTP/3 sends `:authority localhost`, `:scheme https` (`quiche/src/lib.rs:658`) | a header list in both directions, its validation (names, values, pseudo-headers, connection-specific headers forbidden in h2/h3), size limits |
| response headers | none: `hs_h_respond(handle, status, streaming)`; HTTP/3 sends `:status` only (`quiche/src/lib.rs:917`) | as above |
| URIs | a path string; the authority is fixed | scheme, authority, path and query as data; for URIs `std::web` has only `uri_query_value?` and escaping today |
| bodies | chunks; the Botlish side returns `Chunk {n, text: str}` (`hsh.bot`, `hsq.bot`) | bytes (`std::abi::bytes::Bytes`), not text; content length known or not; trailers (h2, h3) |
| errors | negative integers (`-90001` panic, `-90008` cancelled, `-91000 - x509` verify, ...) | declared errors with payloads (ERROR-PAYLOADS.md): the reason, the verify code, the protocol error code |
| limits | Hyper's and quiche's defaults; `hs_h_configure(window, keepalive)`, `hs_q_configure(idle, pacing)` | header size, concurrent streams, body and idle timeouts, as configuration the application owns |

Client conveniences Hyper and quiche do not provide and the probes do not
either: connection pooling and reuse across requests by origin, redirects,
proxies, cookies, content decoding, Alt-Svc discovery (how a client learns
it may use HTTP/3). Which of these an official facility includes is a scope
decision (D7); a minimal one can leave all of them to the application.

### 3.3 TLS

| need | probe | what it takes |
|---|---|---|
| client trust | `hs_tls_client(host, alpn)` trusts the census's test CA only (`tls/src/lib.rs:182`, `trust_store`): no system trust store | the platform's anchors as a policy of the TLS configuration (Linux: a CA bundle file; census section 7, "Projected"); explicit extra anchors; never an option to skip verification (keep the probes' rule) |
| server identity | `hs_tls_server(cert, alpn)`: `cert` selects one of four certificates the process generates (good, wrong host, expired, untrusted) | certificate chain and private key supplied by the application; how key bytes reach BoringSSL without a Botlish secret type (a path read in Rust is ambient file authority; bytes through `MutableBytes` are ordinary values) is a design question |
| session resumption, client certificates, OCSP, SNI on the server | none | scope decision (D7) |

### 3.4 Lifetimes, errors and the C ABI

* **Handles are integers** (`generation << 32 | index`), released by
  `hs::release(handle)`. The census wrote its requirements for lexical
  cleanup (section 11 there); the mechanism is in the language now
  (LEXICAL-RESOURCE-CLEANUP-EXPLORATION-MILESTONE-1.md: `opaque resource
  struct`, `cleanup fn`, release at scope end and on every exit, unwinding
  on coroutine abandonment), and `std::event_loop`'s `Owner` is the
  precedent (`stdlib/event_loop.bot:186`, `cleanup fn release` at 1092).
  A cleanup function declares no errors and never yields (AGENTS.md,
  "Resources"), so graceful endings (TLS close_notify, HTTP/2 GOAWAY, QUIC
  CONNECTION_CLOSE and draining) must be *started* by the cleanup and
  finished by the executor in later turns, as the census's requirement 3
  says. Not built: the resource types, the detach-to-executor release, and
  a test that an abandoned coroutine holding a connection releases it.
* **Test-only exports.** 24 of the unit's 73 C functions exist for
  measurement, fault injection or fixtures (`hs_fx_*`, `hs_set_fault`,
  `hs_fault`, `hs_has_fault`, `hs_fixture_result`, `hs_allocs`,
  `hs_rss_kb`, `hs_stat`, `hs_stats_reset`, `hs_h_stat`, `hs_q_stat`,
  `hs_h_objects`, `hs_tasks`, `hs_tls_outcome`, `hs_sock_buffers`, the
  three `hs_bssl_*` identity probes); the socket and certificate exports are
  fixtures too. The unit's *default* features include `count-alloc`, the
  measuring global allocator (`integration/Cargo.toml`). And the bridge
  reads `HS_CENSUS_FAULT` from the environment when it opens
  (`integration/src/lib.rs:46`): a shipped library must not change behavior
  by an environment variable. A product build needs these behind a test
  feature (a separate unit for tests, as the census already builds for its
  controls).
* **Copies.** Each `recv` allocates a fresh `MutableBytes` on the Botlish
  side (B8). Acceptable for a first release; a borrowed-bytes facility is a
  language milestone of its own.
* **Per-call overhead**: 66-87 C calls per exchange and 20 per streamed
  chunk (cited, census section 13); the census names the batching that
  would remove most of the executor step's calls.

## 4. The integration census's open items, today

Status read in this checkout (observed unless marked); the last column is
the state after HTTP-CLIENT-PACKAGE-MILESTONE-1.md (its section
"Census items"):

| item | then | at this census | after the HTTP client milestone |
|---|---|---|---|
| B1 BoringSSL bundled twice by boring-sys and quiche | upstream; remedy: link-only build | open; a release recipe must use link-only mode | **implemented**: the http unit builds boring-sys link-only against empty archives and defines no BoringSSL symbol (`http-unit-exports`); quiche is not shipped |
| B2 another BoringSSL revision links and runs silently | needs a provider check as a build step | open: the package manager's checks would not catch a unit *compiled* against another revision's headers | **implemented**: the unit references `botlish_boringssl_<tag>_<commit>`, defined only by the provider package's archive: another provider fails the link (`http-provider-identity`, the `provider-mismatch` mutant); the graph refuses another boringssl release (clean room) |
| B3 COMDAT collision of a localized Rust unit | rename `DW.ref.rust_eh_personality` | open; an author-side recipe step | **implemented** in `tools/http-package.tcl` (the unit's COMDAT group renamed after localization) |
| B4 a context-trait implementation takes exactly one context | language | open (`hir/contexts.tcl:298`) | **not needed**: shared dependencies (D1) gave libraries the application's driver; unchanged |
| B5 the Linux driver's watch interest is fixed at creation | package API | open | **worked around** in the http package (another interest is an unwatch and a new watch, counted as `rewatches`); the driver's API unchanged (deferred: a new driver release) |
| B6 quiche's default congestion control never paces | upstream | open | **deferred** with HTTP/3 |
| B7 two BoringSSL conventions | converge | open | **converged for shipping**: the provider package is the unprefixed 0.20261020.0 boring consumes; `tests/cffi/boringssl.tcl`'s prefixed 0.20260929.0 remains a test fixture of the C FFI (deferred) |
| B8 no borrowed foreign bytes | language | open | **not needed** (excluded by the milestone): a read copies one chunk into Botlish storage through the C FFI's write exposure, at most one chunk held natively |
| B9 no integer division | known | open | **still absent**; worked around in the module and its tests |
| B10 `extern c fn` cannot be `nomethod` | known | open | **unchanged**; the externs are `private`, so no method-style call reaches them from a consumer |
| B11 a method call resolved to an invalid candidate | compiler | fixed | fixed |
| B12 one expensive synchronous call blocks the loop | bridge | open | **implemented for name resolution** (a bounded getaddrinfo pool that answers by a foreign wake); TLS handshakes and verification still run on the loop's thread (measured: the report's "Measurements") |
| recommendation 2: scope-bound handles | after lexical cleanup | the HTTP part is not built | **implemented**: clients and exchanges are resources (`ClientOwner`, `ExchangeOwner`) |

## 5. The standard-library route

"Officially of the standard library" means a module under `std::` in
`stdlib/`, loaded from the compiler's own library directory, packed into
both distributions by `StageCompiler`, documented by Compilerpedia's
generated topic, held to the warning gate and the stdlib census.

### 5.1 What blocks the protocol engines there

1. **No native archive of a standard-library module can resolve.**
   NATIVE-LINK-PLAN-MILESTONE-1.md, section 8: "a standard-library
   module's declaration gets no root (`base ""`), so a relative path there
   cannot resolve -- ... nothing resolves against the single executable's
   ZIP or Botlish.app's Resources". The only link declarations in
   `stdlib/` today are system import libraries (`extern c library
   "kernel32"`, `stdlib/windows.bot:66`, `stdlib/windows/fs.bot:134`).
   Hyper, quiche and BoringSSL are not system libraries.
2. **The engines need the Linux driver, which is a package.** The
   census's executor (`hsnet.bot`) needs `event_loop_linux::Native` to arm
   readiness watches. A standard-library module's imports never see the
   application or its packages (STD-NAMESPACE.md; AGENTS.md, "Application
   modules"), so `std::http` cannot name it.
3. **The driver-neutral way around 2 is B4.** The census tried writing the
   executor once over a context trait with a Linux and a deterministic
   implementation; the Linux implementation needs `Loop` and `Native`
   besides its own context, which an implementation may not declare. A
   standard `Readiness` context trait implemented by the package is the
   shape `std::event_loop::Driver` already has (implemented by
   `event_loop_linux::Linux`); it works for `Driver` because a driver's
   operations need only the driver.

### 5.2 Ways through 1, and what each costs

| option | mechanism | cost and conflicts |
|---|---|---|
| S1. a standard native root | the compiler ships the HTTP unit and the provider's archives (the checkout: a build directory; the single executable: unpacked to its cache as `libbotlish_runtime.a` already is; Botlish.app: Resources) and gives standard-library modules a root for `static at` | reverses an explicit rule; every `native/` build (each developer, each CI job) builds or fetches BoringSSL (75 s with CMake, cited) and the Rust unit, or the checkout's stdlib depends on a separately built artifact; the compiler, not the application, chooses the BoringSSL every HTTP program links -- the census's recommendation 3 is the opposite; an application with its own unprefixed BoringSSL then conflicts (LINK-CONFLICT or duplicate symbols); the archives are per target, so each distribution carries its targets' (31 MB unstripped for the unit alone on x86-64, cited; compressed size not measured) |
| S2. fold the engines into the runtime archive | `native/` gains hyper, quiche, boring; every linker's startup links them | rejected: AGENTS.md's event-loop rules ("No compiler, runtime or Tcl knowledge of the event loop ... native handles stay in a driver or its adapter"); the stub (`botlish-aot-stub`, a prebuilt executable) would carry all of it in every stub-linked program; the runtime's build gains bindgen, libclang and CMake. The one thing it would remove is B3 (no second Rust standard library) |
| S3. vocabulary in std, engines in a package | `std::http` is pure Botlish; the package implements it | needs a way for the package's implementation to reach the driver: B4 lifted, or peer dependencies (6.2), or the driver in std (next) |
| S4. the Linux driver in std | rewrite `event_loop_linux`'s C adapter (epoll, eventfd, rings) as Botlish over `std::linux::sys`'s syscall transports | removes blocker 2 without a native archive; the integration ABI native libraries post through (`botlish_event_post`, used by the bridge's foreign-wake path) is C today and would need a syscall-level replacement (a native library writing an eventfd the driver watches); EVENT-LOOP-MILESTONE-1.md's adapter guarantees (record rings, holds, round-robin) would be re-established in Botlish; projected, not assessed further |

### 5.3 What can be standard library today, unblocked

Pure Botlish, every backend, in both distributions with no packing work
(projected):

* `Method` and status as enums or refined Ints; header names and values as
  refinements with `proves` validators (REFINEMENT-VALUES.md) -- token
  characters, no CR/LF/NUL, h2/h3's lowercase rule, the forbidden
  connection-specific headers;
* URI parsing into scheme, authority, path and query, beside `std::web`;
* `Request`, `Response` and header-list types, and the declared errors;
* the API as context traits, if B4 or a peer arrangement lets a package
  implement them.

Admission costs for any new standard module (observed from the repository's
rules and the comparable milestones, `std::event_loop` and `std::actor`): a
milestone report in `docs/` with its INDEX line; an AGENTS.md section ("Keep
it so" and "What to run"); a test file run on both Tcl passes and directly
on the native backends; a golden suite with its fragment, census rows and
manifest regeneration; the warning gate (stdlib modules compile clean or are
manifested with an obstruction); `tools/compilerpedia.tcl generate` and
`check`; `audit/stdlib-census/after.tsv` regenerated; a mutation harness
with `mutants.txt`; where an independent model exists, a fuzzer.

**Platform placement** must be decided: platforms are designated by
namespace (`core/cabi.tcl`'s `platforms`: `linux`, `darwin`, `windows`).
A Linux-only engine under a portable `std::http` would compile for macOS and
Windows and fail at the link; under `std::linux::http` it is
UNSUPPORTED-PLATFORM elsewhere, honestly, and a later portable API moves.

## 6. The package route

"Official" here means: in `packages/`, built by
`tools/package-repository.tcl` (`author::NAME`) in the pinned author image
(`tools/package-build/`), released once per version and recorded in
`packages/RELEASES.tsv`, tested in CI. Precedents: `event_loop_linux`
(a C adapter built per target), `raven` (a C++ library built with CMake per
target, a C bridge archive, license notices packed), `sdl3`/`sdlkit`.

### 6.1 What fits without change

Observed in PACKAGE-MANAGER-MILESTONE-1/2/3.md and the package manager's
rules:

* Prebuilt per-target archives, imported with `native add`, linked by the
  consumer with nothing compiled on its side: the consumer needs no cargo,
  no CMake, no network. Linux x86-64 and AArch64 targets are supported;
  other targets are UNSUPPORTED from the package's own metadata.
* The localized unit (author-side `ld -r`, `objcopy --keep-global-symbols`,
  COMDAT renaming: B3) is an ordinary static archive to the consumer.
* `libstdc++` (libssl.a is C++) declared as a system library with `native
  require`, verified by the distribution's metadata on its own host.
* The audit refuses two static archives defining one symbol, and "one
  library, the same bytes from two instances" is one library
  (PACKAGE-MANAGER-MILESTONE-2.md's conflict table): identical provider
  archives bundled by two packages unify; different pins are refused, never
  mixed silently -- the census's B2 hazard at the package level, except a
  unit compiled against other headers (section 4, B2).
* Provenance records, reproducibility across two runners
  (`package-reproducibility.yml`), checked documentation (raven's README
  and GUIDE blocks compiled by a test).

### 6.2 The structural gap: the driver is a peer dependency

*Closed by SHARED-PACKAGE-DEPENDENCIES-MILESTONE-1.md* (D1, option (a),
without peer declarations): the gap below was confirmed by a two-package
reproducer (that report's section 2: LINK-CONFLICT for the driver's
archive, and MISSING-CONTEXT of `lib_a/drv::Native` and `lib_b/drv::Native`
for an application installing its own `drv::Native`). An application now
has one dependency graph: an HTTP package and any other library that
declare and lock `event_loop_linux` share its one instance, whose `Native`
is the type the application installs, and whose archive is one link
declaration; locks that disagree are a DEPENDENCY-CONFLICT. Point 4's
workaround (the HTTP package re-exporting the driver) is unnecessary. The
BoringSSL provider of the last paragraph is the same shape and is closed
the same way: a provider package two packages lock at one release is one
instance. The text below is the census as it was.

Inferred from documented rules; not executed.

1. The HTTP package's Linux executor needs `event_loop_linux::Native` as a
   context. A package imports only `std`, its own namespace and the
   packages installed under its own `.bot_modules`
   (BOT-MODULES-MILESTONE-1.md: downward only), so it must install
   `event_loop_linux` as its own dependency: the instance
   `http/event_loop_linux`.
2. Only the entry program installs contexts (EVENT-LOOP-MILESTONE-1.md;
   the census's `reject_driver.bot`: CONTEXT-INSTALLATION-UNSUPPORTED), and
   it cannot spell a nested instance (`http/event_loop_linux::Native`,
   "which no source can spell").
3. If the application imports `event_loop_linux` itself, its instance's
   `Native` is a different type from the HTTP package's ("No sharing of
   instances", BOT-MODULES-MILESTONE-1.md): the package's requirement is
   unmet (MISSING-CONTEXT). Both instances also declare the library
   `event_loop_linux` `static at` an archive inside their own directories:
   two archives for one library, which the link plan's merge rule refuses
   (LINK-CONFLICT, the rule the census's `control-second-provider-declared`
   exercised for `crypto`).
4. What compiles today: the application never imports `event_loop_linux`
   and installs the driver through functions the HTTP package re-exports
   (`http::driver()`, `http::native()`). Then the HTTP package owns the
   driver choice, and a second library that also needs `Native` cannot
   exist in the same program.

The same shape applies to the BoringSSL provider (census recommendation 3:
the provider is the application's decision): a package can declare
`extern c library "crypto" static` without a path and let a bundled archive
in the target view satisfy it, but it cannot name a provider *module* the
application chose. Section 9 (D1) lists the three ways to close the gap.

### 6.3 Building it: Rust in the author image

Observed: the author image (`tools/package-build/Dockerfile`) installs
gcc, clang, cmake, ninja, the AArch64 GNU cross toolchain and Tcl 9 from a
pinned Ubuntu snapshot, and **no Rust toolchain**. What a release recipe
needs that no recipe has today (projected from the census's
`tools/build.tcl` and `provider.tcl`):

* a pinned rustc and cargo (the census used 1.97.0), installed by digest
  like the image's other inputs, with the `aarch64-unknown-linux-gnu`
  target;
* the crates offline: `cargo vendor` of the locked graph (75 packages incl.
  build-only), committed or fetched by checksum, so the image's build needs
  no registry;
* libclang for bindgen (boring-sys's build script);
* the provider: BoringSSL at its pin, fetched and checked by tag object and
  commit (the census's `PIN`), built per target with CMake, its archives'
  digests recorded;
* the unit in link-only mode (B1), localized with the COMDAT rename (B3),
  the API-version identity check (B2) as a refusal;
* **byte-identical rebuilds**: one version is one artifact, and the
  reproducibility workflow compares two runners. Rust and CMake builds are
  not reproducible by default (paths in debug and panic strings, `ar`
  timestamps, codegen-unit partitioning); the census did not attempt it
  ("Not done: bit-for-bit reproduction"). `--remap-path-prefix`,
  deterministic archives, a fixed target directory and stripping are the
  known levers; whether they suffice for boring-sys's CMake build is
  unknown.

### 6.4 Package shape

Projected; one option among several:

| package | holds | notes |
|---|---|---|
| `boringssl` (provider) | `libcrypto.a`, `libssl.a` per target, headers, PROVENANCE, Apache-2.0 notices | bundled without a path so identical bytes unify; **link names distinct from OpenSSL's**: a requirement for `crypto` that the bundle does not satisfy is searched in the default library directories next, and on a host with OpenSSL's development package that finds OpenSSL (observed here: `/usr/lib/x86_64-linux-gnu/libcrypto.a` belongs to `libssl-dev`). Renaming the archives (`libbotlish_boringssl_crypto.a`) is independent of symbol prefixing, which boring-sys cannot consume (B7) |
| `http` (engine and API) | the localized unit per target, the Botlish modules, `README.md`/`GUIDE.md` with checked examples, license notices for every crate | depends on the provider and the driver: section 6.2's gap |

HTTP/3 could ship as a feature of the same unit or a second unit; the
census found one unit simpler (one executor, one private Rust standard
library) and warned that two units double both.

## 7. The single executable

### 7.1 What it holds

Observed (`single/package.tcl`, SINGLE-EXECUTABLE.md): `main.tcl`,
`LICENSE`, `core/`, `compiler/`, `hir/`, `surface/`, `service/`, `lsp/`,
`pm/`, `stdlib/`, `native/*.tcl`, Compilerpedia's engine, topics and
generated reference, a `BUILD` file; and the native files `botlish-native`,
`botlish-aot-stub`, `libbotlish_runtime.a` (the last unpacked to a cache
directory only for runs that may link). About 13.7 MB (cited). Botlish.app
stages the same tree (`StageCompiler`, one procedure).

### 7.2 What "part of the single executable" can mean

| option | what changes | what does not |
|---|---|---|
| E1. pure-Botlish `std` modules | nothing: `stdlib/` is packed whole | only the vocabulary of 5.3 |
| E2. a release asset beside it | CI builds the packages and publishes `http-X.Y.Z.botpkg` (and the provider's) next to `single-latest`'s `botlish-linux-x86_64`; users run `botlish add http -repository DIR` with the packed `pm` (`single/smoke-test.sh` already runs `add`, `native add` and `package inspect` through the single executable) | no compiler or package-manager rule changes; the package's version is its own, the executable's tag rolls |
| E3. a repository inside it | `.botpkg` files packed into the ZIP and installable with no download | the package manager's rule "Repositories are named on the command line only: never search a parent, the working directory, a global directory or the environment" needs a decision: an explicitly named built-in repository (`-repository builtin`) keeps "named", any implicit one breaks it; the executable grows by the artifacts (not measured); a compiler build then also needs the package builds (Rust, CMake) |
| E4. compiler-shipped native code | option S1 or S2 of 5.2 | reverses the link-plan rule |

### 7.3 What a user of the single executable needs to build an HTTP program

Whichever option, an HTTP program calls C, so (observed rules, inferred
consequences):

* The `auto` linker uses the system linker for a program that calls C; the
  stub refuses any link plan. The host needs `cc` (the single executable's
  existing FFI requirement) **and the C++ standard library's link name**
  for libssl.a: on Ubuntu 24.04 `libstdc++.so` comes from
  `libstdc++-13-dev`, which `g++` pulls in and `gcc-13` does not (observed:
  `dpkg -S`, `apt-cache depends`). A host with only `gcc` would fail the
  link. The package's `native require stdc++` verifies it on the host and
  names the distribution package.
* A native-backend *run* of a program that calls C is a link plus a run
  (`run_linked`): the census measured about 40 s to compile and link a
  probe against the 31 MB unit (cited). Every edit-run cycle pays it; the
  Tcl backends refuse C calls (`NATIVE-ONLY`), so there is no faster path.
* Executables are large: ~45 MB unstripped for a probe (cited); stripped
  and release sizes were not measured.
* Linux x86-64 only for the single executable itself; Linux AArch64 is a
  package target but the HTTP stack never ran there; Botlish.app (macOS) and
  Windows have no event-loop driver and so no HTTP (UNSUPPORTED, section 8.6).

## 8. Cross-cutting requirements

Whichever route, a shipped HTTP facility needs these (projected unless
marked).

### 8.1 Authority

Socket creation, name resolution and certificate loading behind contexts
the application makes, as `Native` is made from the installed driver
(census section 9). Note the gap the direct-module rule leaves: an `extern c
fn` that opens a socket and takes only integers is not a retaining call, so
calling it is no direct edge (DIRECT-MODULES.md counts retaining calls and
calls of designated modules); the probe modules are not `direct module`
and need not be (observed: no probe module carries the marker). The
authority boundary is therefore the binding module's discipline: every
socket-making C function `private`, reached only through operations that
require the transport context (MODULE-PRIVACY-AND-CONTEXT-ESCAPE-
MILESTONE-1.md's tools; the Icy Tower `sdl.bot` arrangement is the
precedent), checked by a test as `workload-icy-tower-sdl-airlock` does.

### 8.2 Scheduling

* B12: an off-loop worker in the bridge for name resolution, key
  generation and certificate parsing, completing through the integration
  ABI's foreign-wake path, so bounded runs bound the loop.
* B5: `rearm` with an interest in the Linux driver package (a new package
  version), or the census's unwatch-and-watch.
* Multi-core servers: one Botlish VM per thread is the thread/actor
  census's model (THREAD-ACTOR-ARCHITECTURE-CENSUS.md; isolated threads
  are not shipped). A first release is single-threaded per process.

### 8.3 Testing

* Port `check.tcl`'s 50 claims and their negative controls into test files
  that build the packages once (the `tests/cffi/sdl3.tcl` and `raven.tcl`
  pattern: skipped without the build), with host-capability constraints
  (`nativeLinux`), and the fault injection in a test-only unit (3.4).
* GC stress (`BOTLISH_NATIVE_GC_STRESS=1`), never run on this stack. The
  bridge holds no Botlish values, but every exposure and write-back crosses
  the collector's safepoints.
* Linux AArch64 runs (tests-arm64.yml), never done.
* Interoperability against independent peers (`curl` for HTTP/1.1 and
  HTTP/2; Ubuntu 24.04's `curl` 8.5.0 lists HTTP2 and no HTTP3 among its
  features, observed, so an HTTP/3 peer needs another client) and
  conformance suites (h2spec-style) if the scope claims them.
* A mutation harness (`audit/http/tools/mutate.tcl` with `mutants.txt`)
  over the bridge's rules: the census's fault bits are its first mutants.
* Fuzzing the C boundary (handle lifetimes, notice order, chunk sizes);
  the census did not fuzz it.
* CI cost: the census's full check took about 45-50 minutes on a 4-core
  container (cited), most of it builds; the provider build alone 75 s. A
  CI job needs caching of the provider and the unit keyed by their pins.

### 8.4 Errors and diagnostics

Declared errors with payloads in place of negative codes; each new
diagnostic kind (if any compiler support is added) classified in
`tests/static-compile.test`'s census and given a Compilerpedia topic.

### 8.5 Security and maintenance

* The provider pin is a maintenance commitment: BoringSSL has no release
  signatures (cited, census section 5), so the pin (tag object and commit)
  is the authority; each security update is a new provider version, a
  rebuilt unit and a new `http` version (RELEASES.tsv never changes a
  version).
* `boring`, `quiche`, `hyper` and `h2` updates are coupled: boring-sys
  vendors one BoringSSL revision, and quiche requires a boring version.
* The Rust bridge's `unsafe` code (46 occurrences) and the C ABI's pointer
  and length pairs need review before shipping; the census's own text:
  the airlocks' guarantees are "only as good as the foreign boundaries'
  implementations (the census's ... were not fuzzed)".
* `panic = "unwind"` must stay (every export catches panics).

### 8.6 Platforms

| target | protocol engines | event-loop driver | status for HTTP |
|---|---|---|---|
| Linux x86-64 | run (cited) | `event_loop_linux` | the only executed target |
| Linux AArch64 | supported upstream (cited projection) | `event_loop_linux` (built for it) | never run |
| macOS AArch64 | supported upstream | none (kqueue) | blocked on a driver; COFF/Mach-O localization tools differ (no `objcopy`) |
| Windows x86-64 | supported upstream | none (IOCP posts completions: the readiness registry needs a completion form) | blocked on a driver |

### 8.7 Licenses

Every crate's notice and BoringSSL's Apache-2.0 license travel with the
binaries (the precedent: the raven recipe packs Raven's notices as
`licenses/raven/`, `tools/package-repository.tcl`); the workspace's own
crates carry no license field today. Generating the notice set from
`cargo metadata` is mechanical (section 2 did the census of it).

## 9. Decisions the project has to make

| | decision | options | depends on it |
|---|---|---|---|
| D1 | how a library reaches the application's driver | (a) peer/shared dependencies in the package model and the language; (b) lift B4 so a `std` readiness context trait can be implemented with `Loop` and `Native`; (c) the Linux driver in `std` over syscalls (S4). **Decided and built: (a), as shared dependencies without peer declarations** (SHARED-PACKAGE-DEPENDENCIES-MILESTONE-1.md); B4 untouched | any reusable HTTP library, package or std |
| D2 | where the engines live | package (recommended: no rule reversed); std native root (S1); runtime (S2, rejected) | everything after |
| D3 | what "in the single executable" means | E1 + E2 (recommended); E3 with an explicitly named built-in repository; E4 | distribution work only |
| D4 | the BoringSSL convention | converge on one pin; unprefixed (what boring needs) with distinct archive names, the C FFI's acceptance rebuilt on it; or keep two providers with disjoint link names and symbols | provider package, B7 |
| D5 | Rust in the release pipeline | a pinned toolchain and vendored crates in the author image; the reproducibility bar applied or relaxed for Rust artifacts | 6.3 |
| D6 | the API's shape | integer handles behind resource types (minimum); request/response values, header lists, byte bodies; how much is `std` vocabulary | 3, 5.3 |
| D7 | scope of a first release | HTTP/1.1 and HTTP/2 with TLS first (the census's order), HTTP/3 later; which client conveniences (3.2), which TLS features (3.3) | effort |

## 10. Work plan

Ordered by dependency; sizes relative (S: days of focused work, M: a
milestone like the ones in `docs/`, L: several). Projected.

| # | work | size | needs |
|---|---|---|---|
| 1 | D1 decided and built (peer dependencies, or B4, or the std driver) -- done: shared dependencies, SHARED-PACKAGE-DEPENDENCIES-MILESTONE-1.md | M-L | language design |
| 2 | provider: one BoringSSL convention (D4), a provider package with distinct archive names, its recipe in the author image -- done (`packages/boringssl`; HTTP-CLIENT-PACKAGE-MILESTONE-1.md) | M | D4, Rust/CMake in the image |
| 3 | the bridge as a maintained crate: test-only exports and the environment read moved to a test unit, the batched executor step, B12's worker, send retry for UDP -- done for the client (UDP with HTTP/3) | M | -- |
| 4 | transport: addresses, IPv4/IPv6, name resolution off the loop, listen/connect options, the transport context (8.1) -- done for outbound connections (no listen) | M | 3 |
| 5 | HTTP/1.1 and HTTP/2 API: headers, URIs, byte bodies, declared errors, resource-typed handles with detach-to-executor release, graceful shutdown, limits -- done for the client | L | 1, 3, 4 |
| 6 | TLS policy: system trust anchors, application certificates and keys, ALPN, no verification bypass -- done for the client (no client certificates) | M | 2, 5 |
| 7 | the release recipe: vendored crates, pinned rustc, link-only unit, localization, identity checks, reproducible archives, notices; `packages/http` and RELEASES.tsv -- done (boringssl 0.20261020.0 and http 0.1.0 recorded from the pinned image) | M | 2, D5 |
| 8 | tests, GC stress, AArch64, interop, mutants, fuzzing, CI jobs with caching; AGENTS.md section; milestone report -- done but for AArch64 and a CI job | M | 5-7 |
| 9 | HTTP/3: multi-connection endpoints, retry and version negotiation, Alt-Svc, BBR2 configuration | L | 5-8 |
| 10 | std vocabulary module(s) (5.3), Compilerpedia, warning gate, stdlib census | S-M | D2, D6 |
| 11 | distribution: assets beside `single-latest` (E2), README download links, a smoke test that installs and links an HTTP program with the single executable | S | 7, 8 |
| 12 | macOS and Windows drivers, then HTTP there | L each | event-loop work |

Items 1 and 3 can proceed in parallel; nothing in the list needs a second
scheduler or a Tokio runtime (the census's conclusion stands).

## 11. Method and limits

Read for this census: `audit/http-stack/` (all Rust, C, Botlish and Tcl
files' surfaces; the cited lines), HTTP-STACK-INTEGRATION-CENSUS.md,
`single/package.tcl`, SINGLE-EXECUTABLE.md, NATIVE-LINK-PLAN-MILESTONE-1.md
(section 8), BOT-MODULES-MILESTONE-1.md, PACKAGE-MANAGER-MILESTONE-2.md and
-3.md, `packages/` and `packages/RELEASES.tsv`, `tools/package-build/
Dockerfile`, `packages/event_loop_linux/event_loop_linux.bot`,
`stdlib/event_loop.bot`, `stdlib/web.bot`, `hir/contexts.tcl`,
`tests/cffi/boringssl.tcl`, AGENTS.md.

Run for this census, on the session's container (Ubuntu 24.04, x86-64,
rustc 1.97.0):

* `wc -l` and `grep` over `audit/http-stack/` (section 2's counts, the 73
  exports, the 24 test-only ones, `unsafe`);
* `cargo metadata --locked --format-version 1 --manifest-path
  audit/http-stack/Cargo.toml` and a closure walk of its `resolve` graph
  (section 2's dependency and license figures; it downloads crate sources,
  builds nothing);
* `dpkg -S` and `apt-cache depends` for the OpenSSL archive and the
  `libstdc++` link name (sections 6.4, 7.3).

Not run: the census's probes and `check.tcl` (no cached build here, and
the full check is about 50 minutes with network access); any link of the
peer-dependency arrangement of 6.2 (its conclusion is inferred from the
documented rules, and is the first thing to confirm with a two-package
reproducer); any size, timing or reproducibility measurement. Every number
not listed above is cited from HTTP-STACK-INTEGRATION-CENSUS.md.
