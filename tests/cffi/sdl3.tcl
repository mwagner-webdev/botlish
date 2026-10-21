# sdl3.tcl -- the package-owned SDL3 the binding generator's SDL acceptance
# links (C-BINDGEN.md, "SDL3").
#
#   tclsh9.0 tests/cffi/sdl3.tcl          build it (once) and print its
#                                          directory
#   source tests/cffi/sdl3.tcl            cffi::sdl3Dir: the directory, ""
#                                          when not built
#
# The library is the SDL3 release the binding profile pins
# (tools/c-bindgen/profiles/sdl3.tcl: its tag and commit), fetched into the
# C header sources (tools/c-bindgen.tcl fetch sdl3) and built once with
# CMake and Ninja as the shared libSDL3.so. By default the build is
# headless -- no X11 or Wayland (SDL_UNIX_CONSOLE_BUILD): the dummy and
# offscreen video drivers, which the headless acceptance uses, and no
# dependency on the host's desktop development packages.
# BOTLISH_SDL3_CMAKE_FLAGS replaces those flags (empty for a desktop build
# with every backend the host has, for the interactive smoke). Botlish links it by the generated binding's
# `extern c library "SDL3"` and -L; the executable finds it at run time by
# LD_LIBRARY_PATH (Botlish adds no rpath).
#
# The directory is $BOTLISH_SDL3_DIR when set, else sdl3/COMMIT under
# Botlish's cache directory; never the repository. Test and example
# infrastructure only: Botlish's compiler and runtime never build or need it.

namespace eval cffi {
    variable sdlHere [file dirname [file normalize [info script]]]
}

proc cffi::SdlRoot {} {
    variable sdlHere
    return [file dirname [file dirname $sdlHere]]
}

proc cffi::SdlCacheDir {} {
    foreach {var sub} {BOTLISH_CACHE_DIR {} XDG_CACHE_HOME botlish} {
        if {[info exists ::env($var)] && $::env($var) ne ""} {
            return [file normalize [file join $::env($var) {*}$sub]]
        }
    }
    return [file normalize [file join [file home] .cache botlish]]
}

# The pinned {url tag commit} of the binding profile.
proc cffi::SdlSource {} {
    set channel [open [file join [SdlRoot] tools c-bindgen profiles sdl3.tcl] r]
    set text [read $channel]
    close $channel
    if {![regexp {source \{url (\S+) tag (\S+) commit ([0-9a-f]{40})\}} $text -> url tag commit]} {
        error "sdl3.tcl: no pinned source in the sdl3 binding profile"
    }
    return [list url $url tag $tag commit $commit]
}

proc cffi::SdlBuildDir {} {
    if {[info exists ::env(BOTLISH_SDL3_DIR)] && $::env(BOTLISH_SDL3_DIR) ne ""} {
        return [file normalize $::env(BOTLISH_SDL3_DIR)]
    }
    return [file join [SdlCacheDir] sdl3 [dict get [SdlSource] commit]]
}

# The directory holding the built libSDL3.so, or "" when it is not built.
proc cffi::sdl3Dir {} {
    set dir [SdlBuildDir]
    return [expr {[llength [glob -nocomplain -directory $dir libSDL3.so*]] ? $dir : ""}]
}

proc cffi::SdlBuild {} {
    set dir [SdlBuildDir]
    if {[sdl3Dir] ne ""} {
        return $dir
    }
    set root [SdlRoot]
    # The fetch prints the checkout's directory last; a first fetch prints
    # its progress line before it.
    set fetched [exec [info nameofexecutable] [file join $root tools c-bindgen.tcl] fetch sdl3]
    set source [lindex [split [string trim $fetched] \n] end]
    file mkdir $dir
    puts "sdl3: building libSDL3.so in $dir"
    set flags {-DSDL_UNIX_CONSOLE_BUILD=ON -DSDL_X11=OFF -DSDL_WAYLAND=OFF}
    if {[info exists ::env(BOTLISH_SDL3_CMAKE_FLAGS)]} {
        set flags [regexp -all -inline {\S+} $::env(BOTLISH_SDL3_CMAKE_FLAGS)]
    }
    exec cmake -S $source -B $dir -GNinja -DCMAKE_BUILD_TYPE=Release -DSDL_SHARED=ON -DSDL_STATIC=OFF \
        -DSDL_TEST_LIBRARY=OFF -DSDL_TESTS=OFF -DSDL_EXAMPLES=OFF -DSDL_INSTALL=OFF {*}$flags >@stdout 2>@stderr
    exec ninja -C $dir SDL3-shared >@stdout 2>@stderr
    if {[sdl3Dir] eq ""} {
        error "sdl3: the build produced no libSDL3.so in $dir"
    }
    return $dir
}

if {[info exists ::argv0] && [file normalize $::argv0] eq [file normalize [info script]]} {
    puts [cffi::SdlBuild]
}
