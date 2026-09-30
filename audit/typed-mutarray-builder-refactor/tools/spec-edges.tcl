set root [pwd]
source [file join $root compiler compiler.tcl]
source [file join $root surface surface.tcl]
source [file join $root native native.tcl]
interp recursionlimit {} 20000
set hir [native::buildProgramHir [hir::lower [surface::readProgramFile [lindex $argv 0]]]]
set spec [hir::specialize::analyze $hir]
set used [dict get $spec used]
# who has an edge to which used instance
foreach id $used {
    set inst [dict get $spec instances $id]
    foreach e [dict get $inst edges] {
        if {$e in $used} { lappend callers($e) $id }
    }
}
foreach id $used {
    set lab [hir::specialize::label $spec $id]
    if {[string match {*<generic>*} $lab] || [string match {*any*} $lab]} {
        set cs [lmap c [expr {[info exists callers($id)] ? $callers($id) : {}}] {hir::specialize::label $spec $c}]
        puts [format "%-42s <- %s" $lab [join $cs {, }]]
    }
}
