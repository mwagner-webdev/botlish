# raven.tcl -- the package-owned Raven the Raven binding and wrapper link
# (RAVEN-BINDINGS.md).
#
#   tclsh9.0 tests/cffi/raven.tcl         build it (once) and print its
#                                          directory
#   source tests/cffi/raven.tcl           cffi::ravenDir: the directory, ""
#                                          when not built; cffi::ravenDesktopDir:
#                                          the desktop build's (X11, Vulkan),
#                                          "" when not built
#
# The library is the Raven release the binding profile pins
# (tools/c-bindgen/profiles/raven.tcl: its tag and commit), fetched into the
# C header sources (tools/c-bindgen.tcl fetch raven) and built once with
# CMake and Ninja as the shared libraven.so. By default the build is
# headless -- Raven's null platform and no GPU backend
# (-DRAVEN_PLATFORM=null -DRAVEN_BACKEND_VULKAN=OFF): R_BACKEND_NULL and
# `headless` windows, which the tests use, no X11 development package, and
# no download of the Vulkan headers at configuration.
# BOTLISH_RAVEN_CMAKE_FLAGS replaces those flags (empty for a desktop build:
# X11 and the Vulkan renderer, which loads libvulkan.so.1 when a program
# runs). Botlish links it by the generated binding's `extern c library
# "raven"` and -L; an executable finds it at run time by LD_LIBRARY_PATH
# (Botlish adds no rpath).
#
# The directory is $BOTLISH_RAVEN_DIR when set, else raven/COMMIT under
# Botlish's cache directory (raven/COMMIT-FLAGS for other flags); never the
# repository. Test and example infrastructure only: Botlish's compiler and
# runtime never build or need it.

namespace eval cffi {
    variable ravenHere [file dirname [file normalize [info script]]]
}

proc cffi::RavenRoot {} {
    variable ravenHere
    return [file dirname [file dirname $ravenHere]]
}

proc cffi::RavenCacheDir {} {
    foreach {var sub} {BOTLISH_CACHE_DIR {} XDG_CACHE_HOME botlish} {
        if {[info exists ::env($var)] && $::env($var) ne ""} {
            return [file normalize [file join $::env($var) {*}$sub]]
        }
    }
    return [file normalize [file join [file home] .cache botlish]]
}

# The pinned {url tag commit} of the binding profile.
proc cffi::RavenSource {} {
    set channel [open [file join [RavenRoot] tools c-bindgen profiles raven.tcl] r]
    set text [read $channel]
    close $channel
    if {![regexp {source \{url (\S+) tag (\S+) commit ([0-9a-f]{40})\}} $text -> url tag commit]} {
        error "raven.tcl: no pinned source in the raven binding profile"
    }
    return [list url $url tag $tag commit $commit]
}

# The CMake flags of the build: headless unless BOTLISH_RAVEN_CMAKE_FLAGS
# says otherwise.
proc cffi::RavenFlags {} {
    if {[info exists ::env(BOTLISH_RAVEN_CMAKE_FLAGS)]} {
        return [regexp -all -inline {\S+} $::env(BOTLISH_RAVEN_CMAKE_FLAGS)]
    }
    return {-DRAVEN_PLATFORM=null -DRAVEN_BACKEND_VULKAN=OFF}
}

proc cffi::RavenBuildDir {} {
    if {[info exists ::env(BOTLISH_RAVEN_DIR)] && $::env(BOTLISH_RAVEN_DIR) ne ""} {
        return [file normalize $::env(BOTLISH_RAVEN_DIR)]
    }
    if {[info exists ::env(BOTLISH_RAVEN_CMAKE_FLAGS)]} {
        return [RavenDirFor [RavenFlags]]
    }
    return [file join [RavenCacheDir] raven [dict get [RavenSource] commit]]
}

# The cache directory of a build configured with FLAGS other than the
# headless default: another configuration is another library, never the
# headless one's directory.
proc cffi::RavenDirFor {flags} {
    set name [dict get [RavenSource] commit]-[format %08x [zlib crc32 [join $flags " "]]]
    return [file join [RavenCacheDir] raven $name]
}

# DIR when it holds a built libraven.so, else "".
proc cffi::RavenBuilt {dir} {
    if {![llength [glob -nocomplain -directory $dir libraven.so*]]} { return "" }
    return $dir
}

# The directory holding the built libraven.so, or "" when it is not built.
proc cffi::ravenDir {} {
    return [RavenBuilt [RavenBuildDir]]
}

# The desktop build's directory (BOTLISH_RAVEN_CMAKE_FLAGS="" tclsh9.0
# tests/cffi/raven.tcl: X11 and the Vulkan renderer), or "" when it is not
# built.
proc cffi::ravenDesktopDir {} {
    return [RavenBuilt [RavenDirFor {}]]
}

proc cffi::RavenBuild {} {
    set dir [RavenBuildDir]
    if {[ravenDir] ne ""} {
        return $dir
    }
    if {$::tcl_platform(os) ne "Linux"} {
        error "raven: the package-owned Raven is built on Linux only (RAVEN-BINDINGS.md, \"Targets\")"
    }
    set root [RavenRoot]
    # The fetch prints the checkout's directory last; a first fetch prints
    # its progress line before it.
    set fetched [exec [info nameofexecutable] [file join $root tools c-bindgen.tcl] fetch raven]
    set source [lindex [split [string trim $fetched] \n] end]
    file mkdir $dir
    puts "raven: building libraven.so in $dir"
    exec cmake -S $source -B $dir -GNinja -DCMAKE_BUILD_TYPE=Release -DRAVEN_BUILD_SHARED=ON \
        -DRAVEN_BUILD_EXAMPLES=OFF -DRAVEN_BUILD_TESTS=OFF -DRAVEN_BUILD_TOOLS=OFF \
        {*}[RavenFlags] >@stdout 2>@stderr
    exec ninja -C $dir raven >@stdout 2>@stderr
    if {[ravenDir] eq ""} {
        error "raven: the build produced no libraven.so in $dir"
    }
    return $dir
}

if {[info exists ::argv0] && [file normalize $::argv0] eq [file normalize [info script]]} {
    puts [cffi::RavenBuild]
}
