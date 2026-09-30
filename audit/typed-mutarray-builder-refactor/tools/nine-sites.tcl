set root [pwd]
source [file join $root compiler compiler.tcl]
source [file join $root surface surface.tcl]
source [file join $root native native.tcl]
interp recursionlimit {} 20000
set hir [surface::readProgramFile [file join $root examples stdlib csv_records.bot] -strict 0]
set rows {}
dict for {e node} [dict get $hir exprs] {
    if {[dict get $node kind] ne "call" || ![dict get $node reachable]} continue
    lassign [dict get $node target] tk t
    if {$tk ne "block"} continue
    set name [hir::signatures::Name $hir $t]
    if {$name ni {ht_get ht_size}} continue
    set loc [surface::originLocation $hir [dict get $node origin]]
    if {![regexp {csv_records.bot:(\d+):(\d+)} $loc -> l c]} continue
    if {$l < 440} continue
    set arg [lindex [dict get $node args] 0]
    set argNode [dict get $hir exprs $arg]
    lappend rows [list $l $c $name [hir::types::show [hir::typeOf $hir $arg]] [dict get $argNode kind] [hir::types::show [hir::typeOf $hir $e]]]
}
foreach r [lsort -integer -index 1 [lsort -integer -index 0 $rows]] { puts [format "%d:%-4d %-8s arg(%s): %-10s call result: %s" {*}[lrange $r 0 2] [lindex $r 4] [lindex $r 3] [lindex $r 5]] }
