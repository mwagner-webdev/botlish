# The http package: a user's guide

This guide describes what `http` 0.2.0 does, as its tests check it
(tests/http-client.test in the Botlish repository). Every `botlish` block
is a complete program the package's documentation test compiles.

## 1. The runtime

A program that uses `http` installs, in this order:

    with context std::event_loop::create(64)
    with context event_loop_linux::create()       the Linux driver
    with context event_loop_linux::native()       its integration capability
    with context http::create()                   the HTTP runtime: http::Http

`http::Http` is the authority to make connections: every operation that may
open one requires it, and it is made from the driver's `Native` -- so only
the application, which installs contexts, grants it, and a library that
requires it says so in its signatures. The runtime's executor is an
ordinary task of the loop, started with the first client: each turn it
runs a bounded batch of protocol work and settles what that work asked for
(readiness watches, timers, the tasks to wake). Name resolution
(`getaddrinfo`) runs on up to four worker threads, which only resolve and
wake the loop; nothing else runs off the loop's thread.

**Botlish threads.** A program may run VMs on threads of their own
(`std::thread`), each with its own loop (`event_loop_linux` 0.5: one loop
per VM). One thread of a process has the HTTP runtime at a time: the
thread whose `http::create` came first. Its wakes name its own loop, so
other threads' loops neither receive them nor block them. Another thread's
`http::create` is refused -- its first client fails with `Fault` ("the
HTTP runtime is open on another thread") -- until the owner's runtime is
shut down (`http::shutdown`) or its thread ends; then another thread's
runtime opens. A thread that wants HTTP from the owner sends it a message
(`std::actor::remote`).

Every operation that waits -- `send`, `finish`, `read`, `read_all`,
`write` -- suspends only the calling task, so it must run in a task of the
loop (`std::event_loop::adopt`); the loop runs other tasks meanwhile. A task
waiting for HTTP keeps the loop alive; `std::event_loop::run` returns once
no task waits.

`http::shutdown()` (requires the driver's `Native` too) releases every
client and exchange and stops the executor, for the end of a program;
nothing requires it: the process's end releases everything.

## 2. Clients

    {owner, client} = http::client(config)

A client keeps its own connections under one `http::Config`:

| field | default | meaning |
|---|---|---|
| `versions` | `Versions::Negotiate` | `Negotiate`: over https, ALPN offers h2 and http/1.1 and the server chooses (HTTP/1.1 when it chooses none); `Http1`: HTTP/1.1 only; `Http2`: h2 only -- a server that does not select h2 is `Unsupported`, never a silent fallback. An http URI is always HTTP/1.1 (no h2c: `Http2` refuses it) |
| `trust` | system bundle, no anchors | `Trust {system, anchors}`: the system bundle (section 7) and PEM certificates trusted besides |
| `connect_timeout` | 30 s | making a connection -- resolution, TCP, TLS, the HTTP/2 handshake -- and waiting for one when the origin's HTTP/1.1 connections are all busy |
| `idle_timeout` | 300 s | each wait for the server while the client wants data: the response head once the request body is complete, each body chunk; never the program's own pauses |
| `max_connections` | 6 | HTTP/1.1 connections per origin |
| `max_header_bytes` | 64 KiB | a response head's size |
| `pool_idle` | 90 s | how long an idle HTTP/1.1 connection stays reusable |
| `window` | 1 MiB | HTTP/2's receive window per stream (the connection's: four times it) |

Times are microseconds; 0 is no limit. `http::config()` gives the defaults;
a configuration is an ordinary struct (build it with every field, or start
from `config()` and `with_anchors`).

`http::client` fails with `TrustFailed` when its trust store cannot be made
(no system bundle, anchors that are no PEM certificates, nothing trusted).
The owner (`ClientOwner`, a resource) releases the client where its
lexical scope ends -- on every exit of the function holding it, and when a
task holding it is abandoned -- or when `http::close_client(owner)` is
called. The identity (`Client`) is what `send` and `start` take; after the
release, an operation through it fails with `Released`, and the client's
exchanges fail with `Closed`.

Make a client once and reuse it. Making one parses the system's trust
bundle into a store on the loop's thread (about 4 ms on the test machine;
other tasks wait meanwhile), and each client keeps its own connection
pools, so a client per request also pays a new connection -- and a TLS
handshake, which runs on the loop's thread too -- every time.

