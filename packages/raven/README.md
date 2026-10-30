# packages/raven

A Botlish interface to [Raven](https://github.com/oscar-soirey/Raven), the
C11 GUI library (RAVEN-BINDINGS.md): a package an application installs under
its `.bot_modules`:

    tclsh9.0 tests/cffi/raven.tcl                 # once: builds libraven.so (headless by default)
    tclsh9.0 tools/raven-package.tcl install APP  # the package, for the host's target

`install` copies this directory to `APP/.bot_modules/raven`, stages the
committed GENERATED binding of the target beside it
(`generated/c/raven/TARGET/raven/` as the package's `raven/`) and builds
`native/libraven_bridge.a` there with the host's C compiler, against the
pinned Raven's headers.

* `raven.bot` -- the module `raven`: windows, panels and controls as
  nominal handles (a slider's and a spin box's value both raw and admitted:
  RAW-C-FLOAT-FFI-MILESTONE-1.md), the frame loop, themes, actions, timers, synthetic input,
  and the events of everything it made, polled (`raven::events()`); the
  context `raven::Ui` for what needs native memory (starting Raven, sizes,
  rectangles, its last error).
* `native/raven_bridge.c` -- the event bridge: C callbacks that record what
  Raven reports into a queue the module reads. Botlish functions cannot be C
  callbacks, so this is the one C code the package adds; it never calls
  Botlish.
* `raven/` (staged, generated) -- the whole C API, 921 functions:
  `raven::core`, `raven::window`, `raven::controls`, ... for anything the
  module leaves out (a handle's `id` is the Rid those functions take).

Programs link Raven itself by `-L` (the directory `tests/cffi/raven.tcl`
prints) and find `libraven.so` at run time by `LD_LIBRARY_PATH`. Native
backends only: the Tcl backends refuse a C call.

Tests: `tests/raven.test`. Example: `examples/raven/`.
