# audit/event-loop

A thread-local, coroutine-native event loop: the exploratory milestone
EVENT-LOOP-EXPLORATION.md. An isolated prototype -- nothing in `core/`,
`hir/`, `surface/`, `compiler/`, `native/` or `stdlib/` loads it, and
`tests/local.tcl` and CI do not run it.

* `src/evloop.bot` -- the scheduler: one ordinary module over the existing
  coroutines, MutableVectors and contexts (the turn, the ready queue,
  registrations, timers, observers, revocation, shutdown), with the
  `Driver` and `NativePumps` context traits a driver implements.
* `src/simdrv.bot` -- the deterministic driver (a virtual clock and
  scripted records); every `a-*.bot` program runs on it, on all four
  backends.
* `native/evn.c`, `src/evn.bot` -- the Linux driver (epoll, eventfd, the
  monotonic clock, TCP, producer threads); `native/evn_test.c` its C tests.
* `native/evsdl.c`, `src/evsdl.bot` -- SDL3 coordinated with the loop five
  ways, and the lifecycle barrier; `native/evsdlhost.c`,
  `src/evsdlhost.bot` -- SDL3's own application host driving the loop.
* `native/win32/` -- the Win32 probe (message pump, window procedure, modal
  loops); its README has the Windows commands and the Wine evidence.
* `src/` -- the workloads (`gameserver.bot`, `quietlib.bot`, `busylib.bot`,
  `workload.bot`, `mixed.bot`, ...) and the scenario programs: `a-*`
  deterministic, `b-*` native, `s-*` programs the compiler must reject,
  `alloc-*` and `bench-*` the measurements.
* `tools/lifetime.tcl`, `lifetime/` -- a prototype foreign-pointer lifetime
  analysis over HIR and its fixtures.
* `tools/check.tcl` (with `claims.tcl`, `static.tcl`, `native.tcl`,
  `native-more.tcl`) -- every claim of the report, checked
  (`tclsh9.0 audit/event-loop/tools/check.tcl ?-parts sim|static|lifetime|native? ?-only GLOB?`);
  `tools/bench.tcl` -- the performance numbers.
* `repro/trait-op-yield-edge/` -- a compiler bug found on the way, reduced
  (the report, section 12).

The C adapters are built by the tools into `build/` (ignored). The SDL3
parts need the headless SDL3 that `tclsh9.0 tests/cffi/sdl3.tcl` builds, and
are skipped without it; the Win32 probe needs MinGW-w64 and Wine.
