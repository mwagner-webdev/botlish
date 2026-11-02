# packages/sdl3

The generated SDL3 binding as a package (C-BINDGEN.md, "SDL3";
BOT-MODULES-MILESTONE-1.md, "SDL3 workload"): the namespaces `sdl3::init`,
`sdl3::video`, `sdl3::events`, `sdl3::render`, ... of the pinned SDL
release-3.4.18, generated from its headers for each target and never
edited.

This directory holds only the package's descriptor (its name and version:
no native metadata) and this file. `tools/package-repository.tcl` makes
the release with the package manager's authoring commands
(PACKAGE-MANAGER-MILESTONE-3.md): for linux-x86_64 and linux-aarch64 it
stages the committed generated binding `generated/c/sdl3/TARGET/sdl3/`
(`botlish package stage -modules`), imports the binding's thunk archive
(`tools/c-bindgen.tcl build`, the target's compiler) and, for
linux-x86_64, the pinned SDL3 as a bundled shared library
(`tests/cffi/sdl3.tcl`'s build, stripped) with `botlish native add`, which
reads their facts from the files, and declares the system's SDL3 as the
alternative (`botlish native require SDL3 -origin system`). One artifact,
`sdl3-0.2.1.botpkg`, is the release for both targets; the package manager
derives the target view a compilation reads. On linux-x86_64 a consumer
may choose a system-managed SDL3 instead (`"origins": {"SDL3": "system"}`,
verified by the distribution's metadata); on linux-aarch64 SDL3 is the
target system's (reported unverified from another host). The binding links
`SDL3` by `extern c library "SDL3"`, found in the view's library directory.
