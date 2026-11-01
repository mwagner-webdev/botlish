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

Running a program needs the SDL3 shared library (`tests/cffi/sdl3.tcl`
builds the pinned release) by `-L` and `LD_LIBRARY_PATH`: native
deployment is PM-2's, and the package manager neither builds nor installs
it. Native backends only.
