# baseline/ -- the original Icy Tower boundary

The Icy Tower game's program files at commit 6df89a8e, verbatim: the
vertical slice (ICY-TOWER-VERTICAL-SLICE-1.md) before the context refactor
of ICY-TOWER-CONTEXT-REFACTOR-CENSUS.md, whose `sdl.bot` hands raw SDL
pointers -- the renderer, a non-opaque `Video` of six pointers -- across its
boundary to `render.bot` and `main.bot`.

Kept as the regression fixture of CONTEXT-RESOURCE-ESCAPE
(MODULE-PRIVACY-AND-CONTEXT-ESCAPE-MILESTONE-1.md): staged with the
committed SDL3 binding (`tools/c-bindgen.tcl stage sdl3 -app` this
directory), its `main.bot` compiles and draws exactly the twelve warnings
the census's rule predicted for it -- `sdl::color`, `clear`, `present`,
`fill`, `line`, `text`, `scale`, `open`, `poll`, `close` and the structs
`sdl::Video` and `sdl::Polled` -- which `tests/workload-icy-tower.test`'s
`workload-icy-tower-baseline-warnings` pins. It is evidence, not code to
keep current: never edit it (the game is `examples/games/icy-tower/`).
