# HTTP on macOS and server-sent events: an effort estimate

Status: estimate (a survey of the code; nothing was implemented, built or
run for macOS). Surveyed on 2026-11-13, at main `400a7214`.

This document answers two questions about the `http` package
(HTTP-CLIENT-PACKAGE-MILESTONE-1.md): how much work it is to port it to
macOS on Apple Silicon (macos-aarch64), and how much work it is to add
server-sent events (SSE). Each claim below cites the file or document it
rests on. The effort figures are judgement, not measurement. They assume
one engineer who already knows this repository's conventions: mutation
harnesses, clean rooms, and releases that are reproducible and recorded
once in `packages/RELEASES.tsv`.

## 1. Summary

* **Neither exists today.** `http` 0.2.0 runs on Linux x86-64 only and has
  no SSE decoder.
* **SSE: about 1 to 1.5 engineer-weeks** for a decoder with its tests,
  documentation and a release. Automatic reconnection, as a browser's
  EventSource does it, adds 3 to 5 days. SSE is written in plain Botlish
  and does not depend on the platform. It can ship on Linux now and will
  run on macOS unchanged once the port lands.
* **macOS: about 5 to 7 engineer-weeks** for a release that meets the
  repository's standards. A prototype that works on one Mac, with no
  release machinery, is about 1.5 to 2 weeks.
* **What dominates the macOS cost is not Hyper or BoringSSL**, which both
  support macOS. It is the missing macOS event-loop driver, untangling
  `http.bot` from the Linux driver, and building the first package release
  that names a macOS target.
* **Recommended order:** SSE first, because it is cheap and useful right
  away. Then the macOS port, starting with the driver abstraction
  (section 3.2), because that is the step that forces other packages to be
  re-released.

## 2. Where things stand

| Package | Version | Targets | Relevant facts |
|---|---|---|---|
| `http` | 0.2.0 | linux-x86_64 | Depends on `boringssl` and `event_loop_linux` and locks both exactly ([botlish.json](../packages/http/botlish.json)) |
| `boringssl` | 0.20261020.0 | linux-x86_64 | Declares `extern c library "stdc++"` ([boringssl.bot:20](../packages/boringssl/boringssl.bot)) |
| `event_loop_linux` | 0.5.0 | linux-x86_64, linux-aarch64 | Built on epoll and an eventfd ([event_loop_linux.c:67-68](../packages/event_loop_linux/native/event_loop_linux.c)) |
| `process_linux` | 0.1.0 | linux-x86_64 | Locks `event_loop_linux` 0.5.0 exactly ([botlish.json](../packages/process_linux/botlish.json)) |

Each package's release targets are fixed in the author tool's table
([package-repository.tcl:701](../tools/package-repository.tcl)). No package
names a macOS target.

The http README's "Supported platforms" section says macOS is unsupported
because the native unit has never been built there and macOS has no
event-loop driver package. HTTP-SHIPPING-CENSUS.md, section 8.6, records
the same two blockers: a missing kqueue driver, and symbol-localization
tools that differ on Mach-O ("no `objcopy`").

No CI workflow runs `tests/http-client.test`, even on Linux
(HTTP-CLIENT-PACKAGE-MILESTONE-1.md, section 14; no workflow under
`.github/workflows/` names it).

**The compiler side is ready for macOS.** The macOS acceptance tier runs
every Tcl test file, because the list of files it skips on macOS
(`notYetByHost` in [tier.tcl](../tests/platform/tier.tcl)) is empty. That
covers `std::event_loop`, resources, coroutines, the C FFI, byte borrowing
and static archives in the native link plan. This survey found nothing in
`http.bot` that needs a language or runtime feature macOS lacks.

## 3. Porting `http` to macOS

### 3.1 A macOS event-loop driver (1.5 to 2 weeks)

`std::event_loop` gets readiness and wakeups from a driver package. The
only driver is `event_loop_linux`, whose C adapter is 950 lines built on:

* one epoll instance per loop (`epoll_create1`, line 341);
* an eventfd for wakeups from other threads (line 346);
* `epoll_pwait2` for microsecond timeouts (line 722);
* one-shot watches (`EPOLLONESHOT`).

