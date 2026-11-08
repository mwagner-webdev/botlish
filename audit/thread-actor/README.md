# audit/thread-actor -- the thread/actor census's probes

Evidence for THREAD-ACTOR-ARCHITECTURE-CENSUS.md. Everything here is
**disposable**: nothing in the compiler, the runtime, the standard library
or the packages loads it, no test runs it, and it is not a library. A
milestone that implements `std::actor` (M1) writes its own code; it may use
these probes as scenarios.

| path | what |
|---|---|
| `probe-a/actor.bot` | the prototype same-thread actor library: `Postbox[M]`, `Address[M]`, `Inbox[M]`, `open`, `send`, `receive`, `close` over `std::event_loop` channels |
| `probe-a/actors.bot` | Probe A: counters, clients with request/reply, a suspended handler, backpressure, fairness, stale addresses, shutdown (deterministic driver, every backend) |
| `probe-a/sendvalues.bot` | Probe C, runtime half: a mutable collection sent to a same-thread actor is a snapshot |
| `probe-a/failure.bot` | a failing actor's mailbox stays open; reaping closes it |
| `probe-a/reject-*.bot` | programs the compiler must reject (wrong message type, forged address, reading a queue, handler as a value, resuming an adopted task, an affine message) |
| `probe-b/` | Probe B: producer threads (C) posting records with copied payloads through the Linux event loop's ABI v1; the loop's actors copy them into their own heap |
| `probe-c/matrix.bot`, `tools/sendability.tcl` | Probe C: a sendability classifier over real checked types (a prototype; the compiler's judgement is `hir::types::SendClass`, SENDABILITY-AND-VALUE-COPY-MILESTONE-1.md) |
| `probe-d/` | Probe D: a native library served on a Botlish-owned thread of a C host; `reject-*.bot`: what library mode cannot hold between calls |
| `probe-e/` | Probe E: two library instances (two VMs) on two threads exchanging copied messages, also under GC stress |
| `probe-f/` | Probe F: costs of same-thread actors on the Linux driver |
| `tools/run.tcl` | runs a program on every backend and requires one outcome |
| `tools/native-app.tcl` | builds a probe that calls C into a temporary application (the Linux event-loop package installed) and runs it natively |
| `results/` | the outputs the census quotes |

The commands are in the census's section 17 ("Reproducing").
