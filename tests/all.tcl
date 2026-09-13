# all.tcl -- runs the whole test suite.
#
#   tclsh tests/all.tcl

package require tcltest 2.5
namespace import ::tcltest::*

configure -testdir [file dirname [file normalize [info script]]] {*}$argv
set failed [runAllTests]
exit [expr {$failed ? 1 : 0}]
