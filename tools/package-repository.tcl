# package-repository.tcl -- pack this repository's packages into a local
# package repository (PACKAGE-MANAGER-MILESTONE-1.md, "Workloads";
# PACKAGE-MANAGER-MILESTONE-2.md, "Workloads").
#
#   tclsh9.0 tools/package-repository.tcl ?-force? OUT ?NAME...?
#
# writes OUT/NAME-VERSION.botpkg for each named package (default: every
# package of packages/) and prints each release's identity: its name and
# version, the targets it holds and its SHA-256. A release is immutable: an
# OUT that already holds a different NAME-VERSION.botpkg is refused
# (EXISTS: raise the version), unless -force says this local file may be
# overwritten. A consumer then installs them with the ordinary
# commands -- `botlish add sdlkit -repository OUT`, `botlish install
# -target linux-aarch64` -- and nothing package-specific runs on the
# consumer's side: no compiler, no script.
#
# This is the *author's* side, and the one place left where packages differ
# (PM-3 makes it a generic workflow). A package directory of packages/ whose
# botlish.json names targets (schema 2) is one release for every target it
# names: this tool assembles each target's directory, targets/TARGET/, as
# that botlish.json declares it, and refuses to pack a release missing any
# of them (a release never claims a target it does not hold):
#
#   sdl3              targets/T/sdl3/: the committed generated binding of T
#                     (generated/c/sdl3/T/sdl3/, never edited);
#                     targets/T/native/: the binding's thunk archive, built
#                     for T by tools/c-bindgen.tcl build (the host's C
#                     compiler, or clang for T with T's C library headers),
#                     and on linux-x86_64 the pinned SDL3 as a shared
#                     library (tests/cffi/sdl3.tcl's build, stripped);
#   raven             targets/T/raven/: the generated binding of T;
#                     targets/T/native/: the event bridge's archive, built
#                     for T against the pinned Raven's headers, and
#                     libraven's *desktop* build for T -- Raven's X11
#                     platform and Vulkan renderer, which runs headless too
#                     (RAVEN-CLEANROOM-DESKTOP-MILESTONE-1.md): on the host
#                     tests/cffi/raven.tcl's `desktop` configuration (built
#                     here when it is not), for another architecture
#                     Raven's CMake build with that architecture's GNU
#                     cross compiler and that architecture's libX11 (Ubuntu
#                     24.04's packages, pinned below), cached; each checked
#                     to be the desktop build before it is packed;
#   event_loop_linux  targets/T/native/: the adapter's archive built for T.
#
# A target-independent package (sdlkit, a pure-Botlish one) is packed as it
# is. Native files are built here, by the author's toolchain, and travel in
# the artifact as files the package manager inspects but never runs.

set here [file dirname [file normalize [info script]]]
set root [file dirname $here]
source [file join $root pm pm.tcl]

proc usage {} {
    puts stderr "usage: tclsh9.0 tools/package-repository.tcl ?-force? OUT ?NAME...?"
    exit 2
}

set out ""
set names {}
set force 0
foreach arg $argv {
    if {$arg eq "-force"} {
        set force 1
    } elseif {[string match -* $arg]} {
        usage
    } elseif {$out eq ""} {
        set out [file normalize $arg]
    } else {
        lappend names $arg
    }
}
if {$out eq ""} usage
if {$names eq ""} {
    set names {sdl3 sdlkit raven event_loop_linux}
}

namespace eval author {
    variable root $::root
}

# The GNU compiler of TARGET's architecture: the host's cc for the host's
# target, else ARCH-linux-gnu-gcc (Debian's cross compilers).
proc author::cc {target} {
    if {$target eq [pm::target::host]} {
        if {[info exists ::env(CC)] && $::env(CC) ne ""} { return $::env(CC) }
        return cc
    }
    set arch [dict get [pm::target::facts $target] arch]
    set compiler $arch-linux-gnu-gcc
    if {[auto_execok $compiler] eq ""} {
        error "no C compiler for $target: $compiler is not installed (Debian: gcc-$arch-linux-gnu)"
    }
    return $compiler
}

proc author::ar {target} {
    if {$target eq [pm::target::host]} { return ar }
    set tool [dict get [pm::target::facts $target] arch]-linux-gnu-ar
    if {[auto_execok $tool] eq ""} { return ar }
    return $tool
}

proc author::strip {target} {
    if {$target eq [pm::target::host]} { return strip }
    return [dict get [pm::target::facts $target] arch]-linux-gnu-strip
}

# Compiles the C files SOURCES with FLAGS into the archive ARCHIVE for TARGET.
proc author::archive {target sources flags archive} {
    file mkdir [file dirname $archive]
    set objects {}
    foreach source $sources {
        set object [file join [file dirname $archive] [file rootname [file tail $source]].o]
        exec [cc $target] {*}$flags -c $source -o $object
        lappend objects $object
    }
    file delete $archive
    exec [ar $target] rcs $archive {*}$objects
    file delete {*}$objects
}