## 3. Requests

A request is an ordinary value:

    struct Request:
        method: str               a token: "GET", "POST", or an extension method
        target: Uri
        headers: List[Header]
        body: std::abi::bytes::Bytes
        deadline: int             0, or the instant the exchange must be done by
        cancel: Cancel

made by `http::get(uri)`, `http::post(uri, body)` or `http::request(method,
uri)` (`InvalidRequest` for a method that is no token), and changed by
`with_header`, `with_body`, `with_deadline`, `with_timeout` and
`with_cancel`, each a copy with one field replaced.

**URIs.** `http::uri(text)` parses an absolute http or https URI
(`InvalidUri {text, reason}` otherwise): the scheme and the host are
lowercased; the host is a DNS name (ASCII: an internationalized name in its
`xn--` form), a dotted IPv4 address, or an IPv6 address in brackets
(without a zone); the port is explicit or the scheme's default; the path
and the query are kept as written (percent-escapes checked, never decoded
or re-encoded); a fragment is checked and dropped (never sent). User
information (`user@host`) is refused (RFC 9110, section 4.2.4), and so is
any character outside visible ASCII: percent-encode it.
`http::authority(u)`, `http::target(u)` and `http::uri_text(u)` give the
parts as sent.

**Headers.** `http::header(name, value)` (`InvalidRequest` when the name is
no token, or the value holds a control character or leading or trailing
space) and `http::header_bytes(name, bytes)` (the value checked when sent).
Names are lowercased. The client sets `host` (HTTP/1.1; HTTP/2 sends
`:authority`), `content-length` and `transfer-encoding` itself, and owns
connection management: a request carrying `host`, `content-length`,
`transfer-encoding`, `connection`, `keep-alive`, `proxy-connection`,
`upgrade` or `te`, or a pseudo-header, is `InvalidRequest`.

**Bodies** are bytes (`std::abi::bytes::Bytes`), never text: encode text
with `std::str::encode_utf8`. A body passed in the request is sent with its
length (Content-Length, or an exact HTTP/2 DATA length).

## 4. Responses

    {owner, response} = client.send(request)

`send` sends the request and waits for the response head: a `Sent` with the
exchange's owner (`ExchangeOwner`) and the `Response`:

    struct Response:
        status: int
        version: Version          Version::Http1 or Version::Http2
        headers: List[Header]
        exchange: Exchange        what the body is read from

Any status is a response, 404 and 500 included: `send`'s errors are the
exchange's failures (section 6). Header names are lowercase; a repeated
field is kept, each name's values in the order the server sent them (the
order between different names is not kept: RFC 9110 gives it no meaning).
`http::text(h)` is a value as text (`HeaderNotText` when it is not UTF-8),
`http::values(headers, name)` every value of a name, `http::first(headers,
name)` the first as text ("" when there is none).

**Reading.** `response.exchange.read()` returns the next chunk of the body,
waiting when none is there, and an empty `Bytes` at the end (and after it).
The native side holds at most one chunk per exchange: while the program
does not read, the client stops reading the connection, and the server
stops at its flow control (HTTP/2: the stream's window, `Config.window`;
HTTP/1.1: TCP). `read_all(limit)` reads the rest (`BodyTooLarge` beyond
`limit` bytes). Chunk boundaries are wherever the network put them: text
must be decoded once its bytes are complete (a multibyte character may be
split between chunks).

A JSON POST whose response is read as it streams:

