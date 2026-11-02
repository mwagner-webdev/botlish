# raven.tcl -- the package-owned Raven the Raven binding and wrapper link
# (RAVEN-BINDINGS.md; RAVEN-CLEANROOM-DESKTOP-MILESTONE-1.md, "The desktop
# build").
#
#   tclsh9.0 tests/cffi/raven.tcl            build the headless configuration
#                                             (once) and print its directory
#   tclsh9.0 tests/cffi/raven.tcl desktop    the desktop configuration
#   source tests/cffi/raven.tcl              cffi::ravenDir: the headless
#                                             build's directory, "" when not
#                                             built; cffi::ravenDesktopDir:
#                                             the desktop build's;
#                                             cffi::ravenBuild CONFIG: build
#
# The library is the Raven release the binding profile pins
# (tools/c-bindgen/profiles/raven.tcl: its tag and commit), fetched into the
# C header sources (tools/c-bindgen.tcl fetch raven) and built once with
# CMake and Ninja as the shared libraven.so. Two named configurations:
#
#   headless  Raven's null platform and no GPU backend (-DRAVEN_PLATFORM=null
#             -DRAVEN_BACKEND_VULKAN=OFF): R_BACKEND_NULL and `headless`
#             windows only, no X11 development package, no download. The
#             binding's and the package's tests link it.
#   desktop   Raven's X11 platform and its Vulkan renderer
#             (-DRAVEN_PLATFORM=x11 -DRAVEN_BACKEND_VULKAN=ON): real windows.
#             It needs libX11's headers (libx11-dev) to build and libX11.so.6
#             to load; Vulkan is loaded at run time (libvulkan.so.1, and the
#             driver it finds), so only Vulkan's headers are needed to build:
#             the Khronos Vulkan-Headers release pinned below, fetched by
#             tag and checked by commit (never Raven's own unpinned
#             download, never whatever SDK the machine has). Raven compiles
#             its null platform and renderer into every configuration, so
#             this one runs headless too (R_BACKEND_NULL, `headless`, no
#             display needed) -- the raven package bundles it.
#
# BOTLISH_RAVEN_CMAKE_FLAGS replaces the headless configuration's flags with
# its own (a custom configuration, in a directory of its own).
#
# Each configuration is built in a directory of its own under Botlish's
# cache (raven/COMMIT for headless, raven/COMMIT-desktop-VULKAN12 for
# desktop, raven/COMMIT-CRC for custom flags; never the repository), and a
# build is recognized by the stamp it writes there last
# (botlish-raven-configuration: the configuration's name, Raven's commit,
# the flags and the Vulkan headers' commit), never by a library merely
# present: a directory holding another configuration's library -- a stale
# headless build where the desktop one is expected -- is not built. A
# directory without the stamp (a build of an earlier version of this
# script) is built again, in place.
#
# $BOTLISH_RAVEN_DIR, when set, is the headless (or custom) build's
# directory instead; its stamp is checked the same way.
#
# Test, example and package-author infrastructure only: Botlish's compiler
# and runtime never build or need it, and a package consumer never runs it
# (the raven package carries the desktop build).