proc author::copyStripped {target from to} {
    file mkdir [file dirname $to]
    # The library's bytes, never a link (a build's libX.so.0 is one).
    file delete $to
    pm::WriteNew $to [pm::ReadBytes $from]
    exec [strip $target] --strip-unneeded $to
}

proc author::binding {profile target dir} {
    variable root
    set binding [file join $root generated c $profile $target $profile]
    if {![file isdirectory $binding]} {
        error "no committed $profile binding for $target ($binding)"
    }
    file mkdir [file join $dir targets $target]
    file copy $binding [file join $dir targets $target $profile]
}

# The pinned Raven's checkout (tools/c-bindgen.tcl fetch raven).
proc author::ravenSource {} {
    variable root
    set fetched [exec [info nameofexecutable] [file join $root tools c-bindgen.tcl] fetch raven]
    return [lindex [split [string trim $fetched] \n] end]
}

# The libX11 a cross build of Raven's X11 platform links, per target: the
# Debian packages of that architecture (Ubuntu 24.04's, from
# ports.ubuntu.com), pinned by SHA-256 -- the values of the archive's index
# (noble-updates for libX11, noble for the protocol headers), whose
# signature was checked against the Ubuntu archive key when they were
# recorded (RAVEN-CLEANROOM-DESKTOP-MILESTONE-1.md, "The desktop build").
# Only the author's build reads them: they are a link-time stand-in for the
# target system's libX11.so.6, never packed.
namespace eval author {
    variable x11Packages {
        linux-aarch64 {
            https://ports.ubuntu.com/ubuntu-ports/pool/main/libx/libx11/libx11-6_1.8.7-1ubuntu0.1_arm64.deb
            57f0bee78ea23caa31520a565fb12fcbea1ee5ecfd4f2055f12dd0ac3698f439
            https://ports.ubuntu.com/ubuntu-ports/pool/main/libx/libx11/libx11-dev_1.8.7-1ubuntu0.1_arm64.deb
            c67aedaed249c629628c24e717c5b550a066e246c678aa98098002ed0a8017e9
            https://ports.ubuntu.com/ubuntu-ports/pool/main/x/xorgproto/x11proto-dev_2023.2-1_all.deb
            3bf13a2ffb79ecd4014d438936014e5863f79eb59ebf76e8f43356271c90e7ce
        }
    }
}

# A directory holding TARGET's libX11 headers and libraries (usr/include,
# usr/lib/TRIPLET), unpacked from the pinned packages once, in the cache.
proc author::x11Sysroot {target} {
    variable x11Packages
    if {![dict exists $x11Packages $target]} {
        error "no libX11 packages are pinned for $target: Raven's desktop build for it cannot be linked"
    }
    set packages [dict get $x11Packages $target]
    set key [string range [pm::sha256::hex [join $packages \n]] 0 11]
    set dir [file join [cffi::RavenCacheDir] raven-cross x11-$target-$key]
    if {[file isfile [file join $dir complete]]} {
        return $dir
    }
    file delete -force $dir
    file mkdir [file join $dir debs]
    foreach {url sha} $packages {
        set deb [file join $dir debs [file tail $url]]
        exec curl -fsSL --retry 3 -o $deb $url
        set got [pm::sha256::hex [pm::ReadBytes $deb]]
        if {$got ne $sha} {
            file delete -force $dir
            error "[file tail $url]: sha256 $got, not the pinned $sha (a changed or substituted package: check it, and only then update the pin)"
        }
        exec dpkg-deb -x $deb [file join $dir root]
    }
    pm::WriteNew [file join $dir complete] ""
    return $dir
}

# libraven.so.0 of Raven's desktop configuration (X11 and Vulkan) built for
# TARGET.
proc author::libraven {target} {
    variable root
    source [file join $root tests cffi raven.tcl]
    if {$target eq [pm::target::host]} {
        return [file join [cffi::ravenBuild desktop] libraven.so.0]
    }
    # Another architecture: Raven's own CMake build with its GNU cross
    # compiler, the desktop configuration's flags and pinned Vulkan headers,
    # and the target's libX11 (x11Sysroot), cached by a stamp as
    # tests/cffi/raven.tcl caches its builds.
    set configuration [cffi::RavenConfiguration desktop]
    set commit [dict get [cffi::RavenSource] commit]
    set build [file join [cffi::RavenCacheDir] raven-cross $target-$commit-desktop-[string range [dict get $configuration vulkan] 0 11]]
    set stamp "target $target\n[cffi::RavenStamp $configuration]"
    set library [file join $build libraven.so.0]
    set stampFile [file join $build botlish-raven-configuration]
    if {![file isfile $stampFile] || [pm::ReadBytes $stampFile] ne $stamp || ![file exists $library]} {
        set arch [dict get [pm::target::facts $target] arch]
        set sysroot [file join [x11Sysroot $target] root]
        file mkdir $build
        file delete $stampFile
        exec cmake -S [ravenSource] -B $build -GNinja -DCMAKE_BUILD_TYPE=Release -DRAVEN_BUILD_SHARED=ON \
            -DRAVEN_BUILD_EXAMPLES=OFF -DRAVEN_BUILD_TESTS=OFF -DRAVEN_BUILD_TOOLS=OFF \
            {*}[dict get $configuration flags] -DRAVEN_VULKAN_INCLUDE_DIR=[file join [cffi::VulkanHeaders] include] \
            -DX11_X11_INCLUDE_PATH=[file join $sysroot usr include] \
            -DX11_X11_LIB=[file join $sysroot usr lib $arch-linux-gnu libX11.so] \
            -DCMAKE_SYSTEM_NAME=Linux -DCMAKE_SYSTEM_PROCESSOR=$arch -DCMAKE_C_COMPILER=[cc $target] >@stderr 2>@stderr
        exec ninja -C $build raven >@stderr 2>@stderr
        pm::WriteNew $stampFile $stamp
    }
    return $library
}

