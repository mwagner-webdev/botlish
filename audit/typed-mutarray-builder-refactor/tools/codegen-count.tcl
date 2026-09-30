set root [pwd]
source [file join $root compiler compiler.tcl]
source [file join $root surface surface.tcl]
source [file join $root native native.tcl]
interp recursionlimit {} 20000
if {[lindex $argv 0] eq "-off"} { set hir::semantic::enabled 0 }
set used 0; set emitted 0
foreach path [concat [lsort [glob -directory [file join $root bench] *.bot]] [lsort [glob -directory [file join $root examples stdlib] *.bot]]] {
    set hir [native::prepareHir [surface::readProgramFile $path]]
    set spec [hir::specialize::analyze $hir]
    incr used [llength [dict get $spec used]]
    incr emitted [llength [dict get [native::lower::program $hir] functions]]
}
puts "semantic instances [expr {[lindex $argv 0] eq {-off} ? {off} : {on}}]: codegen used $used emitted $emitted"
