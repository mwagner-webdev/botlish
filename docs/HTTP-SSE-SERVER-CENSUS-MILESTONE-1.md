# HTTP-SSE-SERVER-CENSUS-MILESTONE-1

What is still missing before a Botlish program can serve ordinary HTTP/1.1
API requests and long-lived Server-Sent Events streams concurrently,
correctly and with bounded resources. A census, not an implementation: no
compiler, runtime, standard-library or package file changed. The probes and
their results are `../audit/http-sse-server-census/`
(`tools/run.sh` rebuilds and reruns every one of them).

Base: `main` at `ede621b1` (2026-11-13). Host: a Linux x86-64 container
(4 cores, no IPv6 in its kernel), Tcl 9.0.1, rustc 1.97.0, the native
backend built in release mode. Clients: curl 8 and Python 3 sockets.

Evidence labels, used throughout:

* **observed** -- run here; the command and its output are in the audit
  directory's `results/`.
* **source-inspected** -- read in the repository at `ede621b1`, with the file
  named.
* **CI-verified** -- taken from a GitHub Actions run (named).
* **inferred** -- follows from observed or inspected facts; not run.
* **unverified** -- could not be run here; the reason is given.

Main's CI when this census started (**CI-verified**): main's newest finished
`tests` run (`023dfaa3`, run 43162363612) failed in one job, `tests
(cranelift coverage)`, on `vt-large` (tests/value-transfer.test), an
intermittent failure RN-HOST-STARTABLE-APPLICATION-LIBRARY-MILESTONE-1.md
section 21 records; every other job, and tests (linux arm64), tests (macos
arm64), tests (windows x86-64), the Icy Tower workflows, single executable,
c-bindgen and bench at that commit, succeeded. The runs at `ede621b1` were
queued or in progress. This census adds no code any workflow tests.

Contents:

1. Executive verdict
2. Target contract
3. Architecture inventory
4. HTTP/1.1 capability matrix
5. SSE capability matrix
6. Executable probe results
7. Context and ownership assessment
8. Memory and backpressure assessment
9. Platform assessment
10. Prioritized gap register
11. Minimal milestone sequence
12. Recommended next milestone
13. Method and limits

## 1. Executive verdict

**The target is not blocked by the language, the compiler or the runtime.**
A probe server written entirely in Botlish -- about 1,200 lines: the Linux
socket syscalls over the raw syscall transport, HTTP/1.1 heads and
responses, SSE framing, one task per connection on `std::event_loop` and
the Linux driver package's readiness watches, no C of its own and no
change to anything in the repository -- serves the whole acceptance
application on Linux x86-64 (**observed**, section 6): `GET /health`,
`GET /items` and `POST /items` with JSON bodies, `GET /events` as a
long-lived event stream, to many clients at once. An independent client
(Python sockets and curl, nothing of Botlish) drives fifteen scenarios
against the built executable and every one passes: persistent connections
and pipelining, a request in 74 one-byte writes, a stalled client beside
prompt ones (0.9 ms worst latency), events delivered 0.7-1.1 ms after
the POST that caused them, heartbeats on idle streams, a disconnected stream
noticed 1 ms after the client's FIN with its descriptor back, Last-Event-ID
replay from a bounded ring, a subscriber that stops reading dropped at a
64 KiB bound while a healthy one receives all 2,000 events of a burst, a
reset during a burst, 200 concurrent clients, steady memory over 6,000
requests, and a shutdown with streams, a half-sent head and an idle
keep-alive connection open: every stream told, every socket released by
its resource's cleanup, exit status 0 in 50 ms. Under native GC stress the
fifteen pass too, but for one transient failure of the 200-client scenario
in six runs (67 client errors, most likely timeouts at a hundredfold
slowdown; section 6.3).

So the preferred hypothesis holds: **most of the remaining work is package
development** -- a TCP transport, an HTTP/1.1 server with SSE, JSON -- on
facilities that exist. It holds with a short list of exceptions, each
reproduced:

