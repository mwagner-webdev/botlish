# HTTP-CLIENT-PACKAGE-MILESTONE-1.md

The completion report of the HTTP client package milestone: an HTTP/1.1
and HTTP/2 client with TLS, published as official packages (`http`, and
its BoringSSL provider `boringssl`), built on HTTP-STACK-INTEGRATION-
CENSUS.md's architecture (Hyper and BoringSSL in a Rust unit, scheduled by
the Botlish event loop) and HTTP-SHIPPING-CENSUS.md's package route, used
by an application written only against the published artifacts and the
single-file compiler.

## Contents

1. Answer
2. What was built
3. The public API
4. The native unit and its scheduling
5. TLS and trust
6. Streaming and backpressure
7. Lifetimes, cancellation and errors
8. Packages, provider and releases
9. Clean room
10. Testing
11. Measurements
12. Findings (and the compiler fix they led to)
13. Census items
14. Limitations
15. Consequences for the agent TUI
16. Architectural questions
17. Commands

## 1. Answer

**An independently written Botlish program can now install `http` with
`botlish add`, make HTTPS requests to ordinary internet services, stream
request and response bodies under bounded memory, and share the event
loop's driver with other packages, without knowing that the client is
Hyper, Rust or BoringSSL.** The clean room shows it end to end: a stock
Ubuntu container holding a C compiler, the C++ standard library's link
name and a trust bundle -- no Tcl, Rust, Cargo, CMake, checkout or
BoringSSL source -- installs `http`, `event_loop_linux` and a separately
authored library (`feeds`) from published `.botpkg` files with the
single-file compiler, builds a native executable and passes 51 checks: a
public HTTPS GET, a JSON POST with the program's own trust anchor, 64 MiB
streamed with the process's peak memory growing 3.5 MiB, UTF-8 split
across chunks, a streamed upload, the two libraries' requests interleaved
under one driver, and every failure as a declared error (section 9).

It is Linux x86-64 only (the packages name no other target and the package
manager refuses one), HTTP/1.1 and HTTP/2 only (no HTTP/3, server,
WebSocket, redirects, cookies, proxies or decompression: section 14), and
its releases (`http` 0.1.0, `boringssl` 0.20261020.0) are recorded in
`packages/RELEASES.tsv` from the pinned author image, where two fresh
containers built byte-identical artifacts that a host outside the image
also reproduced (section 8).

Two compiler defects surfaced while testing, and one was fixed here
because it leaked the client's resources: natively, a function that owned
a resource and returned a String its caller concatenated (or a small Int,
a scalar String, a projected struct) never released the resource (section
12). The others are recorded with reproducers.

## 2. What was built

