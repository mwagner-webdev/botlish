# app.tcl -- the native scenario application of tests/event-loop-linux.test
# (and of bench/event-loop.tcl): a private directory holding the native
# scenario programs (tests/event-loop/native/*.bot), the shared modules
# they use (tests/event-loop/*.bot), the fixtures' archives built into
# native/, and the Linux driver package installed under .bot_modules
# (tools/event-loop-linux.tcl). Sourced; eventLoopApp::create DIR builds it.
#
# SDL3 (the package-owned headless build of tests/cffi/sdl3.tcl) is
# optional: with it, the SDL adapter's archive is built too
# (eventLoopApp::sdl returns its library directory, "" without it).
namespace eval eventLoopApp {
    variable native [file dirname [file normalize [info script]]]
    variable shared [file dirname $native]
    variable root [file dirname [file dirname $shared]]
}
source [file join $eventLoopApp::root tools event-loop-linux.tcl]
source [file join $eventLoopApp::root tests cffi sdl3.tcl]

proc eventLoopApp::cc {} {
    expr {[info exists ::env(CC)] && $::env(CC) ne "" ? $::env(CC) : "cc"}
}

proc eventLoopApp::archive {dir name sources args} {
    set objects {}
    foreach source $sources {
        set object [file join $dir native [file rootname [file tail $source]].o]
        exec [cc] -O2 -Wall -Wextra -Werror -fPIC -pthread -I[eventLoopLinux::include] {*}$args -c $source -o $object
        lappend objects $object
    }
    set lib [file join $dir native lib$name.a]
    file delete $lib
    exec ar rcs $lib {*}$objects
    file delete {*}$objects
    return $lib
}

# The SDL3 library directory, or "" when tests/cffi/sdl3.tcl has not built
# it (or its headers are missing).
proc eventLoopApp::sdl {} {
    set dir [cffi::sdl3Dir]
    set include [file join [cffi::SdlCacheDir] c-header-src sdl3 include]
    if {$dir eq "" || ![file isdirectory $include]} {
        return ""
    }
    return $dir
}

# Build the application in DIR (created; its previous content removed).
proc eventLoopApp::create {dir} {
    variable native
    variable shared
    file delete -force $dir
    file mkdir [file join $dir native]
    foreach path [glob -directory $shared *.bot] {
        if {![string match reject-* [file tail $path]]} {
            file copy $path $dir
        }
    }
    foreach path [glob -directory $native *.bot] {
        file copy -force $path $dir
    }
    eventLoopLinux::install $dir
    archive $dir fixture [list [file join $native fixture.c]]
    if {[sdl] ne "" && [file exists [file join $native sdl.c]]} {
        set include [file join [cffi::SdlCacheDir] c-header-src sdl3 include]
        archive $dir evsdl [list [file join $native sdl.c]] -I$include
    }
    return $dir
}
