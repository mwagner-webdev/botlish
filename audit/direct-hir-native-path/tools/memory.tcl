#!/usr/bin/env tclsh9.0
# memory.tcl -- the state the relift route holds *in addition to* the front
# end's HIR, per canonical program: the core IR text and the reconstructed HIR
# (its full string representation, which includes its analysis side tables:
# the semantic-instance table, types, scopes, bindings). Approximate by
# construction (Tcl string lengths, not allocator bytes), and only meaningful
# against a tree that still has native::buildProgramHir (-root the parent of
# the direct-HIR milestone). Observation only.
#
#   tclsh9.0 memory.tcl [-root TREE]
set here [file dirname [file normalize [info script]]]
set root [file dirname [file dirname [file dirname $here]]]
if {[lindex $argv 0] eq "-root"} { set root [file normalize [lindex $argv 1]] }
source [file join $root compiler compiler.tcl]
source [file join $root surface surface.tcl]
source [file join $root native native.tcl]
interp recursionlimit {} 20000
set programs [concat [lsort [glob -directory [file join $root bench] *.bot]] \
    [lsort [glob -directory [file join $root examples stdlib] *.bot]]]
set tot [dict create hir 0 ir 0 relifted 0 semantic 0]
puts [format "%-22s %10s %10s %10s %10s" program frontendHIR coreIR relifted "relifted-sem"]
foreach path $programs {
    set h [surface::readProgramFile $path]
    set ir [hir::lower $h]
    set r [native::buildProgramHir $ir]
    set row [list [string length $h] [string length $ir] [string length $r] [string length [dict get $r semantic]]]
    puts [format "%-22s %10d %10d %10d %10d" [file tail $path] {*}$row]
    foreach k {hir ir relifted semantic} v $row { dict incr tot $k $v }
}
puts [format "%-22s %10d %10d %10d %10d" total {*}[dict values $tot]]
