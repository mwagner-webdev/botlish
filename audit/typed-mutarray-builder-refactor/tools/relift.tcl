set root [pwd]
source [file join $root compiler compiler.tcl]
source [file join $root surface surface.tcl]
source [file join $root native native.tcl]
interp recursionlimit {} 20000
set hir0 [surface::readProgramFile [lindex $argv 0] -strict 0]
set hir1 [native::buildProgramHir [hir::lower $hir0]]
foreach {label hir} [list semantic $hir0 relifted $hir1] {
    puts "== $label"
    foreach name {create geo_new geo_grow geo_append geo_finish scan_record_rest scan_records csv_parse} {
        dict for {b binding} [dict get $hir bindings] {
            if {[dict get $binding name] ne $name && [dict get $binding name] ne "mutarray::$name" || [dict get $binding declaredBy] eq ""} continue
            set value [hir::get $hir [dict get $binding declaredBy] value]
            if {[hir::kind $hir $value] ne "block"} continue
            set sig [hir::signatures::of $hir $value]
            set ps [lmap p [dict get $sig params] {format {%s:%s} [dict get $p name] [hir::types::show [hir::signatures::paramType $p]]}]
            puts [format "  %-22s (%s) -> %s" [dict get $binding name] [join $ps ", "] [string trim [lindex [split [hir::types::show [hir::typeOf $hir $value]] >] end]]]
        }
    }
}
