# all.tcl -- runs the whole test suite against the Tcl backends.
#
#   tclsh9.0 tests/all.tcl                        interp and compile
#   CORE_BACKEND=compile tclsh9.0 tests/all.tcl   one backend
#
# stdlib.test and native.test also run programs on cranelift, so the native
# backend must be built (native/). tests/native-coverage.tcl runs the suite
# with CORE_BACKEND=cranelift and classifies what it does not support.
#
# Extra arguments are passed to tcltest (e.g. -file calls.test).

package require tcltest 2.5
namespace import ::tcltest::*

set testDir [file dirname [file normalize [info script]]]

if {![info exists ::env(CORE_BACKEND)]} {
    set failed 0
    foreach backend {interp compile} {
        puts "######## backend: $backend"
        set ::env(CORE_BACKEND) $backend
        if {[catch {exec [info nameofexecutable] [info script] {*}$argv >@ stdout 2>@ stderr}]} {
            set failed 1
        }
    }
    unset ::env(CORE_BACKEND)
    exit $failed
}

configure -testdir $testDir {*}$argv
set failed [runAllTests]
exit [expr {$failed ? 1 : 0}]