# Refuses LIBRARY unless it is Raven's desktop build for TARGET: a shared
# object of the target that loads libX11.so.6 (the X11 platform) and
# exports the Vulkan renderer's API (raven_vulkan.h exists only in a Vulkan
# build). The pack checks the same against the package's metadata; this
# names the mistake -- a headless library where the desktop one belongs --
# before anything is staged.
proc author::checkDesktop {target library} {
    set facts [pm::binary::inspect [pm::ReadBytes $library] $library]
    set problems {}
    if {[dict get $facts kind] ne "elf" || ![pm::native::Matches $target $facts]} {
        lappend problems "it is [pm::binary::describe $facts], not a $target shared object"
    } else {
        if {"libX11.so.6" ni [dict get $facts needed]} {
            lappend problems "it does not load libX11.so.6 (no X11 platform)"
        }
        if {"Rvulkan_get_instance" ni [dict get $facts symbols]} {
            lappend problems "it does not export Rvulkan_get_instance (no Vulkan renderer)"
        }
    }
    if {$problems ne ""} {
        error "$library is not Raven's desktop build for $target: [join $problems {; }]"
    }
}

# The package directory for NAME, assembled in the new directory STAGE (or
# the repository's own, when it is packed as it is).
proc author::assemble {name stage} {
    variable root
    set package [file join $root packages $name]
    set descriptor [pm::descriptor::read [file join $package botlish.json] pack]
    if {![pm::targets::Aware $descriptor]} {
        return $package
    }
    set dir [file join $stage $name]
    file mkdir $dir
    # The common files: the package directory as it is.
    foreach entry [glob -nocomplain -tails -directory $package *] {
        file copy [file join $package $entry] [file join $dir $entry]
    }
    foreach target [dict keys [dict get $descriptor targets]] {
        set native [file join $dir targets $target native]
        switch -- $name {
            sdl3 {
                binding sdl3 $target $dir
                set built [file join $stage shim-$target]
                exec [info nameofexecutable] [file join $root tools c-bindgen.tcl] build sdl3 -target $target -out $built
                file mkdir $native
                foreach archive [glob -directory $built *.a] {
                    file copy $archive $native
                }
                foreach library [dict get $descriptor targets $target libraries] {
                    if {[dict get $library name] eq "SDL3" && [dict get $library origin] eq "bundled"} {
                        source [file join $root tests cffi sdl3.tcl]
                        if {[cffi::sdl3Dir] eq ""} {
                            error "no SDL3 shared library for $target: run tclsh9.0 tests/cffi/sdl3.tcl"
                        }
                        copyStripped $target [file join [cffi::sdl3Dir] libSDL3.so.0] [file join $dir targets $target [dict get $library file]]
                    }
                }
            }
            raven {
                binding raven $target $dir
                archive $target [list [file join $package native raven_bridge.c]] \
                    [list -std=c11 -O2 -Wall -Wextra -Werror -fPIC -pthread -I[file join [ravenSource] include]] \
                    [file join $native libraven_bridge.a]
                set library [libraven $target]
                checkDesktop $target $library
                copyStripped $target $library [file join $native libraven.so.0]
            }
            event_loop_linux {
                archive $target [list [file join $package native event_loop_linux.c]] \
                    {-O2 -Wall -Wextra -Werror -fPIC -pthread} [file join $native libevent_loop_linux.a]
            }
            default {
                error "packages/$name names targets, and this tool knows no recipe for it"
            }
        }
    }
    return $dir
}

file mkdir $out
set status 0
foreach name $names {
    set stage [file tempdir botlish-package-repository]
    try {
        set dir [author::assemble $name $stage]
        set given [dict create -out [list $out]]
        if {$force} { dict set given -force 1 }
        pm::commands::pack [list $dir] $given
        set descriptor [pm::descriptor::read [file join $dir botlish.json] pack]
        if {[pm::targets::Aware $descriptor]} {
            puts "  targets [join [lsort [dict keys [dict get $descriptor targets]]] {, }]"
        } else {
            puts "  targets: every target (no native files)"
        }
    } on error {message options} {
        puts stderr "$name: $message"
        set status 1
    } finally {
        file delete -force $stage
    }
}
exit $status
