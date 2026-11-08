# http -- an HTTP/1.1 and HTTP/2 client for Botlish

`http` is a client for HTTP/1.1 and HTTP/2, with TLS, for Botlish programs
on Linux x86-64. A program sends requests and reads responses as Botlish
values -- URIs, headers, bytes, statuses -- and handles failures as declared
errors; it never sees how the client is built (Hyper, BoringSSL and a Rust
bridge, linked from this package's archive and the `boringssl` package's).

* HTTPS with certificate and host-name verification against the system's
  trust store (and anchors the program adds); no switch turns it off.
* HTTP/2 negotiated by ALPN, HTTP/1.1 otherwise; connections reused (one
  multiplexed HTTP/2 connection per origin, HTTP/1.1 keep-alive).
* Streaming both ways with backpressure: a response is read chunk by chunk
  (at most one chunk and the HTTP/2 window held while the program does not
  read); a request body can be written chunk by chunk.
* Deadlines, connect and idle timeouts, cancellation tokens; clients and
  exchanges are resources, released where their owner's scope ends.
* Scheduled by the program's own event loop (`std::event_loop` with the
  `event_loop_linux` driver): no second scheduler, no Tokio runtime.

GUIDE.md is the user's guide: the API, lifetimes, errors, streaming,
timeouts, cancellation, TLS, connections and the limits.

## Installing

With the single-file compiler (`botlish`) and a repository holding the
released artifacts (`http-0.2.0.botpkg`, `boringssl-0.20261020.0.botpkg`,
`event_loop_linux-0.5.0.botpkg`):

    botlish add http -repository REPO -target linux-x86_64
    botlish add event_loop_linux -repository REPO -target linux-x86_64

The second line is for the program's own use of the driver (it installs
it); the graph holds one `event_loop_linux`, the one `http` locks.

What the host needs to link a program (the system linker: a program that
calls C): a C compiler driver (`cc`), the C++ standard library's link name
(`libstdc++.so`: Ubuntu's `g++` or `libstdc++-13-dev`; BoringSSL's TLS code
is C++), and for HTTPS a trust bundle (`ca-certificates`). Nothing is
compiled from the packages' sources: Cargo, Rust and CMake are not needed.

## A first program

```botlish
import event_loop_linux
import http
import std::abi::bytes
import std::event_loop
import std::int
import std::io
import std::linux::io
import std::str

# The work: one GET, the body read to its end. Every failure is a declared
# error the caller handles.
fn fetch(url: str, context h: http::Http, ev: std::event_loop::Loop, n: event_loop_linux::Native) -> str errors http::InvalidUri, http::InvalidRequest, http::ResolveFailed, http::ConnectFailed, http::TlsVerifyFailed, http::TlsHandshakeFailed, http::ProtocolError, http::Timeout, http::Cancelled, http::Closed, http::Unsupported, http::TrustFailed, http::Released, http::Fault, http::BodyTooLarge, std::event_loop::SchedulerFault:
    {owner, client} = http::client(http::config())
    {owner: exchange, response} = client.send(http::get(http::uri(url)))
    body = response.exchange.read_all(10000000)
    "status ".concat(std::int::to_string(response.status)).concat(", ").concat(std::int::to_string(std::abi::bytes::length(body).value)).concat(" bytes")

# A task of the loop: the work, its failures turned into text, printed.
fn task(url: str, context h: http::Http, ev: std::event_loop::Loop, n: event_loop_linux::Native, io: std::io::IO) -> int errors std::event_loop::SchedulerFault:
    line = fetch(url):
        on http::InvalidUri {reason}:
            "invalid URI: ".concat(reason)
        on http::InvalidRequest {reason}:
            "invalid request: ".concat(reason)
        on http::ResolveFailed {host, reason}:
            "cannot resolve ".concat(host).concat(": ").concat(reason)
        on http::ConnectFailed {host, reason}:
            "cannot connect to ".concat(host).concat(": ").concat(reason)
        on http::TlsVerifyFailed {host, reason}:
            "certificate of ".concat(host).concat(" rejected: ").concat(reason)
        on http::TlsHandshakeFailed {reason}:
            "TLS handshake failed: ".concat(reason)
        on http::ProtocolError {reason}:
            "protocol error: ".concat(reason)
        on http::Timeout {reason}:
            "timed out: ".concat(reason)
        on http::Cancelled:
            "cancelled"
        on http::Closed:
            "client closed"
        on http::Unsupported {reason}:
            "unsupported: ".concat(reason)
        on http::TrustFailed {reason}:
            "no trust anchors: ".concat(reason)
        on http::Released:
            "released"
        on http::Fault {reason}:
            "fault: ".concat(reason)
        on http::BodyTooLarge:
            "body too large"
    std::io::print_line(line):
        on std::io::WriteFailed:
            return 1
    0

fn main(context ev: std::event_loop::Loop, d: event_loop_linux::Linux, n: event_loop_linux::Native, h: http::Http, io: std::io::IO) -> int errors std::event_loop::SchedulerFault, std::event_loop::DriverFault, std::event_loop::LoopReentered:
    coroutine {step, first} = task("https://example.com/")
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

    botlish run fetch.bot
    botlish -emit-native-executable fetch.bot && ./fetch

Either prints one line -- the status and the body's size (`status 200, N
bytes`), or what failed (an executable prints only what its program
writes). The program installs the loop, the
Linux driver, its integration capability, the HTTP runtime made from it
and standard output, and runs one task. `send` waits (the task only: the loop runs other tasks meanwhile)
for the response head; `read_all` reads the body. The client and the
exchange are released where `fetch` ends, on every exit.

## Supported platforms

Linux x86-64 (glibc). The package's metadata names no other target, so the
package manager refuses to prepare another (`UNSUPPORTED`). Linux AArch64,
macOS and Windows are not supported: the native unit has not been built or
tested there (and macOS and Windows have no event-loop driver package).

Botlish threads (`std::thread`): one thread of a process has the HTTP
runtime at a time -- the main VM's or a worker's, beside other threads'
event loops (`event_loop_linux` 0.5 runs one loop per VM, and the
runtime's wakes name its own). Another thread's `http::create` is refused
(its first client fails with `Fault`) until the owner's runtime is shut
down or its thread ends. GUIDE.md, section 1.

## What is inside

| package | version | holds |
|---|---|---|
| `http` | 0.2.0 | `http.bot`; `native/libbotlish_http.a` (the Rust unit: Hyper 1.12.0, h2 0.4.20, boring 5.4.0, the bridge; localized: only its `bh_*` functions are global); the unit's sources (`native/`); `licenses/http/` (the unit's crates and their license files) |
| `boringssl` | 0.20261020.0 | `boringssl.bot`; `native/libbotlish_boringssl.a` (BoringSSL's release tag 0.20261020.0, commit d3bf4795, unpatched, unprefixed, under its own archive name); `licenses/boringssl/LICENSE` |
| `event_loop_linux` | 0.5.0 | the Linux driver of `std::event_loop` (one loop per VM) |

`http` locks the other two exactly; a program's graph holds one instance of
each, shared with every other package that uses them. Each release has a
provenance record beside its artifact (`botlish package inspect
http-0.2.0.botpkg -provenance http-0.2.0.provenance.json` checks it against
the artifact). A provenance record is evidence, not a signature.