```botlish
import event_loop_linux
import http
import std::abi::bytes
import std::event_loop
import std::int
import std::io
import std::linux::io
import std::str

fn utf8(text: str) -> std::abi::bytes::Bytes:
    std::abi::bytes::from_list(std::str::encode_utf8(text))

# A line on standard output (a failed write is not this example's concern).
fn say(text: str, context io: std::io::IO):
    std::io::print_line(text):
        on std::io::WriteFailed:
            unit

fn ask(url: str, key: str, context h: http::Http, ev: std::event_loop::Loop, n: event_loop_linux::Native, io: std::io::IO) -> str errors http::InvalidUri, http::InvalidRequest, http::ResolveFailed, http::ConnectFailed, http::TlsVerifyFailed, http::TlsHandshakeFailed, http::ProtocolError, http::Timeout, http::Cancelled, http::Closed, http::Unsupported, http::TrustFailed, http::Released, http::Fault, std::event_loop::SchedulerFault:
    {owner, client} = http::client(http::config())
    body = utf8("{\"input\": \"hello\", \"stream\": true}")
    request = http::post(http::uri(url), body).with_header(http::header("content-type", "application/json")).with_header(http::header("authorization", "Bearer ".concat(key)))
    {owner: exchange, response} = client.send(request)
    say("status ".concat(std::int::to_string(response.status)))
    # The body as it arrives: each chunk processed, then the next read.
    loop:
        chunk = response.exchange.read()
        size = std::abi::bytes::length(chunk).value
        if size == 0:
            break
        say("chunk of ".concat(std::int::to_string(size)).concat(" bytes"))
    "done"

fn task(url: str, key: str, context h: http::Http, ev: std::event_loop::Loop, n: event_loop_linux::Native, io: std::io::IO) -> int errors std::event_loop::SchedulerFault:
    line = url.ask(key):
        on http::InvalidUri {reason}:
            reason
        on http::InvalidRequest {reason}:
            reason
        on http::ResolveFailed {reason}:
            reason
        on http::ConnectFailed {reason}:
            reason
        on http::TlsVerifyFailed {reason}:
            reason
        on http::TlsHandshakeFailed {reason}:
            reason
        on http::ProtocolError {reason}:
            reason
        on http::Timeout {reason}:
            reason
        on http::Cancelled:
            "cancelled"
        on http::Closed:
            "closed"
        on http::Unsupported {reason}:
            reason
        on http::TrustFailed {reason}:
            reason
        on http::Released:
            "released"
        on http::Fault {reason}:
            reason
    say(line)
    0

fn main(context ev: std::event_loop::Loop, d: event_loop_linux::Linux, n: event_loop_linux::Native, h: http::Http, io: std::io::IO) -> int errors std::event_loop::SchedulerFault, std::event_loop::DriverFault, std::event_loop::LoopReentered:
    coroutine {step, first} = task("https://api.example.com/v1/responses", "TOKEN")
    std::event_loop::adopt(step, first)
    std::event_loop::run()
    0

with context std::event_loop::create(64)
with context event_loop_linux::create()
with context event_loop_linux::native()
with context http::create()
with context std::linux::io::create()
main():
    on std::event_loop::SchedulerFault:
        1
    on std::event_loop::DriverFault:
        2
    on std::event_loop::LoopReentered:
        3
```

