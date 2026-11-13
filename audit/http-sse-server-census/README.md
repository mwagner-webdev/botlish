# audit/http-sse-server-census

Probes and results of HTTP-SSE-SERVER-CENSUS-MILESTONE-1.md (`../../docs/`):
what is still missing for a production-oriented HTTP/1.1 server with
Server-Sent Events written in Botlish. Probe code, not a package: nothing
here is loaded by the compiler, the standard library or a package, and no
test or workflow runs it.

    sh audit/http-sse-server-census/tools/run.sh [p1|p2|p2-gc|p3|p4|protocol|bytes|alloc|all]

assembles each probe as an application directory in a temporary
directory (its files, `probes/rawnet.bot` and, for P2, the Linux driver
package installed by `tools/event-loop-linux.tcl`), builds it with
`main.tcl -emit-native-executable` and runs its independent client. Linux
x86-64 with tclsh9.0, the native backend built, cc, ar, curl and python3.

| Path | What |
|---|---|
| `probes/rawnet.bot` | socket, setsockopt, bind, listen, accept4, sendto (MSG_NOSIGNAL), shutdown, getsockname over `std::linux::abi::x86_64::syscall`; IPv4 and IPv6 loopback addresses. A direct module, x86-64 only |
| `probes/p1/listen.bot` | P1: a blocking responder over rawnet, no event loop: fragmented heads, curl, and the per-read decoding pitfall |
| `probes/p2/server.bot` | P2's entry: installs the loop, the Linux driver and `srv::App`, runs the acceptor and the ticker |
| `probes/p2/srv.bot` | P2's server: a task per connection, persistence, limits, idle deadlines, SSE stream mode, the ring and publisher, the slow-consumer bound, shutdown, the `SocketOwner` resource |
| `probes/p2/http1.bot` | P2's protocol half, pure Botlish: head scanning, parsing, responses, SSE data lines |
| `probes/p2/protocol.bot` | `http1.bot` on every backend |
| `probes/p3/signal.bot` | P3: SIGTERM blocked and read from a signalfd -- the process still dies (the program runs on the runtime's worker thread) |
| `probes/p4/ipv6.bot` | P4: an IPv6 listener on `[::1]` (unverified here: no IPv6 in the container's kernel) |
| `probes/p5/` | P5: a library task calling an application-implemented context trait (the transport/application seam), deterministic driver, every backend |
| `probes/bytes_list.bot` | byte access through a fixed layout, beside the decode failure |
| `drivers/p1_driver.py`, `p2_driver.py`, `p3_driver.py` | the independent clients (Python sockets and curl) |
| `tools/run.sh` | assemble, build, drive |
| `tools/alloc.tcl` | native heap allocations per operation (`native::allocationReport`) |
| `results/` | the outputs the report quotes |
