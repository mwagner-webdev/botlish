# packages/sdlkit

A reusable SDL3 airlock (BOT-MODULES-MILESTONE-1.md, "A reusable SDL3
package with its own binding"): the module `sdlkit` keeps every SDL object
behind its own opaque context `sdlkit::Kit`, so an application uses SDL with
no pointer, native view or C call of its own:

    import sdlkit

    with context sdlkit::open()
    shown = sdlkit::frame()
    sdlkit::close()

It depends on the generated SDL3 binding, the package `sdl3`
(packages/sdl3), which its botlish.json requests and locks; the package
manager installs it in sdlkit's own `.bot_modules`, where only sdlkit sees
it (PACKAGE-MANAGER-MILESTONE-1.md):

    tclsh9.0 tools/package-repository.tcl REPO          # pack sdlkit, sdl3, ...
    botlish add sdlkit -project APP -repository REPO    # APP/.bot_modules/sdlkit,
                                                        # .../sdlkit/.bot_modules/sdl3

sdlkit itself is target-independent (schema 1): its sdl3 dependency is the
target-aware package, and the package manager derives the target view of
both (PACKAGE-MANAGER-MILESTONE-2.md). A program runs natively with the
SDL3 sdl3 bundles, with no -L or LD_LIBRARY_PATH; `botlish native deploy
-target linux-x86_64 -out DIR` places libSDL3.so.0 in DIR/lib for an
executable linked with `-runtime-path '$ORIGIN/lib'`. Native backends only.
