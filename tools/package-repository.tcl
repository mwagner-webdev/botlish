# package-repository.tcl -- pack this repository's packages into a local
# package repository (PACKAGE-MANAGER-MILESTONE-1.md, "Workloads";
# PACKAGE-MANAGER-MILESTONE-2.md, "Workloads").
#
#   tclsh9.0 tools/package-repository.tcl OUT ?NAME...?
#
# writes OUT/NAME-VERSION.botpkg for each named package (default: every
# package of packages/). A consumer then installs them with the ordinary
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
#                     for T against the pinned Raven's headers, and libraven
#                     built for T (tests/cffi/raven.tcl's on the host; for
#                     another architecture, Raven's CMake build with that
#                     architecture's GNU cross compiler, cached);
#   event_loop_linux  targets/T/native/: the adapter's archive built for T.
#
# A target-independent package (sdlkit, a pure-Botlish one) is packed as it
# is. Native files are built here, by the author's toolchain, and travel in
# the artifact as files the package manager inspects but never runs.

set here [file dirname [file normalize [info script]]]
set root [file dirname $here]
source [file join $root pm pm.tcl]

proc usage {} {
    puts stderr "usage: tclsh9.0 tools/package-repository.tcl OUT ?NAME...?"
    exit 2
}

set out ""
set names {}
foreach arg $argv {
    if {[string match -* $arg]} {
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

# libraven.so.0 built for TARGET.
proc author::libraven {target} {
    variable root
    if {$target eq [pm::target::host]} {
        source [file join $root tests cffi raven.tcl]
        set dir [cffi::ravenDir]
        if {$dir eq ""} {
            error "no libraven for $target: run tclsh9.0 tests/cffi/raven.tcl"
        }
        return [file join $dir libraven.so.0]
    }
    # Another architecture: Raven's own CMake build with its GNU cross
    # compiler, headless (Raven's null platform, no Vulkan), cached.
    source [file join $root tests cffi raven.tcl]
    set build [file join [cffi::RavenCacheDir] raven-cross $target]
    set library [file join $build libraven.so.0]
    if {![file exists $library]} {
        set arch [dict get [pm::target::facts $target] arch]
        exec cmake -S [ravenSource] -B $build -GNinja -DCMAKE_BUILD_TYPE=Release -DRAVEN_BUILD_SHARED=ON \
            -DRAVEN_BUILD_EXAMPLES=OFF -DRAVEN_BUILD_TESTS=OFF -DRAVEN_BUILD_TOOLS=OFF \
            -DRAVEN_PLATFORM=null -DRAVEN_BACKEND_VULKAN=OFF -DCMAKE_SYSTEM_NAME=Linux \
            -DCMAKE_SYSTEM_PROCESSOR=$arch -DCMAKE_C_COMPILER=[cc $target] >@stderr 2>@stderr
        exec ninja -C $build raven >@stderr 2>@stderr
    }
    return $library
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
                copyStripped $target [libraven $target] [file join $native libraven.so.0]
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
        pm::commands::pack [list $dir] [dict create -out [list $out] -force 1]
    } on error {message options} {
        puts stderr "$name: $message"
        set status 1
    } finally {
        file delete -force $stage
    }
}
exit $status
