# event-loop-linux.tcl -- install the Linux event-loop driver package
# (packages/event_loop_linux; EVENT-LOOP-MILESTONE-1.md, "Linux driver").
#
#   tclsh9.0 tools/event-loop-linux.tcl install APP   copy the package into
#                                                    APP/.bot_modules/event_loop_linux
#                                                    and build its archive there
#   tclsh9.0 tools/event-loop-linux.tcl include       the directory of
#                                                    botlish_event_loop.h (for a
#                                                    native library's -I)
#
# A package ships its native archive inside itself and links it wherever it
# is installed (NATIVE-LINK-PLAN-MILESTONE-1.md, section 9): its module
# declares `extern c library "event_loop_linux" static at
# "native/libevent_loop_linux.a"`, resolved from the package instance's
# directory. The standard library cannot do the same (a standard module's
# archive path has no root, NATIVE-LINK-PLAN-MILESTONE-1.md, section 8), so
# the driver is the repository's package, built here with the host's C
# compiler (CC, default cc) and ar -- never by the compiler.
#
# Sourced, it defines eventLoopLinux::install and eventLoopLinux::include
# (tests/event-loop-linux.test).
namespace eval eventLoopLinux {
    variable here [file dirname [file normalize [info script]]]
    variable package [file join [file dirname $here] packages event_loop_linux]
}

proc eventLoopLinux::include {} {
    variable package
    return [file join $package native]
}

proc eventLoopLinux::cc {} {
    if {[info exists ::env(CC)] && $::env(CC) ne ""} {
        return $::env(CC)
    }
    return cc
}

# Install the package into APP's .bot_modules and build its archive; the
# installed package's directory.
proc eventLoopLinux::install {app} {
    variable package
    set target [file join $app .bot_modules event_loop_linux]
    file delete -force $target
    file mkdir [file join $target native]
    foreach file {event_loop_linux.bot README.md native/event_loop_linux.c native/botlish_event_loop.h} {
        file copy [file join $package $file] [file join $target $file]
    }
    set object [file join $target native event_loop_linux.o]
    exec [cc] -O2 -Wall -Wextra -Werror -fPIC -pthread -c [file join $target native event_loop_linux.c] -o $object
    exec ar rcs [file join $target native libevent_loop_linux.a] $object
    file delete $object
    return $target
}

if {[info exists ::argv0] && [file normalize $::argv0] eq [file normalize [info script]]} {
    switch -- [lindex $::argv 0] {
        install {
            if {[llength $::argv] != 2} {
                puts stderr "usage: tclsh9.0 tools/event-loop-linux.tcl install APP"
                exit 2
            }
            puts [eventLoopLinux::install [file normalize [lindex $::argv 1]]]
        }
        include {
            puts [eventLoopLinux::include]
        }
        default {
            puts stderr "usage: tclsh9.0 tools/event-loop-linux.tcl install APP | include"
            exit 2
        }
    }
}
