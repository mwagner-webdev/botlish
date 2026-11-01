# package-repository.tcl -- pack this repository's packages into a local
# package repository (PACKAGE-MANAGER-MILESTONE-1.md, "Workloads").
#
#   tclsh9.0 tools/package-repository.tcl OUT ?-target T? ?NAME...?
#
# writes OUT/NAME-VERSION.botpkg for each named package (default: every
# package this host can assemble), for the target T (the host's by
# default). A consumer then installs them with the ordinary commands --
# `botlish add sdlkit -repository OUT` -- and nothing package-specific runs
# on the consumer's side.
#
# This is the *author's* side, and the one place left where packages differ
# (PM-2 and PM-3 make it declarative): a package directory of packages/ is
# packed as it is, except that
#
#   sdl3              is packages/sdl3's descriptor and README with the
#                     committed generated binding of T as its sdl3/ tree
#                     (generated/c/sdl3/T/sdl3/, laid out by
#                     tools/c-bindgen.tcl's stage, never edited);
#   raven             is staged by tools/raven-package.tcl (the wrapper, the
#                     generated binding of T, and native/libraven_bridge.a
#                     built with the host's cc and ar against the pinned
#                     Raven's headers), plus its descriptor;
#   event_loop_linux  is staged by tools/event-loop-linux.tcl (the module and
#                     native/libevent_loop_linux.a built with cc and ar), plus
#                     its descriptor.
#
# The native archives are built here, for T, and travel in the artifact as
# opaque files: the package manager neither builds nor checks them (PM-2).
# An artifact holding a generated binding or an archive is therefore one
# target's: a repository serves one target.

set here [file dirname [file normalize [info script]]]
set root [file dirname $here]
source [file join $root pm pm.tcl]

proc usage {} {
    puts stderr "usage: tclsh9.0 tools/package-repository.tcl OUT ?-target T? ?NAME...?"
    exit 2
}

set out ""
set target ""
set names {}
for {set i 0} {$i < [llength $argv]} {incr i} {
    set arg [lindex $argv $i]
    if {$arg eq "-target"} {
        set target [lindex $argv [incr i]]
    } elseif {[string match -* $arg]} {
        usage
    } elseif {$out eq ""} {
        set out [file normalize $arg]
    } else {
        lappend names $arg
    }
}
if {$out eq ""} usage

proc hostTarget {} {
    set machine $::tcl_platform(machine)
    switch -glob -- "$::tcl_platform(os)/$machine" {
        Linux/x86_64 - Linux/amd64 { return linux-x86_64 }
        Linux/aarch64 - Linux/arm64 { return linux-aarch64 }
        Darwin/arm64 { return macos-aarch64 }
        Windows* { return windows-x86_64 }
    }
    error "package-repository: unknown host $::tcl_platform(os)/$machine"
}
if {$target eq ""} {
    set target [hostTarget]
}
set linux [string match linux-* $target]
if {$names eq ""} {
    set names {sdlkit sdl3}
    if {$linux} {
        lappend names raven event_loop_linux
    }
}

# A package directory for NAME in the new directory STAGE (or the
# repository's own, when it is packed as it is).
proc assemble {name stage} {
    global root target
    set package [file join $root packages $name]
    switch -- $name {
        sdl3 {
            set binding [file join $root generated c sdl3 $target sdl3]
            if {![file isdirectory $binding]} {
                error "no committed SDL3 binding for $target ($binding)"
            }
            set dir [file join $stage sdl3]
            file mkdir $dir
            file copy [file join $package botlish.json] [file join $package README.md] $dir
            file copy $binding [file join $dir sdl3]
            return $dir
        }
        raven {
            source [file join $root tools raven-package.tcl]
            set dir [ravenPackage::install $stage $target]
            file copy [file join $package botlish.json] $dir
            return $dir
        }
        event_loop_linux {
            source [file join $root tools event-loop-linux.tcl]
            set dir [eventLoopLinux::install $stage]
            file copy [file join $package botlish.json] $dir
            return $dir
        }
        default {
            if {![file isfile [file join $package botlish.json]]} {
                error "packages/$name has no botlish.json"
            }
            return $package
        }
    }
}

file mkdir $out
set status 0
foreach name $names {
    set stage [file tempdir botlish-package-repository]
    try {
        set dir [assemble $name $stage]
        pm::commands::pack [list $dir] [dict create -out [list $out] -force 1]
    } on error {message options} {
        puts stderr "$name: $message"
        set status 1
    } finally {
        file delete -force $stage
    }
}
exit $status
