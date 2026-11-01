# packages/sdl3

The generated SDL3 binding as a package (C-BINDGEN.md, "SDL3";
BOT-MODULES-MILESTONE-1.md, "SDL3 workload"): the namespaces `sdl3::init`,
`sdl3::video`, `sdl3::events`, `sdl3::render`, ... of the pinned SDL
release-3.4.18, generated from its headers for one target and never
edited.

This directory holds only the package's descriptor and this file. The
binding itself is the committed `generated/c/sdl3/TARGET/sdl3/`, which
`tools/package-repository.tcl` stages as the package's `sdl3/` tree when it
packs the artifact: an artifact of this package is therefore one target's
(PM-2 selects a target's binding from one package). The binding links
`SDL3` by `extern c library "SDL3"`; the library itself is not part of the
package (`tests/cffi/sdl3.tcl` builds the pinned release).