The parts that do not touch epoll should port as they are: the per-VM loop
handles, the endpoint rings, the pumps, `pthread` keys, and
`CLOCK_MONOTONIC` time.

A kqueue port needs:

* **Watches.** `EVFILT_READ` and `EVFILT_WRITE` registered with
  `EV_ONESHOT`, or with `EV_DISPATCH` and re-enabled on rearm.
* **One record per arming.** The driver's contract reports one readiness
  record per arming, and epoll gives that for free. kqueue reports read
  and write as separate events, so a watch with interest "both" must merge
  them into one record and disarm the other filter.
* **Readiness bits.** Map kqueue's results to the bits the Linux driver
  reports (1 readable, 2 writable, 4 hangup, 8 error): `EV_EOF` becomes
  hangup, `EV_ERROR` becomes error.
* **Wakeups.** An `EVFILT_USER` event triggered with `NOTE_TRIGGER`
  replaces the eventfd, and the "a reset is owed" protocol around it is
  rewritten.
* **Timeouts.** kevent's `timespec` timeout has nanosecond resolution, so
  epoll's millisecond fallback goes away.
* **The native integration ABI unchanged.** Keep
  `botlish_event_loop.h` version 2 as it is, so foreign-thread posts
  (`botlish_event_post2`, which the http unit calls) work as on Linux.

The Botlish module (311 lines) is mostly a copy under a new namespace.
`tests/event-loop-linux.test` (real sockets, threads, cross-thread posts)
needs a macOS counterpart, plus mutants.

**Scope.** A kqueue driver blocks in `kevent`, which is enough for
command-line and terminal programs. A graphical program (SDL or Cocoa on
the main thread) that also uses `http` would need the driver to integrate
with Cocoa's run loop (CFRunLoop). That is separate work, not estimated
here.

### 3.2 Making `http.bot` independent of the driver (3 to 5 days)

`http.bot` names `event_loop_linux` 35 times. The names that matter are:

* the `Http` context, which is made from `event_loop_linux::Native`;
* its watch table, `watches: MutableVector[event_loop_linux::Watch]`
  ([http.bot:982](../packages/http/http.bot));
* `watch`, `rearm` and `unwatch`;
* `endpoint`, `endpoint_id` and `loop_handle`, which feed `bh_set_notify`;
* `now_us`, used by `with_timeout` and by each executor step.

A package's dependencies apply to every target
([descriptor.tcl](../pm/descriptor.tcl)). So `http` cannot depend on
`event_loop_linux` on Linux and on a macOS driver on macOS. There are two
ways out:

* **A context trait that `http` requires (recommended).** It would hold
  int-level operations: watch an fd with an interest, rearm, unwatch, open
  an endpoint, the loop handle, the clock. Both drivers would satisfy it
  structurally, through functions in their own namespaces. This is the
  pattern `std::thread::Doorbell` already uses
  ([thread.bot:313](../stdlib/thread.bot)), and `event_loop_linux`
  satisfies that trait today with `watch_doorbell` and friends. The
  application keeps installing exactly one driver, and `http` stops
  depending on either. The trait can live in `http` or in
  `std::event_loop`; the latter is a standard-library change and ships
  with the compiler.
* **One cross-platform driver package with a module per target.** Package
  views may hold different module contents per target as long as every
  target has the same module names ([author.tcl:1003](../pm/author.tcl)).
  But every consumer of `event_loop_linux` would have to migrate, and an
  application that combines `http` with `process_linux` must not end up
  with two drivers.

Either way, `event_loop_linux` needs a new release (the trait needs
read-and-write watches; the existing doorbell functions watch for reading
only). Versions are exact locks, and an application's graph holds one
version of each package. So `process_linux` must be re-released with the
new lock, or an application using both packages hits a
DEPENDENCY-CONFLICT.

### 3.3 The Rust unit (1 to 2 days)

Hyper, h2, `boring` and the bridge's executor are portable Rust. The
Linux-specific spots are:

* **Socket flags.** [net.rs:285](../packages/http/native/src/net.rs) passes
  `SOCK_NONBLOCK | SOCK_CLOEXEC` to `socket()`. macOS has neither flag,
  and the `libc` crate defines neither for Apple targets, so this does not
  compile. The fix is `fcntl` after `socket()`.
* **SIGPIPE.** [io.rs:189](../packages/http/native/src/bridge/io.rs) sends
  with `MSG_NOSIGNAL`. The `libc` crate defines `MSG_NOSIGNAL` (0x80000)
  for Apple targets, so this compiles. But macOS's documented mechanism is
  the `SO_NOSIGPIPE` socket option, and a test must establish which one
  actually suppresses SIGPIPE on macOS.
* **The weak reference to the driver.**
  [notify.c:12](../packages/http/native/src/notify.c) declares
  `botlish_event_post2` weak, so a program linked without the Linux driver
  still links. On Mach-O, Apple's linker is expected to report a weak
  reference undefined when nothing defines it at static link time. A weak
  *definition* that returns "not implemented" behaves the same on both
  formats. This is expected behavior, not yet tested.
* **errno values.** These differ between the systems (ECONNREFUSED is 111
  on Linux, 61 on macOS). The unit reads them through `libc` constants,
  which are correct per target. But `tests/http-client.test:305` expects
  `code 111`, and `notify.c` returns a hard-coded -38 (Linux's ENOSYS).
* **Trust.** No change is needed. `/etc/ssl/cert.pem`, which macOS ships,
  is already in `SYSTEM_BUNDLES`
  ([tls.rs:40-45](../packages/http/native/src/tls.rs)). See decision 3
  (section 3.7) for its limit.

### 3.4 Build tooling and the `boringssl` package (about 1 week)

`tools/http-package.tcl` builds the provider and the unit, and assumes
Linux and GNU binutils throughout:

* `httppkg::Host` refuses any host that is not Linux (lines 120-125).
* The provider archives are built with `ar x --output`, `objcopy
  --strip-debug` and `ar qcsD` (lines 223, 237, 239). All three are GNU
  extensions.
* The unit is localized with `ld -r`, then `objcopy --keep-global-symbols`
  with ELF COMDAT groups renamed, then `ar rcsD` (lines 318-321).

A Mach-O path needs Apple's `ld -r -exported_symbols_list` (with
`-force_load` of the cargo archive), `strip -S`, and deterministic
archives. Mach-O has no COMDAT groups, so the renaming step goes away.

Localization is required, not cosmetic. An executable also links
Botlish's native runtime, which is Rust too, so an unlocalized unit
brings a second copy of Rust's standard library and the symbols collide.
A Mach-O version of the check that the unit exports only `bh_*` functions
(`http-unit-exports`) is part of this item. `tests/cffi/http.tcl` needs
the same host support.

`boringssl.bot` declares `extern c library "stdc++"`. macOS has no
libstdc++; its C++ runtime is libc++. Link declarations come only from
source, so `boringssl` must become a target-aware package with a module
per target, whose macOS module declares `c++`. That is allowed: the
`sdl3` package already ships a binding module per target.

### 3.5 Release and reproducibility (1 to 1.5 weeks; the least certain item)

* **Where macOS builds run.** Releases are built in the pinned author
  image (`tools/package-build/`), which is Linux. Building for
  aarch64-apple-darwin there would need Apple's SDK. So macOS native files
  must be built on a Mac or a macOS GitHub runner.
* **One artifact for every target.** A release is one artifact covering
  all its targets ([AGENTS.md](../AGENTS.md), "The package manager"). The
  pipeline becomes: macOS runners build the unit, the provider and the
  driver adapter; a Linux job packs them with `botlish native add -target
  macos-aarch64`. The package manager reads Mach-O as bytes, so packing on
  Linux works; system libraries are then "partially verified", which
  packing accepts.
* **Reproducibility.** The rule that two independent builds produce
  identical bytes (`package-reproducibility.yml`) needs a pinned Xcode and
  Rust toolchain on two macOS runners. Runner images drop old Xcode
  versions over time, which makes this fragile.