| # | Gap | Layer | Blocks |
|---|---|---|---|
| G1 | No socket syscalls in `std::linux`, and a package cannot be portable without them: architecture-specific modules are the standard library's alone (`surface/modules.tcl`'s `ModuleFile`) | C | portability to linux-aarch64 (the probe is x86-64 only); authority mediation |
| G5 | `std::abi::bytes::Bytes` has no byte access (index, search): request heads are found by decoding UTF-8 | C | correct handling of non-UTF-8 header octets (obs-text: rejected with 400); copies |
| G7 | `std::event_loop::wait` waits on one registration with no deadline | C | efficient per-connection timeouts (the probe broadcasts ticks to every connection) |
| G10 | **A program cannot take SIGTERM/SIGINT**: it runs on a worker thread, so a signal it blocks still kills the process through the main thread | **D** | graceful shutdown under a supervisor (systemd, containers) |
| G11 | No JSON decoder (only a validator and emitters in `examples/dfa/json/`) | B | validated request bodies |
| G13, G14 | No event-loop driver for macOS or Windows | E | any platform but Linux |
| G6 | Every read costs three buffers (a zeroed one, the kernel's detached copy, the prefix kept); a partial send copies the remainder; no gather write | F | throughput only |

**One runtime gap (G10) is the only finding that needs a compiler or
runtime change, and it blocks production operation, not a functional
server.** Everything else is package or standard-library work.

**The minimum remaining work** is therefore: socket syscalls and byte
search in the standard library (G1, G5; small), an HTTP/1.1 + SSE server
package on the Linux driver (G2-G4; the probe is its feasibility proof),
a JSON package (G11), and, for production, the runtime's signal policy
(G10), deadline waits (G7), the driver's interest change and table limits
(G8, G9) and a wall clock (G15). Section 11 orders them; section 12 scopes
the first.

## 2. Target contract

**Supported** (the acceptance target as this census reads it):

* One Botlish process listening on a configurable TCP port, IPv4 and IPv6
  loopback or any address, HTTP/1.1 (and HTTP/1.0 requests) in clear text;
  TLS terminated by a reverse proxy in front.
* `GET /health` -- a small text response. `GET /items` -- a JSON array.
  `POST /items` -- a JSON object body bounded by a limit, appended to
  application state, answered `201`, published as an event. `GET /events`
  -- `text/event-stream`: `retry:`, `id:`, `event:` and multi-line `data:`
  fields, heartbeat comments on idle streams, open until the client leaves
  or the server shuts down, `Last-Event-ID` honored from a bounded
  in-memory history.
* Concurrency: any number of clients up to a configured limit, one blocking
  neither another nor the streams.
* Robustness: requests split across reads and several requests in one read;
  limits on the head, the body and the number of connections; malformed
  requests answered `400`/`431`/`413`/`501`/`505` and the connection
  closed; idle connections closed; a stream whose client does not read
  dropped at a byte bound; disconnects noticed without waiting for a write;
  no death by SIGPIPE; a clean shutdown that tells streams and releases
  every socket.

**Excluded:** TLS, HTTP/2 and HTTP/3, WebSockets, a general web framework
(routing DSL, middleware, templating), durable event replay, chunked
*request* bodies (`501` is a correct answer for a server that does not
implement them: RFC 9112 section 6.1), compression, range requests,
`Expect: 100-continue` (a client that sends it and waits gets its body
read after its timeout; the probe does not answer `100`), multi-core
serving (section 7, optional), and a thread per connection.

## 3. Architecture inventory

Each facility with its status in the census's five classes: (1) public and
demonstrated, (2) implemented, not public, (3) only through FFI or
platform-specific code, (4) partial or constrained, (5) missing.

| Facility | Where | Class | Evidence |
|---|---|---|---|
| Scheduler: tasks (ordinary coroutines), registrations (sources, channels, timers, observers), Delivery policies, generation-checked revocation, owned registrations, `run`/`shutdown`/`abandon` | `stdlib/event_loop.bot` (`wait` 1441, `post` 1196, `source` 907, `owned_source` 1042, `every` 894, `run` 1769, `shutdown` 1844) | 1 | observed (P2, P5); tests/event-loop.test |
| Wait on several registrations, or with a deadline | -- | 5 | source-inspected: `wait(reg)` takes one registration; `sleep` makes its own timer. A record carries two Ints (`a`, `b`), so a source and Botlish posts share one registration and a task wakes for any of them (the pattern P2 and `tests/event-loop/native/linuxnet.bot` use) |
| Linux driver: epoll, an eventfd, monotonic clock, readiness watches (`watch`, `rearm`, `unwatch`; EPOLLONESHOT, EPOLLRDHUP), endpoints for native producers | `packages/event_loop_linux/` (module; C adapter `native/event_loop_linux.c`) | 1 (a package with its own C adapter) | observed (P2); tests/event-loop-linux.test's game server on real TCP sockets |
| Change a watch's interest | -- | 5 | source-inspected: interest is fixed at `evl_watch` (`event_loop_linux.c` 556); P2 switches with `unwatch` + `watch` |
| Watch capacity | `MAX_WATCHES 4096`, static arrays, linear scan for a free slot (`event_loop_linux.c` 74, 559) | 4 | source-inspected: at most 4,095 connections per loop |
| Sockets (socket, bind, listen, accept4, setsockopt, getsockname, sendto, shutdown) | -- in `std::linux` (`stdlib/linux.bot`: read, write, openat, close, getdents64, mkdirat, unlinkat) | 3 (raw transport) | observed: P1/P2's `rawnet.bot`, a direct module over `std::linux::abi::x86_64::syscall`, all of them, two writable exposures in one getsockname included |
| Architecture-specific module selection | `surface/modules.tcl` `ModuleFile` (1163: `StandardNamespace` first) | 2 | source-inspected: only `std::` namespaces choose `P.ARCH.bot`; a package cannot ship per-architecture syscall numbers |
| Socket I/O through libc instead | `extern c fn` + byte borrowing (`read noescape`/`write noescape`) + errno through `__errno_location()` | 3 | source-inspected: the pattern `stdlib/darwin.bot` and `packages/process_linux` use; not probed for sockets |
| SIGPIPE | `native/src/runtime/aot.rs` 167-193: an executable ignores it at startup; the driver is a Rust program (Rust's startup ignores it) | 1 | source-inspected; observed: P2 S14 (a reset during a burst; the probe also sends with MSG_NOSIGNAL) |
| SIGTERM/SIGINT as events | -- | 5 | observed (P3): see G10 |
| Monotonic time | `event_loop_linux::now_us`, `std::event_loop::now` | 1 | observed |
| Wall-clock time | -- | 5 | source-inspected: no CLOCK_REALTIME anywhere in `stdlib/` or `packages/` |
| Owned bytes: `Bytes`, `MutableBytes` (value semantics), `join`, `slice`, `decode_utf8`, `freeze_prefix` | `stdlib/abi/bytes.bot` | 1 | observed |
| Byte access (index, search, to List) | -- (`stdlib/abi/bytes.bot` 98: "Not here, deliberately: indexing") | 5 | observed (P1 case 3, `bytes_list.bot`); workarounds: decode then search text (P2's `http1::scan`), or a fixed layout `array N of U8` parsed with `std::binary::parse` (`bytes_list.bot`, every backend) |
| Strings: `char_at`, `substring`, `concat`, `append_char`, `length`, `lowercase`, `encode_utf8`; `std::int::to_string`/`from_string` | `core/strings.tcl`, `core/inttext.tcl` registrations | 1 | observed; no `find`/`split` (P2 writes its own) |
| Contexts (opaque context structs, `with context`, static selection), context traits | the language; `stdlib/io.bot` | 1 | observed (P2's `App`; P5's `Routes`) |
| A handler as a function value | -- | 5 by design | source-inspected: CONTEXT-FUNCTION-VALUE (`hir/contexts.tcl` 62, 1406): a function requiring a context is no value |
| Resources: `opaque resource struct` + `cleanup fn`, released where the owner's scope ends, on every exit and on abandonment | the language (`hir/resources.tcl`); `process_linux`'s `ChildOwner` | 1 | observed (P2: `released` equals `accepted` in every run) |
| Concurrency across cores | `std::thread` (a VM per OS thread), `std::actor::remote`, the driver's ABI v2 (a loop per VM) | 1 | source-inspected (BOTLISH-OWNED-THREADS-AND-CROSS-THREAD-ACTORS-MILESTONE-1.md); not probed for serving |
| JSON | `examples/dfa/json/` (recognizers, `validate_bytes`, certified emitters); nothing in `std` | 4 | source-inspected (FUZZING-JSON.md: "the standard library has no JSON emitter"; `decode_text`/`decode_bytes` decode one string token) |
| HTTP | `packages/http`: a client (Hyper and BoringSSL in Rust); `audit/http-stack/`: a Hyper *server* probe | client 1; server 3 (Rust) | source-inspected; another language's server is no evidence here and is not used |
| macOS / Windows networking | Darwin IO through libSystem (`stdlib/darwin.bot`); Windows I/O through kernel32 (`stdlib/windows.bot`); no event-loop driver on either | 5 | source-inspected (EVENT-LOOP-MILESTONE-1.md section 14); observed: P2 refused for both targets |

## 4. HTTP/1.1 capability matrix

What a correct minimal HTTP/1.1 server must do (protocol obligations) and
what can wait, against what Botlish has. "Probe" names the scenario that
shows it (section 6).

| Requirement | Obligation? | Botlish today | Status | Evidence |
|---|---|---|---|---|
| Bind and listen, IPv4 | yes | raw syscalls (`rawnet.bot`) | available, not in `std` (G1) | observed P1, P2 |
| Bind and listen, IPv6 | yes for "any address" deployments | the same syscalls, a 28-byte `sockaddr_in6` | **unverified** (no IPv6 in this kernel: `socket(AF_INET6)` is -97 here, for Python too) | P4 |
| Accept, close, half-close (`shutdown`) | yes | raw syscalls | available (G1) | observed |
| Nonblocking accept/read/write with readiness | yes | `SOCK_NONBLOCK`, watches, `-11` (EAGAIN) | available | observed S04, S10 |
| Incremental, fragmented request heads | yes | `join` + decode with a cut character allowed at the end (`http1::decoded`) | available with a workaround (G5) | observed S03, P1 |
| Request line, header fields, case-insensitive names | yes | `char_at`/`substring`/`lowercase`, hand-written search | available | observed S11 |
| Header octets outside UTF-8 (obs-text) | must be parsed or rejected | rejected with `400` | constrained (G5) | observed S11 ("invalid UTF-8 head") |
| `Host` required in HTTP/1.1 | yes (`400` without it) | yes | available | observed S11 |
| `Content-Length` bodies, split anywhere | yes | `blen`/`bslice` | available | observed S03 |
| Chunked request bodies | a server may answer `501` | `501` | deferred (F) | observed S11 |
| Status line, headers, `Content-Length` responses | yes | yes | available | observed S01 |
| Persistent connections, `Connection: close`, HTTP/1.0 default close | yes | yes | available | observed S02, S11 |
| Pipelined requests answered in order | yes | yes (one task per connection reads them in order) | available | observed S02 |
| Partial writes | yes | `sendto` result, `slice` of the rest, writable interest while output is pending | available; the rest is copied (G6) | observed S10 (9 EAGAIN, 1 interest switch) |
| Head, body and connection limits | yes for production | `431`, `413`, refuse beyond `max_conns` | available | observed S11 |
| Read/idle timeout | yes for production | a ticker posts to every connection; each checks its deadline | available, O(connections) per tick (G7) | observed S04 (closed 2.04 s after a 2 s deadline) |
| Write timeout | yes for production | the same ticker could check it; the probe bounds bytes instead | not probed (inferred feasible, G7) | -- |
| Malformed input | yes | `400`/`505`/`501` and close | available | observed S11 |
| `Date` header | MUST for an origin server *with a clock* (RFC 9110 section 6.6.1) | no wall clock | missing (G15) | source-inspected |
| Graceful shutdown with requests active | yes for production | an in-process trigger works (`POST /shutdown`); **SIGTERM does not** | partial (G10) | observed S13, P3 |
| `Expect: 100-continue`, ranges, compression, trailers | no | -- | deferred (F) | -- |

## 5. SSE capability matrix

| Requirement | Botlish today | Status | Evidence |
|---|---|---|---|
| `Content-Type: text/event-stream`, response framed by the connection's end (no `Content-Length`, no chunking: RFC 9112 section 6.3 item 8) | the connection task writes the head and switches to stream mode | available | observed S05 (curl and Python read it) |
| `data:` lines, CR/LF/CRLF in the payload split into data lines, blank-line termination | `http1::data_lines` | available | observed S05 (CRLF in a JSON body arrives as two data lines, rejoined to the original) |
| `event:`, `id:`, `retry:` | written per event; `retry: 1000` once | available | observed S05 |
| Many events on one open response | yes | available | observed S05, S10 (2,000 events) |
| Heartbeat comments on idle streams | `: heartbeat` when the ticker finds the period passed | available | observed S07 (4 in 1.65 s at 300 ms; the ticker's 100 ms granularity) |
| Streaming without buffering the response | each event is appended to the connection's pending bytes and sent at once | available | observed S05 (0.7-1.1 ms from POST to event) |
| Multiple subscribers | a subscriber table in the application context; one post per subscriber | available | observed S06 (5 streams) |
| Events from other requests and tasks | `publish` frames the event once into a ring and posts its sequence number to each subscriber's registration (a record carries two Ints, never data) | available | observed S05, S06, S10 |
| Ordinary requests while streams are open | yes | available | observed S06 (50 requests beside 5 streams: worst 0.9 ms) |
| Disconnect detection without a write | the stream's watch stays readable-armed; a read of 0 ends it | available | observed S08 (1 ms after the FIN; descriptors back to baseline) |
| Backpressure: bounded per-subscriber output | the pending bytes are checked after every append; beyond the bound the stream is dropped | available | observed S10 (dropped at 69,510 bytes against a 65,536 bound: the bound plus one wake's events) |
| A slow subscriber must not stall others | the publisher writes into the ring and posts; each subscriber sends from its own task | available | observed S10 (the healthy stream got all 2,000) |
| A burst larger than the history | the publisher yields every 32 events (`yield_now`); a subscriber that falls more than the ring behind is dropped (`lagged`) | available (a policy) | observed S10 (ring 4,096); inferred: with a ring smaller than a burst and no yields, every subscriber lags |
| Cancellation and shutdown of streams | a stop flag and a broadcast post: each stream writes `event: shutdown`, flushes and closes | available | observed S13 |
| `Last-Event-ID` on reconnect | events after it replayed from the ring when it is still there | available (in memory) | observed S09 |
| Durable replay | -- | out of scope | -- |

**A server that sends one event and closes** is not what the probe does:
S05 checks the response is still open after the last event, S07 that an
idle stream stays open on heartbeats.

## 6. Executable probe results

All commands from the repository root with `LANG=C.utf8 LC_ALL=C.utf8`.
`sh audit/http-sse-server-census/tools/run.sh all` assembles each probe as
an application in a temporary directory, builds it with `main.tcl
-emit-native-executable` and runs its driver. The results files hold the
outputs quoted here.

### 6.1 P1: a listener over raw syscalls, no event loop (`probes/p1/listen.bot`)

`sh tools/run.sh p1` -> `results/p1-listen.txt` (**observed**). Every
syscall succeeds (`socket 3`, `setsockopt 0`, `bind 0`, `listen 0`,
`getsockname 0` -- two writable byte exposures in one syscall); curl gets
`HTTP/1.1 200 OK` with the expected body (exit 0); a request sent in 26
fragments of 1-3 bytes is assembled from 26 reads and answered. Its third
case is a deliberate negative: P1 decodes each read separately, and a
request whose path holds `é` cut between two reads fails with InvalidUtf8
-- the reason P2 accumulates bytes and decodes the whole head, allowing a
cut character only at the end (G5).

### 6.2 P2: the target application (`probes/p2/`)

`server.bot` (entry: installs `std::event_loop::create(64)`, the Linux
driver, its `Native` capability and the application context `srv::App`,
opens the listener, starts the acceptor and ticker tasks, runs the loop),
`srv.bot` (the server: tasks, publishing, the socket resource), `http1.bot`
(the protocol half: pure Botlish, no authority), `rawnet.bot` (syscalls).
Build: 30.1 s for `-emit-native-executable` here (P1: 2.5 s); a 12 MB
executable.

`sh tools/run.sh p2` -> `results/p2-scenarios.txt` (**observed**, 15/15
PASS, 15 s; the same run assembled by `tools/run.sh` from the committed
files):

| Scenario | What the independent client did | Result |
|---|---|---|
| S01 curl | `curl -i /health`; `curl -X POST -d '{"name": "first"}' /items`; `curl /items` | `200`; `{"id": 1}`; `json.loads` gives `[{"name": "first"}]`; exit 0 |
| S02 persistence, pipelining | 5 requests on one connection, 3 pipelined in one send, the last with `Connection: close` | 5 x `200` in order; closed after the last |
| S03 fragmentation | a POST in 74 one-byte sends, UTF-8 body cut inside `é` and `☕` | `201`; the item stored exactly |
| S04 concurrency | one connection holds half a head; 20 requests on others | worst 0.9 ms, median 0.2 ms; the stalled one closed by the 2 s idle deadline 2.04 s later |
| S05 stream | `/events` open; 3 POSTs 300 ms apart, CRLF inside the JSON | ids 1, 2, 3; 0.7-1.1 ms from each POST to its event; data rejoined exactly; still open |
| S06 requests beside streams | 5 streams open; 50 requests; one POST | worst 0.9 ms; each stream got the event |
| S07 heartbeat | an idle stream for 1.65 s at a 300 ms period | 4 comments |
| S08 disconnect | 3 streams, then the clients close | ended 1 ms after the FIN, no write needed; server descriptors 6 -> 9 -> 6; `released` = `closed` |
| S09 Last-Event-ID | 5 events, reconnect with `Last-Event-ID: 2` | ids 3, 4, 5 |
| S10 slow consumer | `SO_SNDBUF` 4 KiB; a stream that never reads beside a healthy one; 2,000 events of ~230 bytes | healthy: 2,000; the reader-less stream dropped at 69,510 bytes queued (bound 65,536); RSS 4,308 -> 6,028 KiB; requests afterwards: worst 1.0 ms |
| S11 limits, malformed | 10 bad or edge requests | `431`, `413`, `400` (garbage line, no Host, invalid UTF-8, non-JSON body), `501` (chunked), `505` (HTTP/2.0), `404`, HTTP/1.0 closes; server still answers |
| S12 many connections | 200 concurrent clients x 5 keep-alive requests | 200/200 in 0.18 s; descriptors back to 6 |
| S13 shutdown | 3 streams, a half-sent head and an idle keep-alive connection; `POST /shutdown` | every stream got `event: shutdown` then EOF; the other two EOF; exit 0 in 0.05 s; `accepted 7 closed 7 released 7` |
| S14 reset | a client resets its stream (SO_LINGER 0) during a 500-event burst | server alive, exit 0 |
| S15 memory | 6,000 keep-alive requests in batches | VmRSS 5,568 KiB after 1,000, 5,600 after 6,000 |

### 6.3 P2 under GC stress

`BOTLISH_NATIVE_GC_STRESS=1` (a collection attempt at every allocation)
set for the server (**observed**). The first pass
(`results/p2-scenarios-gc-stress.txt`, a build from before `http1.bot` was
split out of `srv.bot`: the same code, moved) passed 14 of 15 (S10's burst
took 8.6 s instead of 0.05 s); S12 failed once: 133 of 200 clients
completed, 67 errors, within the driver's 10 s client timeout, at 14.6 s.
S12 rerun four times under GC stress with the same timeout
(`results/p2-s12-gc-stress.txt`): 200/200, 0 errors, 18.0-19.7 s each.
A second full pass from the committed files (`tools/run.sh p2-gc`,
`results/p2-scenarios-gc-stress-2.txt`): 15 of 15, S12 in 21.1 s. The server stayed up and returned to its
baseline descriptors in the failing run too. The errors' kind was not
recorded in that run (the driver printed only their count; it prints them
now). **Inferred:** client-side timeouts -- the listen backlog is 128, so
connections beyond it can wait for SYN retransmissions (1 s, 3 s, ...),
and every request is about 100 times slower under stress -- not a server
fault; not proven.

### 6.4 The protocol half on every backend (`probes/p2/protocol.bot`)

`sh tools/run.sh protocol` -> `results/p2-protocol-backends.txt`
(**observed**): interp, compile, cranelift and cranelift-generic print the
same value -- scanner states for prefixes a read could deliver (`[0, 0, 0,
1, 1]`), the head's byte length 81, method, target, `Content-Length` 14,
the UTF-8 body, a head cut inside a character reported incomplete (0, not
invalid), non-UTF-8 octets reported invalid (3), an over-long head (2),
missing Host `400`, chunked `501`, HTTP/1.0 closing, SSE data lines, a
response's bytes. The server itself is native-only: `main.tcl run -backend
interp` refuses its first C call with NATIVE-ONLY
(`results/p2-backends-and-targets.txt`).

### 6.5 Byte access (`probes/bytes_list.bot`)

`results/bytes-list.txt` (**observed**, every backend): decoding the
first 6 bytes of `GET /é H\r\n\r\nxyz` fails (InvalidUtf8); a 16-byte
layout `array 16 of std::binary::U8` parsed with `std::binary::parse`
gives the 16 bytes as a List and the head's end (9) without decoding. Only
for a buffer of exactly the layout's size (LayoutLengthMismatch
otherwise). Two frictions found on the way, neither a defect:
`std::abi::bytes::from_list([71, 255])` is a TYPE error by design
(tests/abi-bytes.test's `abi-bytes-rejects-non-byte-lists-statically`:
Ints are converted to Byte explicitly), and a List of a domain type is not
admitted where `List[int]` is declared (`List[int[std::binary::U8]]` for a
`List[int]` parameter).

### 6.6 P3: SIGTERM (`probes/p3/signal.bot`)

`sh tools/run.sh p3` -> `results/p3-signal.txt` (**observed**). The
program blocks SIGTERM (`rt_sigprocmask`: 0), opens a signalfd for it (3)
and reads it; the driver sends SIGTERM to the process. The process has two
threads, and the program runs on the second (`pid 6226 tid 6227`): the
runtime's worker (MAIN-THREAD-STARTUP-MILESTONE-1.md: `worker` is every
target's default; `main-thread` is macOS AArch64's only). The main thread,
which only joins the worker, does not block SIGTERM, so the kernel delivers
the process-directed signal there and the default action ends the process:
**exit status -15**, the read never returns. Nothing a Botlish program can
call changes another thread's mask. G10.

### 6.7 P4: IPv6 (`probes/p4/ipv6.bot`)

`results/p4-ipv6.txt`: `socket(AF_INET6)` returns -97 (EAFNOSUPPORT); the
container has no `/proc/net/if_inet6` and Python's `socket.AF_INET6` fails
the same way. **Unverified.** The probe differs from P2's IPv4 path only
in the address bytes; GitHub's ubuntu runners have IPv6 loopback, so a CI
run of `tools/run.sh p4` settles it.

### 6.8 P5: the transport/application seam (`probes/p5/`)

`results/p5-handler-seam.txt` (**observed**, every backend, the
deterministic driver). A library module (`weblib.bot`) declares `context
trait Routes: fn route(path: str) -> str` and a connection task that calls
`r.route(p)`. The application (`app.bot`) implements it with its own
context `Items`: the implementation changes the application's state,
reaches `std::event_loop::Loop` through a helper, and yields -- inside the
library's task. The traces are identical on interp, compile, cranelift and
cranelift-generic. Declaring the Loop as a second context of the
implementation makes it no implementation ("an implementation takes
exactly one, the context Items it implements", MISSING-CONTEXT): the
helper is the way.

### 6.9 Other observations

* Targets (`results/p2-backends-and-targets.txt`): `-check -target
  linux-aarch64` accepts P2 -- the x86-64 transport is a Linux namespace on
  any Linux target -- but it cannot run there (an x86-64 syscall);
  `macos-aarch64` and `windows-x86_64` refuse it at `rawnet.bot`'s import
  of `std::linux::abi::x86_64` (UNSUPPORTED-PLATFORM).
* Allocation figures: section 8.

## 7. Context and ownership assessment

How P2 represents each lifetime, and what it shows:

| Lifetime | Representation in P2 | Assessment |
|---|---|---|
| Server | `srv::App`, an opaque context struct installed by the entry program: configuration, counters, items, the event ring, the connection table (registrations, live and subscriber flags, current watches) | natural; mutable through context places, one thread, no locks |
| Listening socket | the acceptor task: a watch on the descriptor, an owned source; closed when the task ends | a resource would close it on abandonment too (not done in the probe) |
| Accepted connection | one task (a coroutine adopted by the loop) holding two resources: `SocketOwner` (its cleanup stops the recorded watch, shuts down and closes the descriptor) and the registration's `Owner` (revokes it); task-local MutableArrays for input, output and state | **the strongest result**: every exit of the task (end of input, error, limit, idle, slow drop, shutdown) leaves through the owners' scope, and `released` equals `closed` wherever the driver compares them (S08; S13: accepted 7, closed 7, released 7), GC stress included |
| Request | a `http1::Request` value and its body `Bytes`; scratch is locals | no lifetime question: values |
| Response | `Bytes` appended to the connection's pending output | a streaming response is a mode of the connection task, not an object |
| SSE subscription | the same connection task in stream mode; its registration in the subscriber table | publishers never hold the stream: they post a sequence number; payloads live once, in the ring |
| Application state | `App`'s collections | shared by every task through the context, statically |
| Shutdown, cancellation | a stop flag and a broadcast post; `std::event_loop::shutdown`/`abandon` would unwind tasks and run their cleanups | observed for the flag; abandonment's cleanups are source-inspected (Resources, AGENTS.md) |

The census's questions:

* **Can a connection retain its own mutable parsing and output state?** Yes
  (**observed**): task-local MutableArrays live in the coroutine across its
  suspensions.
* **Can handlers receive dependencies through contexts?** Yes inside one
  program (**observed**: `srv::handle` requires `App` and `Loop`). Across a
  library boundary, not as a callback: a function requiring a context is
  no value (CONTEXT-FUNCTION-VALUE). The designed seam is a context trait
  the application implements, selected statically and monomorphized
  (**observed**, P5) -- the shape `std::event_loop::Driver` and `std::io::IO`
  already have. Its one constraint: the implementation declares only its
  own context and reaches others through helpers.
* **Can one request publish an event consumed by independent SSE
  connections?** Yes (**observed**, S05, S06). A registration carries two
  Ints, so the event's data cannot travel in the record: it goes into
  shared state (the ring) and the record carries its sequence number. That
  is a property of `std::event_loop`, not a defect; a channel of values
  would be a library addition (`std::actor` mailboxes already carry values
  between same-thread actors).
* **Can an SSE writer retain what it needs without extending a request's
  lifetime?** Yes: the stream needs only its descriptor, its registration
  and a cursor into the ring; nothing of the request.
* **Can connections be cancelled and resources reliably released?** Yes
  (**observed**, S08, S13; GC stress included).
* **Timers, socket I/O and other tasks on one loop?** Yes (**observed**:
  the ticker, every connection and publishing share one loop). The friction
  is G7: a task waits on one registration, so a connection's deadline
  reaches it as a post from a ticker that visits every connection.
* **Restrictions around affine values, coroutine frames, mutable state
  across suspension?** None met. The owner/identity split (`process_linux`'s
  `Spawned {owner, child}`, P2's `SocketOwner` plus the descriptor number)
  is needed because passing a resource to a function moves it; the probe
  followed that idiom without trouble.
* **Separation of transport and application?** P2's `http1.bot` has no
  authority and runs on every backend; `srv.bot` holds the authority. A
  package would put the transport behind its own context (as
  `std::linux::io`'s LinuxIO and `process_linux`'s Processes do) so that the
  application is not a `direct module` -- P2 is, because it calls
  `rawnet.bot` directly (DIRECT-MODULES.md).

Language versus library: every awkwardness above is a library's (G1, G5,
G7, G8) or a documented language rule with a workaround (one declared
context per trait implementation; no stateful callbacks). None blocks the
target.

Multi-core serving (optional, **inferred**): `std::thread` runs a VM per
OS thread, each installing its own Linux driver (ABI v2: one loop per VM),
and `SO_REUSEPORT` would give each its own listener; SSE fan-out across
VMs would go through `std::actor::remote`'s copied messages. Not probed.

## 8. Memory and backpressure assessment

**Boundedness is a correctness requirement and it is met** (**observed**):

* request heads at 8 KiB (`431`), bodies at 64 KiB (`413`), connections at
  a configured maximum;
* each stream's pending output at a byte bound (S10: the bound plus one
  wake's events), its lag at the ring's size;
* the event history at the ring's size (allocated once: a MutableArray of
  Strings);
* kernel buffers by `SO_SNDBUF` (S10 sets 4 KiB) and the client's window;
* memory steady across 6,000 requests (S15) and returning near its start
  after a 2,000-event burst (S10).

**Allocations and copies** (**observed**, `results/alloc.txt`,
`tools/alloc.tcl`: native heap allocations per operation, the difference
of 110 and 10 repetitions divided by 100):

| Operation | Allocations | Bytes | By kind |
|---|---:|---:|---|
| `zeroed(4096)` then `freeze_prefix` of 32 bytes | 3 | 4,200 | MutableBytes 1, Bytes 1, Struct 1 |
| `std::linux::read` into `zeroed(4096)` | 3 | 8,264 | MutableBytes 2, Struct 1 |
| `join` of 32 bytes onto a buffer | 6 | 2,168 | List 3, ListPlan 1, Bytes 1, Struct 1 |
| `http1::scan` of a 130-byte head (decode, text search) | 248 | 11,558 | String 126, MutableArray 115, others 7 |
| `http1::scan` + `http1::parse` of that head | 323 | 18,728 | MutableArray 289, String 26, others 8 |
| `http1::response` of a 200 with a 3-byte body | 18 | 1,446 | String 5, List 5, Bytes 3, StringPlan 2, Struct 2, ListPlan 1 |
| an SSE frame (String) to `Bytes` | 2 | 400 | List 1, Bytes 1 |
| `http1::data_lines` of 30 characters | 30 | 1,398 | String 29, MutableArray 1 |

Summing the rows a `GET /health` costs P2 on the order of 350
allocations (**inferred**), nine tenths of them in the head scan and parse:
the probe's own text search makes a MutableArray per candidate position and
works character by character on a decoded String. A byte search over the
received `Bytes` (G5) replaces both; that is the largest allocation win
available, and it is library work.

What the figures and the sources say (**source-inspected** where not
measured):

* **A read costs three buffers.** `std::linux::read` takes a MutableBytes
  and the kernel writes a fresh detached copy of it
  (`stdlib/linux/sys.x86_64.bot`'s `read`: `detach`); the caller makes the
  zeroed buffer first and `freeze_prefix` copies the bytes read. A read
  that returns its count of bytes as a new `Bytes` -- one allocation of the
  right size -- would be a small `std::linux` addition (G6).
* **Appending to a pending buffer copies it** (`join`), and a partial send
  copies the rest (`slice`): there is no pointer arithmetic and the address
  bridge exposes a whole payload, so "send from offset K" needs either an
  offset-taking bridge (a registered native) or a C adapter function
  (`process_linux`'s `pl_write` takes an offset for exactly this). Worst
  case quadratic in the pending bytes; bounded by the stream's bound.
* **No gather write.** `writev`/`sendmsg` take an array of addresses in
  memory; Botlish exposes payload addresses only as syscall registers or C
  arguments, never as a pointer value stored in memory
  (C-POINTER-BORROWING.md; AGENTS.md, "C pointer borrowing"), so several
  buffers must be joined first. An optimization, not a
  correctness gap.
* **Reusable per-connection buffers and arenas are not expressible.**
  MutableBytes is a value whose every change works on a fresh copy
  (MUTABLE-BYTES.md); `stdlib/abi/bytes.bot` allows that a later
  optimization "may skip a copy when no other value can observe the
  storage", and P2's measurements show none does for `read` today. There is no arena allocator; the collector
  reclaims (S15). A long-lived SSE connection holds nothing per request, so
  the arena-reset concern does not arise in this design.
* **SSE fan-out allocates per subscriber**: each stream turns the ring's
  String into bytes again (`utf8(framed)`); storing frames as `Bytes` once
  would share them (a package choice).

Zero-allocation operation is an optimization goal; none of the above is
needed for the target.

## 9. Platform assessment

| | Linux x86-64 | Linux AArch64 | macOS AArch64 | Windows x86-64 |
|---|---|---|---|---|
| Event-loop driver | `event_loop_linux` (observed) | the same package (its archive is built for linux-aarch64 too: tools/package-repository.tcl) | none: a kqueue driver with an `EVFILT_USER` wakeup (EVENT-LOOP-MILESTONE-1.md section 14) | none: readiness through WSAPoll or completions through IOCP (a source posting completion records, the section's design note); the exploration's Win32 driver ran under Wine only |
| Sockets | raw syscalls (observed) | raw syscalls need the AArch64 numbers in a standard-library module (G1), or libc | libSystem C functions through `extern c fn` (Darwin IO's pattern; no syscalls by rule) | Winsock through `extern c fn` (`ws2_32`), kernel32's pattern |
| P2 as written | runs | compiles, cannot run (x86-64 syscalls) | refused: UNSUPPORTED-PLATFORM | refused: UNSUPPORTED-PLATFORM |
| Protocol half (`http1.bot`) | every backend (observed) | portable (inferred: pure Botlish) | portable (inferred) | portable (inferred) |
| SIGTERM | G10 | G10 (the same worker startup) | a `main-thread` executable runs the program on the main thread (inferred: its mask is then the process's main thread's); SIGTERM there via kqueue's `EVFILT_SIGNAL` | console control events, not signals |
| CI that could verify | tests.yml (ubuntu-latest) | tests-arm64.yml | macos-arm64.yml | windows-x86_64.yml |

Components by portability:

* **Pure Botlish, portable:** HTTP/1.1 parsing and serialization, SSE
  framing, routing, the subscriber table and ring, limits and policies --
  P2's `http1.bot` and most of `srv.bot`'s logic. Testable on every backend
  and under `std::event_loop::deterministic` with a simulated network (the
  game-server scenario's `tests/event-loop/simnet.bot` is the precedent).
* **Shared interface, per-platform drivers:** the scheduler is
  platform-free; the transport needs "watch a socket for readiness"
  (Linux, macOS, WSAPoll) or "post completions" (IOCP). A transport API
  written in terms of read/write tasks (as `process_linux`'s `read`/`write`
  are) hides which.
* **Platform packages:** the socket calls and the driver.
* **Missing native capability:** none for Linux; for the others, the
  drivers (E). Neither port is a compiler gap: the C FFI, layouts and
  native views exist on macOS and Windows.

The design to avoid: making the server's API expose descriptors or epoll
facts. P2 keeps them inside `srv.bot`; a package should keep them inside
its transport.

## 10. Prioritized gap register

Ordered by what they block. "First server": blocks the first functional
server. "Production": blocks production-quality operation only.

| ID | Cat. | Missing capability | Evidence | Minimal remedy | Depends on | First server | Production |
|---|---|---|---|---|---|---|---|
| G1 | C | socket syscalls in `std::linux`, per architecture | P1, P2 needed `rawnet.bot`; `ModuleFile` selects per-architecture files for `std::` only | thin wrappers, numbers in `std::linux::sys`, a mediating context | -- | no (x86-64 works) | yes |
| G2 | B | a TCP transport package | P2's acceptor and connection task | listener/connection resources over the driver | G1 (or libc) | yes, as the package to build | yes |
| G3 | B | an HTTP/1.1 server package | P2's `http1.bot`, `srv.bot`; S01-S04, S11-S15 | the package | G2, G5 | yes | yes |
| G4 | B | SSE in that package | S05-S10, S13 | stream mode, broadcaster, bounds | G3 | yes | yes |
| G5 | C | byte index and search on `Bytes` | P1 case 3; `bytes_list.bot`; 248 allocations per head scan | `at`, `find` in the byte store | -- | no | yes |
| G6 | F | fewer copies per read and send; gather writes | `results/alloc.txt` | read returning `Bytes`; a byte queue; an offset send | G1 | no | no (throughput) |
| G7 | C | wait with a deadline, or on several registrations | `wait(reg)`; P2's ticker | `wait_until` on the deadline heap | -- | no | yes, at scale |
| G8 | B | change a watch's interest | `evl_watch` fixes it; P2 switches by re-watching | `evl_watch_modify` | -- | no | no |
| G9 | B | more than 4,095 watches per loop | `MAX_WATCHES` | growable tables | -- | no | beyond ~4,000 connections |
| G10 | D | SIGTERM/SIGINT reaching the program | P3: exit -15 | signal masks in the runtime's threads; a signalfd wrapper | -- | no | yes |
| G11 | B | JSON decoding | `examples/dfa/json/`; FUZZING-JSON.md | a `json` package | -- | partly (validation) | yes |
| G12 | B | IPv6, verified | P4 (no IPv6 here) | the address builder of G1; P4 in CI | G1 | no | yes |
| G13 | E | macOS: driver and sockets | P2 refused for macos-aarch64; EVENT-LOOP-MILESTONE-1.md section 14 | a kqueue driver, a libSystem transport | G2's API | no | on macOS |
| G14 | E | Windows: driver and sockets | P2 refused for windows-x86_64; the same section | a WSAPoll or IOCP driver, a Winsock transport | G2's API | no | on Windows |
| G15 | C | a wall clock, the `Date` header | no CLOCK_REALTIME anywhere | `clock_gettime(CLOCK_REALTIME)`, HTTP-date formatting | G1 | no | yes |

The entries in detail:

**G1. Socket syscalls in the standard library (C).**
Missing: `socket`, `bind`, `listen`, `accept4`, `connect`, `setsockopt`,
`getsockopt`, `getsockname`, `getpeername`, `sendto`/`recvfrom`,
`shutdown` in `std::linux` with their numbers in `std::linux::sys`
(x86-64, AArch64), and `sockaddr_in`/`sockaddr_in6` builders. Evidence:
`stdlib/linux.bot` has none; P1/P2 needed `rawnet.bot` with x86-64
numbers; `surface/modules.tcl`'s `ModuleFile` gives architecture-specific
files to `std::` namespaces only, so a package cannot select numbers per
architecture. Remedy: thin wrappers in the style of `std::linux::read`
(one syscall, the raw result), and a context mediating them (as
`std::linux::io::LinuxIO` mediates read and write) so that a server package
is not a direct module. Alternative without std work (B): a package over
libc's C functions (`extern c fn socket`, errno through
`__errno_location()`), portable across Linux architectures. Depends on:
nothing. First server: no (x86-64 works today). Production: yes
(portability, authority).

**G2. A TCP transport (B).** Listener and connection lifetimes as
resources (an owner and an identity, `process_linux`'s shape), accept with
a connection limit and an EMFILE policy (P2 breaks out of its accept loop
on any error: with EMFILE the listener stays readable and the acceptor
would spin -- inferred), read/write as task operations over watches with
writable interest only while output is pending, fairness bursts, counters.
Reuses: the Linux driver, resources, owned registrations. Depends on G1 (or
libc). First server: yes as a package to depend on; the probe shows it is
writable.

**G3. An HTTP/1.1 server (B).** Everything in section 4 marked available:
incremental head scanning, parsing, framing, persistence and pipelining,
limits, idle and write deadlines, error responses, shutdown; routing to the
application through a context trait (P5). Depends on G2, G5 (or the decode
workaround). First server: yes.

**G4. SSE (B, with G3).** Stream mode, framing, heartbeats, the bounded
per-stream pending bytes with a drop policy, a broadcaster with a ring and
`Last-Event-ID`. About 150 of P2's lines. Depends on G3.

**G5. Byte access on Bytes (C).** Missing: `std::abi::bytes::at(data, i)`
and `find(data, needle, from)` (and perhaps a bounded `to_list`). Evidence:
`stdlib/abi/bytes.bot` excludes indexing deliberately; P1's split
character; P2 decodes heads (and rejects non-UTF-8 octets, which HTTP
field values may contain); the layout workaround needs a fixed size.
Remedy: two natives in the byte store (core/bytestore.tcl, ops.rs), in
both runtimes. First server: no. Production: yes (obs-text, copies).

**G6. Read and write copies (F).** A read costs three buffers (a zeroed
one, the kernel's detached copy, the prefix kept: section 8); appends and
partial sends copy; no gather write. Remedy: a
`std::linux` read returning a fresh `Bytes` of the count read; a byte
queue in the transport package; an offset form of the send bridge or a C
adapter call. Throughput only.

**G7. Deadline waits (C).** `std::event_loop::wait(reg)` has no deadline
and no several-registration form. P2's ticker posts to every connection
every 100 ms: O(connections) wakes per tick for idle timeouts and
heartbeats. Remedy: `wait_until(reg, deadline)` on the scheduler's existing
deadline heap (`stdlib/event_loop.bot` 719), or a timer delivering into a
given source. Production: yes at scale.

**G8. Watch interest change (B).** `event_loop_linux` fixes a watch's
interest (`interest_bits`, `evl_watch`: `event_loop_linux.c` 546-578);
switching costs `unwatch` + `watch` (an EPOLL_CTL_DEL, an ADD, a slot), and
one descriptor cannot have two watches (epoll's EEXIST). Remedy:
`evl_watch_modify` and `event_loop_linux::modify`. Depends on nothing;
blocks neither.

**G9. Driver table limits (B).** 4,096 watches per loop in static arrays,
found by linear scan (`MAX_WATCHES`, `event_loop_linux.c` 74, 559).
Remedy: growable tables with a free list. Depends on nothing. Production
at more than ~4,000 connections per loop.

**G10. Termination signals (D).** A program cannot take SIGTERM or SIGINT
(P3: exit -15 although the program blocked SIGTERM and read a signalfd).
Remedy (runtime): the worker startup blocks the asynchronous termination
signals (SIGTERM, SIGINT, SIGHUP, SIGQUIT) in the process's main thread
-- and in any thread the runtime makes -- and leaves them unblocked in the
program's thread, so their default action is unchanged unless the program
blocks them itself and reads a signalfd (then every thread blocks them and
the signal waits for the program). `runtime::aot::run` and the native
library's threads are the places (MAIN-THREAD-STARTUP-MILESTONE-1.md's
`Startup`). Then a `std::linux` signalfd wrapper and an event-loop source.
A C adapter with a load-time constructor could block the signals before
the runtime starts -- that would hide a runtime gap behind FFI, and is not
recommended. First server: no (in-process shutdown works, S13).
Production: yes.

**G11. JSON (B).** No decoder to values: `examples/dfa/json/` validates
and emits; P2 accepts a body after a bracket check. Remedy: a `json`
package: a bounded decoder (depth, size) to a value type, and an encoder
(string escaping; the certified emitters show it can be proven). Not
`std` first (FUZZING-JSON.md recorded the emitter's absence; nothing needs
it in the compiler). First server: the target's "bounded JSON body"
wants validation; `json.bot`'s validator could be vendored meanwhile.

**G12. IPv6 (B, unverified).** The same syscalls with a 28-byte address
(P4); unverified in this kernel. Remedy: run P4 in CI (ubuntu runners
have `::1`). Depends on G1's address builders.

**G13. macOS (E).** A kqueue driver of `std::event_loop::Driver` (wakeups
by `EVFILT_USER`) and a socket package over libSystem's C functions (no
Darwin syscalls, by rule). **G14. Windows (E).** A Winsock package and a
driver (WSAPoll for readiness at small scale, or IOCP completion sources:
records carrying completed reads, not readiness). Both depend on G2's API
not exposing descriptors or epoll facts; neither blocks Linux.

**G15. Wall clock and `Date` (C).** No realtime clock in `std` or the
packages. RFC 9110 requires `Date` from an origin server with a clock.
Remedy: `clock_gettime(CLOCK_REALTIME)` in `std::linux` (or the driver) and
HTTP-date formatting in the server package (Botlish has no integer
division, `.mod` exists: a library function). Production: yes.

**Optional (F):** chunked request bodies; `Expect: 100-continue`; chunked
response streaming (to keep a connection after a stream ends); a channel
of values between tasks; multi-core serving; the Tcl backends for sockets
(never: native-only by design); `from_list` of Int literals (deliberately
a TYPE error); the List-of-domain admission seen in 6.5; the build time of
event-loop programs (30 s for P2).

## 11. Minimal milestone sequence

The candidate structure of six steps collapses: the event loop needs no
correction (step 1), and SSE is a mode of the HTTP server, not a milestone
of its own (steps 3 and 4).

**M1 -- Linux sockets in the standard library (C; small).** G1 and G5: the
syscalls on x86-64 and AArch64 behind a mediating context, address
builders, `std::abi::bytes::at`/`find`, a `std::linux` read returning a
fresh `Bytes` (G6's first part). Reuses: `std::linux::sys`'s architecture
selection, the byte store, the address bridges. Acceptance: P1 rewritten
on `std::linux` runs on linux-x86_64 and linux-aarch64 (tests-arm64.yml),
the byte natives agree on every backend, P4 passes in CI (G12).

**M2 -- HTTP server package with SSE (B).** G2, G3, G4: a package on the
Linux driver and M1, its API a context trait for routes (P5), its
transport and protocol halves separate. Acceptance: section 12. This is
the smallest milestone that produces a real, externally accessible,
supported server; the shortest path to a real SSE endpoint is inside it --
or, today, P2 itself (`tools/run.sh p2`).

**M3 -- Termination signals (D; small).** G10 in the runtime, a signalfd
wrapper and a source; M2's server stops gracefully on SIGTERM. Acceptance:
P3's driver sees exit status 0 after the program logs the signal; a
program that does not block the signal still dies of it (unchanged).
Independent of M1 and M2.

**M4 -- Production robustness (B, C).** G7 (`wait_until`), G8, G9, G11
(the `json` package), G15 (wall clock, `Date`), EMFILE policy, write
deadlines, read-path allocations (G6). Acceptance: 10,000 idle connections
with deadlines and no ticker; a JSON fuzzer against an oracle; RSS and CPU
per request measured against M2.

**M5 -- Portability (E).** G13, G14: a macOS kqueue driver and libSystem
transport, then Windows. Acceptance: M2's scenarios on macos-arm64.yml and
windows-x86_64.yml.

## 12. Recommended next milestone

**M2, with M1's two standard-library pieces as its first part:
HTTP-SERVER-PACKAGE-MILESTONE-1.** Doing M1 alone first gives nothing
externally visible; doing M2 without it bakes x86-64 syscall numbers and
the decode workaround into a package. Together they are the smallest step
to a supported server, and the probe has already retired the
architectural risk.

Scope:

1. `std::linux`: socket, bind, listen, accept4, connect, setsockopt,
   getsockname, sendto, recvfrom, shutdown (x86-64 and AArch64 numbers in
   `std::linux::sys`), sockaddr builders, a mediating context;
   `std::abi::bytes::at` and `find` in both runtimes.
2. A package `http_server` (Linux): listener and connection resources;
   one task per connection; HTTP/1.1 heads (bytes, not decoded text: obs-text
   accepted in field values), `Content-Length` bodies, persistence and
   pipelining, limits (head, body, connections), idle and write deadlines
   (the ticker until M4), error responses; SSE stream mode with framing,
   heartbeats, a bounded per-stream queue with a drop policy and counters,
   a broadcaster with a ring and `Last-Event-ID`; in-process shutdown; a
   context trait `Routes` the application implements; MSG_NOSIGNAL sends.
3. The acceptance application as the package's example (`/health`,
   `/items`, `/events`), with a vendored JSON validator until G11.

Acceptance criteria:

* P2's fifteen scenarios, unchanged in intent, against the example built
  with the single-file compiler from the released package (a clean room:
  the compiler and the artifact only), on linux-x86_64 and, in
  tests-arm64.yml, linux-aarch64; also under GC stress.
* An independent conformance pass: a Python client using `h11` (an
  independent HTTP/1.1 implementation) for framing, pipelining and error
  cases; curl and a browser-grade SSE client (Python `sseclient` or
  `EventSource` in a headless Chromium) for streams.
* A parser fuzzer against an oracle (h11's acceptance), several seeds,
  with no crash, no unbounded allocation and identical accept/reject
  decisions on the agreed subset.
* The protocol half on every backend, and the server logic under
  `std::event_loop::deterministic` with a simulated network.
* A mutation catalog (limits, framing, the drop policy, cleanup) killed by
  the tests; the warning gate clean.
* Measurements: requests per second and CPU per request on one core,
  events per second to 1,000 subscribers, RSS per idle connection.

## 13. Method and limits

* Probes are temporary code: `rawnet.bot` and P2 are deliberately
  unpolished and are not a package. Nothing in `stdlib/`, `packages/`,
  the compiler or the runtime changed.
* The client side is Python's socket module and curl; no Botlish code
  plays a client.
* One machine, one kernel, shared: latencies are single runs and only
  bounds ("worst 0.9 ms") are claimed.
* Not run here: IPv6 (no kernel support), Linux AArch64, macOS, Windows,
  a browser's EventSource, an h11 conformance pass, more than 200
  concurrent connections, Tcl backends for sockets (refused by design).
* The GC-stress S12 failure's cause is inferred, not proven (6.3).
