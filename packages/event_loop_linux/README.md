# packages/event_loop_linux

The production Linux driver of `std::event_loop` (EVENT-LOOP-MILESTONE-1.md,
"Linux driver"): a Botlish package -- a module tree with its own native
adapter -- that an application installs under its `.bot_modules`:

    tclsh9.0 tools/event-loop-linux.tcl install APP

copies this directory to `APP/.bot_modules/event_loop_linux` and builds
`native/libevent_loop_linux.a` there with the host's C compiler. The
module links it by a path relative to the package instance
(`extern c library "event_loop_linux" static at "native/libevent_loop_linux.a"`).

* `event_loop_linux.bot` -- the module: the driver context `Linux`
  (implements `std::event_loop::Driver`) and the integration capability
  `Native` (endpoints, readiness watches, wakeups).
* `native/event_loop_linux.c` -- the C adapter: epoll, an eventfd, the
  monotonic clock, per-source endpoint rings, readiness watches, pumps,
  round-robin record collection and holds.
* `native/botlish_event_loop.h` -- the integration ABI a native library
  posts through (`botlish_event_post`, `botlish_event_wake`, pumps).

With the package manager (PACKAGE-MANAGER-MILESTONE-1.md),
`tools/package-repository.tcl REPO` stages the package the same way -- the
archive built on the author's side -- and packs it with its botlish.json as
`REPO/event_loop_linux-0.1.0.botpkg`; an application installs it with
`botlish add event_loop_linux -repository REPO`, and nothing is compiled on
the consumer's side. The artifact is one target's (its archive).

Tests: `tests/event-loop-linux.test`, `tests/package-workloads.test`.
