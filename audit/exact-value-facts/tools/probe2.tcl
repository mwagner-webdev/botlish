# probe2.tcl FILE -- semantic result types of every function + instance results
set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]
source [file join $root compiler compiler.tcl]
source [file join $root surface surface.tcl]
set hir [surface::readProgramFile [lindex $argv 0] -strict 1]
puts [hir::format $hir]
set spec [hir::specialize::analyze $hir]
foreach id [dict get $spec used] {
    puts "instance [hir::specialize::label $spec $id] -> [hir::types::show [dict get $spec instances $id result]]"
}
