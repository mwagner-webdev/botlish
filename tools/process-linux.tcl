# process-linux.tcl -- the process_linux package's native archive and a test
# application of it, before a release (PROCESS-LINUX-PACKAGE-MILESTONE-1.md).
#
#   tclsh9.0 tools/process-linux.tcl archive OUT ?-testing 1?
#       compile packages/process_linux/native/process_linux.c into the
#       archive OUT (the released build; -testing 1: the testing build, with
#       the pl_t_* probes and fault bits, which no release holds)
#   tclsh9.0 tools/process-linux.tcl app DIR ?-testing 1?
#       install event_loop_linux and process_linux into DIR/.bot_modules as
#       one package graph (process_linux uses the application's driver), as
#       the package manager's installation makes them, from this checkout
#   tclsh9.0 tools/process-linux.tcl helper OUT
#       build the tests' deterministic helper child (tests/process/child.c)
#
# The release recipe (tools/package-repository.tcl's author::process_linux)
# compiles the same file with the same flags (archiveFlags). The host's C
# compiler (CC, default cc) and ar, never the compiler's: a consumer installs
# the released artifact and compiles nothing. Sourced, it defines
# processLinux::archive, processLinux::app and processLinux::helper
# (tests/process-linux.test).
namespace eval ::processLinux {
    variable here [file dirname [file normalize [info script]]]
    variable root [file dirname $here]
    variable package [file join $root packages process_linux]
    # The flags of every build of the adapter: the release recipe's too.
    variable archiveFlags {-O2 -Wall -Wextra -Werror -fPIC -pthread}
}

proc ::processLinux::cc {} {
    if {[info exists ::env(CC)] && $::env(CC) ne ""} {
        return $::env(CC)
    }
    return cc
}

# Compile the adapter into the archive OUT (TESTING: with -DPL_TESTING).
proc ::processLinux::archive {out {testing 0}} {
    variable package
    variable archiveFlags
    file mkdir [file dirname $out]
    set object [file rootname $out].[pid].o
    set flags $archiveFlags
    if {$testing} { lappend flags -DPL_TESTING }
    exec [cc] {*}$flags -c [file join $package native process_linux.c] -o $object
    file delete $out
    exec ar rcs $out $object
    file delete $object
    return $out
}

# Install event_loop_linux and process_linux into APP/.bot_modules as one
# package graph; APP.
proc ::processLinux::app {app {testing 0}} {
    variable root
    variable package
    set modules [file join $app .bot_modules]
    file delete -force [file join $modules process_linux]
    file mkdir $modules
    source [file join $root tools event-loop-linux.tcl]
    eventLoopLinux::install $app
    set target [file join $modules process_linux]
    file mkdir [file join $target native]
    foreach file {process_linux.bot README.md GUIDE.md} {
        if {[file exists [file join $package $file]]} {
            file copy -force [file join $package $file] [file join $target $file]
        }
    }
    archive [file join $target native libprocess_linux.a] $testing
    set f [open [file join $modules .graph] w]
    puts -nonewline $f "botlish package graph 1\napplication event_loop_linux process_linux\npackage event_loop_linux\npackage process_linux event_loop_linux\n"
    close $f
    return $app
}

# The tests' helper child (tests/process/child.c) at OUT.
proc ::processLinux::helper {out} {
    variable root
    file mkdir [file dirname $out]
    exec [cc] -O2 -Wall -Wextra -Werror [file join $root tests process child.c] -o $out
    return $out
}

if {[info exists ::argv0] && [file normalize $::argv0] eq [file normalize [info script]]} {
    set opts [dict create -testing 0]
    set positional {}
    set args [lrange $::argv 1 end]
    for {set i 0} {$i < [llength $args]} {incr i} {
        set a [lindex $args $i]
        if {[string match -* $a]} {
            dict set opts $a [lindex $args [incr i]]
        } else {
            lappend positional $a
        }
    }
    set usage "usage: tclsh9.0 tools/process-linux.tcl archive OUT ?-testing 1? | app DIR ?-testing 1? | helper OUT"
    if {[llength $positional] != 1} {
        puts stderr $usage
        exit 2
    }
    set path [file normalize [lindex $positional 0]]
    switch -- [lindex $::argv 0] {
        archive { puts [processLinux::archive $path [dict get $opts -testing]] }
        app { puts [processLinux::app $path [dict get $opts -testing]] }
        helper { puts [processLinux::helper $path] }
        default {
            puts stderr $usage
            exit 2
        }
    }
}