| path | what |
|---|---|
| `packages/http/http.bot` | the module: URIs, headers, requests, responses, errors, the runtime context `Http`, clients and exchanges as resources, the executor task |
| `packages/http/native/` | the Rust unit (crate `botlish_http`): the bridge (bounded executor, timers on the loop's clock, readiness, notices, generation-checked handles, the FFI guard), the client (Hyper 1.12.0, h2 0.4.20, http 1.5.0), TLS (boring 5.4.0), the name-resolver pool, the C ABI (`bh_*`), the `testing` feature |
| `packages/http/README.md`, `GUIDE.md` | the user's documentation: installation, prerequisites, a first program; the guide's API, lifetimes, errors, streaming, timeouts, cancellation, TLS, connections, limits, with two more complete programs |
| `packages/boringssl/` | the provider: `PIN` (BoringSSL's release tag 0.20261020.0, tag object and commit), `boringssl.bot` (the link declarations), `native/identity.c` (the provider's identity symbol) |
| `tools/http-package.tcl` | the author's builds: the pinned BoringSSL (CMake, Ninja), its one archive, the unit (cargo, link-only, localized), a test application's package graph |
| `tools/package-repository.tcl` | `author::boringssl`, `author::http`: the release recipes (`native add`, `native require`, staged license files) |
| `tools/package-build/` | the pinned author image gains Rust 1.97.0 (rustup-init 1.28.2 by SHA-256) and apt retries |
| `tests/http-client.test`, `tests/http/` | 38 tests against independent peers (`server.py`, nghttpd), the PKI (`pki.sh`), the test client, the URI and header oracles |
| `tests/cffi/http.tcl` | builds the native files for the tests (the release recipe's builds) |
| `audit/http-client/cleanroom/` | the clean room: its image, harness, consumer program, the `feeds` library, results |
| `audit/http-client/tools/` | `syntax-fuzz.tcl` (URIs and header fields against their oracles), `mutate.tcl` and `mutants.txt`, `measure.tcl`, `attribute.py` (callgrind attribution) |
| `audit/http-client/results/` | the measurements as measured |
| `audit/http-client/bench/bench.bot` | the measurement program |
| `audit/http-client/findings/` | reproducers of the compiler findings (section 12) |
| `native/lower.tcl`, `tests/resources/forms.bot` | the release fix and its regression test |
| `compilerpedia/topics/capabilities.topic` | `capability.http`: `-help http` leads to the package |

## 3. The public API

GUIDE.md is the reference; in short:

* **Runtime.** A program installs four contexts in order --
  `std::event_loop::create(N)`, `event_loop_linux::create()`,
  `event_loop_linux::native()` and `http::create()` -- and runs its HTTP
  work in tasks of the loop (`std::event_loop::adopt`). Every operation
  that waits suspends the calling task only.
* **Configuration.** `http::config()` gives the defaults (negotiate
  HTTP/2 by ALPN, system trust, 30 s connect timeout, 300 s idle timeout,
  6 HTTP/1.1 connections per origin, 64 KiB of response head, 90 s pool
  idle, a 1 MiB HTTP/2 window); `with_anchors(config, pem)` adds trust
  anchors as data; a `Config` is an ordinary struct.
* **Requests.** `http::uri(text)` parses an absolute http or https URI
  (RFC 3986; IPv4 and IPv6 literals; no user information; the fragment
  dropped) or fails with `InvalidUri {text, reason}`; `http::get`,
  `http::post`, `http::request(method, uri)` (a token method);
  `with_header` (`http::header(name, value)` validates a token name, a
  field value and refuses names the client owns: connection-specific
  fields, `host`, `content-length`; `header_bytes` takes a value's bytes,
  checked when sent), `with_body` (Bytes), `with_deadline`/`with_timeout`,
  `with_cancel`.
* **Clients and exchanges are resources.** `http::client(config)` is
  `{owner, client}`; `send(client, request)` waits for the head and is
  `{owner, response}` with `status`, `version`, `headers` (a list, repeated
  names kept in order) and `exchange`; `start(client, request, length)`
  streams a request body (`write`, then `finish`, which waits for the
  head); `read(exchange)` is the next chunk (empty at the end),
  `read_all(exchange, limit)` the rest. The owners (`ClientOwner`,
  `ExchangeOwner`) release where their scopes end, or explicitly with
  `close_client` and `close`.
* **Errors** are declared and carry payloads: `InvalidUri`,
  `InvalidRequest`, `ResolveFailed {host, reason, code}`, `ConnectFailed
  {host, port, reason, code}`, `TlsVerifyFailed {host, reason, code}`
  (BoringSSL's verify result), `TlsHandshakeFailed`, `ProtocolError
  {reason, code}` (an HTTP/2 error code where there is one), `Timeout
  {phase, reason}` (`Phase::Connect`, `Deadline`, `Idle`), `Cancelled`,
  `Closed`, `Released`, `Unsupported`, `TrustFailed`, `HeaderNotText`,
  `BodyTooLarge`, `Fault`. A response of any status is a response.
* **Cancellation.** `http::cancellation()` is a token; `http::cancel(c)`
  fails every exchange carrying it (and every later one) with `Cancelled`
  and drops its native work at once.

## 4. The native unit and its scheduling

The census's bridge, productized (HTTP-SHIPPING-CENSUS.md, section 3, and
this milestone's brief, section 12):

* **One step per turn, batched.** The module's executor task calls
  `bh_step(budget, now, buf)` once per wake: the unit sets its clock to the
  driver's, fires due timers, polls at most `budget` (32) of the tasks
  ready when the step began, each once, and writes what Botlish must do --
  interest changes, notices to waiting tasks, its next deadline -- as
  32-byte records into Botlish storage, read with a layout. One C call per
  turn replaces the census's several (section 11).
* **Readiness and timers are the loop's.** The unit asks for read or
  write interest on a descriptor; the module watches it with
  `event_loop_linux` and reports readiness back. The driver's watch
  interest is fixed at creation (the census's B5), so another interest is
  an unwatch and a new watch (`rewatches` counts them). Timers are the
  unit's deadlines, slept by the executor task with the loop's timer.
* **Name resolution off the loop.** getaddrinfo blocks, so it runs on a
  pool of four threads with a bounded queue; an answer wakes the loop
  through the driver's foreign post (`botlish_event_post`), the only thing
  those threads do (the census's B12, for resolution).
* **Handles stay inside.** Rust objects are reached by generation-checked
  handles (`generation << 32 | index`) the module keeps in its resources'
  fields; a handle whose object is gone, or whose slot was reused, is
  refused (`Released`; `http-stale-handle` and its control).
* **Panics never cross the boundary**: every `bh_*` function runs inside a
  guard that turns a panic into a status the module reports as `Fault`.
* **Probe-only behavior is gone from the released unit.** The census's
  environment variable (`HS_CENSUS_FAULT`) is no more; fault injection,
  counters and a counting allocator are the `testing` feature's, which the
  released unit does not build (every fault check compiles to `false`) and
  whose exports (`bh_t_*`) only the test unit has (`http-unit-exports`).
* **No Tokio runtime.** Hyper's executor and timer traits are implemented
  on the bridge; tokio (1.54.1) is in the dependency graph only through
  h2's codec, with the features `bytes`, `io-util` and `sync`: no `rt`,
  `time` or `net`.

## 5. TLS and trust

* **Verification is always on**: the chain, the host name (or, for an IP
  literal, the address: `set_ip`, no SNI), expiry, with partial wildcards
  refused; TLS 1.2 and later; ALPN offers h2 and http/1.1 under the default
  policy. No option, environment variable or code path turns it off.
* **Trust anchors.** `Trust {system, anchors}`: the system's bundle (the
  first of the documented distribution paths that exists:
  `/etc/ssl/certs/ca-certificates.crt`, Red Hat's, SUSE's, Alpine's) and
  PEM anchors the program passes as data. The unit reads no other file and
  no environment variable (`SSL_CERT_FILE` is not read): the program reads
  an anchor file if it wants one (the clean room's consumer does). A client
  with no anchor at all is refused when it is made (`TrustFailed`).
* **Failures are distinct**: `TlsVerifyFailed` carries BoringSSL's verify
  result (62 host mismatch, 10 expired, 20 unknown issuer, 19
  self-signed in the chain); `TlsHandshakeFailed` is everything else.
* **Version policy.** `Versions::Negotiate` (ALPN), `Http1` and `Http2`.
  HTTP/2-only refuses a server that does not select h2 (`Unsupported`),
  never a silent HTTP/1.1; an http URI is HTTP/1.1 (no h2c).

## 6. Streaming and backpressure

The unit holds **at most one chunk per exchange** that the program has not
taken: the response pump polls Hyper's body only once the previous chunk
was read, so HTTP/2's flow-control window (1 MiB by default, configurable)
or TCP's buffers stop the server. Measured with a reader that pauses 1.5 s
after its first chunk: at most 16 KiB held natively; the server got only
as far ahead as the window lets it (under 128 KiB with a 64 KiB window,
under 1.25 MiB with the default); the negative control (the pump ignoring
the consumer) holds almost the whole 4 MiB (`http-backpressure`,
`http-backpressure-control`). A request body is written chunk by chunk
through a one-chunk slot: `write` waits for room. In the clean room a
64 MiB response grew the process's peak memory by 3.5 MiB.

## 7. Lifetimes, cancellation and errors

* An exchange released before its body ended is abandoned: HTTP/2 resets
  the stream and keeps the shared connection; HTTP/1.1 closes the
  connection (never reused mid-message). Releasing a client fails its
  exchanges with `Closed` and closes its connections.
* A task abandoned by the loop releases what it owns (lexical cleanup).
* Cancellation drops the exchange's native task at once; a token stays
  cancelled for later requests.
* Three limits are distinct: the connect timeout (name resolution,
  connecting and the TLS handshake; and waiting for a pooled HTTP/1.1
  connection), the idle timeout (the server's silence
  before the head and between chunks, never while the program does not
  read), the request's deadline (the whole exchange).
* A request that failed before it was sent on a reused connection (a
  keep-alive connection the server had closed) is retried, up to four
  connections; a failure after sending is reported, never retried.

## 8. Packages, provider and releases

**The graph.** `http` 0.1.0 depends on `boringssl` 0.20261020 and
`event_loop_linux` 0.3 and locks 0.20261020.0 and 0.3.0. An application
that adds `http`, the driver and another library using the driver gets one
instance of each (`.bot_modules/.graph`: `application event_loop_linux
feeds http`, `package http boringssl event_loop_linux`); a library locking
another BoringSSL release is a DEPENDENCY-CONFLICT naming both locks, the
installation unchanged (clean room).

**The provider.** BoringSSL fetched by its pinned tag, checked by tag
object and commit, built unpatched and unprefixed by its own CMake (Ninja,
Release, PIC), then put into one archive of its own name,
`libbotlish_boringssl.a` (crypto, ssl, and `identity.o`, which defines
`botlish_boringssl_0_20261020_0_d3bf4795ad5b79d646cddf2fec687da5b9b502db`),
each member's debug sections stripped. One archive, not two, because the
native audit counts a weak definition present in both libcrypto and libssl
as a duplicate (section 12). It declares `stdc++` as a system library (the
TLS code is C++).

**The unit.** cargo `--locked`, one codegen unit, paths remapped; boring-sys
in link-only mode against empty archives (no BoringSSL inside); `ld -r`
into one object, `objcopy --keep-global-symbols` leaving only the `bh_*`
functions global, the Rust personality's COMDAT group renamed (the
census's B3); a deterministic archive. It references the provider's
identity symbol, so it links only with the provider it was built against
(the census's B2).

**Releases** (recorded in `packages/RELEASES.tsv`), built by
`tools/package-build/author.sh build OUT -release boringssl event_loop_linux
http` in the pinned author image (Ubuntu 24.04 by digest, Ubuntu's archive
at 2026-11-01T00:00Z, gcc and g++ 13.3.0, cmake 3.28.3, ninja 1.11.1, clang
18 for boring-sys's bindgen, Rust 1.97.0 by rustup-init 1.28.2 checked by
SHA-256):

| artifact | SHA-256 | size |
|---|---|---|
| `boringssl-0.20261020.0.botpkg` | `9124d0a25d4c08579530d1d18fdafb0c92c27fe3f223b6227220503383edf453` | 1,821,938 (7 files, 5,805,143 unpacked) |
| `http-0.1.0.botpkg` | `3d40620ee4bead40c3df6c5e076ce7193ecbe73a5104f21bd62bf08d2b0bc436` | 5,326,480 (95 files, 17,611,825 unpacked) |
| `event_loop_linux-0.3.0.botpkg` (the recorded release, rebuilt) | `3746cece124b660fa03bf018271e4d5bc6d25f2bf684da84bc9fd621a2bc453c` | 33,589 |
| provenance records (boringssl, http) | `c6fb5d8e63d08fdcc7d5eac72a6dbf30ca99b048490666cd0d305ed61ec9a08b`, `5263823b8ed31aa903c82a3536679cb7a4da5b4795ead1f569a7ae5f46f6cbd8` | |
| the unit `libbotlish_http.a` inside `http` | `26490165a9072ff1195ada72c2e64512bfd26fd540501c633663f4f2692f8e27` | 17,040,508 |

**Reproducibility.** Two builds in fresh containers of the image produced
byte-identical artifacts and provenance records; the same command on this
host, outside the image (its own Rust 1.97.0 and gcc 13.3.0, a cache made
hours earlier), produced the same two artifacts, so `-release` accepts
them as the recorded releases. Earlier candidates made on the host
differed only in the two documentation files changed in between
(`botlish package compare`). The image could first be built only after
two changes this milestone made to its Dockerfile: apt retries (the pinned
Ubuntu snapshot answered 502 and 500 for hours through this environment's
proxy, the failure main's `package-reproducibility` run shows) and the
`rustc --version` check run with rustup's home. With them the branch's
`package reproducibility` workflow passes. Each artifact has a provenance
record beside it (`botlish package inspect ... -provenance` checks it; the
clean room does). License notices travel in the artifacts: BoringSSL's
LICENSE, and every crate of the unit's dependency closure with its own
license files (`licenses/http/crates/`, `CRATES.md`).

## 9. Clean room

`audit/http-client/cleanroom/` (commands in section 17). The image is
Ubuntu 24.04 with `gcc g++ libc6-dev ca-certificates` and nothing else;
the harness copies in the single-file compiler (built from 6673eb8, which
holds the fix of section 12), the recorded release artifacts and their
provenance records, the consumer's source
(`app/main.bot`) and the test CA's certificate (the consumer's own anchor
file). The peers run outside it: `tests/http/server.py` with a certificate
the test CA signs, one signed by a CA nobody trusts, and a closed port.

Results (`audit/http-client/cleanroom/results/`): **51 checks, all passed**
-- no Tcl, Rust, Cargo, CMake, Ninja, checkout or BoringSSL source;
`botlish add` of `http`, `event_loop_linux` and `feeds`; one instance of
each package; `verify` clean; both provenance records match; the program
builds warning-free (48 s; a 7.2 MB executable depending on no shared
BoringSSL or OpenSSL, holding the unit and the provider once); then:

| workload | observed |
|---|---|
| A: public HTTPS GET (`https://example.com/`) | 200 over HTTP/2, `text/html`, 577 bytes, nothing left |
| B: JSON POST with the program's anchor | 200 over HTTP/2; the peer saw POST, `application/json`, the bearer token; the echoed body equal to the body sent |
| C: streaming | 67,108,864 bytes in 4,096 chunks (largest 16,384); at most 16,384 bytes held natively; peak memory +3.5 MiB; UTF-8 text in 27 chunks decoded whole; a 4 MiB upload in 64 writes echoed whole |
| D: a separately authored library | `feeds` (its own client and timer) and the application's own requests interleaved under the one driver; at the application's end feeds' client was still open; nothing left once feeds finished |
| E: failures | `ResolveFailed` (no-such-host.invalid), `TlsVerifyFailed` (an unknown issuer), `ConnectFailed` (refused), `Timeout` deadline, `Timeout` idle (body), `Cancelled`, an early release (`Released` afterwards, no exchange left, the client usable) |
| a library locking another BoringSSL | DEPENDENCY-CONFLICT naming both locks; the installation unchanged |

**One environment fact.** This environment's outbound TLS goes through an
inspecting gateway whose root is in the host's system store, not in a
stock container's. The harness installs it into the container's system
store when `BOTLISH_CLEANROOM_SYSTEM_CA` names it (and says so in the
transcript), as the operator of such a network would. Without it, workload
A fails exactly as it should -- `TlsVerifyFailed self signed certificate
in certificate chain` -- and every other check passes
(`results/checks-without-operator-ca.txt`, from the first run, with the
compiler of a64bd30 and the artifacts before they were recorded): the
client trusts the system's store and the program's anchors, and nothing
else.

## 10. Testing

### 10.1 tests/http-client.test

38 tests, all passing (the last full run: 38 passed, 0 skipped, on this
milestone's final code); the native files come from the release recipe's
builds (`tests/cffi/http.tcl`); the client is `tests/http/client.bot`
built with the test unit. The peers are independent of Hyper and BoringSSL:

* `tests/http/server.py`: Python 3.13.18's asyncio and ssl (OpenSSL
  3.5.9), the `h2` 4.3.0 library for HTTP/2, a small HTTP/1.1
  implementation of its own (plaintext; TLS with h2 and http/1.1; TLS
  http/1.1 only; wrong-host, expired and untrusted certificates from
  `tests/http/pki.sh`, made by the openssl command-line tool);
* nghttpd (nghttp2 1.59.0, C) for HTTP/2 over TLS where installed.

This is interoperability evidence, not a conformance claim: the client's
HTTP/1.1 and HTTP/2 are Hyper's and h2's, and no client conformance suite
was run (h2spec, the common one, tests servers). What the tests establish
is that the package's use of them -- framing, flow control, ALPN, header
validation, errors -- behaves as documented against two independent
servers.

| area | tests |
|---|---|
| the unit and the provider | `http-unit-exports` (only `bh_*` global; the test unit adds `bh_t_*`), `http-provider-identity`, `http-package-metadata` (http's locks are the repository's releases; the identity names boringssl's version and commit), `http-warning-clean` (warning-free, three builds) |
| requests and responses | `http-get-h1`, `http-get-h2-tls`, `http-get-ip-literal`, `http-post-json`, `http-post-json-h1`, `http-repeated-headers`, `http-statuses`, `http-utf8-split` (one byte per write), `http-upload` (declared length, chunked HTTP/1.1, HTTP/2 DATA), `http-header-validation` (both layers: the constructors and the unit's check of a hand-built header) |
| protocol and TLS | `http-alpn`, `http-tls-verify` (62, 10, 20, and the test CA under system trust alone), `http-trust-config`, `http-transport-failures`, `http-timeouts` (the three limits), `http-protocol-failures` (a short HTTP/1.1 body, an HTTP/2 RST_STREAM, an invalid status line) |
| flow control and scheduling | `http-backpressure` and its control, `http-executor-budget` and its control (64 requests at once: at most 32 polls per step; the control polls them all), `http-concurrency` (one HTTP/2 connection for 8 streams; at most 6 HTTP/1.1 connections), `http-keep-alive`, `http-resolver-control` |
| lifetimes | `http-cancel`, `http-abandon` and its control, `http-stale-handle` and its control, `http-release-client`, `http-lifetime-fuzz` (twenty seeded orders of sends, reads, releases, cancellations and waits on both protocols: every outcome a value or a declared error, nothing left), `http-gc-stress` (`BOTLISH_NATIVE_GC_STRESS=1`) |
| interop and docs | `http-nghttpd` (3 MiB exactly; eight requests on one connection), `http-package-docs` (every example of README.md and GUIDE.md compiles under `-warnings error`; they reach public hosts, so they are compiled, not run), `http-uri` |

The negative controls use the test unit's fault bits, each a rule the
tests check: a lost foreign wake (1), an unbounded run (2), releases that
leave tasks (128), an index-only handle lookup (256), a pump that ignores
the consumer (512).

### 10.2 Fuzzing

* **URIs and header fields** (`audit/http-client/tools/syntax-fuzz.tcl`):
  generated from grammars of valid parts and corruptions, run through the
  package (`parse-many`, `headers-many`) and through independent oracles
  (`tests/http/uri_oracle.py`, `tests/http/header_oracle.py`, written from
  the documentation and the RFCs). Seeds 1-4: 12,000 URIs (1,944 valid)
  and 12,000 header fields (4,526 accepted), 0 disagreements.
* **Handle operations and lifetime ordering, cancellation against
  completion, notices and wakeups** (`http-lifetime-fuzz`): seeded
  sequences of sends, reads, exchange and client releases, cancellations
  and waits, on both protocols, then the native counts (clients,
  exchanges, tasks, watches) must be zero.
* **Chunk boundaries**: UTF-8 one byte per write (`http-utf8-split`),
  bodies in the server's frames from 1 KiB to 64 KiB, declared, chunked
  and DATA-framed uploads, a declared length the body falls short of.

### 10.3 Mutation testing

`audit/http-client/tools/mutate.tcl` (`mutants.txt`): each mutant is
applied to a private copy of the tree, whose own cache rebuilds the
provider archive and the units, and must be killed by the detectors its
lines name. **16 mutants, 16 killed** -- the brief's nine kinds and seven
more:

| mutant | the defect | killed by |
|---|---|---|
| `tls-no-hostname` | the certificate's names never checked against the host | `http-tls-verify` |
| `tls-no-verify` | `SSL_VERIFY_NONE` | `http-tls-verify` |
| `header-value-control` | the constructor accepts control characters, CR LF included | `http-header-validation` |
| `header-native-value` | the unit accepts any bytes as a hand-built header's value | `http-header-validation` |
| `body-duplicate-chunk` | each received chunk queued twice | `http-get-h1`, `http-get-h2-tls`, `http-utf8-split` |
| `body-drop-chunk` | every second chunk dropped | the same three |
| `backpressure-ignored` | the pump reads on while a chunk waits | `http-backpressure` |
| `cancel-leaves-task` | a cancelled exchange's task runs on | `http-cancel` |
| `release-leaves-task` | a released exchange's task runs on | `http-abandon` |
| `slab-index-only` | a stale handle reaches the object that reused its slot | `http-stale-handle` |
| `executor-unbounded` | a step polls every ready task | `http-executor-budget` |
| `foreign-wake-lost` | the resolver's answer never posted to the loop | `http-resolver-control` |
| `deadline-ignored` | a request's deadline never enforced | `http-timeouts` |
| `uri-bad-escape` | `%` needs one hex digit, not two | `http-uri`, `syntax-fuzz.tcl` |
| `provider-mismatch` | the provider archive identifies another BoringSSL | `http-provider-identity`, `http-get-h1` (the link fails) |
| `graph-lock-drift` | http locks a driver release the repository does not hold | `http-package-metadata` |

Two lessons from the first run, both fixed before the second: the native
check of a header *name* had a mutant that survived because no program can
reach it (the module checks every name before the native call: an
equivalent mutant, replaced by the value check's, which a hand-built
header does reach); and the harness reused the provider archive an earlier
mutant had built, so the recipe's mutant never ran (it now rebuilds the
archive and the units per mutant). `uri-bad-escape` was first killed only
by the fuzzer; `http-uri` now refuses `%az` too.

The compiler fix of section 12 was checked by the affine and coroutine
catalogs' mutants of `native/lower.tcl` (affine 2 of 2, coroutines 3 of 3
killed), the affine (seeds 1, 5), coroutine (1, 5) and lexical-cleanup (1,
7) fuzzers (0 disagreements), and `tools/mutant-catalogs.tcl`.

### 10.4 The integration census's 50 claims

How each of HTTP-STACK-INTEGRATION-CENSUS.md's claims maps to the client
(section 16 of that report):

| claims | for the client |
|---|---|
| `provider-provenance`, `unit-link-only` | the release recipe (fetch checks, link-only build); `http-unit-exports` |
| `A-crypto-only` | not the client's (the C crypto airlock is a census probe) |
| `hyper-http1`, `hyper-http2-streams` | `http-get-h1`, `http-get-h2-tls`, `http-concurrency`, `http-nghttpd` |
| `hyper-http2-backpressure`, `stalled-consumer`, `control-no-backpressure` | `http-backpressure` and its control |
| `hyper-http2-cleanup`, `tls-cleanup`, `lifetime-connection`, `lifetime-shutdown` | `http-abandon`, `http-release-client`, `http-lifetime-fuzz` (no watch, task or object left) |
| `hyper-http2-bounded-polls`, `bounded-progress`, `control-unbounded-poll` | `http-executor-budget` and its control |
| `tls-scenarios` | `http-tls-verify`, `http-alpn`, `http-trust-config` |
| `foreign-wake`, `control-lost-foreign-wake` | `http-resolver-control` (the resolver's answer is the foreign wake) |
| `application-call-kick`, `control-no-kick` | covered by every request (an application call makes work ready); the explicit control (fault 8) has no test of its own |
| `panic-containment` | the guard is unchanged; no test injects a panic in the released API (the census's probe did) |
| `lifetime-stale`, `control-stale-completion` | `http-stale-handle` and its control |
| `idle-cpu` | not re-measured |
| `deterministic-driver`, `deterministic-trace` | not applicable: the package runs under the Linux driver only |
| `no-tokio-runtime`, `tokio-features` | the unit's dependency graph: tokio 1.54.1 (h2's codec) with the features `bytes`, `default`, `io-util` and `sync` only (`cargo tree -e features -i tokio`): no `rt`, `time` or `net` |
| `combined-consumers`, `combined-one-provider`, `link-one-provider-*`, `control-private-copy-*`, `bundled-twice`, `bundled-link-order`, `control-other-revision`, `control-second-provider-declared` | one provider by construction: one archive, the identity symbol, the graph's single boringssl (`http-provider-identity`, the clean room's symbol checks and its conflict); quiche is not shipped, so nothing bundles a second copy |
| `control-library-installs-driver` | unchanged rule: `http` installs nothing; the application installs the driver (clean room D) |
| `lifetime-listener`, every `quiche-*`, `quiche-loss-recovery`, `control-quiche-timer-never-armed` | server and HTTP/3 probes: out of this milestone |
| `measurements-recorded` | section 11 |

## 11. Measurements

`tclsh9.0 audit/http-client/tools/measure.tcl -runs 3` (medians of three
runs) on this 4-core shared container, with the released unit (no test
feature; `audit/http-client/bench/bench.bot`), the system linker, loopback
peers: the Python test peer (`tests/http/server.py`), nghttpd serving a
64 MiB file over TLS, Python's `http.server` serving it over plaintext
HTTP/1.0, and curl 8.5.0 (OpenSSL 3.0.13, nghttp2 1.59.0) against the same
peers as a baseline. Representative, not benchmarks: the peers bound
several numbers, as noted. The raw table and the attribution below are in
`audit/http-client/results/measurements.txt`
(`audit/http-client/tools/attribute.py` makes the attribution).

| measurement | value |
|---|---:|
| warm HTTP/1.1 GET (6 bytes), plaintext, one client | 217 µs (curl, same peer: 151 µs) |
| warm HTTP/2 GET (6 bytes), TLS, one client | 460 µs (curl: 376 µs) |
| guarded C calls per request (HTTP/1.1, HTTP/2) | 14.2, 17.7 |
| cold request, new client, HTTP/1.1 plaintext | 4.5 ms |
| cold request, new client, HTTP/2 over TLS (handshake included) | 6.4 ms |
| of which making the client (the system bundle and the anchors parsed into a trust store) | 4.0 ms |
| 64 concurrent HTTP/2 requests of 16 KiB on one connection (whole process: start, client, handshake) | 102 ms |
| download 64 MiB, HTTP/2 over TLS from nghttpd (16 KiB frames: 4,096 chunks) | 258 MiB/s (curl: 931) |
| download 64 MiB, plaintext from `http.server` (1,175 chunks) | 1,280 MiB/s (curl: 1,800) |
| guarded C calls per chunk (HTTP/2, plaintext) | 3.2, 2.0 |
| peak memory growth while 64 MiB passed (HTTP/2, plaintext) | 3.8 MiB, 1.8 MiB |
| most bytes held natively for one exchange (HTTP/2, plaintext) | 16 KiB, 112 KiB (one read of the socket) |
| slow consumer (2 ms per chunk), 64 MiB over HTTP/2: peak memory growth | 3.7 MiB (16 KiB held natively; 7.4 MiB/s) |
| upload 16 MiB and read the echo back, plaintext, writes of 1 KiB / 16 KiB / 64 KiB / 1 MiB | 60 / 399 / 477 / 427 MiB/s (curl, same peer, without `Expect: 100-continue`'s wait: about 790) |
| upload 16 MiB, HTTP/2 over TLS, writes of 1 KiB / 16 KiB / 64 KiB / 1 MiB | 3 / 17 / 19 / 20 MiB/s (curl: 20: the peer's pure-Python HTTP/2 bounds it) |
| guarded C calls per write, plaintext (1 KiB ... 1 MiB) | 3.0, 3.6, 5.6, 42.2 |
| front end of a program importing `http` (no cache) | 29 s |
| front end, code generation and the system link | 49 s (the clean room: 48 s) |
| executable (the measurement program), unstripped / stripped | 17.0 MB / 6.1 MB (the clean room's: 7.2 MB) |
| `libbotlish_http.a` / `libbotlish_boringssl.a` | 17.0 MB / 5.8 MB |
| `http-0.1.0.botpkg` / `boringssl-0.20261020.0.botpkg` | 5.3 MB (17.6 MB unpacked) / 1.8 MB (5.8 MB) |

**Per request and per chunk, with the test unit** (`tests/http/client.bot`'s
`costs`: 100 sequential GETs on a warm client, then a 1 MiB body in 4 KiB
chunks; the client side only, unlike the census's figures, which counted
both ends in one process):

| per | C calls | executor steps | polls | notices | readiness | bytes copied out / in | Rust allocations (bytes) |
|---|---:|---:|---:|---:|---:|---:|---:|
| HTTP/1.1 request | 14.3 | 5.1 | 6.2 | 3.0 | 1.1 | 396 / 18 | 45.3 (45.5 KB) |
| HTTP/2 request (TLS) | 16.3 | 7.0 | 9.2 | 3.0 | 1.2 | 422 / 18 | 51.3 (44.1 KB) |
| HTTP/1.1 4 KiB chunk | 3.0 | 1.0 | 2.0 | 1.0 | 0 | 3,993 / 0 | 2.2 (2.9 KB) |
| HTTP/2 4 KiB chunk (TLS) | 3.4 | 1.0 | 1.8 | 1.0 | 0.4 | 4,175 / 0 | 4.6 (11.0 KB) |

Resource counts after completion, cancellation, release and abandonment
are zero in every test that ends a scenario (`final: clients 0 exchanges
0`), the lifetime fuzzer's twenty orders included.

**Where the time goes.** Callgrind's instruction counts (no `perf` here)
of the warm HTTP/2 run, 201 requests minus 1 (startup subtracted): about
1.9 million instructions per request --

| | share |
|---|---:|
| copying and zeroing (libc `memcpy`, `memset`) | 29% |
| allocation (libc `malloc`, `free`) | 28% |
| Botlish runtime: layout decoding (`bin_extent`, `bin_decode`, `rt_bin_load`) | 16% |
| Botlish runtime: everything else (construction, heap, structs, vectors) | 15% |
| compiled Botlish code | 7.5% |
| Hyper, h2 and the bridge | 1.7% |
| BoringSSL | 0.7% |

and for a 16 MiB HTTP/2 download (per 16 KiB chunk, about 640,000
instructions): copying and zeroing 49%, allocation 15%, BoringSSL
(decryption) 13%, the Botlish runtime 15%, compiled Botlish 4.6%, Hyper
and the bridge 1.1%. **The overhead is the module's own buffer handling on
the Botlish side of the boundary**, not Hyper, TLS, C crossings or the
event loop's syscalls (kernel time is not in these counts): every `read` allocates and
zeroes a 64 KiB `MutableBytes` for the C call to write into, whatever the
chunk's size, then copies the chunk out of it; every executor step
allocates its 2 KiB record buffer and decodes all 64 records of the batch
layout, though a step returns a few. Both are local to `http.bot` and have
plain remedies -- a read buffer sized to the waiting chunk (the unit knows
it: `Recv::front`), and decoding only the records a step returned -- left
for a later release, which would be a new version (0.1.0 is recorded).
None needs a zero-copy facility.

**Against the integration census** (its section 13; it counted both ends
in one process): C calls per exchange fell from 75 (HTTP/1.1) and 87
(HTTP/2) to 14 and 16-18 for the client -- the batched step replaced the
census's per-query calls -- and per streamed chunk from 20 to 3. Rust
allocations per exchange are higher (45 and 51 for the client alone,
against 33 and 43 for both ends): the production API's head and failure
records, and Hyper's client-side header map. The unit is 17 MB against
31 MB (no quiche), a program 17 MB unstripped against 45 MB; compiling and
linking a program takes 49 s against about 40 s (the module is larger).
Latency and throughput are not comparable directly (the census's peer was
Hyper in the same process; here, Python's asyncio and nghttpd).

## 12. Findings (and the compiler fix they led to)

**F1. Resources were not released on several native sequence forms
(fixed).** `native/lower.tcl`'s `Sequence` releases the affine values that
die after each statement. The lowerings of a sequence whose value takes a
form of its own -- a construction plan (`SequenceTo`: a String its caller
concatenates), a raw Int (`SequenceRaw`), a scalar String
(`SequenceShort`), a virtual aggregate (`SequenceVirtual`), and the five
companion bodies that end in `retmulti` -- evaluated their statements
without those releases. A function owning an http exchange whose result a
caller concatenated leaked the exchange natively, once per call (the
interpreter released it). Found by `http-header-validation`, whose final
count showed an exchange left; reduced to a resource program without http
(`tests/resources/forms.bot`, 0 releases of 6 natively before the fix).
Fixed with one statement loop for every form (`SequenceStatements`) and
the releases after each form's last expression. Validated by
`tests/resources.test`, `tests/affine.test`, `tests/coroutines.test`,
`tests/affine-applications.test`,
`tests/written-affine-applications.test`, `tests/event-loop.test`,
`tests/event-loop-linux.test`, `tests/resources.test` and
`tests/affine.test` under GC stress, and `tools/mutant-catalogs.tcl` (86
catalogs, 3,037 mutants, every one still applies).

**F2. A fold's method-style call charged another module's function
(open).** With `std::linux::fs` imported, `fold p in parts with
intermediate acc "": acc.concat(p)` is rejected in the monomorphized
program as if `acc.concat` were `std::linux::fs::concat` (UNHANDLED-ERROR
of NotAPath, FOLD-INTERMEDIATE-TYPE), although `acc` is a str; the same
call outside a fold compiles (`audit/http-client/findings/
fold-method-monomorphized.bot`). Worked around with
`std::str::concat(acc, p)`.

**F3. A method-call decision costs a build per call (open).** With
`std::str` and `std::linux::fs` both imported, every `"...".concat(...)`
is a whole-program trial build: `std::linux::fs::concat`'s first parameter
is an opaque struct the kind proofs never exclude for a str receiver
(METHOD-DECISION-FILTER.md excludes by named struct only between named
structs). Six calls cost 15 builds and 11 s, against 2 builds and 0.8 s
without that import (`findings/concat-deviations.bot`); the clean room's
first consumer program took over ten minutes to check before its lines
were built with one helper. The same mechanism made a lexical helper of
the module named like a method (`at`) cost 69 builds and seven minutes:
renamed and marked `nomethod` (`http-warning-clean` keeps a program
importing http at three builds).

**F4. Calling an Int is accepted (open).** A local Int binding that
shadows a function of the same name is called without a diagnostic and
fails at run time with NOT-CALLABLE, naming the value
(`findings/call-of-shadowing-int.bot`); with a declared result type the
program is instead rejected by an unrelated-looking TYPE diagnostic.

**F5. The native audit counts a weak definition twice.** BoringSSL's
libcrypto and libssl each define some symbols weakly; as two archives of
one package the audit refused them as duplicates. The provider is one
archive (it is one library to its consumers anyway); the audit's rule is
unchanged.

**F6. `std::event_loop::now()` is the turn's clock.** It is 0 before the
first turn and does not advance within one: a deadline computed from it
before the loop runs is already past. The package's `with_timeout` uses
`event_loop_linux::now_us()`, the driver's clock read now; GUIDE.md says
so.

**F7. A test-harness hazard.** `tests/http-client.test` once deleted its
directory, PKI included, when the first executable was built after a peer
had started: a later test regenerated a different CA and saw code 20. The
build now deletes only `.bot_modules`.

## 13. Census items

The status of HTTP-SHIPPING-CENSUS.md's open items after this milestone is
in that document's section 4 (revised): B1, B2, B3 and B12 (for name
resolution) and scope-bound handles are implemented; B5 is worked around
in the package (the driver's API is unchanged); B6 is deferred with
HTTP/3; B7 is converged for shipping (the C FFI tests keep their prefixed
fixture); B4 and B8 were not needed; B9 and B10 remain.

## 14. Limitations

* **Platform**: Linux x86-64 (glibc) only. The unit has not been built or
  tested on AArch64 (the recipe and the package name one target); macOS
  and Windows have no event-loop driver package.
* **IPv6**: the client resolves and connects to IPv6 addresses (it parses
  IPv6 literals, getaddrinfo returns both families, connects try each
  address in order), but no IPv6 connection could be tested here: this
  container's kernel refuses IPv6 sockets (EAFNOSUPPORT, code 97).
* **Not implemented** (the milestone's exclusions): HTTP/3, servers,
  WebSocket, redirects, cookies, proxies (`HTTPS_PROXY` is not read),
  decompression, caching, client certificates, SSE decoding, Happy
  Eyeballs (a name's addresses are tried one after another, all within
  the one connect timeout, which covers resolution, connecting and the
  TLS handshake).
* **On the loop's thread**: TLS handshakes and certificate verification
  run inside the executor's step (measured in section 11); a very slow
  handshake delays other tasks by its duration.
* **CI**: no workflow runs `tests/http-client.test` yet (it needs the
  provider's and the unit's builds, Python's h2 and nghttpd); it runs
  locally.

## 15. Consequences for the agent TUI

For an agent TUI the HTTP side is now usable: streaming responses
(server-sent events arrive as chunks the program decodes itself),
cancellation tokens for a user's interrupt, deadlines and idle timeouts,
bearer tokens in headers, JSON bodies as bytes, and one event loop for the
network, timers and other packages. What it still lacks on the HTTP side
is small and consumer-level: no SSE or JSON parser in the package (a
consumer's few dozen lines), no proxy support (an issue on networks that
require `HTTPS_PROXY`), and the platform restriction (Linux x86-64). The
remaining obstacles are elsewhere: managed subprocess execution (an
agent's tools), terminal input and rendering as event-loop sources, and
reading a credential file -- all outside the HTTP client.

## 16. Architectural questions

**A. Can a third-party Botlish application now use a production-quality
HTTP client without knowing that its implementation uses Hyper, Rust or
BoringSSL?** Yes, on Linux x86-64. The clean room's consumer and the
`feeds` library are written against URIs, headers, Bytes, statuses,
declared errors and two resource owners; they never name a handle, a Rust
type, a BoringSSL object or a C type, and the installation needs no Rust,
Cargo or BoringSSL source -- only the C compiler driver and the C++
standard library's link name the system linker needs, which README.md
states. "Production-quality" with stated limits: no proxy support, no
redirects, Linux x86-64 only (section 14).

**B. Can that client coexist with independently authored event-loop
consumers under one shared driver and one coherent package graph?** Yes.
Clean room D: `feeds` (its own client and timer, written apart from
`http`) and the application's own requests run concurrently under the
application's one driver, from one graph holding one instance of
`event_loop_linux`, `http` and `boringssl`; a library that locks another
provider release is refused as a DEPENDENCY-CONFLICT, the installation
unchanged. Nothing in `http` installs or selects a driver: the
application installs it, and `http::create()` takes the driver's
integration capability as a context.

**C. Can long-lived streaming HTTP requests run without monopolizing the
event loop, leaking resources or bypassing Botlish's explicit context
authority?** Yes, with one bound to keep in mind. The executor polls at
most 32 ready tasks per step (`http-executor-budget`), readiness and
timers are the loop's, and a reader that stops reading stops the server
(at most one chunk held natively; a 64 MiB stream grew the process by
3.5 MiB). Resources are released on every exit, abandonment included, and
the lifetime fuzzer, cancellation, release and abandonment tests end with
no client, exchange, task or watch left -- after the compiler fix of
section 12, without which natively compiled consumers leaked exchanges in
some code shapes. Authority: every operation that connects requires the
`Http` context, made from the driver's `Native` capability, which only an
entry program installs; no native function is public. The bound: a TLS
handshake runs on the loop's thread (section 11 measures it).

**D. What additional language or standard-library facilities, if any,
were genuinely necessary rather than merely convenient?** None was
necessary: the package is ordinary Botlish over existing facilities --
the C FFI with byte borrowing, layouts, resources and lexical cleanup,
shared dependencies, the event loop and its Linux driver. One compiler
*defect* had to be fixed (section 12, F1): it made resources leak, so it
blocked correctness, not expressiveness. Convenient but absent: integer
division (B9), a `str` join or format (lines are built with a fold), an
SSE or JSON decoder (consumers' code), a driver `rearm` with an interest
(B5, worked around), and method-call decisions that do not cost a
whole-program build per call in some import sets (F3).

**E. Is the remaining obstacle to a cleanroom AI-agent TUI primarily
managed subprocess execution, or does HTTP still have consumer-visible
deficiencies?** Primarily subprocess execution, terminal input and output
as event-loop sources, and the platform restriction. On the HTTP side the
consumer-visible deficiencies are small and known: no proxy support
(environments that require `HTTPS_PROXY` cannot reach a provider), no
built-in SSE or JSON decoding (a consumer's few dozen lines), and Linux
x86-64 only.
None of them needs the client's architecture to change.

## 17. Commands

Build the native files (Botlish's cache, once; needs cargo and rustc 1.95+,
cmake, ninja, cc and c++, git, the network):

```bash
tclsh9.0 tests/cffi/http.tcl
```

The tests (Python 3 with `h2`, openssl; nghttpd where installed):

```bash
LANG=C.utf8 LC_ALL=C.utf8 tclsh9.0 tests/http-client.test -tmpdir "$(mktemp -d)"
```

```bash
tclsh9.0 tests/resources.test
```

Fuzzing, mutation testing and measurements:

```bash
tclsh9.0 audit/http-client/tools/syntax-fuzz.tcl -seed 1 -count 3000
```

```bash
tclsh9.0 audit/http-client/tools/mutate.tcl
```

```bash
tclsh9.0 audit/http-client/tools/measure.tcl -runs 3
```

The release artifacts (in the pinned author image, for a release):

```bash
tools/package-build/author.sh image
```

```bash
tools/package-build/author.sh build OUT -release boringssl event_loop_linux http
```

or, as candidates on any host with the toolchains:

```bash
tclsh9.0 tools/package-repository.tcl OUT boringssl event_loop_linux http
```

The clean room (Docker; the single-file compiler from `single/build.sh`):

```bash
audit/http-client/cleanroom/cleanroom.sh image
```

```bash
audit/http-client/cleanroom/repository.sh REPO OUT
```

```bash
BOTLISH_CLEANROOM_SYSTEM_CA=/path/to/operator-root.pem audit/http-client/cleanroom/cleanroom.sh run single/out/botlish REPO RESULTS
```

(`repository.sh REPO OUT` copies the three releases from the directory
`OUT` made above; `repository.sh REPO` builds them itself.)