namespace eval cffi {
    variable ravenHere [file dirname [file normalize [info script]]]
    # The Vulkan headers of the desktop configuration: Khronos's release
    # v1.3.290 (the version Raven's own CMake asks for), checked by commit.
    variable vulkanHeaders {url https://github.com/KhronosGroup/Vulkan-Headers.git tag v1.3.290 commit b379292b2ab6df5771ba9870d53cf8b2c9295daf}
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

# The pinned Raven's checkout (tools/c-bindgen.tcl fetch raven prints its
# directory last; a first fetch prints its progress line before it).
proc cffi::RavenCheckout {} {
    set fetched [exec [info nameofexecutable] [file join [RavenRoot] tools c-bindgen.tcl] fetch raven]
    return [lindex [split [string trim $fetched] \n] end]
}

# The pinned Vulkan headers' checkout (fetched once, checked by commit:
# tools/cheader's fetch), beside the C header sources.
proc cffi::VulkanHeaders {} {
    variable vulkanHeaders
    source [file join [RavenRoot] tools cheader common.tcl]
    return [::chdr::fetch vulkan-headers $vulkanHeaders]
}

# The configuration NAME: {name N flags F vulkan COMMIT}. The desktop
# configuration's flags name its Vulkan headers' directory only when it is
# built (cffi::RavenConfigure), so that knowing the configuration fetches
# nothing.
proc cffi::RavenConfiguration {name} {
    variable vulkanHeaders
    switch -- $name {
        headless {
            if {[info exists ::env(BOTLISH_RAVEN_CMAKE_FLAGS)]} {
                return [dict create name custom flags [regexp -all -inline {\S+} $::env(BOTLISH_RAVEN_CMAKE_FLAGS)] vulkan ""]
            }
            return [dict create name headless flags {-DRAVEN_PLATFORM=null -DRAVEN_BACKEND_VULKAN=OFF} vulkan ""]
        }
        desktop {
            return [dict create name desktop flags {-DRAVEN_PLATFORM=x11 -DRAVEN_BACKEND_VULKAN=ON -DRAVEN_FETCH_VULKAN_HEADERS=OFF} \
                vulkan [dict get $vulkanHeaders commit]]
        }
    }
    error "raven.tcl: no configuration $name (headless or desktop)"
}

# The directory of CONFIGURATION's build.
proc cffi::RavenDirOf {configuration} {
    set commit [dict get [RavenSource] commit]
    switch -- [dict get $configuration name] {
        desktop {
            return [file join [RavenCacheDir] raven $commit-desktop-[string range [dict get $configuration vulkan] 0 11]]
        }
        custom - headless {
            if {[info exists ::env(BOTLISH_RAVEN_DIR)] && $::env(BOTLISH_RAVEN_DIR) ne ""} {
                return [file normalize $::env(BOTLISH_RAVEN_DIR)]
            }
            if {[dict get $configuration name] eq "custom"} {
                set crc [format %08x [zlib crc32 [join [dict get $configuration flags] " "]]]
                return [file join [RavenCacheDir] raven $commit-$crc]
            }
            return [file join [RavenCacheDir] raven $commit]
        }
    }
}

# The stamp a build of CONFIGURATION writes when it is complete.
proc cffi::RavenStamp {configuration} {
    return [join [list "configuration [dict get $configuration name]" \
        "raven [dict get [RavenSource] commit]" \
        "flags [dict get $configuration flags]" \
        "vulkan-headers [dict get $configuration vulkan]"] \n]\n
}

proc cffi::RavenStampFile {dir} {
    return [file join $dir botlish-raven-configuration]
}

# DIR when it holds a complete build of CONFIGURATION (its stamp and a
# libraven.so), else "".
proc cffi::RavenBuiltAs {dir configuration} {
    set stamp [RavenStampFile $dir]
    if {![file isfile $stamp] || ![llength [glob -nocomplain -directory $dir libraven.so*]]} {
        return ""
    }
    set channel [open $stamp r]
    set text [read $channel]
    close $channel
    if {$text ne [RavenStamp $configuration]} { return "" }
    return $dir
}

# The directory holding the built headless libraven.so (or the custom
# configuration's), or "" when it is not built.
proc cffi::ravenDir {} {
    set configuration [RavenConfiguration headless]
    return [RavenBuiltAs [RavenDirOf $configuration] $configuration]
}

# The desktop build's directory (tclsh9.0 tests/cffi/raven.tcl desktop:
# X11 and the Vulkan renderer), or "" when it is not built.
proc cffi::ravenDesktopDir {} {
    set configuration [RavenConfiguration desktop]
    return [RavenBuiltAs [RavenDirOf $configuration] $configuration]
}

# Builds the configuration NAME (headless or desktop) unless it is built;
# its directory.
proc cffi::ravenBuild {{name headless}} {
    set configuration [RavenConfiguration $name]
    set dir [RavenDirOf $configuration]
    if {[RavenBuiltAs $dir $configuration] ne ""} {
        return $dir
    }
    if {$::tcl_platform(os) ne "Linux"} {
        error "raven: the package-owned Raven is built on Linux only (RAVEN-BINDINGS.md, \"Targets\")"
    }
    set source [RavenCheckout]
    set flags [dict get $configuration flags]
    if {[dict get $configuration name] eq "desktop"} {
        lappend flags -DRAVEN_VULKAN_INCLUDE_DIR=[file join [VulkanHeaders] include]
    }
    file mkdir $dir
    # The stamp goes last: a build that stops before it is no build.
    file delete [RavenStampFile $dir]
    puts "raven: building the [dict get $configuration name] libraven.so in $dir"
    exec cmake -S $source -B $dir -GNinja -DCMAKE_BUILD_TYPE=Release -DRAVEN_BUILD_SHARED=ON \
        -DRAVEN_BUILD_EXAMPLES=OFF -DRAVEN_BUILD_TESTS=OFF -DRAVEN_BUILD_TOOLS=OFF \
        {*}$flags >@stdout 2>@stderr
    exec ninja -C $dir raven >@stdout 2>@stderr
    if {![llength [glob -nocomplain -directory $dir libraven.so*]]} {
        error "raven: the build produced no libraven.so in $dir"
    }
    set channel [open [RavenStampFile $dir] w]
    puts -nonewline $channel [RavenStamp $configuration]
    close $channel
    return $dir
}

# Compatibility: the headless (or custom) build, and its CMake flags.
proc cffi::RavenBuild {} {
    return [ravenBuild headless]
}

proc cffi::RavenFlags {} {
    return [dict get [RavenConfiguration headless] flags]
}

if {[info exists ::argv0] && [file normalize $::argv0] eq [file normalize [info script]]} {
    if {[llength $::argv] > 1 || [lindex $::argv 0] ni {"" headless desktop}} {
        puts stderr "usage: tclsh9.0 tests/cffi/raven.tcl ?headless|desktop?"
        exit 2
    }
    set configuration headless
    if {[llength $::argv]} { set configuration [lindex $::argv 0] }
    puts [cffi::ravenBuild $configuration]
}