* **New releases** (each recorded once in `packages/RELEASES.tsv`):
  `boringssl` (target-aware), `http` 0.3.0, `event_loop_linux` 0.6.0, the
  new macOS driver 0.1.0, and a `process_linux` re-release.
* **First of its kind.** No package has shipped a macOS target before,
  and the consumer side has never installed one on macOS in practice: the
  Icy Tower macOS build stages its SDL binding by hand. Expect surprises.

### 3.6 Tests, CI and a clean room on macOS (about 1 week)

* **The http tests.** `tests/http-client.test` uses Python asyncio, `ssl`
  and `h2` peers, and makes its certificates with `openssl`. Python's
  packages install on macOS runners with pip, but macOS's `openssl` is
  LibreSSL, whose flags may differ. Test expectations that hold errno
  values need values per host (section 3.3).
* **CI.** No workflow runs the http tests today. A macOS job has to build
  the provider (CMake, Ninja) and the unit (cargo) before it can test.
* **The clean room.** The Linux clean room uses Docker
  (`audit/http-client/cleanroom/`), which macOS runners cannot run. A
  macOS equivalent installs Botlish.app and the artifacts on a fresh
  runner. Proving that no Rust or CMake was used needs a restricted
  `PATH`, because the runner image has both preinstalled.

### 3.7 Total and decisions

| Item | Effort |
|---|---|
| 3.1 macOS (kqueue) driver | 1.5 to 2 weeks |
| 3.2 driver abstraction in `http.bot` | 3 to 5 days |
| 3.3 Rust unit fixes | 1 to 2 days |
| 3.4 build tooling, target-aware `boringssl` | about 1 week |
| 3.5 release and reproducibility | 1 to 1.5 weeks |
| 3.6 tests, CI, clean room | about 1 week |
| **Shippable** | **about 5 to 7 weeks** |
| Prototype (3.1 to 3.4, built and run locally on one Mac) | about 1.5 to 2 weeks |

The port needs four decisions:

1. **Driver abstraction.** A context trait that `http` requires
   (recommended), or one cross-platform driver package (section 3.2).
2. **macOS release builds.** Whether they must meet the same "two
   independent builds, identical bytes" rule as Linux releases, given how
   fragile pinned Xcode versions are on hosted runners.
3. **Trust store.** `/etc/ssl/cert.pem` holds Apple's system roots, but
   not roots added only to the Keychain, such as roots installed by an
   organization's device management. Trusting the Keychain would mean
   verifying through Apple's Security framework instead of BoringSSL's
   store. That changes the package's rule of one documented trust source,
   and is a design decision, not a port detail.
4. **Graphical programs.** Whether macOS GUI programs (SDL or Cocoa) using
   `http` are in scope, which would add CFRunLoop integration
   (section 3.1).

Linux AArch64 is not done either: the unit has never been built for it
(README). It is not a prerequisite for macOS, but it would exercise the
AArch64 build of Rust and BoringSSL inside the pinned Linux image first.
Windows remains blocked separately: its I/O completion ports report
completion, not readiness, which the bridge's readiness registry does not
model (HTTP-SHIPPING-CENSUS.md, 8.6).

## 4. Server-sent events

### 4.1 What the client already provides

Responses stream chunk by chunk with backpressure: `http::read` returns
each chunk as it arrives, at most one chunk held natively
([http.bot:1601](../packages/http/http.bot)). Cancellation tokens and
deadlines exist. The default idle timeout is 300 s per wait "because a
server-sent event stream may be quiet for minutes"
([http.bot:311](../packages/http/http.bot)). HTTP/1.1 and HTTP/2 streams
behave the same to a reader.

The milestone report calls the missing piece "a consumer's few dozen lines"
(HTTP-CLIENT-PACKAGE-MILESTONE-1.md, sections 15 and 16). That is true of
a bare decoder, not of one tested to this repository's standards.

### 4.2 Scope options

* **A decoder (recommended minimum).** The WHATWG event-stream rules:
  * strip the UTF-8 byte-order mark once, at the start;
  * split lines on CRLF, LF or CR, including a CR that ends one chunk
    before an LF that starts the next;
  * the fields `data`, `event`, `id` (ignored if it contains NUL) and
    `retry` (ASCII digits only);
  * comment lines starting with `:`;
  * dispatch on a blank line: data lines joined with LF, the trailing LF
    removed, no event when the data is empty, type `message` by default,
    and the last event ID kept across events.