**Streaming a request body.** `client.start(request, length)` sends the
head and the request's own body, and returns the exchange's owner and
identity without waiting; `exchange.write(bytes)` writes the next chunk
(waiting while the one chunk the native side holds has not been taken: the
connection's backpressure), and `exchange.finish()` ends the body and waits
for the response head. `length` is the whole body's length when known
(sent as Content-Length, and held to it: `InvalidRequest` when the writes
are longer or `finish` comes early) or -1 (HTTP/1.1 chunked; HTTP/2 DATA
frames). A server may answer before the body is complete; `write` then
fails with `ProtocolError` ("the request body is closed") and `finish`
returns the response.

    {owner, exchange} = client.start(http::request("PUT", target), -1)
    exchange.write(first_part)
    exchange.write(second_part)
    response = exchange.finish()

## 5. Lifetimes

Clients and exchanges are resources (`opaque resource struct`): an owner
is affine -- it moves into a function, a struct, a task, and the function or
task holding it last releases it where its scope ends, on every exit
(a return, a failure, the task's abandonment). The identities (`Client`,
`Exchange`) are ordinary values to pass around and copy.

* Releasing an exchange whose body was read to its end returns its
  HTTP/1.1 connection to the pool.
* Releasing one before (abandoning it): an HTTP/2 stream is reset
  (RST_STREAM CANCEL) and the connection goes on; an HTTP/1.1 connection is
  closed, never reused.
* Releasing a client closes its connections -- a TLS connection after one
  nonblocking attempt to send close_notify, an HTTP/2 connection without
  GOAWAY: the peer is told no more than that one write achieves -- and its
  exchanges fail with `Closed`.
* After a release, its identity's operations fail with `Released`.

## 6. Errors

Every failure is a declared error of the `http` namespace; none is a
negative number, and none is a status.

| error | payload | when |
|---|---|---|
| `InvalidUri` | `text, reason` | `http::uri`: no absolute http or https URI it takes |
| `InvalidRequest` | `reason` | a method, header or body that may not be sent; a streamed body that breaks its declared length |
| `ResolveFailed` | `host, reason, code` | name resolution failed (`code`: getaddrinfo's EAI_* code) |
| `ConnectFailed` | `host, port, reason, code` | no address accepted a TCP connection (`code`: the last attempt's errno) |
| `TlsVerifyFailed` | `host, reason, code` | the certificate did not verify (`code`: BoringSSL's X.509 verify result -- 10 expired, 18 self-signed, 20 unknown issuer, 62 host-name mismatch, ...) |
| `TlsHandshakeFailed` | `host, reason` | the TLS handshake failed otherwise |
| `ProtocolError` | `reason, code` | the connection broke the protocol or broke: a malformed response, a reset stream (`code`: the HTTP/2 error code, -1 for none), a body cut short |
| `Timeout` | `phase, reason` | `Phase::Connect`, `Phase::Deadline` (the request's), `Phase::Idle` (the server's silence) |
| `Cancelled` | | the request's cancellation token was cancelled |
| `Closed` | | the exchange's client was released |
| `Released` | | an identity used after its owner released it |
| `Unsupported` | `reason` | a configuration or protocol this client does not do |
| `TrustFailed` | `reason` | `http::client`: its trust anchors could not be made |
| `HeaderNotText` | `name` | `http::text` of a value that is no UTF-8 |
| `BodyTooLarge` | `limit` | `read_all` past its limit |
| `Fault` | `reason, code` | a defect of the package (a contained panic of the native unit, a call from another thread), or a runtime made while another thread's is open (section 1): never a network condition |

A request is sent again on another connection only when the first one
hands it back unsent (no byte of it reached the connection), whatever its
method; it is never retried after it may have been sent.

## 7. TLS

Verification is always on: the chain to a trusted anchor, the validity
period, and the host name -- or, for an IP literal, the address -- against
the certificate (partial wildcards refused). SNI carries the host name
(never an IP literal). TLS 1.2 is the minimum.

**The system bundle** is the first regular file of
`/etc/ssl/certs/ca-certificates.crt` (Debian, Ubuntu),
`/etc/pki/ca-trust/extracted/pem/tls-ca-bundle.pem` and
`/etc/pki/tls/certs/ca-bundle.crt` (Fedora, RHEL), `/etc/ssl/ca-bundle.pem`
(openSUSE) and `/etc/ssl/cert.pem`, read when a client is made. No
environment variable (`SSL_CERT_FILE`, `SSL_CERT_DIR`) is read, and no
other file. With `Trust.system` false only the anchors are trusted; a
private service's CA is added with `with_anchors(config, pem)`.

## 8. Timeouts, deadlines and cancellation

Three limits, three phases of `Timeout`: `Config.connect_timeout`
(`Phase::Connect`), `Config.idle_timeout` (`Phase::Idle`: the server's
silence while the client waits for data) and the request's `deadline`
(`Phase::Deadline`: the whole exchange, its body included).
`request.with_timeout(micros)` sets the deadline from the driver's clock now
(`event_loop_linux::now_us`); `with_deadline` takes an instant of that clock.

A cancellation token (`http::cancellation()`, an identity to copy to whoever
may cancel) is carried by requests (`with_cancel`); `http::cancel(token)`
fails every exchange in flight carrying it with `Cancelled`, wakes its
task, drops its native work at once (an HTTP/2 stream reset, an HTTP/1.1
connection closed), and fails every later request carrying it at once:

```botlish
import event_loop_linux
import http
import std::event_loop
import std::io
import std::linux::io

fn stopper(c: http::Cancel, context h: http::Http, ev: std::event_loop::Loop) -> int errors std::event_loop::SchedulerFault:
    std::event_loop::sleep(2000000)
    http::cancel(c):
        on http::Fault:
            0
    0

fn slow(url: str, c: http::Cancel, context h: http::Http, ev: std::event_loop::Loop, n: event_loop_linux::Native) -> str errors std::event_loop::SchedulerFault:
    {owner, client} = http::client(http::config()):
        on http::TrustFailed:
            return "no trust"
        on http::Unsupported:
            return "unsupported configuration"
        on http::Fault:
            return "client fault"
    target = http::uri(url):
        on http::InvalidUri:
            return "invalid URI"
    request = http::get(target).with_cancel(c).with_timeout(10000000)
    sent = client.send(request):
        on http::Cancelled:
            return "cancelled"
        on http::Timeout:
            return "timed out"
        on http::InvalidRequest:
            return "invalid request"
        on http::ResolveFailed:
            return "resolution failed"
        on http::ConnectFailed:
            return "connection failed"
        on http::TlsVerifyFailed:
            return "certificate rejected"
        on http::TlsHandshakeFailed:
            return "handshake failed"
        on http::ProtocolError:
            return "protocol error"
        on http::Closed:
            return "closed"
        on http::Unsupported:
            return "unsupported"
        on http::TrustFailed:
            return "no trust anchors"
        on http::Released:
            return "released"
        on http::Fault:
            return "fault"
    {owner: exchange, response} = sent
    "answered"

fn task(url: str, context h: http::Http, ev: std::event_loop::Loop, n: event_loop_linux::Native, io: std::io::IO) -> int errors std::event_loop::SchedulerFault:
    c = http::cancellation():
        on http::Fault:
            return 1
    coroutine {step, first} = stopper(c)
    std::event_loop::adopt(step, first)
    std::io::print_line(url.slow(c)):
        on std::io::WriteFailed:
            return 2
    0

fn main(context ev: std::event_loop::Loop, d: event_loop_linux::Linux, n: event_loop_linux::Native, h: http::Http, io: std::io::IO) -> int errors std::event_loop::SchedulerFault, std::event_loop::DriverFault, std::event_loop::LoopReentered:
    coroutine {step, first} = task("https://example.com/slow")
    std::event_loop::adopt(step, first)
    std::event_loop::run()
    0

with context std::event_loop::create(64)
with context event_loop_linux::create()
with context event_loop_linux::native()
with context http::create()
with context std::linux::io::create()
main():
    on std::event_loop::SchedulerFault:
        1
    on std::event_loop::DriverFault:
        2
    on std::event_loop::LoopReentered:
        3
```

Abandoning the task that waits (the loop's `abandon`) releases what it
owns, the exchange included: an exchange is cancelled by its owner's end
as well.

## 9. Connections

Per client and origin (scheme, host, port): one HTTP/2 connection every
request to the origin shares (the server's concurrent-stream limit makes a
request wait for a stream); HTTP/1.1 connections, at most `max_connections`
open, each carrying one exchange at a time and reused (keep-alive) when its
response body was read to its end, while younger than `pool_idle`. While the
first connection to an origin whose protocol is not known yet is being
made, other requests to it wait for it (it may be HTTP/2, which they would
share).

A program holding `max_connections` unread HTTP/1.1 responses of one
origin and sending another gets `Timeout` (`Phase::Connect`) after the
connect timeout: read or release responses before sending more to the same
HTTP/1.1 origin.

Name resolution tries the addresses in the order getaddrinfo returns them
(RFC 6724's), one after another; the first that accepts a TCP connection
is used. This is sequential fallback, not Happy Eyeballs.

## 10. Counters

`http::stats()` gives the runtime's counters: live clients, exchanges and
native tasks, watched descriptors, name resolutions outstanding, the pools,
and the boundary's costs (C calls, executor runs and polls, bytes copied
each way, the most body bytes held for one exchange, panics contained).

## 11. What this release does not do

No HTTP/3 or QUIC; no server; no WebSocket; no automatic redirects (a 3xx
is a response); no cookies; no proxy configuration; no transparent
decompression (a `content-encoding` body arrives as sent); no response
trailers; no cache; no Happy Eyeballs; no h2c (HTTP/2 without TLS); no
client certificates, session resumption or OCSP; no TLS key logging or
verification bypass, ever. Linux x86-64 only. One thread of a process
uses the runtime at a time (section 1); two threads making requests at once
need two processes, or one thread serving the other's requests. The response body crosses
into Botlish storage as a copy per chunk (no borrowed foreign bytes). A
TLS handshake runs on the loop's thread, inside the executor's step. IPv6
connections are made like IPv4 ones but have not been tested yet (the test
machine refused IPv6 sockets); IPv6 literals are parsed and verified.