* **A convenience reader.** A suspending `next event` over an exchange,
  so a program does not manage the decoder state itself.
* **Automatic reconnection (optional).** As a browser's EventSource does
  it: a retry timer on the event loop, a `Last-Event-ID` header, stop on
  status 204, fail on a status that is not 200 or a wrong content type.
  Streaming POST requests, such as an LLM API's, do not need it.

### 4.3 Constraints the design must respect

* **No byte indexing.** `Bytes` offers `slice` and `decode_utf8` but no
  operation that reads one byte
  ([bytes.bot](../stdlib/abi/bytes.bot)), so the decoder works on decoded
  text. A chunk may end in the middle of a UTF-8 character. Holding back
  up to three trailing bytes when `decode_utf8` fails, and joining them to
  the next chunk, handles that. Invalid UTF-8 anywhere else stays an
  error, a stricter policy than the spec's replacement characters, which
  the package documents.
* **Iterate text in order, never by index.** Native `char_at` is O(1) on
  ASCII text but searches from the start on non-ASCII text
  (`char_at_index`, [ops.rs:2829](../native/src/runtime/ops.rs)). An
  index loop would be quadratic on, for example, model output that
  contains non-ASCII text. A loop over the text's characters is linear,
  and appending to a String in a fold is linear natively
  (FOLD-VIRTUAL-LIST-CONSTRUCTION-MILESTONE-1.md).
* **No native code.** The decoder needs nothing in the Rust unit and
  nothing that depends on the platform.

### 4.4 Where it lives

As a module of the `http` package (for example `http::sse`), or as a
separate pure-Botlish package that depends on `http`. Either way it is a
new release. Any change under `packages/http`, documentation included, is
a new version, built twice in the pinned author image and recorded. The
Rust unit itself would not change.

### 4.5 Testing

* The decoder runs on every backend without a network, so its cases can
  be a golden suite.
* A fuzzer splits a corpus at every point and compares the events with an
  independent Python reference, following the repository's oracle
  pattern.
* An SSE server in `tests/http-client.test`, over HTTP/1.1 and HTTP/2,
  covers heartbeats, cancellation and the idle timeout.
* Mutants, and a section in GUIDE.md.

### 4.6 Effort

| Item | Effort |
|---|---|
| Decoder and convenience reader | 2 to 3 days |
| Tests: golden suite, split fuzzer and oracle, live peer, mutants; GUIDE section | 2 to 3 days |
| Release: `http` 0.3.0 rebuilt and recorded | about 1 day |
| **Decoder total** | **about 1 to 1.5 weeks** |
| Optional reconnection | 3 to 5 more days |

## 5. Order and dependencies

1. **SSE on Linux.** Independent of everything in section 3.
2. **Driver abstraction (3.2),** with the `event_loop_linux` and
   `process_linux` re-releases. Worth doing early even though it changes
   nothing for Linux users: it is the step that moves package locks.
3. **macOS driver (3.1) and Rust fixes (3.3),** as a prototype on a Mac.
4. **Build tooling (3.4), then release and CI (3.5, 3.6).**

If the SSE release (`http` 0.3.0) lands before the driver abstraction,
the abstraction becomes `http` 0.4.0. Doing both in one release saves one
release cycle.

## 6. What this estimate did not check

* **Nothing was compiled for aarch64-apple-darwin:** no Mac was available
  for this survey. The constants in section 3.3 come from the `libc`
  crate's Apple definitions (`src/unix/bsd/apple/mod.rs` on its main
  branch).
* **The weak-reference behavior on Mach-O,** and whether `MSG_NOSIGNAL`
  or `SO_NOSIGPIPE` suppresses SIGPIPE, are expectations to verify, not
  observations.
* **The effort figures** are one reviewer's judgement from reading the
  code. No milestone of this kind (the first macOS package release) has
  been done before to calibrate them against.
